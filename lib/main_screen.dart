import 'package:brio/monitoring_screen.dart';
import 'package:brio/pengaturan_screen.dart';
import 'package:brio/riwayat_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar semua halaman yang akan ditampilkan
  static const List<Widget> _pages = <Widget>[
    MonitoringScreen(),
    RiwayatScreen(),
    PengaturanScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state setiap halaman agar tidak reset saat berpindah
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF7266CF),
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: BottomNavigationBar(
              selectedLabelStyle: const TextStyle(
                fontSize: 12, // Reduced from default size
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12, // Reduced from default size
                fontWeight: FontWeight.w500,
              ),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // lingkaran putih saat tidak dipilih
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.grey,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF433A84), // lingkaran ungu saat dipilih
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Monitoring',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // lingkaran putih saat tidak dipilih
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.grey,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF433A84), // lingkaran ungu saat dipilih
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // lingkaran putih saat tidak dipilih
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.grey,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF433A84), // lingkaran ungu saat dipilih
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Pengaturan',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white, // Warna saat dipilih
              onTap: _onItemTapped,
              backgroundColor: Colors
                  .transparent, // Transparan agar warna container terlihat
              elevation: 0, // Hilangkan bayangan default
              type:
                  BottomNavigationBarType.fixed, // Tipe agar label tidak hilang
              showUnselectedLabels: false, // Sembunyikan label yang tidak aktif
            ),
          ),
        ),
      ),
    );
  }
}
