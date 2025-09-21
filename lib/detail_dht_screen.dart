import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailDhtScreen extends StatefulWidget {
  const DetailDhtScreen({super.key});

  @override
  _DetailDhtScreenState createState() => _DetailDhtScreenState();
}

class _DetailDhtScreenState extends State<DetailDhtScreen> {
  final String deviceId = "1000000001"; // Ganti dengan ID perangkat Anda
  bool _showTemperatureChart = true;

  List<FlSpot> _temperatureData = [];
  List<FlSpot> _humidityData = [];

  double _avgTemp = 0.0;
  double _avgHum = 0.0;
  String _lastUpdate = "--:--:--";

  late StreamSubscription<DatabaseEvent> _historySubscription;

  // Add this variable to track sensor status
  bool isSensorActive =
      true; // You should update this based on your sensor data

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    final dbRef = FirebaseDatabase.instance.ref('devices/$deviceId/history');
    _historySubscription = dbRef.limitToLast(20).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        final List<FlSpot> tempData = [];
        final List<FlSpot> humData = [];
        double totalTemp = 0;
        double totalHum = 0;
        int count = 0;

        data.forEach((key, value) {
          final item = value as Map<dynamic, dynamic>;
          final timestamp = (item['timestamp'] ?? 0).toDouble();
          final temp = (item['temperature'] ?? 0.0).toDouble();
          final hum = (item['humidity'] ?? 0.0).toDouble();

          if (timestamp > 0) {
            tempData.add(FlSpot(timestamp, temp));
            humData.add(FlSpot(timestamp, hum));
            totalTemp += temp;
            totalHum += hum;
            count++;
          }
        });

        if (count > 0) {
          final dt = DateTime.now(); // waktu saat ini perangkat
          _lastUpdate =
              "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} "
              "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
        }


        setState(() {
          _temperatureData = tempData;
          _humidityData = humData;
          _avgTemp = count > 0 ? totalTemp / count : 0;
          _avgHum = count > 0 ? totalHum / count : 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _historySubscription.cancel();
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
          'Detail Sensor DHT22',
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
            // Untuk saat ini, kita tampilkan rata-rata sebagai Sensor 1 & 2
            _buildSensorInfoCard('Sensor 1', _avgTemp, _avgHum),
            const SizedBox(height: 16),
            _buildSensorInfoCard(
              'Sensor 2',
              _avgTemp,
              _avgHum,
            ), // Ganti dengan data sensor 2 jika ada
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

  Widget _buildSensorInfoCard(String title, double temp, double hum) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF8A64D6,
            ).withOpacity(0.1), // Warna shadow mengikuti tema baru
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10), // Shadow lebih ke bawah
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 3), // Shadow tambahan untuk efek kedalaman
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ), // Reduced vertical padding from 12
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8A64D6), Color(0xFF6A4C9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A64D6).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSensorActive
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFF5252),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isSensorActive
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFFF5252))
                                .withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Reduced from 16
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Remove the border
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sensors,
                        color: Colors.white.withOpacity(0.9),
                        size: 14, // Reduced from 16
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DHT22',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFFE883), // Changed to yellow
                          fontWeight: FontWeight.bold, // Made bold
                          fontSize: 12, // Reduced from 14
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14), // Reduced from 16
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suhu',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 12, // Reduced from 14
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.thermostat,
                            color: Color(0xFF978AF4),
                            size: 28, // Reduced from 32
                          ),
                          const SizedBox(width: 8),
                          Text(
                            temp.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 28, // Reduced from 32
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              ' °C',
                              style: GoogleFonts.poppins(
                                fontSize: 16, // Reduced from 20
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelembapan',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 12, // Reduced from 14
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Color(0xFF978AF4),
                            size: 28, // Reduced from 32
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hum.toStringAsFixed(0),
                            style: GoogleFonts.poppins(
                              fontSize: 28, // Reduced from 32
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              ' %',
                              style: GoogleFonts.poppins(
                                fontSize: 16, // Reduced from 20
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
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
            color: const Color(
              0xFF5D51BC,
            ).withOpacity(0.1), // Warna shadow mengikuti tema
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10), // Shadow lebih ke bawah
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 3), // Shadow tambahan untuk efek kedalaman
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D51BC), Color(0xFF5044AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'RATA-RATA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Reduced from 16
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suhu',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 12, // Reduced from 14
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.thermostat,
                            color: Color(0xFF978AF4),
                            size: 28, // Reduced from 32
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _avgTemp.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 28, // Reduced from 32
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              ' °C',
                              style: GoogleFonts.poppins(
                                fontSize: 16, // Reduced from 20
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelembapan',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 12, // Reduced from 14
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Color(0xFF978AF4),
                            size: 28, // Reduced from 32
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _avgHum.toStringAsFixed(0),
                            style: GoogleFonts.poppins(
                              fontSize: 28, // Reduced from 32
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              ' %',
                              style: GoogleFonts.poppins(
                                fontSize: 16, // Reduced from 20
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildChartSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF5D51BC,
            ).withOpacity(0.1), // Warna shadow mengikuti tema
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10), // Shadow lebih ke bawah
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 3), // Shadow tambahan untuk efek kedalaman
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D51BC), Color(0xFF5044AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Grafik Sensor',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Reduced from 16
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildChartToggle(
                        'Suhu',
                        _showTemperatureChart,
                        () => setState(() => _showTemperatureChart = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildChartToggle(
                        'Kelembapan',
                        !_showTemperatureChart,
                        () => setState(() => _showTemperatureChart = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 24, 24, 12),
                    child: _temperatureData.isEmpty || _humidityData.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : LineChart(
                            _showTemperatureChart
                                ? temperatureChart()
                                : humidityChart(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8A64D6), Color(0xFF6A4C9C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFFF4F7FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF8A64D6),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : const Color(0xFF8A64D6),
              fontWeight: FontWeight.w600,
              fontSize: 12, // Reduced from 14
            ),
          ),
        ),
      ),
    );
  }

  // --- GRAFIK ---

  LineChartData temperatureChart() {
    // normalisasi data: negatif → 0
    final normalizedSpots = _temperatureData
        .map((e) => FlSpot(e.x, e.y < 0 ? 0.0 : e.y))
        .toList();

    if (normalizedSpots.isEmpty) {
      return LineChartData(
        lineBarsData: [],
        minY: 0,
        maxY: 10,
        titlesData: FlTitlesData(show: false),
      );
    }

    // cari max Y dan bulatkan ke kelipatan 5
    final rawMaxY = normalizedSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);
    final interval = 5.0;
    final roundedMaxY = ((rawMaxY / interval).ceil()) * interval;

    return LineChartData(
      minY: 0,
      maxY: roundedMaxY,
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}°C',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: normalizedSpots,
          isCurved: true,
          color: const Color(0xFF5D51BC),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: const Color(0xFF5D51BC),
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5D51BC).withOpacity(0.2),
                const Color(0xFF5044AA).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData humidityChart() {
    // normalisasi data: negatif → 0
    final normalizedSpots = _humidityData
        .map((e) => FlSpot(e.x, e.y < 0 ? 0.0 : e.y))
        .toList();

    if (normalizedSpots.isEmpty) {
      return LineChartData(
        lineBarsData: [],
        minY: 0,
        maxY: 10,
        titlesData: FlTitlesData(show: false),
      );
    }

    // cari max Y dan bulatkan ke kelipatan 10
    final rawMaxY = normalizedSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);
    final interval = 10.0;
    final roundedMaxY = ((rawMaxY / interval).ceil()) * interval;

    final gradient = LinearGradient(
      colors: [
        const Color(0xFF5D51BC).withOpacity(0.8), // garis utama tegas
        const Color(
          0xFF5044AA,
        ).withOpacity(0.2), // gradient bawah tetap terlihat
      ],

      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return LineChartData(
      minY: 0,
      maxY: roundedMaxY,
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}%',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: normalizedSpots,
          isCurved: true,
          gradient: gradient,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true, // tampilkan lingkaran
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFF5D51BC),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5D51BC).withOpacity(0.5),
                const Color(0xFF5044AA).withOpacity(0.0),
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
