import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../auth/auth_services.dart';

class UsersForm extends StatefulWidget {
  const UsersForm({super.key});

  @override
  State<UsersForm> createState() => _UsersFormState();
}

class _UsersFormState extends State<UsersForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final Map<String, String> _bankSampahOptions = {};
  String? _selectedBankSampahNama;
  String idBS = '';
  String userId = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    getUserData();
    // Ambil data bank sampah dari Firestore
    FirebaseFirestore.instance
        .collection('banksampah')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // Ambil ID bank sampah dan nama bank sampah
        String bankId = doc.id;
        String bankNama = doc['nama'];

        // Simpan dalam Map
        _bankSampahOptions[bankNama] = bankId;
      }

      // Set nilai awal _selectedBankSampahNama jika diperlukan
      if (_bankSampahOptions.isNotEmpty) {
        _selectedBankSampahNama = _bankSampahOptions
            .keys.first; // Pilih nama bank pertama sebagai nilai awal

        idBS = _bankSampahOptions[_selectedBankSampahNama]!; //
      }

      // Panggil setState untuk memperbarui tampilan
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Admin Bank Sampah'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 60, right: 30, left: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedBankSampahNama,
                items: _bankSampahOptions.keys.map((bankNama) {
                  return DropdownMenuItem<String>(
                    value: bankNama,
                    child: Text(bankNama),
                  );
                }).toList(),
                onChanged: (newNamaBank) {
                  setState(() {
                    _selectedBankSampahNama = newNamaBank;
                    idBS = _bankSampahOptions[
                        newNamaBank]!; // Ambil ID yang sesuai dari Map
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Pilih Bank Sampah',
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      isLoading = true;
                      const CircularProgressIndicator();
                    });

                    await AuthServices.createAdminBS(
                        _emailController.text, _passwordController.text, idBS);

                    QuerySnapshot<Map<String, dynamic>> cek =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: _emailController.text)
                            .get();

                    if (cek.docs.isNotEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Registrasi Berhasil',
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green);
                      _emailController.clear();
                      _passwordController.clear();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();

                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
