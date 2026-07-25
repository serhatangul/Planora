import 'package:flutter/material.dart';

import '../models/expense_item.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/planora_empty_state.dart';

enum ExpenseSortMode {
  newest,
  oldest,
  highest,
  lowest,
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController(text: DateTime.now().day.toString());
  final _searchController = TextEditingController();

  String? _selectedCategory;
  String _filterCategory = 'Tümü';
  ExpenseSortMode _sortMode = ExpenseSortMode.newest;
  bool _showForm = false;
  String? _editingExpenseId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _capitalize(String value) {
    if (value.trim().isEmpty) return value;

    final index = value.indexOf(RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]'));
    if (index == -1) return value;

    return value.substring(0, index) +
        value[index].toUpperCase() +
        value.substring(index + 1);
  }

  List<ExpenseItem> _filteredExpenses(PlanoraController controller) {
    final query = _searchController.text.trim().toLowerCase();

    var expenses = controller.expensesForSelectedMonth.toList();

    if (_filterCategory != 'Tümü') {
      expenses = expenses
          .where((expense) => expense.category == _filterCategory)
          .toList();
    }

    if (query.isNotEmpty) {
      expenses = expenses.where((expense) {
        return expense.title.toLowerCase().contains(query) ||
            controller.categorySearchText(expense.category).contains(query) ||
            expense.amount.round().toString().contains(query) ||
            expense.day.toString().contains(query);
      }).toList();
    }

    switch (_sortMode) {
      case ExpenseSortMode.newest:
        expenses.sort((a, b) => b.day.compareTo(a.day));
        break;
      case ExpenseSortMode.oldest:
        expenses.sort((a, b) => a.day.compareTo(b.day));
        break;
      case ExpenseSortMode.highest:
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSortMode.lowest:
        expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return expenses;
  }

  void _startAdd() {
    final now = DateTime.now();

    setState(() {
      _editingExpenseId = null;
      _titleController.clear();
      _amountController.clear();
      _dayController.text = now.day.toString();
      _selectedCategory = null;
      _showForm = true;
    });
  }

  void _startEdit(ExpenseItem expense) {
    setState(() {
      _editingExpenseId = expense.id;
      _titleController.text = expense.title;
      _amountController.text = expense.amount.round().toString();
      _dayController.text = expense.day.toString();
      _selectedCategory = expense.category;
      _showForm = true;
    });
  }

  Future<void> _quickAddAmountToExpense(ExpenseItem expense) async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return _ExpenseQuickAmountDialog(
          lang: lang,
          currencySymbol: controller.currencySymbol,
        );
      },
    );

    if (!mounted) return;
    if (amount == null || amount <= 0) return;

    final today = DateTime.now().day;

    await controller.addExpense(
      title: expense.title,
      category: expense.category,
      amount: amount,
      day: today,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_expensesQuickAddText(lang, 'success'))),
    );
  }



  void _cancelForm() {
    FocusScope.of(context).unfocus();

    setState(() {
      _editingExpenseId = null;
      _titleController.clear();
      _amountController.clear();
      _selectedCategory = null;
      _showForm = false;
    });
  }

  Future<void> _saveExpense() async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;
    final amount = MoneyFormatter.parseAmount(_amountController.text);
    final day = int.tryParse(_dayController.text.trim()) ?? DateTime.now().day;
    final category = _selectedCategory ?? controller.categories.first;
    final title = _capitalize(_titleController.text.trim());

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_expensesText(lang, 'invalidAmount'))),
      );
      return;
    }

    if (_editingExpenseId == null) {
      await controller.addExpense(
        title: title,
        category: category,
        amount: amount,
        day: day,
      );
    } else {
      await controller.updateExpense(
        id: _editingExpenseId!,
        title: title,
        category: category,
        amount: amount,
        day: day,
      );
    }

    if (!mounted) return;
    _cancelForm();
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final lang = controller.appLanguageCode;
            final selectedCategory = _selectedCategory ?? controller.categories.first;
            final filteredExpenses = _filteredExpenses(controller);
            final categoryFilters = ['Tümü', ...controller.categories];

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _expensesText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _expensesMonthSubtitle(lang, _expensesMonthYearLabel(lang, controller.selectedMonth)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _expensesText(lang, 'spentThisMonth'),
                              style: TextStyle(
                                color: Color(0xFFC8D3FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              MoneyFormatter.format(controller.expensesTotal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _recordCountText(lang, controller.expenseCount),
                        style: const TextStyle(
                          color: Color(0xFF9FFFE0),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_showForm)
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: _editingExpenseId == null ? _expensesText(lang, 'newExpense') : _expensesText(lang, 'editExpense'),
                          actionLabel: _expensesText(lang, 'close'),
                          onActionTap: _cancelForm,
                        ),
                        const SizedBox(height: 14),
                        _InputField(
                          label: _expensesText(lang, 'expenseName'),
                          controller: _titleController,
                          icon: Icons.edit_rounded,
                        ),
                        const SizedBox(height: 14),
                        _InputField(
                          label: _expensesText(lang, 'amount'),
                          controller: _amountController,
                          icon: Icons.currency_lira_rounded,
                          prefix: controller.currencySymbol,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _InputField(
                          label: _expensesText(lang, 'day'),
                          controller: _dayController,
                          icon: Icons.calendar_today_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.softBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(18),
                              items: controller.categories
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(controller.categoryLabel(category)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedCategory = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Material(
                            color: AppColors.darkNavy,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _saveExpense,
                              child: Center(
                                child: Text(
                                  _editingExpenseId == null ? _expensesText(lang, 'addExpenseAction') : _expensesText(lang, 'save'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 54,
                    child: Material(
                      color: AppColors.darkNavy,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _startAdd,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                _expensesText(lang, 'addExpense'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _expensesText(lang, 'searchHint'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.4),
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categoryFilters
                        .map(
                          (category) => _FilterChip(
                            label: category,
                            active: _filterCategory == category,
                            onTap: () => setState(() => _filterCategory = category),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SortChip(
                        label: _expensesText(lang, 'newToOld'),
                        active: _sortMode == ExpenseSortMode.newest,
                        onTap: () => setState(() => _sortMode = ExpenseSortMode.newest),
                      ),
                      _SortChip(
                        label: _expensesText(lang, 'oldToNew'),
                        active: _sortMode == ExpenseSortMode.oldest,
                        onTap: () => setState(() => _sortMode = ExpenseSortMode.oldest),
                      ),
                      _SortChip(
                        label: _expensesText(lang, 'amountHigh'),
                        active: _sortMode == ExpenseSortMode.highest,
                        onTap: () => setState(() => _sortMode = ExpenseSortMode.highest),
                      ),
                      _SortChip(
                        label: _expensesText(lang, 'amountLow'),
                        active: _sortMode == ExpenseSortMode.lowest,
                        onTap: () => setState(() => _sortMode = ExpenseSortMode.lowest),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: _expensesText(lang, 'expenseList'),
                  actionLabel: _recordCountText(lang, filteredExpenses.length),
                ),
                const SizedBox(height: 12),
                if (filteredExpenses.isEmpty)
                  PlanoraEmptyState(
                    icon: controller.expensesForSelectedMonth.isEmpty
                        ? Icons.shopping_bag_outlined
                        : Icons.search_off_rounded,
                    title: controller.expensesForSelectedMonth.isEmpty
                        ? _expensesText(lang, 'emptyTitle')
                        : _expensesText(lang, 'filterEmptyTitle'),
                    description: controller.expensesForSelectedMonth.isEmpty
                        ? _expensesText(lang, 'emptyDescription')
                        : _expensesText(lang, 'filterEmptyDescription'),
                    actionLabel: controller.expensesForSelectedMonth.isEmpty ? _expensesText(lang, 'addExpense') : null,
                    onActionTap: controller.expensesForSelectedMonth.isEmpty ? _startAdd : null,
                    color: AppColors.warning,
                  )
                else
                  ...filteredExpenses.map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(expense.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 22),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) => controller.removeExpense(expense.id),
                        child: _ExpenseCard(
                          expense: expense,
                          onTap: () => _quickAddAmountToExpense(expense),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}




String _expensesQuickAddText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Tutar ekle',
      'en': 'Add amount',
      'ru': 'Добавить сумму',
    },
    'amount': {
      'tr': 'Eklenecek tutar',
      'en': 'Amount to add',
      'ru': 'Сумма для добавления',
    },
    'cancel': {
      'tr': 'Vazgeç',
      'en': 'Cancel',
      'ru': 'Отмена',
    },
    'add': {
      'tr': 'Ekle',
      'en': 'Add',
      'ru': 'Добавить',
    },
    'success': {
      'tr': 'Tutar bugünün tarihine ayrı harcama olarak eklendi.',
      'en': 'Amount added as a separate expense for today.',
      'ru': 'Сумма добавлена отдельным расходом на сегодня.',
    },
    'tapToAdd': {
      'tr': 'Tutar ekle',
      'en': 'Add amount',
      'ru': 'Добавить',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class _ExpenseQuickAmountDialog extends StatefulWidget {
  const _ExpenseQuickAmountDialog({
    required this.lang,
    required this.currencySymbol,
  });

  final String lang;
  final String currencySymbol;

  @override
  State<_ExpenseQuickAmountDialog> createState() => _ExpenseQuickAmountDialogState();
}

class _ExpenseQuickAmountDialogState extends State<_ExpenseQuickAmountDialog> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = MoneyFormatter.parseAmount(_amountController.text);
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_expensesQuickAddText(widget.lang, 'title')),
      content: TextField(
        controller: _amountController,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: _expensesQuickAddText(widget.lang, 'amount'),
          prefixText: '${widget.currencySymbol} ',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_expensesQuickAddText(widget.lang, 'cancel')),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(_expensesQuickAddText(widget.lang, 'add')),
        ),
      ],
    );
  }
}


String _expensesMonthYearLabel(String code, DateTime month) {
  final months = {
    'tr': [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    'ru': [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ],
  };

  final language = code == 'en' || code == 'ru' ? code : 'tr';
  return '${months[language]![month.month - 1]} ${month.year}';
}

String _expensesText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'invalidAmount': {
      'tr': 'Lütfen geçerli bir harcama tutarı gir.',
      'en': 'Please enter a valid expense amount.',
      'ru': 'Введите корректную сумму расхода.',
    },
    'title': {
      'tr': 'Harcama kayıtları',
      'en': 'Expense records',
      'ru': 'Записи расходов',
    },
    'spentThisMonth': {
      'tr': 'Bu ay harcanan',
      'en': 'Spent this month',
      'ru': 'Потрачено в этом месяце',
    },
    'newExpense': {
      'tr': 'Yeni harcama',
      'en': 'New expense',
      'ru': 'Новый расход',
    },
    'editExpense': {
      'tr': 'Harcamayı düzenle',
      'en': 'Edit expense',
      'ru': 'Редактировать расход',
    },
    'close': {
      'tr': 'Kapat',
      'en': 'Close',
      'ru': 'Закрыть',
    },
    'expenseName': {
      'tr': 'Harcama adı',
      'en': 'Expense name',
      'ru': 'Название расхода',
    },
    'amount': {
      'tr': 'Tutar',
      'en': 'Amount',
      'ru': 'Сумма',
    },
    'day': {
      'tr': 'Gün',
      'en': 'Day',
      'ru': 'День',
    },
    'addExpenseAction': {
      'tr': 'Harcamayı Ekle',
      'en': 'Add Expense',
      'ru': 'Добавить расход',
    },
    'save': {
      'tr': 'Kaydet',
      'en': 'Save',
      'ru': 'Сохранить',
    },
    'addExpense': {
      'tr': 'İlk Harcamayı Ekle',
      'en': 'Add First Expense',
      'ru': 'Добавить первый расход',
    },
    'searchHint': {
      'tr': 'Harcama, kategori, tutar veya gün ara',
      'en': 'Search expense, category, amount, or day',
      'ru': 'Поиск по расходу, категории, сумме или дню',
    },
    'newToOld': {
      'tr': 'Yeni → Eski',
      'en': 'Newest → Oldest',
      'ru': 'Новые → Старые',
    },
    'oldToNew': {
      'tr': 'Eski → Yeni',
      'en': 'Oldest → Newest',
      'ru': 'Старые → Новые',
    },
    'amountHigh': {
      'tr': 'Tutar yüksek',
      'en': 'Highest amount',
      'ru': 'Сумма выше',
    },
    'amountLow': {
      'tr': 'Tutar düşük',
      'en': 'Lowest amount',
      'ru': 'Сумма ниже',
    },
    'expenseList': {
      'tr': 'Harcama listesi',
      'en': 'Expense list',
      'ru': 'Список расходов',
    },
    'emptyTitle': {
      'tr': 'Henüz harcama yok',
      'en': 'No expenses yet',
      'ru': 'Расходов пока нет',
    },
    'filterEmptyTitle': {
      'tr': 'Filtreye uygun harcama yok',
      'en': 'No expenses match this filter',
      'ru': 'Нет расходов по этому фильтру',
    },
    'emptyDescription': {
      'tr': 'İlk harcamanızı kaydederek günlük giderlerinizi takip etmeye başlayın.',
      'en': 'Record your first expense to start tracking daily spending.',
      'ru': 'Запишите первый расход, чтобы начать отслеживать ежедневные траты.',
    },
    'filterEmptyDescription': {
      'tr': 'Arama kelimesini, kategori filtresini veya sıralamayı değiştirerek tekrar deneyebilirsin.',
      'en': 'Change the search term, category filter, or sorting and try again.',
      'ru': 'Измените поиск, фильтр категории или сортировку и попробуйте снова.',
    },
    'all': {
      'tr': 'Tümü',
      'en': 'All',
      'ru': 'Все',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _expensesMonthSubtitle(String code, String month) {
  switch (code) {
    case 'en':
      return 'Variable expenses in $month';
    case 'ru':
      return 'Переменные расходы за $month';
    case 'tr':
    default:
      return '$month içindeki değişken harcamalar';
  }
}

String _recordCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count records';
    case 'ru':
      return '$count записей';
    case 'tr':
    default:
      return '$count kayıt';
  }
}

String _expenseDayCategoryText(String code, int day, String category) {
  switch (code) {
    case 'en':
      return 'Day $day · $category';
    case 'ru':
      return '$day-й день · $category';
    case 'tr':
    default:
      return '$day. gün · $category';
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.onTap,
  });

  final ExpenseItem expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = PlanoraScope.of(context).appLanguageCode;

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: expense.color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${expense.day}',
                  style: TextStyle(
                    color: expense.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    _expenseDayCategoryText(lang, expense.day, PlanoraScope.of(context).categoryLabel(expense.category)),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  MoneyFormatter.format(expense.amount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _expensesQuickAddText(lang, 'tapToAdd'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = PlanoraScope.of(context).appLanguageCode;
    final displayLabel = label == 'Tümü' ? _expensesText(lang, 'all') : PlanoraScope.of(context).categoryLabel(label);

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: Material(
        color: active ? AppColors.darkNavy : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? AppColors.darkNavy : AppColors.stroke,
              ),
            ),
            child: Text(
              displayLabel,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FilterChip(label: label, active: active, onTap: onTap);
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.prefix,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? prefix;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        prefixText: prefix,
        filled: true,
        fillColor: AppColors.softBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.4),
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
