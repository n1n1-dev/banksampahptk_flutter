import 'package:flutter/material.dart';
import '../constant/constant.dart';
import '../auth/auth_services.dart';
import '../pages/sampahbanksampah/sampahbanksampah_list.dart';
import '../pages/sampah/sampah_list.dart';
import '../pages/users/users_page.dart';
import 'home_page.dart';
import 'keranjang_estimasi_page.dart';
import 'mapsuser_page.dart';
import 'settings_page.dart';
import '../pages/banksampah/banksampah_list.dart';

class HomeRoutePage extends StatefulWidget {
  final int selected;
  const HomeRoutePage({super.key, required this.selected});

  @override
  State<HomeRoutePage> createState() => _HomeRoutePageState();
}

class _HomeRoutePageState extends State<HomeRoutePage> {
  int selectedIndex = 0;
  final widgetSuperAdmin = [
    const HomePage(),
    const MapsUserPage(),
    const UsersPage(),
    const BankSampahList(),
    const SampahList(),
    const SettingsPage(),
  ];

  final widgetAdmin = [
    const HomePage(),
    const SampahBankSampahList(),
    const SettingsPage(),
  ];

  final widgetNasabah = [
    const HomePage(),
    const MapsUserPage(),
    const KeranjangEstimasiPage(),
    const SettingsPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Indikator loading jika Future masih berjalan.
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Tampilkan pesan error jika ada kesalahan.
        } else if (snapshot.hasData) {
          final userData =
              snapshot.data!; // Data pengguna yang diterima dari Future.

          if (userData['rules'] == 'superadmin') {
            return Scaffold(
                body: widgetSuperAdmin.elementAt(selectedIndex),
                bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.home,
                          color: lPrimaryColor,
                        ),
                        label: 'Beranda'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.map,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.map,
                          color: lPrimaryColor,
                        ),
                        label: "Bank Sampah"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.supervised_user_circle,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.supervised_user_circle,
                          color: lPrimaryColor,
                        ),
                        label: "Users"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.comment_bank_sharp,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.comment_bank_sharp,
                          color: lPrimaryColor,
                        ),
                        label: "Bank Sampah"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.list_alt_rounded,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.list_alt_rounded,
                          color: lPrimaryColor,
                        ),
                        label: "Daftar Sampah"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.manage_accounts,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.manage_accounts,
                          color: lPrimaryColor,
                        ),
                        label: "Pengaturan")
                  ],
                  currentIndex: selectedIndex,
                  onTap: onItemTapped,
                  fixedColor: tlPrimaryColor,
                  selectedLabelStyle:
                      const TextStyle(color: tlPrimaryColor, fontSize: 10),
                  unselectedLabelStyle:
                      const TextStyle(color: pPrimaryColor, fontSize: 10),
                ));
          } else if (userData['rules'] == 'admin') {
            return Scaffold(
                body: widgetAdmin.elementAt(selectedIndex),
                bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.home,
                          color: lPrimaryColor,
                        ),
                        label: 'Beranda'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.list_alt_rounded,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.list_alt_rounded,
                          color: lPrimaryColor,
                        ),
                        label: "Daftar Sampah"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.manage_accounts,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.manage_accounts,
                          color: lPrimaryColor,
                        ),
                        label: "Pengaturan")
                  ],
                  currentIndex: selectedIndex,
                  onTap: onItemTapped,
                  fixedColor: tlPrimaryColor,
                  selectedLabelStyle:
                      const TextStyle(color: tlPrimaryColor, fontSize: 10),
                  unselectedLabelStyle:
                      const TextStyle(color: pPrimaryColor, fontSize: 10),
                ));
          } else if (userData['rules'] == 'nasabah') {
            return Scaffold(
                body: widgetNasabah.elementAt(selectedIndex),
                bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.home,
                          color: lPrimaryColor,
                        ),
                        label: 'Beranda'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.map,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.map,
                          color: lPrimaryColor,
                        ),
                        label: "Bank Sampah"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.wallet_rounded,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.wallet_rounded,
                          color: lPrimaryColor,
                        ),
                        label: "Keranjang Estimasi"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.manage_accounts,
                          color: dlPrimaryColor,
                        ),
                        activeIcon: Icon(
                          Icons.manage_accounts,
                          color: lPrimaryColor,
                        ),
                        label: "Pengaturan")
                  ],
                  currentIndex: selectedIndex,
                  onTap: onItemTapped,
                  fixedColor: tlPrimaryColor,
                  selectedLabelStyle:
                      const TextStyle(color: tlPrimaryColor, fontSize: 10),
                  unselectedLabelStyle:
                      const TextStyle(color: pPrimaryColor, fontSize: 10),
                ));
          }
          return const Center(child: Text('User tidak ditemukan'));
        } else {
          return const Center(
            child: Text('User tidak ditemukan'),
          ); // Tampilkan pesan jika user tidak ditemukan.
        }
      },
    ));
  }
}
