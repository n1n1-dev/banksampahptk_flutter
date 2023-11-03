import 'dart:math';

// Fungsi Keanggotaan untuk variabel Jarak
double dekat(double jarak) {
  if (jarak <= 0) return 1;
  if (jarak >= 2) return 0;
  return (2 - jarak) / 2;
}

double sedang(double jarak) {
  if (jarak <= 1 || jarak >= 5) return 0;
  if (jarak >= 1 && jarak <= 3) return (jarak - 1) / 2;
  return (5 - jarak) / 2;
}

double jauh(double jarak) {
  if (jarak <= 4) return 0;
  return 1;
}

// Fungsi Keanggotaan untuk variabel Harga Beli Sampah
double murah(double harga) {
  if (harga <= 0) return 1;
  if (harga >= 5000) return 0;
  return (5000 - harga) / 5000;
}

double hargaSedang(double harga) {
  if (harga <= 3000 || harga >= 10000) return 0;
  if (harga >= 3000 && harga <= 6500) return (harga - 3000) / 3500;
  return (10000 - harga) / 3500;
}

double mahal(double harga) {
  if (harga <= 8000) return 0;
  return 1;
}

double tsukamotoJarakRekomendasi(double jarak) {
  double a1 = dekat(jarak);
  double a2 = sedang(jarak);
  double a3 = jauh(jarak);

  // Defuzzifikasi menggunakan metode centroid
  double centroidDirekomendasikan = 100;
  double centroidPertimbangan = 50;
  double centroidTidakDirekomendasikan = 0;

  double hasilRekomendasi = (a1 * centroidDirekomendasikan +
          a2 * centroidPertimbangan +
          a3 * centroidTidakDirekomendasikan) /
      (a1 + a2 + a3);

  return hasilRekomendasi;
}

double tsukamotoHargaRekomendasi(double harga) {
  double a1 = mahal(harga);
  double a2 = hargaSedang(harga);
  double a3 = murah(harga);

  // Defuzzifikasi menggunakan metode centroid
  double centroidDirekomendasikan = 100;
  double centroidPertimbangan = 50;
  double centroidTidakDirekomendasikan = 0;

  double hasilRekomendasi = (a1 * centroidDirekomendasikan +
          a2 * centroidPertimbangan +
          a3 * centroidTidakDirekomendasikan) /
      (a1 + a2 + a3);

  return hasilRekomendasi;
}

// Inferensi Tsukamoto
double rekomendasi(double jarak, double harga) {
  double a1 = max(dekat(jarak), mahal(harga));
  double a2 = max(sedang(jarak), hargaSedang(harga));
  double a3 = max(jauh(jarak), murah(harga));

  // Defuzzifikasi menggunakan metode centroid
  double centroidDirekomendasikan = 100;
  double centroidPertimbangan = 50;
  double centroidTidakDirekomendasikan = 0;

  double hasilRekomendasi = (a1 * centroidDirekomendasikan +
          a2 * centroidPertimbangan +
          a3 * centroidTidakDirekomendasikan) /
      (a1 + a2 + a3);

  return hasilRekomendasi;
}
