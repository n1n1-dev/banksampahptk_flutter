import '../../models/data_model.dart';
import '../../models/data_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../constant/constant.dart';

class SampahForm extends StatefulWidget {
  final String statusState;
  final DocumentSnapshot? dataId;

  const SampahForm({required this.statusState, super.key, this.dataId});

  @override
  State<SampahForm> createState() => _SampahFormState();
}

class _SampahFormState extends State<SampahForm> {
  TextEditingController namasampahController = TextEditingController();
  TextEditingController satuanController = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();

  static const _locale = 'id';
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.statusState == 'Ubah Sampah') {
      namasampahController.text = widget.dataId!['nama'];
      satuanController.text = widget.dataId!['satuan'];
      hargaBeliController.text = widget.dataId!['hargaBeli'].toString();
    } else {
      namasampahController.clear;
      satuanController.clear;
      hargaBeliController.clear;
    }
  }

  @override
  void dispose() {
    namasampahController.dispose();
    satuanController.dispose();
    hargaBeliController.dispose();
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
                    Text('Nama Sampah *', style: CustomBS.titleForm),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: namasampahController,
                      keyboardType: TextInputType.text,
                      decoration: CustomBS.decorationForm.copyWith(),
                      style: CustomBS.inputtitleForm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama Sampah Harus Diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Text('Satuan *', style: CustomBS.titleForm),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: satuanController,
                      keyboardType: TextInputType.text,
                      decoration: CustomBS.decorationForm.copyWith(),
                      style: CustomBS.inputtitleForm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Satuan Harus Diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Text('Harga Beli *', style: CustomBS.titleForm),
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
                            selection:
                                TextSelection.collapsed(offset: string.length),
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
                    const SizedBox(height: 50.0),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: ElevatedButton(
                          style: CustomBS.buttonPurple,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String hargaBeli =
                                  hargaBeliController.text.replaceAll('.', '');
                              DataServices service = DataServices();

                              if (widget.statusState == 'Ubah Sampah') {
                                Sampah sampah = Sampah(
                                    id: widget.dataId!.id,
                                    nama: namasampahController.text,
                                    satuan: satuanController.text,
                                    hargaBeli: int.parse(hargaBeli));
                                service.updateSampah(sampah).then(
                                    (value) => Navigator.of(context).pop());
                              } else {
                                Sampah sampah = Sampah(
                                    nama: namasampahController.text,
                                    satuan: satuanController.text,
                                    hargaBeli: int.parse(hargaBeli));
                                service.addSampah(sampah).then(
                                    (value) => Navigator.of(context).pop());
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save),
                                const SizedBox(width: 2),
                                Text('Simpan', style: CustomBS.titleButton),
                              ],
                            ),
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
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(widget.statusState, style: CustomBS.titleBar),
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
