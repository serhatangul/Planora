import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';


String _categoryText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'newCategory': {'tr': 'Yeni kategori', 'en': 'New category', 'ru': 'Новая категория'},
    'exampleHint': {'tr': 'Örn: Sağlık, Eğitim, Eğlence', 'en': 'Ex: Health, Education, Entertainment', 'ru': 'Напр.: Здоровье, Образование, Развлечения'},
    'cancel': {'tr': 'Vazgeç', 'en': 'Cancel', 'ru': 'Отмена'},
    'add': {'tr': 'Ekle', 'en': 'Add', 'ru': 'Добавить'},
    'addFailed': {'tr': 'Kategori eklenemedi. Aynı isimde kategori olabilir.', 'en': 'Category could not be added. A category with the same name may already exist.', 'ru': 'Не удалось добавить категорию. Возможно, категория с таким именем уже существует.'},
    'editCategory': {'tr': 'Kategoriyi düzenle', 'en': 'Edit category', 'ru': 'Редактировать категорию'},
    'categoryName': {'tr': 'Kategori adı', 'en': 'Category name', 'ru': 'Название категории'},
    'save': {'tr': 'Kaydet', 'en': 'Save', 'ru': 'Сохранить'},
    'updateFailed': {'tr': 'Kategori güncellenemedi. Aynı isimde kategori olabilir.', 'en': 'Category could not be updated. A category with the same name may already exist.', 'ru': 'Не удалось обновить категорию. Возможно, категория с таким именем уже существует.'},
    'defaultDeleteFailed': {'tr': 'Varsayılan kategoriler silinemez.', 'en': 'Default categories cannot be deleted.', 'ru': 'Категории по умолчанию нельзя удалить.'},
    'inUseDeleteFailed': {'tr': 'Bu kategori ödemelerde kullanıldığı için silinemez. Önce ilgili ödemeleri değiştir.', 'en': 'This category is used in payments and cannot be deleted. Change the related payments first.', 'ru': 'Эта категория используется в платежах и не может быть удалена. Сначала измените связанные платежи.'},
    'deleteFailed': {'tr': 'Kategori silinemedi.', 'en': 'Category could not be deleted.', 'ru': 'Не удалось удалить категорию.'},
    'title': {'tr': 'Kategoriler', 'en': 'Categories', 'ru': 'Категории'},
    'hero': {'tr': 'Ödemelerini kendi kategorilerine göre düzenle.', 'en': 'Organize your payments by your own categories.', 'ru': 'Организуйте платежи по своим категориям.'},
    'addNewCategory': {'tr': 'Yeni Kategori Ekle', 'en': 'Add New Category', 'ru': 'Добавить новую категорию'},
    'categoryList': {'tr': 'Kategori listesi', 'en': 'Category list', 'ru': 'Список категорий'},
    'limitInfo': {'tr': 'Limit belirlediğinde Planora limite yaklaşan veya limiti aşan kategoriler için uyarı üretir.', 'en': 'When you set a limit, Planora creates alerts for categories approaching or exceeding the limit.', 'ru': 'Когда вы задаёте лимит, Planora создаёт уведомления для категорий, которые приближаются к лимиту или превышают его.'},
    'defaultCategory': {'tr': 'Varsayılan kategori', 'en': 'Default category', 'ru': 'Категория по умолчанию'},
    'usedInPayments': {'tr': 'Ödemelerde kullanılıyor', 'en': 'Used in payments', 'ru': 'Используется в платежах'},
    'customCategory': {'tr': 'Özel kategori', 'en': 'Custom category', 'ru': 'Пользовательская категория'},
    'limit': {'tr': 'Limit', 'en': 'Limit', 'ru': 'Лимит'},
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _categoryLimitText(String code, String symbol, int limit, int used) {
  switch (code) {
    case 'en':
      return 'Limit: $symbol$limit · Used: $symbol$used';
    case 'ru':
      return 'Лимит: $symbol$limit · Использовано: $symbol$used';
    case 'tr':
    default:
      return 'Limit: $symbol$limit · Kullanılan: $symbol$used';
  }
}


class _UppercaseFirstLetterFormatter extends TextInputFormatter {
  const _UppercaseFirstLetterFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final firstLetterIndex = text.indexOf(RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşüА-Яа-яЁё]'));
    if (firstLetterIndex == -1) return newValue;

    final firstLetter = text[firstLetterIndex];
    final upperFirstLetter = firstLetter.toUpperCase();

    if (firstLetter == upperFirstLetter) return newValue;

    final updatedText =
        text.substring(0, firstLetterIndex) +
        upperFirstLetter +
        text.substring(firstLetterIndex + 1);

    return newValue.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: newValue.selection.baseOffset.clamp(0, updatedText.length),
      ),
      composing: TextRange.empty,
    );
  }
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.title,
    required this.hintText,
    required this.cancelLabel,
    required this.confirmLabel,
    this.initialValue = '',
  });

  final String title;
  final String hintText;
  final String cancelLabel;
  final String confirmLabel;
  final String initialValue;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        inputFormatters: const [
          _UppercaseFirstLetterFormatter(),
        ],
        decoration: InputDecoration(
          hintText: widget.hintText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class CategorySettingsScreen extends StatelessWidget {
  const CategorySettingsScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final planora = PlanoraScope.of(context);
    final lang = planora.appLanguageCode;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _CategoryNameDialog(
          title: _categoryText(lang, 'newCategory'),
          hintText: _categoryText(lang, 'exampleHint'),
          cancelLabel: _categoryText(lang, 'cancel'),
          confirmLabel: _categoryText(lang, 'add'),
        );
      },
    );

    if (result == null || !context.mounted) return;

    final ok = await planora.addCategory(result);

    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_categoryText(lang, 'addFailed'))),
      );
    }
  }

  Future<void> _showRenameDialog(BuildContext context, String oldName) async {
    final planora = PlanoraScope.of(context);
    final lang = planora.appLanguageCode;
    final visibleName = planora.categoryLabel(oldName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _CategoryNameDialog(
          title: _categoryText(lang, 'editCategory'),
          hintText: _categoryText(lang, 'categoryName'),
          cancelLabel: _categoryText(lang, 'cancel'),
          confirmLabel: _categoryText(lang, 'save'),
          initialValue: visibleName,
        );
      },
    );

    if (result == null || !context.mounted) return;

    // Default categories are stored internally in their canonical form.
    // If the localized label is saved without an edit, keep that stored name unchanged.
    final newName = result.trim() == visibleName.trim() ? oldName : result;

    final ok = await planora.renameCategory(
      oldName: oldName,
      newName: newName,
    );

    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_categoryText(lang, 'updateFailed'))),
      );
    }
  }

  Future<void> _deleteCategory(BuildContext context, String category) async {
    final planora = PlanoraScope.of(context);
    final lang = planora.appLanguageCode;

    if (planora.isDefaultCategory(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_categoryText(lang, 'defaultDeleteFailed'))),
      );
      return;
    }

    if (planora.isCategoryInUse(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_categoryText(lang, 'inUseDeleteFailed'))),
      );
      return;
    }

    final ok = await planora.deleteCategory(category);

    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_categoryText(lang, 'deleteFailed'))),
      );
    }
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
                        _categoryText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.category_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _categoryText(lang, 'hero'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                GradientButton(
                  label: _categoryText(lang, 'addNewCategory'),
                  icon: Icons.add_rounded,
                  onPressed: () => _showAddDialog(context),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: _categoryText(lang, 'categoryList')),
                const SizedBox(height: 12),
                ...controller.categories.map(
                  (category) {
                    final summary = controller.categorySummary
                        .where((item) => item.title == category)
                        .toList();

                    final used = summary.isEmpty ? 0.0 : summary.first.used;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryCard(
                        lang: lang,
                        category: category,
                        color: controller.colorForCategory(category),
                        isDefault: controller.isDefaultCategory(category),
                        isInUse: controller.isCategoryInUse(category),
                        limit: controller.categoryLimit(category),
                        used: used,
                        onRename: () => _showRenameDialog(context, category),
                        onDelete: () => _deleteCategory(context, category),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  child: Row(
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _categoryText(lang, 'limitInfo'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
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

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.lang,
    required this.category,
    required this.color,
    required this.isDefault,
    required this.isInUse,
    required this.limit,
    required this.used,
    required this.onRename,
    required this.onDelete,
  });

  final String lang;
  final String category;
  final Color color;
  final bool isDefault;
  final bool isInUse;
  final double limit;
  final double used;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isEditingLimit = false;
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(text: widget.limit.round().toString());
  }

  @override
  void didUpdateWidget(covariant _CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isEditingLimit && oldWidget.limit != widget.limit) {
      _limitController.text = widget.limit.round().toString();
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _saveLimit() async {
    final currencySymbol = PlanoraScope.of(context).currencySymbol;
    final normalized = _limitController.text
        .replaceAll(currencySymbol, '')
        .replaceAll('₺', '')
        .replaceAll('₽', '')
        .replaceAll(r'$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    final limit = double.tryParse(normalized) ?? 0;

    await PlanoraScope.of(context).updateCategoryLimit(
      category: widget.category,
      limit: limit,
    );

    if (!mounted) return;

    FocusScope.of(context).unfocus();
    setState(() => _isEditingLimit = false);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.limit <= 0 ? 0.0 : (widget.used / widget.limit).clamp(0.0, 1.3);

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.folder_rounded, color: widget.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PlanoraScope.of(context).categoryLabel(widget.category),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.isDefault
                          ? _categoryText(widget.lang, 'defaultCategory')
                          : widget.isInUse
                              ? _categoryText(widget.lang, 'usedInPayments')
                              : _categoryText(widget.lang, 'customCategory'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onRename,
                icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: widget.isDefault ? null : widget.onDelete,
                icon: Icon(
                  Icons.delete_rounded,
                  color: widget.isDefault ? AppColors.stroke : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ProgressLine(
            value: ratio.clamp(0.0, 1.0),
            gradient: LinearGradient(colors: [widget.color, widget.color]),
          ),
          const SizedBox(height: 10),
          if (_isEditingLimit)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _limitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: _categoryText(widget.lang, 'limit'),
                      prefixText: '₺ ',
                      filled: true,
                      fillColor: AppColors.softBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.stroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.stroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.4),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    onSubmitted: (_) => _saveLimit(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _saveLimit,
                  icon: const Icon(Icons.check_circle_rounded, color: AppColors.brandGreen),
                ),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _limitController.text = widget.limit.round().toString();
                    setState(() => _isEditingLimit = false);
                  },
                  icon: const Icon(Icons.cancel_rounded, color: AppColors.textSecondary),
                ),
              ],
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _limitController.text = widget.limit.round().toString();
                setState(() => _isEditingLimit = true);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _categoryLimitText(
                          widget.lang,
                          PlanoraScope.of(context).currencySymbol,
                          widget.limit.round(),
                          widget.used.round(),
                        ),
                      style: const TextStyle(
                        color: AppColors.brandBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_note_rounded, color: AppColors.brandBlue, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
