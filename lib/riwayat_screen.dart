import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Enum untuk filter waktu
enum TimeFilter { jam1, jam12, jam24 }

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final String deviceId = "C44F337F3A58";
  late StreamSubscription<DatabaseEvent> _historySubscription;

  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];

  // State untuk grafik
  List<FlSpot> _suhuSpots = [];
  List<FlSpot> _lembapSpots = [];
  List<FlSpot> _soilSpots = [];

  // State untuk filter
  TimeFilter _selectedFilter = TimeFilter.jam24;
  bool _showSuhu = true;
  bool _showLembap = true;
  bool _showSoil = true;

  // State untuk filter tanggal
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    final dbRef = FirebaseDatabase.instance
        .ref('devices/$deviceId/history')
        .limitToLast(1500);
    _historySubscription = dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        final List<Map<String, dynamic>> loadedHistory = [];
        data.forEach((key, value) {
          final item = value as Map<dynamic, dynamic>;
          loadedHistory.add({
            'soil': item['soilMoisture'] ?? 0,
            'temperature': item['temperature'] ?? 0.0,
            'humidity': item['humidity'] ?? 0.0,
            'timestamp': item['timestamp'] ?? 0,
          });
        });
        loadedHistory.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        setState(() {
          _allHistory = loadedHistory;
          _applyFilter();
        });
      }
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    Duration duration;
    switch (_selectedFilter) {
      case TimeFilter.jam1:
        duration = const Duration(hours: 1);
        break;
      case TimeFilter.jam12:
        duration = const Duration(hours: 12);
        break;
      case TimeFilter.jam24:
        duration = const Duration(hours: 24);
        break;
    }
    final cutOffTime = now.subtract(duration).millisecondsSinceEpoch ~/ 1000;

    _filteredHistory = _allHistory
        .where((log) => log['timestamp'] >= cutOffTime)
        .toList();

    _suhuSpots = _filteredHistory
        .map(
          (log) => FlSpot(
            log['timestamp'].toDouble(),
            log['temperature'].toDouble(),
          ),
        )
        .toList();
    _lembapSpots = _filteredHistory
        .map(
          (log) =>
              FlSpot(log['timestamp'].toDouble(), log['humidity'].toDouble()),
        )
        .toList();
    _soilSpots = _filteredHistory
        .map(
          (log) => FlSpot(log['timestamp'].toDouble(), log['soil'].toDouble()),
        )
        .toList();

    if (mounted) {
      setState(() {});
    }
  }

  void _applyDateFilter() {
    if (_selectedDate == null) {
      _applyFilter();
      return;
    }
    final startOfDay =
        DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        ).millisecondsSinceEpoch ~/
        1000;
    final endOfDay =
        DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch ~/
        1000;

    _filteredHistory = _allHistory
        .where(
          (log) =>
              log['timestamp'] >= startOfDay && log['timestamp'] <= endOfDay,
        )
        .toList();

    _suhuSpots = _filteredHistory
        .map(
          (log) => FlSpot(
            log['timestamp'].toDouble(),
            log['temperature'].toDouble(),
          ),
        )
        .toList();
    _lembapSpots = _filteredHistory
        .map(
          (log) =>
              FlSpot(log['timestamp'].toDouble(), log['humidity'].toDouble()),
        )
        .toList();
    _soilSpots = _filteredHistory
        .map(
          (log) => FlSpot(log['timestamp'].toDouble(), log['soil'].toDouble()),
        )
        .toList();

    setState(() {});
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
        backgroundColor: const Color(0xFFF4F7FE),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Riwayat',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildChartCard(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Riwayat Sensor',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildHistoryListCard(),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Teks kiri
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF5347AD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Grafik Sensor',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Baris filter waktu & filter grafik
                Row(
                  children: [
                    // Filter waktu (ActionChip dengan icon)
                    PopupMenuButton<TimeFilter>(
                      onSelected: (val) {
                        setState(() {
                          _selectedFilter = val;
                          _applyFilter();
                        });
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: TimeFilter.jam1,
                          child: Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                color: Color(0xFF5347AD),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('1 Jam'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: TimeFilter.jam12,
                          child: Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                color: Color(0xFF5347AD),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('12 Jam'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: TimeFilter.jam24,
                          child: Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                color: Color(0xFF5347AD),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('24 Jam'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5347AD).withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF5347AD),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedFilter == TimeFilter.jam1
                                  ? '1 Jam'
                                  : _selectedFilter == TimeFilter.jam12
                                  ? '12 Jam'
                                  : '24 Jam',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5347AD),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF5347AD),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter grafik sensor (PopupMenuButton)
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        setState(() {
                          _showSuhu = val == 'Suhu' || val == 'Semua';
                          _showLembap = val == 'Kelembapan' || val == 'Semua';
                          _showSoil = val == 'Soil' || val == 'Semua';
                        });
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Suhu',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.thermostat,
                                color: Colors.orange,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Suhu'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Kelembapan',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.water_drop,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Kelembapan'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Soil',
                          child: Row(
                            children: const [
                              Icon(Icons.grass, color: Colors.blue, size: 18),
                              SizedBox(width: 8),
                              Text('Soil'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Semua',
                          child: Row(
                            children: [
                              Icon(
                                Icons.select_all,
                                color: Color(0xFF5347AD),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Semua'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5347AD).withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showSuhu && _showLembap && _showSoil
                                  ? Icons.select_all
                                  : _showSuhu
                                  ? Icons.thermostat
                                  : _showLembap
                                  ? Icons.water_drop
                                  : Icons.grass,
                              color: _showSuhu && _showLembap && _showSoil
                                  ? const Color(0xFF5347AD)
                                  : _showSuhu
                                  ? Colors.orange
                                  : _showLembap
                                  ? Colors.red
                                  : Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showSuhu && _showLembap && _showSoil
                                  ? 'Semua'
                                  : _showSuhu
                                  ? 'Suhu'
                                  : _showLembap
                                  ? 'Kelembapan'
                                  : 'Soil',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5347AD),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF5347AD),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1.5,
                  child:
                      _suhuSpots.isEmpty &&
                          _lembapSpots.isEmpty &&
                          _soilSpots.isEmpty
                      ? Center(
                          child: Text(
                            "Tidak ada data untuk ditampilkan",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF5347AD),
                            ),
                          ),
                        )
                      : LineChart(_mainChart()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryListCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E5FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF6B4CC7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Sensor',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Filter tanggal button
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF6B4CC7),
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _applyDateFilter();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedDate == null
                              ? 'Filter Tanggal'
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        if (_selectedDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = null;
                                _applyDateFilter();
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          (_filteredHistory.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Belum ada data riwayat sensor.',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredHistory.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final history = _filteredHistory[index];
                    final logTime = DateTime.fromMillisecondsSinceEpoch(
                      history['timestamp'] * 1000,
                    );
                    final formattedTime = DateFormat(
                      'HH:mm dd-MM-yy',
                    ).format(logTime);

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Suhu: ${history['temperature']}°C, '
                                'Kelembapan: ${history['humidity']}%, '
                                'Soil: ${history['soil']}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedTime,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  LineChartData _mainChart() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 50,
          ),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        if (_showSuhu) _buildLineBarData(_suhuSpots, Colors.orange),
        if (_showLembap) _buildLineBarData(_lembapSpots, Colors.red),
        if (_showSoil) _buildLineBarData(_soilSpots, Colors.blue),
      ],
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
