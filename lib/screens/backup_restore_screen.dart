import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';


String _backupText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'backupCreated': {
      'tr': 'Yedek oluşturuldu. Kopyalayabilirsin.',
      'en': 'Backup created. You can copy it.',
      'ru': 'Резервная копия создана. Её можно скопировать.',
    },
    'backupCopied': {
      'tr': 'Yedek panoya kopyalandı.',
      'en': 'Backup copied to clipboard.',
      'ru': 'Резервная копия скопирована в буфер обмена.',
    },
    'clipboardEmpty': {
      'tr': 'Panoda kullanılabilir yedek metni bulunamadı.',
      'en': 'No usable backup text was found in the clipboard.',
      'ru': 'В буфере обмена не найден подходящий текст резервной копии.',
    },
    'pasteJsonFirst': {
      'tr': 'Önce yedek JSON metnini yapıştır.',
      'en': 'Paste the backup JSON text first.',
      'ru': 'Сначала вставьте JSON резервной копии.',
    },
    'restoreDialogTitle': {'tr': 'Yedeği geri yükle', 'en': 'Restore backup', 'ru': 'Восстановить резервную копию'},
    'restoreDialogMessage': {
      'tr': 'Bu işlem mevcut Planora verilerini yedekteki verilerle değiştirecek. Devam etmek istiyor musun?',
      'en': 'This will replace your current Planora data with the backup data. Do you want to continue?',
      'ru': 'Это заменит текущие данные Planora данными из резервной копии. Продолжить?',
    },
    'cancel': {'tr': 'Vazgeç', 'en': 'Cancel', 'ru': 'Отмена'},
    'restore': {'tr': 'Geri yükle', 'en': 'Restore', 'ru': 'Восстановить'},
    'restoreSuccess': {'tr': 'Yedek başarıyla geri yüklendi.', 'en': 'Backup restored successfully.', 'ru': 'Резервная копия успешно восстановлена.'},
    'restoreFailed': {
      'tr': 'Yedek geri yüklenemedi. JSON formatını kontrol et.',
      'en': 'Backup could not be restored. Check the JSON format.',
      'ru': 'Не удалось восстановить резервную копию. Проверьте формат JSON.',
    },
    'title': {'tr': 'Yedekleme', 'en': 'Backup', 'ru': 'Резервное копирование'},
    'subtitle': {
      'tr': 'Planora verilerini JSON olarak dışa aktar veya daha önce aldığın yedeği geri yükle.',
      'en': 'Export Planora data as JSON or restore a backup you created earlier.',
      'ru': 'Экспортируйте данные Planora в JSON или восстановите ранее созданную копию.',
    },
    'info': {
      'tr': 'Yedek; gelir ayarları, ödemeler, ödeme durumları, harcamalar, kategoriler ve limitleri içerir.',
      'en': 'The backup includes income settings, payments, payment statuses, expenses, categories, and limits.',
      'ru': 'Резервная копия включает настройки дохода, платежи, статусы, расходы, категории и лимиты.',
    },
    'createBackup': {'tr': 'Yedek Oluştur', 'en': 'Create Backup', 'ru': 'Создать копию'},
    'copy': {'tr': 'Kopyala', 'en': 'Copy', 'ru': 'Копировать'},
    'pasteFromClipboard': {'tr': 'Panodan Yapıştır', 'en': 'Paste from Clipboard', 'ru': 'Вставить из буфера'},
    'jsonHint': {
      'tr': 'Yedek JSON metni burada görünecek veya buraya yapıştırılacak.',
      'en': 'Backup JSON text will appear here or can be pasted here.',
      'ru': 'JSON резервной копии появится здесь или может быть вставлен сюда.',
    },
    'restoreBackup': {'tr': 'Yedeği Geri Yükle', 'en': 'Restore Backup', 'ru': 'Восстановить копию'},
    'warning': {
      'tr': 'Geri yükleme mevcut verilerin üzerine yazar. Önce mevcut verilerin yedeğini almak güvenlidir.',
      'en': 'Restoring overwrites current data. It is safer to create a backup first.',
      'ru': 'Восстановление перезапишет текущие данные. Сначала безопаснее создать резервную копию.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _backupController = TextEditingController();

  @override
  void dispose() {
    _backupController.dispose();
    super.dispose();
  }

  void _generateBackup() {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;
    final backup = controller.exportBackupJson();
    _backupController.text = backup;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_backupText(lang, 'backupCreated'))),
    );
  }

  Future<void> _copyBackup() async {
    if (_backupController.text.trim().isEmpty) {
      _generateBackup();
    }

    await Clipboard.setData(
      ClipboardData(text: _backupController.text),
    );

    if (!mounted) return;

    final lang = PlanoraScope.of(context).appLanguageCode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_backupText(lang, 'backupCopied'))),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';

    if (text.trim().isEmpty) {
      if (!mounted) return;
      final lang = PlanoraScope.of(context).appLanguageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_backupText(lang, 'clipboardEmpty'))),
      );
      return;
    }

    setState(() => _backupController.text = text);
  }

  Future<void> _importBackup() async {
    final raw = _backupController.text.trim();

    final lang = PlanoraScope.of(context).appLanguageCode;

    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_backupText(lang, 'pasteJsonFirst'))),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_backupText(lang, 'restoreDialogTitle')),
          content: Text(
            _backupText(lang, 'restoreDialogMessage'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_backupText(lang, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_backupText(lang, 'restore')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final ok = await PlanoraScope.of(context).importBackupJson(raw);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? _backupText(lang, 'restoreSuccess') : _backupText(lang, 'restoreFailed'),
        ),
      ),
    );

    if (ok) {
      Navigator.of(context).pop();
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
                        _backupText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _backupText(lang, 'subtitle'),
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
                        child: const Icon(Icons.cloud_done_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _backupText(lang, 'info'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: _backupText(lang, 'createBackup'),
                        icon: Icons.file_upload_rounded,
                        onTap: _generateBackup,
                        dark: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: _backupText(lang, 'copy'),
                        icon: Icons.copy_rounded,
                        onTap: _copyBackup,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  label: _backupText(lang, 'pasteFromClipboard'),
                  icon: Icons.content_paste_rounded,
                  onTap: _pasteFromClipboard,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _backupController,
                  minLines: 10,
                  maxLines: 18,
                  decoration: InputDecoration(
                    hintText: _backupText(lang, 'jsonHint'),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
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
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Material(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _importBackup,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.restore_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _backupText(lang, 'restoreBackup'),
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
                const SizedBox(height: 16),
                PremiumCard(
                  color: const Color(0xFFFFFBF4),
                  borderColor: AppColors.warning.withOpacity(0.24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _backupText(lang, 'warning'),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.dark = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: dark ? AppColors.darkNavy : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: dark ? AppColors.darkNavy : AppColors.stroke,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: dark ? Colors.white : AppColors.textPrimary,
                    size: 19,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      color: dark ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
