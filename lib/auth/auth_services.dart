import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // UID pengguna yang baru dibuat
        String uid = userCredential.user!.uid;

        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');

        final userRole = UserRules(
            userId: uid, email: email, rules: 'nasabah', banksampahId: '-');
        usersCollection.doc(uid).set(userRole.toMap());

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(email, password);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "Password Terlalu Lemah",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "Email Sudah Ada",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'invalid-email') {
        Fluttertoast.showToast(
            msg: "Format Email Tidak Valid",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }

  static Future<UserCredential?> createAdminBS(
      String email, String password, String banksampahId) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      UserCredential? userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // UID pengguna yang baru dibuat
        String uid = userCredential.user!.uid;

        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');

        final userRole = UserRules(
            userId: uid,
            email: email,
            rules: 'admin',
            banksampahId: banksampahId);
        usersCollection.doc(uid).set(userRole.toMap());

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(email, password);
      }
      await app.delete();
      return Future.sync(() => userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "Password Terlalu Lemah",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "Email Sudah Ada",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'invalid-email') {
        Fluttertoast.showToast(
            msg: "Format Email Tidak Valid",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
    }
    return null;
  }

  static Future<void> deleteAdminBS(email, password) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);

    try {
      User? userCredential = FirebaseAuth.instance.currentUser;

      UserCredential? userCredentialSecondary =
          await FirebaseAuth.instanceFor(app: app)
              .signInWithEmailAndPassword(email: email, password: password);
      if (userCredentialSecondary.user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentialSecondary.user?.uid)
            .delete();
        userCredentialSecondary.user!.delete();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.remove(email);
      }
      return Future.sync(() => userCredential);
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
    }
  }

  static Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: "Password Anda Salah",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'invalid-email') {
        Fluttertoast.showToast(
            msg: "Format Email Tidak Valid",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'user-disabled') {
        Fluttertoast.showToast(
            msg: "Akun Dinonaktifkan",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      } else if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: "Akun Tidak Terdaftar",
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red);
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red);
      return false;
    }
  }
}

Future<Map<String, dynamic>> getUserData() async {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser!.uid)
      .get();

  if (userSnapshot.exists) {
    return userSnapshot.data() as Map<String, dynamic>;
  }

  return {}; // tampilkan jika user tidak ada
}
