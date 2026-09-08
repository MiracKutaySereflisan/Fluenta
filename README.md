# Fluenta

İngilizce sınav hazırlık uygulaması. SwiftUI, iOS. Veri cihazda tutulur,
uygulama çevrimdışı çalışır.

Beceri başına ayrı çalışma modülleri ve CEFR seviyelerine göre kurulmuş bir içerik
yapısı var. Seviye, onboarding'deki tespit sınavıyla belirlenir ve ilerleme buna
göre takip edilir.

## Modüller

| Modül | Ne yapıyor |
|---|---|
| Seviye tespiti | Havuzdan rastgele seçilen sorularla giriş sınavı, her seferinde farklı |
| Kelime | SM-2 aralıklı tekrar algoritmasıyla kartlar, kişisel sözlük |
| Okuma | Evrensel sözlük (kelimeye basılı tut) ve çoktan seçmeli quiz |
| Dinleme | Cihaz üstü TTS, hız ayarı, transkript, quiz |
| Yazma | Süreli yazma, kelime sayacı |
| Konuşma | Teleprompter: cihaz üstü konuşma tanıma, doğru okunan kelimeler yeşile döner |
| Konuşma | IELTS Part 2 Cue Card: 1 dakika hazırlık, 2 dakika konuşma |
| İlerleme | Seri takibi, haftalık grafik, "hatadan ustalığa" ölçümü, rozetler |

## Yapı

```
Fluenta/
  App/              Giriş noktası, sekme yapısı, açılış
  Core/
    Models/         Veri modelleri
    Persistence/    Cihaz üstü JSON saklama, tohum veri
    Services/       Seviye ilerlemesi, konuşma ve TTS servisleri
  Features/
    Onboarding/     Karşılama ve seviye tespit sınavı
    Practice/       Beceri modülleri
    Vocabulary/     Kelime çalışma
    Home/           İlerleme kartı
  Components/       Paylaşılan arayüz parçaları
  Config/           Yapılandırma (backend bağlanınca kullanılacak alanlar)
```

## Çalıştırma

- Xcode 16 veya üzeri, iOS 17.0+

```
Fluenta.xcodeproj → aç → ⌘R
```

**Teleprompter modülü gerçek cihaz ister.** Simülatörde mikrofon ve konuşma tanıma
güvenilir çalışmaz.

`Config/AppConfig.swift` içindeki alanlar yer tutucudur; uygulama backend olmadan
tam çalışır.

## Henüz yok

Bilinçli olarak ertelenenler: backend ve içerik yönetimi, otomatik yazma
değerlendirmesi, StoreKit 2 aboneliği, tam sınav simülasyonu (mock test).

## Telif

Tüm hakları saklıdır. Kod incelenmek üzere paylaşılmıştır.
