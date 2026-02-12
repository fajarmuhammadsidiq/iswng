# Testing and Quality Gates

Dokumen ini menjelaskan strategi test yang sudah diterapkan di project serta quality gate minimum sebelum merge/release.

## 1. Struktur Test Saat Ini

- `/Users/gg/Documents/iseng/iswng/test/unit/memory_game_engine_test.dart`
  - Unit test untuk logic game memory:
    - inisialisasi deck
    - aturan flip kartu
    - match/mismatch
    - pengurangan nyawa
    - game over
    - reset game
- `/Users/gg/Documents/iseng/iswng/test/widget_test.dart`
  - Test data sanity untuk memastikan setiap kategori memiliki item kartu.

## 2. Cara Menjalankan Test

Jalankan dari root project:

```bash
flutter test
```

Untuk analyzer:

```bash
flutter analyze --no-pub
```

## 3. Quality Gates (PR)

- `flutter test` harus lulus.
- Tidak boleh ada warning/error analyzer baru.
- Perubahan di logic game wajib disertai test.

## 4. Quality Gates (Release)

- Semua gate PR lulus.
- Regression test untuk flow utama:
  - buka kategori
  - main sampai menang
  - game over lalu retry
- Profiling performa di mode profile untuk memastikan tidak ada jank signifikan saat animasi kartu.

## 5. Catatan Implementasi

Agar logic game bisa diuji unit, logic dipisahkan ke:

- `/Users/gg/Documents/iseng/iswng/lib/app/modules/home/domain/memory_game_engine.dart`

UI di `/Users/gg/Documents/iseng/iswng/lib/app/modules/home/views/home_view.dart` tetap menggunakan behavior lama (delay resolusi 600ms + dialog win/game over), tetapi state dan aturan game kini dikelola oleh engine tersebut.
