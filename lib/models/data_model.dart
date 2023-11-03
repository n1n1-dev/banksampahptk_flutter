import 'package:cloud_firestore/cloud_firestore.dart';

// class user
class UserRules {
  final String userId;
  final String email;
  final String rules;
  String banksampahId;

  UserRules({
    required this.userId,
    required this.email,
    required this.rules,
    required this.banksampahId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'rules': rules,
      'banksampahId': banksampahId,
    };
  }
}

//class banksampah
class BankSampah {
  final String? id;
  final String nama;
  final String legalitas;
  final String alamat;
  final GeoPoint lokasi;

  BankSampah(
      {this.id,
      required this.nama,
      required this.legalitas,
      required this.alamat,
      required this.lokasi});

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'legalitas': legalitas,
      'alamat': alamat,
      'lokasi': lokasi,
    };
  }
}

// class sampah
class Sampah {
  final String? id;
  final String nama;
  final String satuan;
  final int hargaBeli;

  Sampah(
      {this.id,
      required this.nama,
      required this.satuan,
      required this.hargaBeli});

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'satuan': satuan,
      'hargaBeli': hargaBeli,
    };
  }
}

// class referensi dari class sampah dan class banksampah
class SampahBankSampah {
  final String? id;
  final DocumentReference banksampahRef;
  final DocumentReference sampahRef;
  final int hargaBeli;

  SampahBankSampah({
    this.id,
    required this.banksampahRef,
    required this.sampahRef,
    required this.hargaBeli,
  });

  Map<String, dynamic> toMap() {
    return {
      'banksampahRef': banksampahRef,
      'sampahRef': sampahRef,
      'hargaBeli': hargaBeli
    };
  }

  factory SampahBankSampah.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final hargaBeli = data['hargaBeli'] ?? 0;

    // Ambil referensi dari dokumen sampah
    final sampahRef = data['sampahRef'] as DocumentReference;
    // Ambil referensi dari dokumen bank sampah
    final banksampahRef = data['banksampahRef'] as DocumentReference;

    return SampahBankSampah(
      id: snapshot.id,
      sampahRef: sampahRef,
      banksampahRef: banksampahRef,
      hargaBeli: hargaBeli,
    );
  }
}

// class details banksampah
class DetailsBankSampah {
  final String? id;
  final String nama;
  final String legalitas;
  final String alamat;
  final double lokasiLatitude;
  final double lokasiLongitude;
  Map<String, int> hargaSampah;

  DetailsBankSampah(
      {this.id,
      required this.nama,
      required this.legalitas,
      required this.alamat,
      required this.lokasiLatitude,
      required this.lokasiLongitude,
      required this.hargaSampah});
}

// class referensi dari class sampahbanksampah
class KeranjangEstimasi {
  final DocumentReference sampahbanksampahRef;
  final int jumlah;
  final String usersId;

  KeranjangEstimasi({
    required this.sampahbanksampahRef,
    required this.jumlah,
    required this.usersId,
  });

  Map<String, dynamic> toMap() {
    return {
      'sampahbanksampahRef': sampahbanksampahRef,
      'jumlah': jumlah,
      'usersId': usersId,
    };
  }

  factory KeranjangEstimasi.fromMap(Map<String, dynamic> map) {
    final sampahbanksampahRef = map['sampahbanksampahRef'] as DocumentReference;
    final jumlah = map['jumlah'];
    final usersId = map['userId'] ?? '';
    return KeranjangEstimasi(
      sampahbanksampahRef: sampahbanksampahRef,
      jumlah: jumlah,
      usersId: usersId,
    );
  }
}

// class detail dari class KeranjangEstimasi
class KeranjangDetail {
  final String namaBankSampah;
  final String namaSampah;
  final int hargaBeli;
  final int jumlah;
  final String userId;

  KeranjangDetail({
    required this.namaBankSampah,
    required this.namaSampah,
    required this.hargaBeli,
    required this.jumlah,
    required this.userId,
  });
}
