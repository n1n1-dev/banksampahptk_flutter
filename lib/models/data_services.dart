import '../../models/data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DataServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //Begin Sampah
  addSampah(Sampah sampahData) async {
    try {
      await _db.collection("sampah").add(sampahData.toMap());
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Tambah Data Jenis Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  updateSampah(Sampah sampahData) async {
    try {
      await _db
          .collection("sampah")
          .doc(sampahData.id)
          .update(sampahData.toMap());
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Ubah Data Jenis Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<void> deleteSampah(String documentId) async {
    try {
      await _db.collection("sampah").doc(documentId).delete();
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Hapus Data Jenis Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
    }
  }

  //End Sampah
  //************************ */
  //************************ */

  //************************ */
  //************************ */
  //Begin BankSampah
  addBankSampah(BankSampah banksampahData) async {
    try {
      await _db.collection("banksampah").add(banksampahData.toMap());
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Tambah Data Bank Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  updateBankSampah(BankSampah banksampahData) async {
    try {
      await _db
          .collection("banksampah")
          .doc(banksampahData.id)
          .update(banksampahData.toMap());
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Ubah Data Bank Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<void> deleteBankSampah(String documentId) async {
    try {
      await _db.collection("banksampah").doc(documentId).delete();
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Hapus Data Bank Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
    }
  }

//menampilkan daftar bank sampah
  Stream<QuerySnapshot> getBankSampahStream() {
    try {
      CollectionReference banksampah =
          FirebaseFirestore.instance.collection("banksampah");
      return banksampah.snapshots();
    } catch (e) {
      throw Exception('Tidak Bisa Mendapatkan Data Bank Sampah');
    }
  }

  //End BankSampah
  //************************ */
  //************************ */

  //************************ */
  //************************ */
  //Begin SampahBankSampah
  addSampahBankSampah(SampahBankSampah sampahbanksampahData) async {
    try {
      await _db
          .collection("sampahbanksampah")
          .add(sampahbanksampahData.toMap());
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Tambah Data Jenis Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  updateSampahBankSampah(SampahBankSampah sampahbanksampahData) async {
    try {
      await _db
          .collection("sampahbanksampah")
          .doc(sampahbanksampahData.id)
          .update(sampahbanksampahData.toMap());
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Ubah Harga Jenis Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<void> deleteSampahBankSampah(String documentId) async {
    try {
      await _db.collection("sampahbanksampah").doc(documentId).delete();
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Hapus Data Jenis Sampah",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
    }
  }

  // fungsi mendapatkan daftar sampah dari class SampahBankSampah
  Future getDaftarSampahBankSampah(DocumentReference banksampahRef) async {
    List<Sampah> daftarSampah = [];
    List<int> harga = [];
    List<String> idSampahBankSampah = [];

    try {
      // Query untuk mendapatkan data sampah bank sampah tertentu dari koleksi SampahBankSampah
      QuerySnapshot sampahBankSampahQuery = await FirebaseFirestore.instance
          .collection('sampahbanksampah')
          .where('banksampahRef', isEqualTo: banksampahRef)
          .get();

      for (QueryDocumentSnapshot doc in sampahBankSampahQuery.docs) {
        // Dapatkan referensi banksampahRef dari dokumen SampahBankSampah
        DocumentReference sampahRef = doc['sampahRef'];
        harga.add(doc['hargaBeli']);
        idSampahBankSampah.add(doc.id);

        // Dapatkan data BankSampah dari referensi banksampahRef
        DocumentSnapshot sampahDoc = await sampahRef.get();

        // Buat objek BankSampah dari data yang didapatkan, including jarak
        Sampah sampahData = Sampah(
          id: sampahDoc.id,
          nama: sampahDoc['nama'],
          satuan: sampahDoc['satuan'],
          hargaBeli: sampahDoc['hargaBeli'],
        );

        // Tambahkan objek Sampah ke dalam daftar jika belum ada
        if (!daftarSampah.contains(sampahData)) {
          daftarSampah.add(sampahData);
        }
      }
    } catch (e) {
      return false;
      // Handle error jika terjadi
    }
    Map<String, dynamic> hasil = {
      "daftarSampah": daftarSampah,
      "harga": harga,
      "idSampahBankSampah": idSampahBankSampah,
    };

    return hasil;
  }

  //End Sampah BankSampah
  //************************ */
  //************************ */

  //************************ */
  //************************ */
  // Keranjang Estimasi

  // hapus keranjangestimasi
  Future<void> deleteKeranjangEstimasi(String documentId) async {
    try {
      await _db.collection("keranjangestimasi").doc(documentId).delete();
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Hapus Data Keranjang Estimasi",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
    }
  }

  Future<void> findDocumentByReference(
      String collectionPath,
      String fieldName,
      DocumentReference reference,
      String idUser,
      KeranjangEstimasi estimasiData) async {
    try {
      final existingDocument = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where(fieldName, isEqualTo: reference)
          .where("usersId", isEqualTo: idUser)
          .get();

      if (existingDocument.docs.isNotEmpty) {
        // Dokumen ditemukan, notifikasi sudah ada data
        Fluttertoast.showToast(
          msg: "Jenis Sampah Sudah Ada di Keranjang Estimasi",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
        );
      } else {
        // Dokumen tidak ditemukan, tambahkan estimasiData
        await addKeranjangEstimasi(estimasiData);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan $e", // Atur pesan yang sesuai
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
      );
    }
  }

  addKeranjangEstimasi(KeranjangEstimasi estimasiData) async {
    try {
      await _db.collection("keranjangestimasi").add(estimasiData.toMap());
      Fluttertoast.showToast(
          msg: "Jenis Sampah Berhasil Ditambahkan di Keranjang Estimasi",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.teal);
      return true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Anda Tidak Memiliki Akses Tambah Data Keranjang Estimasi",
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  // menampilkan data detail keranjang estimasi
  Stream<KeranjangDetail> getKeranjangDetails(
      KeranjangEstimasi keranjang) async* {
    final sampahBankSampahDoc = await keranjang.sampahbanksampahRef.get();
    final jumlah = keranjang.jumlah;
    final usersId = keranjang.usersId;
    final bankSampahDoc = await sampahBankSampahDoc['banksampahRef'].get();
    final sampahDoc = await sampahBankSampahDoc['sampahRef'].get();

    final namaBankSampah = bankSampahDoc['nama'];
    final namaSampah = sampahDoc['nama'];
    final hargaBeli = sampahBankSampahDoc['hargaBeli'];

    yield KeranjangDetail(
      namaBankSampah: namaBankSampah,
      namaSampah: namaSampah,
      hargaBeli: hargaBeli,
      jumlah: jumlah,
      userId: usersId,
    );
  }

  //End Keranjang Estimasi
  //************************ */
  //************************ */
  //************************ */

  Future<int> banksampahSum() async {
    var snapshot = await _db.collection("banksampah").count().get();
    return snapshot.count;
  }

  Future<int> jenissampahSum() async {
    var snapshot = await _db.collection("sampah").count().get();
    return snapshot.count;
  }
}
