import 'package:flutter/material.dart';

import '../models/receipt_scan_result.dart';
import '../services/receipt_scanner_service.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();

  ReceiptScanResult? _result;
  String? _category;
  bool _isScanning = false;
  bool _showRawText = false;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final controller = PlanoraScope.of(context);

    setState(() => _isScanning = true);
    try {
      final result = await ReceiptScannerService.scanReceipt(
        categories: controller.categories,
      );
      if (!mounted || result == null) return;

      setState(() {
        _result = result;
        _merchantController.text = result.merchant;
        _amountController.text =
            result.total > 0 ? result.total.round().toString() : '';
        _dayController.text = result.day.toString();
        _category = controller.categories.contains(result.suggestedCategory)
            ? result.suggestedCategory
            : controller.categories.first;
      });
    } on ReceiptScannerException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _save() async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;
    final amount = MoneyFormatter.parseAmount(_amountController.text);
    final day = int.tryParse(_dayController.text.trim()) ?? DateTime.now().day;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_scanText(lang, 'invalidAmount'))),
      );
      return;
    }

    await controller.addExpense(
      title: _merchantController.text.trim().isEmpty
          ? _scanText(lang, 'fallbackTitle')
          : _merchantController.text.trim(),
      category: _category ?? controller.categories.first,
      amount: amount,
      day: day,
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
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
                    _scanText(lang, 'title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _scanText(lang, 'subtitle'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            PremiumCard(
              color: AppColors.darkCard,
              borderColor: AppColors.darkCard,
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _scanText(lang, 'privacyTitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _scanText(lang, 'privacyBody'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isScanning ? null : _scan,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt_rounded),
                label: Text(
                  _isScanning
                      ? _scanText(lang, 'scanning')
                      : _scanText(lang, 'scanButton'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 22),
              SectionHeader(title: _scanText(lang, 'reviewTitle')),
              const SizedBox(height: 12),
              PremiumCard(
                child: Column(
                  children: [
                    _ScanField(
                      controller: _merchantController,
                      label: _scanText(lang, 'merchant'),
                      icon: Icons.storefront_rounded,
                    ),
                    const SizedBox(height: 12),
                    _ScanField(
                      controller: _amountController,
                      label: _scanText(lang, 'total'),
                      icon: Icons.payments_rounded,
                      prefix: controller.currencySymbol,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    _ScanField(
                      controller: _dayController,
                      label: _scanText(lang, 'day'),
                      icon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.softBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category ?? controller.categories.first,
                          isExpanded: true,
                          items: controller.categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child:
                                      Text(controller.categoryLabel(category)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _category = value),
                        ),
                      ),
                    ),
                    if (_result!.currencySymbol.isNotEmpty &&
                        _result!.currencySymbol !=
                            controller.currencySymbol) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_rounded,
                                color: AppColors.warning),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currencyWarning(
                                  lang,
                                  _result!.currencySymbol,
                                  controller.currencySymbol,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          _scanText(lang, 'save'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PremiumCard(
                onTap: () => setState(() => _showRawText = !_showRawText),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_snippet_rounded,
                            color: AppColors.brandBlue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _scanText(lang, 'rawText'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Icon(_showRawText
                            ? Icons.expand_less
                            : Icons.expand_more),
                      ],
                    ),
                    if (_showRawText) ...[
                      const SizedBox(height: 12),
                      SelectableText(
                        _result!.rawText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanField extends StatelessWidget {
  const _ScanField({
    required this.controller,
    required this.label,
    required this.icon,
    this.prefix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? prefix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefix == null ? null : '$prefix ',
        filled: true,
        fillColor: AppColors.softBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
      ),
    );
  }
}

String _scanText(String code, String key) {
  final language = {'tr', 'en', 'ru', 'vi'}.contains(code) ? code : 'tr';
  const values = {
    'title': {
      'tr': 'Akıllı Fiş Tarama',
      'en': 'Smart Receipt Scan',
      'ru': 'Умное сканирование чека',
      'vi': 'Quét hóa đơn thông minh'
    },
    'subtitle': {
      'tr':
          'Fişi tara, toplamı ve kategoriyi kontrol et, ardından harcamaya ekle.',
      'en':
          'Scan a receipt, review the total and category, then add it as an expense.',
      'ru':
          'Отсканируйте чек, проверьте сумму и категорию, затем добавьте расход.',
      'vi':
          'Quét hóa đơn, kiểm tra tổng tiền và danh mục, sau đó thêm vào chi tiêu.'
    },
    'privacyTitle': {
      'tr': 'Cihaz üzerinde özel tarama',
      'en': 'Private on-device scanning',
      'ru': 'Приватное сканирование на устройстве',
      'vi': 'Quét riêng tư trên thiết bị'
    },
    'privacyBody': {
      'tr':
          'Fiş metni Apple Vision ile cihazda okunur. Görsel Planora sunucusuna yüklenmez.',
      'en':
          'Receipt text is read on-device with Apple Vision. The image is not uploaded to a Planora server.',
      'ru':
          'Текст чека распознаётся на устройстве с Apple Vision. Изображение не загружается на сервер Planora.',
      'vi':
          'Nội dung hóa đơn được đọc trực tiếp trên thiết bị bằng Apple Vision. Ảnh không được tải lên máy chủ Planora.'
    },
    'scanButton': {
      'tr': 'Fişi kamerayla tara',
      'en': 'Scan receipt with camera',
      'ru': 'Сканировать чек камерой',
      'vi': 'Quét hóa đơn bằng camera'
    },
    'scanning': {
      'tr': 'Fiş okunuyor…',
      'en': 'Reading receipt…',
      'ru': 'Распознавание чека…',
      'vi': 'Đang đọc hóa đơn…'
    },
    'reviewTitle': {
      'tr': 'Sonucu kontrol et',
      'en': 'Review result',
      'ru': 'Проверьте результат',
      'vi': 'Kiểm tra kết quả'
    },
    'merchant': {
      'tr': 'İşletme / harcama adı',
      'en': 'Merchant / expense name',
      'ru': 'Магазин / название расхода',
      'vi': 'Cửa hàng / tên chi tiêu'
    },
    'total': {
      'tr': 'Toplam tutar',
      'en': 'Total amount',
      'ru': 'Итоговая сумма',
      'vi': 'Tổng tiền'
    },
    'day': {
      'tr': 'Ayın günü',
      'en': 'Day of month',
      'ru': 'День месяца',
      'vi': 'Ngày trong tháng'
    },
    'save': {
      'tr': 'Harcamaya ekle',
      'en': 'Add expense',
      'ru': 'Добавить расход',
      'vi': 'Thêm chi tiêu'
    },
    'rawText': {
      'tr': 'Okunan ham metin',
      'en': 'Recognized raw text',
      'ru': 'Распознанный текст',
      'vi': 'Văn bản đã nhận dạng'
    },
    'invalidAmount': {
      'tr': 'Lütfen geçerli bir toplam tutar gir.',
      'en': 'Enter a valid total amount.',
      'ru': 'Введите корректную итоговую сумму.',
      'vi': 'Vui lòng nhập tổng tiền hợp lệ.'
    },
    'fallbackTitle': {
      'tr': 'Fiş harcaması',
      'en': 'Receipt expense',
      'ru': 'Расход по чеку',
      'vi': 'Chi tiêu từ hóa đơn'
    },
  };
  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _currencyWarning(String code, String detected, String selected) {
  switch (code) {
    case 'en':
      return 'The receipt appears to use $detected, while Planora is set to $selected. The amount will not be converted.';
    case 'ru':
      return 'В чеке обнаружена валюта $detected, а в Planora выбрана $selected. Сумма не будет конвертирована.';
    case 'vi':
      return 'Hóa đơn có vẻ dùng $detected, trong khi Planora đang đặt là $selected. Số tiền sẽ không được quy đổi.';
    case 'tr':
    default:
      return 'Fişte $detected algılandı, Planora ise $selected kullanıyor. Tutar dönüştürülmeyecek.';
  }
}
