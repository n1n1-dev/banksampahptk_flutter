import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constant/constant.dart';
import '../../models/data_model.dart';
import '../../models/data_services.dart';

// ignore: must_be_immutable
class SampahBankSampahForm extends StatefulWidget {
  List<String> results = [];
  dynamic idBankSampah = '';
  SampahBankSampahForm(
      {super.key, required this.results, required this.idBankSampah});

  @override
  State<SampahBankSampahForm> createState() => _SampahBankSampahForm();
}

class _SampahBankSampahForm extends State<SampahBankSampahForm> {
  DataServices service = DataServices();

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllSampah() {
    return FirebaseFirestore.instance.collection('sampah').snapshots();
  }

  final List<String> _selectedItems = [];

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Jenis Sampah'),
      content: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
            stream: getAllSampah(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];

                        return widget.results.contains(doc.id)
                            ? Container()
                            : CheckboxListTile(
                                title: Text(doc['nama'],
                                    style: CustomBS.titleListSampah),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Satuan : ${doc['satuan']}',
                                        style: CustomBS.subtitleListSampah),
                                    Text(
                                        CurrencyFormat.convertToIdr(
                                            doc['hargaBeli'], 0),
                                        style: CustomBS.titleHargaSampah),
                                  ],
                                ),
                                autofocus: false,
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                selected: _selectedItems.contains(doc.id),
                                value: _selectedItems.contains(doc.id),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedItems.add(doc.id);
                                    } else {
                                      _selectedItems.remove(doc.id);
                                    }

                                    if (value == true) {
                                      addDataToFirestore(doc);
                                    }
                                  });
                                },
                              );
                      })
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ),
      actions: [
        ElevatedButton(
          style: CustomBS.buttonWhiteOrange,
          onPressed: _close,
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  void addDataToFirestore(DocumentSnapshot doc) {
    var idDoc = 'sampah/${doc.id}';
    var sampahRefId = FirebaseFirestore.instance.doc(idDoc);

    final DocumentReference<Map<String, dynamic>> targetRef =
        FirebaseFirestore.instance.doc('banksampah/${widget.idBankSampah}');

    SampahBankSampah sampah = SampahBankSampah(
        banksampahRef: targetRef,
        sampahRef: sampahRefId,
        hargaBeli: doc['hargaBeli']);
    service
        .addSampahBankSampah(sampah)
        .then((value) => Navigator.of(context).pop());
  }
}
