import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AturThresholdScreen extends StatefulWidget {
  const AturThresholdScreen({super.key});

  @override
  _AturThresholdScreenState createState() => _AturThresholdScreenState();
}

class _AturThresholdScreenState extends State<AturThresholdScreen> {
  final String deviceId = "1000000001";
  late DatabaseReference _configRef;

  // Controllers for text fields
  final TextEditingController _lowController = TextEditingController();
  final TextEditingController _highController = TextEditingController();

  // State variables
  int _currentLow = 30;
  int _currentHigh = 80;
  late StreamSubscription<DatabaseEvent> _configSubscription;

  @override
  void initState() {
    super.initState();
    _configRef = FirebaseDatabase.instance.ref('devices/$deviceId/config');
    _activateListeners();
  }

  void _activateListeners() {
    _configSubscription = _configRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        setState(() {
          _currentLow = data['lowThreshold'] ?? 0;
          _currentHigh = data['highThreshold'] ?? 0;
          // Set initial text for controllers
          _lowController.text = _currentLow.toString();
          _highController.text = _currentHigh.toString();
        });
      }
    });
  }

  Future<void> _updateThreshold() async {
    final int? newLow = int.tryParse(_lowController.text);
    final int? newHigh = int.tryParse(_highController.text);

    if (newLow != null && newHigh != null) {
      if (newLow >= newHigh) {
        // Show error if low is greater than or equal to high
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Batas minimal harus lebih kecil dari batas maksimal!',
            ),
          ),
        );
        return;
      }

       setState(() {
        // Update nilai di UI
        _currentLow = newLow;
        _currentHigh = newHigh;

        // Update controller juga
        _lowController.text = _currentLow.toString();
        _highController.text = _currentHigh.toString();
      });

      try {
        // Update ke Firebase
        await _configRef.update({
          'lowThreshold': _currentLow,
          'highThreshold': _currentHigh,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Threshold berhasil diperbarui!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan ke Firebase: $e')),
        );
      }

      FocusScope.of(context).unfocus(); // Close keyboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon masukkan angka yang valid!')),
      );
    }
  }

  void _resetFields() {
    setState(() {
      _currentLow = 0; // atau 30 kalau mau default 30
      _currentHigh = 0; // atau 80 kalau mau default 80
      _lowController.text = _currentLow.toString();
      _highController.text = _currentHigh.toString();
    });
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  @override
  void dispose() {
    _configSubscription.cancel();
    _lowController.dispose();
    _highController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pengaturan Threshold',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14, // Reduced from 16 to 14
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 16.0,
        ), // Reduced vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentThresholdCard(),
            const SizedBox(height: 24), // Reduced from 32
            Text(
              'Atur batas nilai threshold',
              style: GoogleFonts.poppins(
                fontSize: 16, // Reduced from 18 to 13
                fontWeight: FontWeight.bold,
                color: Colors.black, // Changed to match monitoring style
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            _buildInputField(
              label: 'Low',
              icon: Icons.arrow_downward,
              hint: '30',
              controller: _lowController,
              sliderColor: const Color(0xFFFFC042),
              value: _currentLow.toDouble(),
              onChanged: (value) {
                setState(() {
                  _currentLow = value.round();
                });
              },
            ),
            const SizedBox(height: 12), // Reduced from 16
            _buildInputField(
              label: 'High',
              icon: Icons.arrow_upward,
              hint: '80',
              controller: _highController,
              sliderColor: const Color(0xFF95FF78),
              value: _currentHigh.toDouble(),
              onChanged: (value) {
                setState(() {
                  _currentHigh = value.round();
                });
              },
            ),
            const SizedBox(height: 24), // Reduced from 32
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    'ATUR',
                    const Color(0xFF5347AD),
                    Colors.white,
                    _updateThreshold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildButton(
                    'RESET',
                    const Color(0xFFFFC107),
                    Colors.black87,
                    _resetFields,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentThresholdCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D51BC).withOpacity(0.1),
            blurRadius: 15, // Reduced from 20
            offset: const Offset(0, 8), // Reduced from 10
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ), // Reduced padding
            decoration: BoxDecoration(
              color: const Color(0xFF5347AD),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), // Reduced from 20
                topRight: Radius.circular(16), // Reduced from 20
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/soil_icon.svg',
                  height: 27,
                  width: 27,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Threshold Kelembapan Tanah',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Reduced from 16 to 13
                  ),
                ),
              ],
            ),
          ),
          // Content
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 14,
            ), // Reduced padding
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF786CD3), Color(0xFF978AF4)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Low threshold
                Column(
                  children: [
                    Text(
                      'Low',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20, // Reduced from 16 to 13
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: const Color(0xFFFFC042),
                          size: 42, // Increased from 24 to 42
                        ),
                        Text(
                          '$_currentLow%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFC042),
                            fontSize:
                                36, // Reduced from 42 to 36 to match monitoring
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Divider
                Container(
                  width: 3,
                  height: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                // High threshold
                Column(
                  children: [
                    Text(
                      'High',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20, // Reduced from 16 to 13
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: const Color(0xFF95FF78),
                          size: 42, // Increased from 24 to 42
                        ),
                        Text(
                          '$_currentHigh%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF95FF78),
                            fontSize:
                                36, // Reduced from 42 to 36 to match monitoring
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required Color sliderColor,
    required double value,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ), // Reduced padding
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF786CD3), Color(0xFF978AF4)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10), // Reduced from 12
          ),
          child: Row(
            children: [
              Icon(icon, color: sliderColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // Reduced from 16 to 13
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Reduced from 12
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8, // Reduced from 10
                offset: const Offset(0, 3), // Reduced from 4
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    fontSize: 20, // Reduced from 24 to 20
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintText: hint,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      onChanged(double.parse(value));
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit,
                  color: const Color(0xFF8D8AFF),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: sliderColor,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: sliderColor,
            overlayColor: sliderColor.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: (newValue) {
              onChanged(newValue);
              controller.text = newValue.round().toString();
            },
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
        padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 16
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Reduced from 12
        elevation: 4, // Reduced from 5
        shadowColor: bgColor.withOpacity(0.3), // Reduced opacity
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13, // Reduced from 16 to 13
        ),
      ),
    );
  }
}
