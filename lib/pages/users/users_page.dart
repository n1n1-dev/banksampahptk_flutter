import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_services.dart';
import '../../constant/constant.dart';
import '../../models/data_services.dart';
import 'users_form.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  DataServices service = DataServices();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banksampah').snapshots(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      elevation: 5,
                      pinned: true,
                      title: Text('Daftar Admin Bank Sampah',
                          style: CustomBS.titleBar),
                      centerTitle: true,
                      expandedHeight: 80.0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(100),
                          ),
                          side: BorderSide(color: Colors.deepPurple, width: 1)),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];

                        return Container(
                          alignment: Alignment.center,
                          color: Colors.orange[100 * (index % 9)],
                          child: ExpansionTile(
                              title: Text(doc['nama'],
                                  style: CustomBS.titleListSampah),
                              children: <Widget>[
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('rules', isEqualTo: 'admin')
                                      .where('banksampahId', isEqualTo: doc.id)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const Text(
                                          'Tidak Ada Daftar Admin Bank Sampah');
                                    } else {
                                      return ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final document =
                                              snapshot.data!.docs[index];

                                          final email =
                                              document['email'] as String;

                                          return ListTile(
                                            title: Text(email),
                                            trailing: ElevatedButton(
                                              style: CustomBS.buttonPink,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Konfirmasi'),
                                                      content: Text(
                                                          'Hapus "$email" ? '),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Batal'),
                                                          child: const Text(
                                                              'Batal'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            SharedPreferences
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            String emailadbs =
                                                                prefs
                                                                    .getString(
                                                                        email)
                                                                    .toString();

                                                            await AuthServices
                                                                .deleteAdminBS(
                                                                    email,
                                                                    emailadbs);

                                                            QuerySnapshot<
                                                                    Map<String,
                                                                        dynamic>>
                                                                cek =
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .where(
                                                                        'email',
                                                                        isEqualTo:
                                                                            email)
                                                                    .get();

                                                            if (cek
                                                                .docs.isEmpty) {
                                                              // ignore: use_build_context_synchronously
                                                              Navigator.pop(
                                                                  context,
                                                                  'Batal');

                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      'Akun Admin Bank Sampah Berhasil Dihapus',
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green);
                                                            }
                                                          },
                                                          child: const Text(
                                                              'Hapus'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.0,
                                                    vertical: 12.0),
                                                child:
                                                    Icon(Icons.delete_forever),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ]),
                        );
                      }, childCount: snapshot.data!.docs.length),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          final route =
              MaterialPageRoute(builder: (context) => const UsersForm());
          Navigator.push(context, route);
        }),
        tooltip: 'Tambah Admin',
        child: const Icon(Icons.add),
      ),
    );
  }
}
