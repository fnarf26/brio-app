import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({Key? key}) : super(key: key);

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _namaController = TextEditingController(text: 'Jonny');
  final _emailController = TextEditingController(text: 'jonny23@gmail.com');

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
        child: Column(
          children: [
            _buildProfilePicture(),
            const SizedBox(height: 28),
            _buildTextField(label: 'Nama', controller: _namaController),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  readOnly: true,
                ),
                const SizedBox(
                  height: 14,
                ), // Tambahkan jarak agar tidak terlalu mepet
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: Text(
                      'Reset Password',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF5347AD),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    'SIMPAN',
                    const Color(0xFF4F4DAE),
                    Colors.white,
                    () {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildButton(
                    'BATAL',
                    const Color(0xFFD90429), // Ganti warna merah sesuai Logout
                    Colors.white,
                    () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: const Color(0xFF8D8AFF).withOpacity(0.8),
          child: const Icon(Icons.person, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          child: Text(
            'Ubah foto profil',
            style: GoogleFonts.poppins(
              color: const Color(0xFF5347AD),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: readOnly
                ? null
                : const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF8D8AFF),
                    size: 20,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F4DAE), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: bgColor.withOpacity(0.15),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
