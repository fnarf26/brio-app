import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'atur_threshold_screen.dart';
import 'profil_screen.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16, // Reduced from 16 to 14 to match monitoring
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 16.0,
        ), // Adjusted padding
        child: Column(
          children: [
            const SizedBox(height: 8), // Reduced spacing
            _buildSettingItem(
              context: context,
              icon: Icons.person_outline_rounded,
              text: 'Profil',
              gradientColors: [
                const Color(0xFF8D8AFF),
                const Color(0xFF4F4DAE),
              ],
              onTap: () {
                // Navigasi ke halaman profil
              },
            ),
            const SizedBox(height: 12), // Reduced spacing
            _buildSettingItem(
              context: context,
              icon: Icons.sensors_rounded,
              text: 'Atur Threshold',
              gradientColors: [
                const Color(0xFF8D8AFF),
                const Color(0xFF4F4DAE),
              ],
              onTap: () {
                // Navigasi ke halaman atur threshold
              },
            ),
            const SizedBox(height: 12), // Reduced spacing
            _buildSettingItem(
              context: context,
              icon: Icons.logout_rounded,
              text: 'Logout',
              gradientColors: [
                const Color(0xFFF07167),
                const Color(0xFFD90429),
              ],
              onTap: () {
                // Logika untuk logout
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    double iconSize = 30,
  }) {
    return GestureDetector(
      onTap: () {
        if (text == 'Atur Threshold') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AturThresholdScreen(),
            ),
          );
        } else if (text == 'Profil') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilScreen()),
          );
        } else {
          onTap(); // Call the provided onTap for other items
        }
      },
      child: Container(
        height: 65, // Reduced from 80 to 65
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3), // Reduced opacity
              blurRadius: 8, // Reduced blur
              offset: const Offset(0, 4), // Reduced offset
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20), // Reduced from 24 to 20
            if (text == 'Atur Threshold')
              Padding(
                padding: const EdgeInsets.all(1.5), // Reduced from 8 to 6
                child: Image.asset(
                  'assets/images/soil_icon.png',
                  color: Colors.white,
                  height: iconSize, // Reduced from 24 to 22
                  width: iconSize, // Reduced from 24 to 22
                ),
              )
            else
              Icon(
                icon,
                color: Colors.white,
                size: iconSize, // Reduced from 24 to 22
              ),
            const SizedBox(width: 12), // Reduced from 16 to 12
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              width: 60, // Reduced from 70 to 60
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12), // Reduced opacity
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16), // Reduced from 20 to 16
                  bottomRight: Radius.circular(16), // Reduced from 20 to 16
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18, // Reduced from 20 to 18
              ),
            ),
          ],
        ),
      ),
    );
  }
}
