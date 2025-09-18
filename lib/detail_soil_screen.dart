import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brio/atur_threshold_screen.dart';

class DetailSoilScreen extends StatefulWidget {
  const DetailSoilScreen({super.key});

  @override
  _DetailSoilScreenState createState() => _DetailSoilScreenState();
}

class _DetailSoilScreenState extends State<DetailSoilScreen> {
  final String deviceId = "1000000001"; // Ganti dengan ID perangkat Anda

  // State variables for UI
  int _soilMoisture = 0;
  bool _pumpStatus = false;
  bool _isManualControl = true;
  String _lastUpdate = "--:--:--";
  List<FlSpot> _soilData = [];

  int _lowThreshold = 0;
  int _highThreshold = 0;

  late StreamSubscription<DatabaseEvent> _dataSubscription;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    final dbRef = FirebaseDatabase.instance.ref('devices/$deviceId');
    _dataSubscription = dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        final currentData = data['current'] as Map<dynamic, dynamic>?;
        final configData = data['config'] as Map<dynamic, dynamic>?;
        final historyData = data['history'] as Map<dynamic, dynamic>?;

        // Process current and config data
        if (currentData != null) {
          _soilMoisture = currentData['soilMoisture'] ?? 0;
          _pumpStatus = currentData['pumpStatus'] ?? false;
          _isManualControl = currentData['isManualControl'] ?? true;
          final lastTimestamp = currentData['timestamp'];
          if (lastTimestamp != null) {
            final dt = DateTime.fromMillisecondsSinceEpoch(
              lastTimestamp * 1000,
            );
            _lastUpdate =
                "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}-${dt.month}-${dt.year}";
          }
        }
        if (configData != null) {
          _lowThreshold = configData['lowThreshold'] ?? 30;
          _highThreshold = configData['highThreshold'] ?? 80;
        }

        // Process history for the chart
        if (historyData != null) {
          final List<FlSpot> chartData = [];
          historyData.forEach((key, value) {
            final item = value as Map<dynamic, dynamic>;
            final timestamp = (item['timestamp'] ?? 0).toDouble();
            final soil = (item['soilMoisture'] ?? 0).toDouble();
            if (timestamp > 0) {
              chartData.add(FlSpot(timestamp, soil));
            }
          });
          _soilData = chartData;
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Sensor SOIL',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14, // Reduced from 16
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSensorInfoCard('Sensor 1', _soilMoisture),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSensorInfoCard('Sensor 2', _soilMoisture),
                ), // Placeholder
              ],
            ),
            const SizedBox(height: 16),
            _buildAverageCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Grafik Sensor'),
            const SizedBox(height: 10),
            _buildChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdDisplay() {
    return Column(
      children: [
        Text(
          _isManualControl
              ? 'Threshold kelembapan tanah'
              : 'Threshold (Otomatis)',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFE883),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '↓$_lowThreshold%', // Updated threshold value
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFC042),
                fontWeight: FontWeight.bold,
                fontSize: 16, // Reduced from 18
              ),
            ),
            Text(
              '↑$_highThreshold%',
              style: GoogleFonts.poppins(
                color: const Color(0xFF95FF78), // Updated to green
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPumpStatusDisplay() {
    return Column(
      children: [
        Text(
          'Status Pompa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12), // Increased spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40, // Fixed width for icon
              child: Image.asset(
                'assets/images/pump_icon.png',
                height: 38, // Increased size
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12), // Increased spacing
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pumpStatus ? 'ON' : 'OFF',
                  style: GoogleFonts.poppins(
                    color: _pumpStatus ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced from 22
                  ),
                ),
                Text(
                  _isManualControl ? 'Manual' : 'Otomatis',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500, // Added medium weight
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4F4DAE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F4DAE).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // Added to make divider full height
        child: Row(
          children: [
            Expanded(child: _buildThresholdDisplay()),
            const VerticalDivider(
              // Updated divider
              color: Colors.white24,
              thickness: 1,
              width: 32, // Increased spacing around divider
            ),
            Expanded(child: _buildPumpStatusDisplay()),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorInfoCard(String title, int value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D51BC).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF978AF4), Color(0xFF786CD3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Reduced from 14
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/soil_icon.png',
                  height: 14, // Reduced from 16
                  width: 14, // Reduced from 16
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                const Text(
                  'SOIL',
                  style: TextStyle(
                    color: Color(
                      0xFFFFE883,
                    ), // Changed from Colors.white to yellow
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // Reduced from 12
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center align items vertically
              children: [
                SvgPicture.asset(
                  'assets/icons/soil_icon.svg',
                  height: 36, // Reduced from 40
                  width: 36, // Reduced from 40
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF4F4DAE), // Changed from 0xFF978AF4 to 0xFF4F4DAE
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 10), // Reduced from 12
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center content vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 2,
                        ), // Add small space between texts
                        child: Text(
                          'Kelembapan tanah',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF4E4E4E),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        '$value%',
                        style: GoogleFonts.poppins(
                          fontSize: 28, // Keep this size for readability
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D51BC).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6A68D4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/soil_icon.png', // Changed to soil_icon.png
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'RATA-RATA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Reduced from 14
                  ),
                ),
                const Spacer(),
                Text(
                  _lastUpdate,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11, // Reduced from 12
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/soil_icon.svg',
                  height: 45,
                  width: 45,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF6A68D4),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Rata-rata\nKelembapan Tanah',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4F4DAE),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_soilMoisture.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13, // Reduced from 18
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D51BC).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F4DAE),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 20,
                ), // Added chart icon
                const SizedBox(width: 8),
                Text(
                  'GRAFIK KELEMBAPAN TANAH',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Reduced from 14
                  ),
                ),
              ],
            ),
          ),
          // Chart
          Container(
            padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
            height: 300, // Fixed height for better proportion
            child: _soilData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LineChart(soilChart()),
          ),
        ],
      ),
    );
  }

  LineChartData soilChart() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            interval: 20,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${value.toInt()}%',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.grey.withOpacity(0.2)),
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      minX: _soilData.first.x,
      maxX: _soilData.last.x,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: _soilData,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Color(0xFF8D8AFF), Color(0xFF4F4DAE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF4F4DAE),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8D8AFF).withOpacity(0.2),
                const Color(0xFF4F4DAE).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
