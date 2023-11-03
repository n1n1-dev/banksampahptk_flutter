import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../auth/auth_services.dart';
import '../../constant/constant.dart';
import '../../models/data_model.dart';
import '../../models/data_services.dart';
import 'sampahbanksampah_form.dart';

class SampahBankSampahList extends StatefulWidget {
  const SampahBankSampahList({Key? key}) : super(key: key);

  @override
  State<SampahBankSampahList> createState() => _SampahBankSampahList();
}

class _SampahBankSampahList extends State<SampahBankSampahList> {
  DataServices service = DataServices();

  TextEditingController hargaBeliController = TextEditingController();

  static const _locale = 'id';
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  final _formKey = GlobalKey<FormState>();

  List<String> results = [];

  String idBankSampah = '';
  dynamic targetRef = '';

  @override
  void initState() {
    super.initState();
    _getDataUser();
    hargaBeliController.clear;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllDocuments() {
    return FirebaseFirestore.instance
        .collection('sampahbanksampah')
        .where('banksampahRef', isEqualTo: targetRef)
        .snapshots();
  }

  Future<void> _getDataUser() async {
    var hasil = await getUserData();
    setState(() {
      idBankSampah = hasil['banksampahId'];
    });
    targetRef = FirebaseFirestore.instance.doc('banksampah/$idBankSampah');
  }

  @override
  void dispose() {
    hargaBeliController.dispose();
    super.dispose();
  }

  void _showMultiSelect() async {
    await FirebaseFirestore.instance
        .collection('sampahbanksampah')
        .where('banksampahRef', isEqualTo: targetRef)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> s) {
      for (var e in s.docs) {
        DocumentReference<Map<String, dynamic>> sampahRef = e['sampahRef'];
        setState(() {
          results.add(sampahRef.id);
        });
      }
    });

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SampahBankSampahForm(
            results: results, idBankSampah: idBankSampah);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getAllDocuments(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      elevation: 5,
                      pinned: true,
                      title:
                          Text('Daftar Jenis Sampah', style: CustomBS.titleBar),
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var idData = snapshot.data!.docs[index].id;
                          var hargaData =
                              snapshot.data!.docs[index]['hargaBeli'];
                          Map<String, dynamic> data =
                              snapshot.data!.docs[index].data();
                          DocumentReference<Map<String, dynamic>> sampahRef =
                              data['sampahRef'];
                          return sampahbanksampahList(
                              sampahRef, idData, hargaData, index);
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMultiSelect,
        tooltip: 'Tambah Jenis Sampah',
        child: const Icon(Icons.add),
      ),
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> sampahbanksampahList(
      DocumentReference<Map<String, dynamic>> sampahRef,
      idData,
      hargaData,
      int index) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: sampahRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> sampahData = snapshot.data!.data()!;
          return Container(
            alignment: Alignment.center,
            color: Colors.amber[100 * (index % 9)],
            child: ExpansionTile(
              title: Text(sampahData['nama'], style: CustomBS.titleListSampah),
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 50),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Harga Beli Bank Sampah : ${CurrencyFormat.convertToIdr(hargaData, 0)}',
                          style: CustomBS.titleHargaSampah),
                      Text(
                          'Harga Referensi : ${CurrencyFormat.convertToIdr(sampahData['hargaBeli'], 0)}',
                          style: CustomBS.subtitleListSampah),
                    ],
                  ),
                  subtitle: Text('Satuan : ${sampahData['satuan']}',
                      style: CustomBS.subtitleListSampah),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: CustomBS.buttonOrange,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _edit(
                                sampahData, context, idData, sampahRef);
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 12.0),
                        child: Icon(Icons.edit),
                      ),
                    ),
                    ElevatedButton(
                      style: CustomBS.buttonPink,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: Text(
                                  'Hapus Jenis Sampah "${sampahData['nama']}" ? '),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Batal'),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    service.deleteSampahBankSampah(idData).then(
                                        (value) => Navigator.of(context).pop());
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 12.0),
                        child: Icon(Icons.delete_forever),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20)
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  AlertDialog _edit(Map<String, dynamic> sampahData, BuildContext context,
      idData, DocumentReference<Map<String, dynamic>> sampahRef) {
    return AlertDialog(
      title: const Text('Ubah Harga Beli'),
      content: SizedBox(
        height: 150,
        child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Harga Beli "${sampahData['nama']}" *',
                  style: CustomBS.titleForm),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: hargaBeliController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                    prefixText: _currency,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ))),
                style: CustomBS.inputtitleForm,
                onChanged: (string) {
                  if (string.length > 1) {
                    string = _formatNumber(string.replaceAll('.', ''));
                    hargaBeliController.value = TextEditingValue(
                      text: string,
                      selection: TextSelection.collapsed(offset: string.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga Beli Harus Diisi';
                  }
                  return null;
                },
              ),
            ])),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Batal');
            hargaBeliController.clear();
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              String hargaBeli = hargaBeliController.text.replaceAll('.', '');
              SampahBankSampah editdataSampah = SampahBankSampah(
                  id: idData,
                  banksampahRef: targetRef,
                  sampahRef: sampahRef,
                  hargaBeli: int.parse(hargaBeli));
              service
                  .updateSampahBankSampah(editdataSampah)
                  .then((value) => Navigator.of(context).pop());
              hargaBeliController.clear();
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
