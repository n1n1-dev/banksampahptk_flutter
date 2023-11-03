import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/map_type.dart';
import 'package:lottie/lottie.dart';
import '../../constant/constant.dart';
import 'banksampah_form.dart';

class MapsPage extends StatefulWidget {
  final String? statusState;
  final DocumentSnapshot? dataId;
  const MapsPage({super.key, this.statusState, this.dataId});

  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  var mapType = MapType.normal;
  CameraPosition? _cameraPosition;
  Position? devicePosition;
  late LatLng _defaultLatLng;
  late LatLng _draggedLatlng;
  String _draggedAddress = "";
  double _lat = 0;
  double _long = 0;
  String address = "";

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    //lokasi default lat long kamera
    _defaultLatLng = const LatLng(-0.0352231, 109.331888);
    _draggedLatlng = _defaultLatLng;
    _lat = _defaultLatLng.latitude;
    _long = _defaultLatLng.longitude;
    _cameraPosition = CameraPosition(target: _defaultLatLng, zoom: 12);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position?> getCurrentLocation() async {
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _getAddress(LatLng(currentPosition.latitude, currentPosition.longitude));
    } catch (e) {
      currentPosition = null;
      Fluttertoast.showToast(msg: "Lokasi perangkat belum diaktifkan");
    }
    return currentPosition;
  }

  void onSelectedMapType(Type value) {
    setState(() {
      switch (value) {
        case Type.Normal:
          // TYPE NORMAL
          mapType = MapType.normal;
          break;
        case Type.Hybrid:
          // TYPE HYBRID
          mapType = MapType.hybrid;
          break;
        case Type.Terrain:
          // TYPE TERRAIN
          mapType = MapType.terrain;
          break;
        case Type.Satellite:
          // TYPE SATELLITE
          mapType = MapType.satellite;
          break;
        default:
      }
    });
  }

  Future _getAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark address = placemarks[0];
    String addresStr =
        "${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}, ${address.postalCode}";
    setState(() {
      _draggedAddress = addresStr;
      _lat = position.latitude;
      _long = position.longitude;
    });
  }

  Future searchLocation() async {
    try {
      await GeocodingPlatform.instance
          .locationFromAddress(address)
          .then((value) async {
        GoogleMapController controller = await _googleMapController.future;
        LatLng target = LatLng(value[0].latitude, value[0].longitude);
        CameraPosition cameraPosition =
            CameraPosition(target: target, zoom: 17);
        CameraUpdate cameraUpdate =
            CameraUpdate.newCameraPosition(cameraPosition);
        controller.animateCamera(cameraUpdate);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Lokasi tidak di temukan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Google Maps"),
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
      body: Stack(
        children: [buildMaps(), _getCustomPin(), _cardAddress()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          getCurrentLocation().then((position) async {
            setState(() {
              devicePosition = position;
            });
            if (devicePosition == null) return;
            GoogleMapController controller = await _googleMapController.future;
            LatLng target = LatLng(position!.latitude, position.longitude);
            CameraPosition cameraPosition =
                CameraPosition(target: target, zoom: 17);
            CameraUpdate cameraUpdate =
                CameraUpdate.newCameraPosition(cameraPosition);
            controller.animateCamera(cameraUpdate);
          });
        },
        splashColor: Colors.amber,
        label: const Row(
          children: [
            Icon(Icons.gps_fixed),
            SizedBox(width: 5),
            Text('Lokasi Saat Ini')
          ],
        ),
      ),
    );
  }

  Widget buildMaps() {
    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: _cameraPosition!,
      onCameraIdle: () {
        _getAddress(_draggedLatlng);
      },
      onCameraMove: (cameraPosition) {
        _draggedLatlng = cameraPosition.target;
      },
      onMapCreated: (GoogleMapController controller) {
        if (!_googleMapController.isCompleted) {
          _googleMapController.complete(controller);
        }
      },
    );
  }

  Widget _getCustomPin() {
    return Center(
      child: SizedBox(
        width: 150,
        child: Lottie.asset("assets/images/pin.json"),
      ),
    );
  }

  Widget _cardAddress() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 3.5,
        width: double.infinity,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // field pencarian
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 4),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Masukkan alamat...',
                        contentPadding:
                            const EdgeInsets.only(left: 15, top: 15),
                        suffixIcon: IconButton(
                          onPressed: searchLocation,
                          icon: const Icon(Icons.search),
                        )),
                    onChanged: (value) {
                      address = value;
                    },
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alamat Pin',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Latitude: $_lat',
                          style: CustomBS.titleDark,
                        ),
                        Text(
                          'Longitude: $_long',
                          style: CustomBS.titleDark,
                        ),
                        Text(
                          _draggedAddress,
                          style: CustomBS.titleDark,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BankSampahForm(
                                          lokasipeta: _draggedAddress,
                                          statusState: widget.statusState,
                                          dataId: widget.dataId,
                                          lat: _lat,
                                          long: _long)));
                            },
                            child: const Text("Ambil Lokasi")),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
