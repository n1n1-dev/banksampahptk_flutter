import 'maps_page.dart';
import '/models/data_model.dart';
import '/models/data_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constant/constant.dart';

class BankSampahForm extends StatefulWidget {
  final String? statusState;
  final DocumentSnapshot? dataId;
  final String? lokasipeta;
  final double lat;
  final double long;

  const BankSampahForm(
      {this.statusState,
      super.key,
      this.dataId,
      this.lokasipeta,
      required this.lat,
      required this.long});

  @override
  State<BankSampahForm> createState() => _BankSampahFormState();
}

class _BankSampahFormState extends State<BankSampahForm> {
  TextEditingController namabanksampahController = TextEditingController();
  TextEditingController legalitasController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  GeoPoint? lokasi;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.lokasipeta != null) {
      alamatController.text = widget.lokasipeta!;
      lokasi = GeoPoint(widget.lat, widget.long);
    }
    if (widget.statusState == 'Ubah Bank Sampah') {
      namabanksampahController.text = widget.dataId!['nama'];
      legalitasController.text = widget.dataId!['legalitas'];
      alamatController.text = widget.dataId!['alamat'].toString();
      lokasi = widget.dataId!['lokasi'];
    } else if (widget.statusState == 'Tambah Bank Sampah') {
      namabanksampahController.clear;
      legalitasController.clear;
      alamatController.clear;
    }
  }

  @override
  void dispose() {
    namabanksampahController.dispose();
    legalitasController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            backgroundContainer(context),
            Positioned(
              top: 120,
              child: mainContainer(),
            ),
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
      height: 550,
      width: 320,
      child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 30, top: 5, right: 30, bottom: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30.0),
                    Text('Nama Bank Sampah *', style: CustomBS.titleForm),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: namabanksampahController,
                      keyboardType: TextInputType.text,
                      decoration: CustomBS.decorationForm.copyWith(),
                      style: CustomBS.inputtitleForm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama Bank Sampah Harus Diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Text('Legalitas *', style: CustomBS.titleForm),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: legalitasController,
                      keyboardType: TextInputType.text,
                      decoration: CustomBS.decorationForm.copyWith(),
                      style: CustomBS.inputtitleForm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Legalitas Harus Diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Text('Alamat *', style: CustomBS.titleForm),
                        const SizedBox(width: 5),
                        ElevatedButton(
                            onPressed: () {
                              final route = MaterialPageRoute(
                                  builder: (context) => MapsPage(
                                      statusState: widget.statusState,
                                      dataId: widget.dataId));
                              Navigator.push(context, route);
                            },
                            child: const Text("cari alamat")),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text((widget.lokasipeta != null ||
                            widget.statusState == 'Tambah Bank Sampah')
                        ? 'lokasi : latitude ${widget.lat}, longitude ${widget.long}'
                        : 'lokasi : latitude ${widget.dataId!['lokasi'].latitude}, longitude  ${widget.dataId!['lokasi'].longitude}'),
                    const SizedBox(height: 2.0),
                    TextFormField(
                      controller: alamatController,
                      keyboardType: TextInputType.text,
                      decoration: CustomBS.decorationForm.copyWith(
                          hintText: 'Cari dan ambil alamat pada peta'),
                      maxLines: 10,
                      minLines: 1,
                      style: CustomBS.inputtitleForm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat Harus Diisi';
                        }
                        return null;
                      },
                      enabled: (widget.lokasipeta != null &&
                                  widget.statusState == 'Tambah Bank Sampah') ||
                              (widget.statusState == 'Ubah Bank Sampah')
                          ? true
                          : false,
                    ),
                    const SizedBox(height: 50.0),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: ElevatedButton(
                          style: CustomBS.buttonPurple,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              DataServices service = DataServices();

                              if (widget.statusState == 'Ubah Bank Sampah') {
                                BankSampah bankSampah = BankSampah(
                                    id: widget.dataId!.id,
                                    nama: namabanksampahController.text,
                                    legalitas: legalitasController.text,
                                    alamat: alamatController.text,
                                    lokasi: widget.lokasipeta != null
                                        ? GeoPoint(widget.lat, widget.long)
                                        : widget.dataId!['lokasi']);
                                service.updateBankSampah(bankSampah).then(
                                      (value) => Navigator.of(context)
                                          .popUntil((route) => route.isFirst),
                                    );
                              } else if (widget.statusState ==
                                  'Tambah Bank Sampah') {
                                BankSampah bankSampah = BankSampah(
                                    nama: namabanksampahController.text,
                                    legalitas: legalitasController.text,
                                    alamat: alamatController.text,
                                    lokasi: GeoPoint(widget.lat, widget.long));
                                service.addBankSampah(bankSampah).then(
                                      (value) => Navigator.of(context)
                                          .popUntil((route) => route.isFirst),
                                    );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            child: Text('Simpan', style: CustomBS.titleButton),
                          ),
                        ),
                      ),
                    )
                  ]),
            )),
      ),
    );
  }

  Column backgroundContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
            lPrimaryColor,
            mPrimaryColor,
            nPrimaryColor,
          ])),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(widget.statusState ?? '', style: CustomBS.titleBar)
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
