# Planora Flutter MVP v1

Bu paket, Planora için premium görünümlü ilk Flutter MVP kod iskeletidir.

## İçerik

- Premium açık tema
- Planora logo widget
- Ana panel
- Ödeme ekleme ekranı
- Ödeme takvimi
- Aylık analiz
- Profil / ayarlar
- Dummy sample data
- Harcama limiti özelliği için sonraki faz notu

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Proje yapısı

```text
lib/
  main.dart
  theme/
    app_theme.dart
  models/
    payment_item.dart
    sample_data.dart
  screens/
    app_shell.dart
    dashboard_screen.dart
    add_payment_screen.dart
    calendar_screen.dart
    analysis_screen.dart
    profile_screen.dart
  widgets/
    premium_widgets.dart
  utils/
    money_formatter.dart
```

## Sonraki geliştirme fazları

### Faz 1 — MVP fonksiyonel hale getirme
- Gerçek ödeme ekleme
- Local state yönetimi
- Ödeme silme / düzenleme
- Kategori yönetimi
- Para birimi seçimi

### Faz 2 — Kalıcı veri
- Local storage
- Kullanıcı ayarlarının saklanması
- Ödeme tekrarlarının hesaplanması

### Faz 3 — Bildirimler
- Ödeme günü hatırlatması
- Geciken ödeme uyarısı
- Maaş günü bildirimi

### Faz 4 — Harcama Limitleri
Bu özellik bilinçli olarak ilk koda eklenmedi. Sonraki fazda eklenecek:

- Kategori bazlı aylık limit
- %70 / %80 / %100 bildirim eşiği
- Limit dolunca kategori uyarısı
- Limit aşılınca kritik uyarı
- Dashboard’da Akıllı Uyarılar kartı

### Faz 5 — Backend / Cloud
- Kullanıcı hesabı
- Cloud sync
- Firebase / Supabase entegrasyonu
- Yedekleme
- Premium abonelik sistemi
