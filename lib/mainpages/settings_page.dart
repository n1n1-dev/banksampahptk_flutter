import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/auth_page.dart';
import '../constant/constant.dart';
import '../auth/auth_services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String email = '';
  String rules = '';
  String namaBS = '';
  String legalitasBS = '';
  String lokasilatBS = '';
  String lokasilongBS = '';
  String alamatBS = '';

  @override
  void initState() {
    super.initState();
    _getDataUser();
  }

  Future _getDataUser() async {
    var hasil = await getUserData();

    if (hasil['rules'] == 'admin') {
      DocumentSnapshot<Map<String, dynamic>> bsData = await FirebaseFirestore
          .instance
          .collection('banksampah')
          .doc(hasil['banksampahId'])
          .get();

      setState(() {
        namaBS = bsData['nama'];
        GeoPoint lok = bsData['lokasi'];
        legalitasBS = bsData['legalitas'];
        lokasilatBS = lok.latitude.toString();
        lokasilongBS = lok.longitude.toString();
        alamatBS = bsData['alamat'];
      });
    }

    setState(() {
      email = hasil['email'];
      rules = hasil['rules'];
    });
  }

  //signout function
  signOut() async {
    await auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backgroundContainer(context),
            mainContainer(),
          ],
        ),
      ),
    );
  }

  Widget mainContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width / 1.05,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.black,
        color: Colors.greenAccent[100],
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.2,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  color: Colors.green[500],
                  size: 100,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text('User Email',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    )),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Hak Akses',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    )),
                Text(
                  rules,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                rules == 'admin' ? adminbsData() : const SizedBox(),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => signOut(),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green)),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Row(
                        children: [Text('Log Out')],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column backgroundContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 120,
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
            lPrimaryColor,
            mPrimaryColor,
            nPrimaryColor,
          ])),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                'Pengaturan',
                style: CustomBS.titleBar,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget adminbsData() {
    return Column(
      children: [
        const Text('Bank Sampah',
            style: TextStyle(
              fontSize: 15,
              color: Colors.green,
            )),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const Text('Nama : ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                  )),
              Expanded(
                child: Text(namaBS,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    )),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const Text('Legalitas : ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                  )),
              Expanded(
                child: Text(legalitasBS,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    )),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const Text('Lokasi : ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                  )),
              Expanded(
                child: Text('$lokasilatBS , $lokasilongBS',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    )),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const Text('Alamat : ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                  )),
              Expanded(
                child: Text(alamatBS,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
