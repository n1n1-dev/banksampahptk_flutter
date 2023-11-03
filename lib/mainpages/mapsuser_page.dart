import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/map_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../auth/auth_services.dart';
import '../constant/constant.dart';
import '../constant/fuzzy_tsukamoto.dart';
import '../models/data_model.dart';
import '../models/data_services.dart';

class MapsUserPage extends StatefulWidget {
  const MapsUserPage({super.key});

  @override
  State<MapsUserPage> createState() => _MapsUserPageState();
}

class _MapsUserPageState extends State<MapsUserPage> {
  DataServices service = DataServices();
  String idUser = '';
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();
  var mapType = MapType.normal;
  Set<Marker> listData = {};
  double latitude = -0.0352231;
  double longitude = 109.331888;
  List<DetailsBankSampah> daftarBankSampah = [];
  List<DetailsBankSampah> filteredList = [];
  bool filterTerdekat = false;
  bool filterHarga = false;
  bool filterBest = false;
  bool isLoading = true;
  Position? currentPosition; // Untuk menyimpan lokasi pengguna saat ini

  Stream<List<DetailsBankSampah>> streamBankSampahData() async* {
    List<DetailsBankSampah> detailsBankSampah = [];
    Map<String, int> hasil = {};

    QuerySnapshot bsQuery =
        await FirebaseFirestore.instance.collection('banksampah').get();

    if (bsQuery.docs.isNotEmpty) {
      for (QueryDocumentSnapshot docBS in bsQuery.docs) {
        GeoPoint lok = docBS['lokasi'];
        DocumentReference<Map<String, dynamic>> targetRef =
            FirebaseFirestore.instance.doc('banksampah/${docBS.id}');
        QuerySnapshot sbsQuery = await FirebaseFirestore.instance
            .collection('sampahbanksampah')
            .where('banksampahRef', isEqualTo: targetRef)
            .get();

        if (sbsQuery.docs.isNotEmpty) {
          for (QueryDocumentSnapshot docSBS in sbsQuery.docs) {
            DocumentReference sampahRef = docSBS['sampahRef'];
            DocumentSnapshot sampahDoc = await sampahRef.get();

            hasil = {
              sampahDoc['nama']: sampahDoc['hargaBeli'],
            };
          }
        }

        DetailsBankSampah detailsBS = DetailsBankSampah(
          id: docBS.id,
          nama: docBS['nama'],
          legalitas: docBS['legalitas'],
          alamat: docBS['alamat'],
          lokasiLatitude: lok.latitude,
          lokasiLongitude: lok.longitude,
          hargaSampah: hasil,
        );

        // Tambahkan objek Sampah ke dalam daftar jika belum ada
        if (!detailsBankSampah.contains(detailsBS)) {
          detailsBankSampah.add(detailsBS);
        }

        // Kirim data melalui Stream
        yield detailsBankSampah;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      streamBankSampahData().listen((detailsBankSampah) {
        setState(() {
          daftarBankSampah.addAll(detailsBankSampah);
          isLoading =
              false; // Setelah data dimuat, ubah isLoading menjadi false.
        });
      }, onError: (error) {
        debugPrint('Terjadi kesalahan: $error');
        isLoading = false; // Ubah isLoading jika terjadi kesalahan.
      });
    });

    checkLocationPermission();
    // Mendapatkan lokasi pengguna saat aplikasi dimulai
    _getCurrentLocation();
  }

  // Fungsi untuk memeriksa dan meminta izin lokasi
  Future<void> checkLocationPermission() async {
    await Permission.location.request();
  }

  // Fungsi untuk mendapatkan lokasi pengguna saat ini
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Lokasi perangkat belum diaktifkan");
    }
  }

  void onSelectedMapType(Type value) {
    setState(() {
      switch (value) {
        case Type.Normal:
          mapType = MapType.normal;
          break;
        case Type.Hybrid:
          mapType = MapType.hybrid;
          break;
        case Type.Terrain:
          mapType = MapType.terrain;
          break;
        case Type.Satellite:
          mapType = MapType.satellite;
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menambahkan filter sesuai dengan kondisi

    for (var e in daftarBankSampah) {
      if (!filteredList.contains(e)) {
        filteredList.add(e);
      }
    }

    for (var doc in filteredList) {
      listData.add(
        Marker(
          markerId: MarkerId(doc.nama),
          position: LatLng(doc.lokasiLatitude, doc.lokasiLongitude),
          infoWindow: InfoWindow(
            title: 'Bank Sampah : ${doc.nama}',
            snippet: 'Alamat : ${doc.alamat}',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    }

    if (currentPosition != null && filterTerdekat) {
      // Menghitung jarak menggunakan geolocator
      double userLatitude = currentPosition!.latitude;
      double userLongitude = currentPosition!.longitude;

      filteredList = filteredList.where((bankSampah) {
        double distance = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            bankSampah.lokasiLatitude,
            bankSampah.lokasiLongitude);
        double nilaiFuzzy = tsukamotoJarakRekomendasi(distance / 1000);

        return (nilaiFuzzy >=
            50); // minimal nilai fuzzy pada centroidPertimbangan
      }).toList();
    }

    // Fungsi untuk menghitung totalFuzzy
    double hitungTotalFuzzy(DetailsBankSampah bankSampah) {
      double totalFuzzy = 0.0;

      for (String jenisSampah in bankSampah.hargaSampah.keys) {
        double harga = bankSampah.hargaSampah[jenisSampah]!.toDouble();
        double fuzzyValue = tsukamotoHargaRekomendasi(harga);
        totalFuzzy += fuzzyValue;
      }

      return totalFuzzy;
    }

    if (filterHarga) {
      double totalFuzzyTertinggi = 0.0;
      DetailsBankSampah? bankSampahTertinggi;

      for (DetailsBankSampah bankSampah in daftarBankSampah) {
        double totalFuzzy = hitungTotalFuzzy(bankSampah);

        // Bandingkan dengan totalFuzzy tertinggi yang ada
        if (totalFuzzy > totalFuzzyTertinggi) {
          totalFuzzyTertinggi = totalFuzzy;
          bankSampahTertinggi = bankSampah;
        }
      }

      // Hanya tambahkan bankSampahTertinggi ke dalam filteredList
      if (bankSampahTertinggi != null) {
        filteredList = [bankSampahTertinggi];
      }
    }

    if (filterBest) {
      double userLatitude = currentPosition!.latitude;
      double userLongitude = currentPosition!.longitude;

      double shortestDistance = double.infinity;
      double highestPrice = 0.0;
      DetailsBankSampah? recommendedBankSampah;

      // Loop melalui semua bankSampah untuk mencari yang terbaik
      for (DetailsBankSampah bankSampah in filteredList) {
        double distance = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            bankSampah.lokasiLatitude,
            bankSampah.lokasiLongitude);
        double hargaTermahal = bankSampah.hargaSampah.values
            .reduce((a, b) => a < b ? b : a)
            .toDouble();

        // Hitung nilai rekomendasi menggunakan fungsi fuzzy
        double fuzzyRecommendation =
            rekomendasi((distance / 1000), hargaTermahal);

        // Bandingkan dengan yang terbaik sejauh ini
        if (fuzzyRecommendation >= 50 &&
            (distance < shortestDistance ||
                (distance == shortestDistance &&
                    hargaTermahal > highestPrice))) {
          shortestDistance = distance;
          highestPrice = hargaTermahal;
          recommendedBankSampah = bankSampah;
        }
      }

      // Hasil rekomendasi adalah recommendedBankSampah
      if (recommendedBankSampah != null) {
        filteredList = [recommendedBankSampah];
      } else {
        // Tidak ada yang direkomendasikan
        filteredList = [];
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Bank Sampah",
            style: CustomBS.titleBar,
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: onSelectedMapType,
              itemBuilder: (context) {
                return googleMapTypes.map((typeGoogle) {
                  return PopupMenuItem(
                    value: typeGoogle.type,
                    child: Text(typeGoogle.type.name),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                direction: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text('Terdekat'),
                    labelStyle: const TextStyle(color: Colors.white),
                    elevation: 8,
                    backgroundColor: Colors.deepPurple,
                    selectedColor: Colors.deepPurple,
                    checkmarkColor: Colors.teal,
                    selected: filterTerdekat,
                    onSelected: (selected) {
                      setState(() {
                        filterTerdekat = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Harga Terbaik'),
                    labelStyle: const TextStyle(color: Colors.white),
                    elevation: 8,
                    backgroundColor: Colors.teal,
                    selectedColor: Colors.teal,
                    checkmarkColor: Colors.amber,
                    selected: filterHarga,
                    onSelected: (selected) {
                      setState(() {
                        filterHarga = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Terekomendasi'),
                    labelStyle: const TextStyle(color: Colors.white),
                    elevation: 8,
                    backgroundColor: Colors.deepOrangeAccent,
                    selectedColor: Colors.deepOrangeAccent,
                    checkmarkColor: Colors.amber,
                    selected: filterBest,
                    onSelected: (selected) {
                      setState(() {
                        filterBest = selected;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: Stack(children: [
                  buildMaps(),
                  DraggableScrollableSheet(
                      initialChildSize: .25,
                      minChildSize: .1,
                      maxChildSize: .8,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40.0),
                                topLeft: Radius.circular(40.0)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.green, spreadRadius: 6),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ElevatedButton(
                                    style: CustomBS.buttonWhiteOrange,
                                    onPressed: () {
                                      _onClickLocation(
                                          filteredList[index].lokasiLatitude,
                                          filteredList[index].lokasiLongitude);
                                    },
                                    child: const Icon(Icons.location_on),
                                  ),
                                  title: ElevatedButton(
                                    style: CustomBS.buttonWhiteOrange,
                                    onPressed: () async {
                                      DocumentReference<Map<String, dynamic>>
                                          targetRef =
                                          FirebaseFirestore.instance.doc(
                                              'banksampah/${filteredList[index].id}');

                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SingleChildScrollView(
                                            child: AlertDialog(
                                              title: Text(
                                                'Bank Sampah ${filteredList[index].nama}',
                                                style: CustomBS.titleListSampah,
                                              ),
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Legalitas : ${filteredList[index].legalitas}',
                                                    style: CustomBS
                                                        .subtitleListSampah,
                                                  ),
                                                  const Divider(
                                                    thickness: 1,
                                                  ),
                                                  Text(
                                                    'Lokasi :  ${filteredList[index].lokasiLatitude}, ${filteredList[index].lokasiLongitude}',
                                                    style: CustomBS
                                                        .subtitleListSampah,
                                                  ),
                                                  const Divider(
                                                    thickness: 1,
                                                  ),
                                                  Text(
                                                    'Alamat  ${filteredList[index].alamat}',
                                                    style: CustomBS
                                                        .subtitleListSampah,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  FutureBuilder(
                                                    future: service
                                                        .getDaftarSampahBankSampah(
                                                            targetRef),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else {
                                                        // Akses hasil dari future di sini
                                                        Map<String, dynamic>
                                                            hasil =
                                                            snapshot.data;

                                                        List<Sampah>
                                                            daftarSampah =
                                                            hasil[
                                                                "daftarSampah"];
                                                        List<int> harga =
                                                            hasil["harga"];
                                                        List<String> idHasil =
                                                            hasil[
                                                                "idSampahBankSampah"];

                                                        if (daftarSampah
                                                            .isEmpty) {
                                                          return Text(
                                                              'Tidak Ada Daftar Jenis Sampah',
                                                              style: CustomBS
                                                                  .titlePurple);
                                                        }

                                                        return Column(
                                                          children: [
                                                            Text(
                                                                'Daftar Jenis Sampah',
                                                                style: CustomBS
                                                                    .titlePurple),
                                                            ListView.builder(
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  daftarSampah
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final sampah =
                                                                    daftarSampah[
                                                                        index];
                                                                final hargaB =
                                                                    harga[
                                                                        index];
                                                                final idSampahBankSampah =
                                                                    idHasil[
                                                                        index];

                                                                return Column(
                                                                  children: [
                                                                    ListTile(
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      leading:
                                                                          const Icon(
                                                                              Icons.adjust_sharp),
                                                                      title:
                                                                          Text(
                                                                        sampah
                                                                            .nama,
                                                                        style: CustomBS
                                                                            .titleDark,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        'Satuan: ${sampah.satuan}',
                                                                        style: CustomBS
                                                                            .titleDark,
                                                                      ),
                                                                      trailing: Text(
                                                                          CurrencyFormat.convertToIdr(
                                                                              hargaB,
                                                                              0),
                                                                          style:
                                                                              CustomBS.titlePurple),
                                                                    ),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          var userData =
                                                                              await getUserData();
                                                                          setState(
                                                                              () {
                                                                            idUser =
                                                                                userData['userId'] ?? '';
                                                                          });
                                                                          DocumentReference<Map<String, dynamic>>
                                                                              dataIdRef =
                                                                              FirebaseFirestore.instance.doc('sampahbanksampah/$idSampahBankSampah');
                                                                          KeranjangEstimasi dataEstimasi = KeranjangEstimasi(
                                                                              sampahbanksampahRef: dataIdRef,
                                                                              jumlah: 1,
                                                                              usersId: idUser);

                                                                          service.findDocumentByReference(
                                                                              'keranjangestimasi',
                                                                              'sampahbanksampahRef',
                                                                              dataIdRef,
                                                                              idUser,
                                                                              dataEstimasi);
                                                                        },
                                                                        child: const Text(
                                                                            'Tambah Keranjang Estimasi'))
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  style: CustomBS
                                                      .buttonWhiteOrange,
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Icon(
                                                      Icons.close_fullscreen),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(filteredList[index].nama),
                                        const Icon(Icons.arrow_forward_ios)
                                      ],
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alamat ${filteredList[index].alamat}',
                                        style: CustomBS.subtitleListSampah,
                                      ),
                                      Text(
                                        'Jarak: ${currentPosition != null ? '${(Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, filteredList[index].lokasiLatitude, filteredList[index].lokasiLongitude) / 1000).toStringAsFixed(2)} km' : '-'}',
                                        style: CustomBS.titlePurple,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      })
                ]),
              ),
            ],
          ),
        ));
  }

  Widget buildMaps() {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            mapType: mapType,
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 12),
            onMapCreated: (GoogleMapController controller) {
              if (!_googleMapController.isCompleted) {
                _googleMapController.complete(controller);
              }
            },
            markers: listData,
          ),
        ),
        const SizedBox(height: 45),
      ],
    );
  }

  void _onClickLocation(double lat, double lgn) async {
    setState(() {
      latitude = lat;
      longitude = lgn;
    });
    GoogleMapController controller = await _googleMapController.future;
    LatLng target = LatLng(latitude, longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: target, zoom: 17, bearing: 192, tilt: 55);
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(cameraPosition);
    controller.animateCamera(cameraUpdate);
  }
}
