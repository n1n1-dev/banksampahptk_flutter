import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constant/constant.dart';
import '../../models/data_services.dart';
import 'sampah_form.dart';

class SampahList extends StatefulWidget {
  const SampahList({super.key});

  @override
  State<SampahList> createState() => _SampahListState();
}

class _SampahListState extends State<SampahList> {
  DataServices service = DataServices();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("sampah").snapshots(),
        builder: (context, snapshot) {
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
                      delegate: SliverChildBuilderDelegate((context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        return Container(
                          alignment: Alignment.center,
                          color: Colors.blue[100 * (index % 9)],
                          child: sampahList(doc, context),
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
          final route = MaterialPageRoute(
              builder: (context) =>
                  const SampahForm(statusState: 'Tambah Sampah'));
          Navigator.push(context, route);
        }),
        tooltip: 'Tambah Bank Sampah',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget sampahList(DocumentSnapshot<Object?> doc, BuildContext context) {
    return ExpansionTile(
      title: Text(doc['nama'], style: CustomBS.titleListSampah),
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.only(left: 50),
          title: Text(CurrencyFormat.convertToIdr(doc['hargaBeli'], 0),
              style: CustomBS.titleHargaSampah),
          subtitle: Text('Satuan : ${doc['satuan']}',
              style: CustomBS.subtitleListSampah),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: CustomBS.buttonOrange,
              onPressed: () async {
                final route = MaterialPageRoute(
                    builder: (context) =>
                        SampahForm(statusState: 'Ubah Sampah', dataId: doc));
                // ignore: use_build_context_synchronously
                Navigator.push(context, route);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
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
                      content: Text('Hapus Jenis Sampah "${doc['nama']}" ? '),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Batal'),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            service
                                .deleteSampah(doc.id)
                                .then((value) => Navigator.of(context).pop());
                          },
                          child: const Text('Hapus'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
                child: Icon(Icons.delete_forever),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}
