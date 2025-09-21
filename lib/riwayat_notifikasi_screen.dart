import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

// Enum untuk status filter
enum FilterStatus { semua, on, off }

class RiwayatNotifikasiScreen extends StatefulWidget {
  const RiwayatNotifikasiScreen({super.key});

  @override
  _RiwayatNotifikasiScreenState createState() =>
      _RiwayatNotifikasiScreenState();
}

class _RiwayatNotifikasiScreenState extends State<RiwayatNotifikasiScreen> {
  final String deviceId = "1000000001"; // Ganti dengan device ID yang sesuai
  late StreamSubscription<DatabaseEvent> _logsSubscription;

  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];

  // State untuk filter
  DateTime? _selectedDate;
  FilterStatus _selectedStatus = FilterStatus.semua;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    final dbRef = FirebaseDatabase.instance.ref('devices/$deviceId/pump_logs');
    _logsSubscription = dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        final List<Map<String, dynamic>> loadedLogs = [];
        data.forEach((key, value) {
          final item = value as Map<dynamic, dynamic>;
          loadedLogs.add({
            'soil': item['soil'] ?? 0,
            'action': item['action'] ?? 'UNKNOWN',
            'timestamp': item['timestamp'] ?? 0,
          });
        });
        // Urutkan dari yang terbaru
        loadedLogs.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        setState(() {
          _allLogs = loadedLogs;
          _applyFilters(); // Terapkan filter saat data baru masuk
        });
      }
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> tempLogs = List.from(_allLogs);

    // Filter berdasarkan status (ON/OFF)
    if (_selectedStatus == FilterStatus.on) {
      tempLogs = tempLogs.where((log) => log['action'] == 'ON').toList();
    } else if (_selectedStatus == FilterStatus.off) {
      tempLogs = tempLogs.where((log) => log['action'] == 'OFF').toList();
    }

    // Filter berdasarkan tanggal
    if (_selectedDate != null) {
      tempLogs = tempLogs.where((log) {
        final logDate = DateTime.fromMillisecondsSinceEpoch(
          log['timestamp'] * 1000,
        );
        return logDate.year == _selectedDate!.year &&
            logDate.month == _selectedDate!.month &&
            logDate.day == _selectedDate!.day;
      }).toList();
    }

    setState(() {
      _filteredLogs = tempLogs;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5347AD),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF5347AD),
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _applyFilters();
      });
    }
  }

  @override
  void dispose() {
    _logsSubscription.cancel();
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
          'Pesan Notifikasi',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada notifikasi",
                      style: GoogleFonts.poppins(),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return _buildNotificationCard(log, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Ubah dari end ke start
        children: [
          // Filter Tanggal
          ActionChip(
            avatar: const Icon(
              Icons.calendar_today,
              size: 16,
              color: Color(0xFF5347AD),
            ),
            label: Text(
              _selectedDate == null
                  ? 'Semua Tanggal'
                  : DateFormat('dd/MM/yy').format(_selectedDate!),
            ),
            onPressed: () => _selectDate(context),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 10),
          // Filter Status
          PopupMenuButton<FilterStatus>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: Colors.white,
            onSelected: (FilterStatus result) {
              setState(() {
                _selectedStatus = result;
                _applyFilters();
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<FilterStatus>>[
                  PopupMenuItem<FilterStatus>(
                    value: FilterStatus.semua,
                    child: _buildFilterMenuItem(
                      'Semua Notifikasi',
                      Icons.notifications_outlined,
                      FilterStatus.semua == _selectedStatus,
                    ),
                  ),
                  PopupMenuItem<FilterStatus>(
                    value: FilterStatus.on,
                    child: _buildFilterMenuItem(
                      'Pompa Aktif (ON)',
                      Icons.power,
                      FilterStatus.on == _selectedStatus,
                    ),
                  ),
                  PopupMenuItem<FilterStatus>(
                    value: FilterStatus.off,
                    child: _buildFilterMenuItem(
                      'Pompa Nonaktif (OFF)',
                      Icons.power_off_outlined,
                      FilterStatus.off == _selectedStatus,
                    ),
                  ),
                ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF5347AD).withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: Color(0xFF5347AD)),
                  const SizedBox(width: 6),
                  Text(
                    _selectedStatus == FilterStatus.semua
                        ? 'Jenis'
                        : (_selectedStatus == FilterStatus.on ? 'ON' : 'OFF'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5347AD),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> log, int index) {
    final bool isPumpOn = log['action'] == 'ON';
    final int soilValue = log['soil'];
    final bool isLowMoisture = soilValue < 30;
    // ambil waktu dari IoT
    final DateTime logTime = DateTime.fromMillisecondsSinceEpoch(
      log['timestamp'] * 1000,
    ).toLocal();

    // ambil waktu sekarang (aplikasi/HP)
    final DateTime now = DateTime.now();  

    final Color cardColor = index.isOdd
        ? const Color(0xFF7654B2)
        : const Color(0xFF5347AD);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Soil Percentage
          Text(
            '$soilValue%',
            style: GoogleFonts.poppins(
              color: isLowMoisture
                  ? const Color(0xFFFF8A80)
                  : const Color(0xFFB9F6CA),
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Notification Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLowMoisture
                      ? 'Kelembapan tanah rendah!'
                      : 'Kelembapan tanah normal!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Pompa air otomatis ',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      isPumpOn ? 'ON' : 'OFF',
                      style: GoogleFonts.poppins(
                        color: isPumpOn ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Timestamp
          SizedBox(
            width: 65, // cukup utk dd/MM/yyyy + HH:mm
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(now),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('HH:mm').format(now),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this new helper method for filter menu items
  Widget _buildFilterMenuItem(String text, IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Color(0xFF5347AD).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Color(0xFF5347AD) : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: isSelected ? Color(0xFF5347AD) : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
