import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/auth_services.dart';
import '../constant/constant.dart';
import '../models/data_model.dart';
import '../models/data_services.dart';

class KeranjangEstimasiPage extends StatefulWidget {
  const KeranjangEstimasiPage({super.key});

  @override
  State<KeranjangEstimasiPage> createState() => _KeranjangEstimasiPageState();
}

class _KeranjangEstimasiPageState extends State<KeranjangEstimasiPage> {
  DataServices service = DataServices();
  List idData = [];
  List<KeranjangDetail> keranjangDetails = [];
  List<TextEditingController> quantityControllers = [];
  List<double> subtotals = [];
  double total = 0;
  String idUser = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    var hasil = await getUserData();
    setState(() {
      idUser = hasil['userId'] ?? '';
    });
    final keranjangEstimasiCollection = FirebaseFirestore.instance
        .collection('keranjangestimasi')
        .where('usersId', isEqualTo: idUser);

    QuerySnapshot keranjangEstimasiSnapshot =
        await keranjangEstimasiCollection.get();

    for (var doc in keranjangEstimasiSnapshot.docs) {
      idData.add(doc.id);
      var keranjangEstimasiObject =
          KeranjangEstimasi.fromMap(doc.data() as Map<String, dynamic>);

      // Panggil metode getKeranjangDetails data_services.dart untuk mengambil detail
      Stream<KeranjangDetail> detailStream =
          service.getKeranjangDetails(keranjangEstimasiObject);

      // Tambahkan detail ke daftar saat data tersedia
      detailStream.listen((keranjangDetail) {
        setState(() {
          keranjangDetails.add(keranjangDetail);
          quantityControllers.add(TextEditingController(text: '1'));
          subtotals.add(keranjangDetail.hargaBeli.toDouble());
          calculateTotal();
        });
      });
    }
  }

  void calculateTotal() {
    double newTotal = 0;
    for (int i = 0; i < keranjangDetails.length; i++) {
      var keranjangDetail = keranjangDetails[i];
      double harga = keranjangDetail.hargaBeli.toDouble();
      double jumlah = double.tryParse(quantityControllers[i].text) ?? 0;
      subtotals[i] = harga * jumlah;
      newTotal += subtotals[i];
    }
    setState(() {
      total = newTotal;
    });
  }

  @override
  void dispose() {
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    super.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: keranjangDetails.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  var keranjangDetail = keranjangDetails[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: GestureDetector(
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: Text(
                                  'Hapus Jenis Sampah "${keranjangDetail.namaSampah}" ? '),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Batal'),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    service
                                        .deleteKeranjangEstimasi(idData[index])
                                        .then((value) {
                                      // Hapus item dari daftar
                                      setState(() {
                                        keranjangDetails.removeAt(index);
                                        quantityControllers.removeAt(index);
                                        subtotals.removeAt(index);
                                        idData.removeAt(index);
                                        calculateTotal();
                                      });

                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const SizedBox(
                        width: 40,
                        child: Icon(
                          Icons.delete,
                          color: pinkColorBS,
                        ),
                      ),
                    ),
                    title: Text(
                      keranjangDetail.namaSampah,
                      style: CustomBS.titleListSampah,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bank Sampah : ${keranjangDetail.namaBankSampah}'),
                        Text(
                            'Harga : ${CurrencyFormat.convertToIdr(keranjangDetail.hargaBeli, 0)}'),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 40,
                              child: TextFormField(
                                controller: quantityControllers[index],
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(',')
                                ],
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 209, 185, 185),
                                          width: 2,
                                        ))),
                                style: CustomBS.inputtitleForm,
                                onChanged: (value) {
                                  calculateTotal();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jumlah Sampah Harus Diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      CurrencyFormat.convertToIdr(subtotals[index], 0),
                      style: CustomBS.titleHargaSampah,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 1,
                color: Colors.teal,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: CustomBS.titleHargaSampah,
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(total, 0),
                      style: CustomBS.titleHargaSampah,
                    ),
                  ],
                ),
              ),
            ],
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
                'Estimasi Penjualan Sampah',
                style: CustomBS.titleBar,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
