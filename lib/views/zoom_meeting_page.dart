import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ZoomMeetingPage extends StatefulWidget {
  const ZoomMeetingPage({Key? key}) : super(key: key);

  @override
  _ZoomMeetingPageState createState() => _ZoomMeetingPageState();
}

class _ZoomMeetingPageState extends State<ZoomMeetingPage> {
  DateTime? _startTime;
  DateTime? _endTime;
  Map<String, bool> attendanceRecords = {};
  int streakPoints = 0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      attendanceRecords = (prefs.getString('attendance') ?? '{}')
          .split(';')
          .where((e) => e.contains(':'))
          .fold({}, (map, entry) {
        List<String> pair = entry.split(':');
        if (pair.length == 2) {
          map[pair[0]] = pair[1] == 'true';
        }
        return map;
      });
      streakPoints = prefs.getInt('streakPoints') ?? 0;
    });
  }

  Future<void> _saveAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = attendanceRecords.entries.map((e) => "${e.key}:${e.value}").join(';');
    await prefs.setString('attendance', data);
    await prefs.setInt('streakPoints', streakPoints);
  }

  void _joinMeeting() {
    _startTime = DateTime.now();
    final Uri zoomAppUri = Uri.parse("zoommtg://zoom.us/join?confno=82921302998&pwd=iampeace");
    final Uri zoomWebUri = Uri.parse("https://us02web.zoom.us/j/82921302998?pwd=iampeace");
    launchUrl(zoomAppUri).catchError((_) => launchUrl(zoomWebUri));
  }

  void _endMeeting() {
    _endTime = DateTime.now();
    if (_startTime != null && _endTime != null) {
      final duration = _endTime!.difference(_startTime!).inSeconds;
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

      setState(() {
        if (duration >= 10) { // ✅ Updated threshold to 10 seconds
          attendanceRecords[dateKey] = true;
          _updateStreak();
        } else {
          attendanceRecords[dateKey] = false;
          streakPoints = 0;
        }
      });

      _saveAttendance();
    }
  }

  void _updateStreak() {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterdayKey = _getPreviousDate(todayKey);

    if (attendanceRecords[yesterdayKey] == true) {
      streakPoints += 1;
    } else {
      streakPoints = 1;
    }
  }

  String _getPreviousDate(String dateKey) {
    DateTime date = DateFormat('yyyy-MM-dd').parse(dateKey).subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F0E6),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          _buildStreakBadge(),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildCalendar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _joinMeeting();
          Timer(const Duration(seconds: 10), _endMeeting); // ✅ Updated time threshold
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.video_call, color: Colors.white),
      ),
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          const Text("🔥 ", style: TextStyle(fontSize: 18)),
          Text(
            "$streakPoints",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.access_time, size: 50, color: Color(0xFF203A43)),
          const SizedBox(height: 10),
          Text(
            "Track Your Meeting Attendance",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: attendanceRecords[DateFormat('yyyy-MM-dd').format(_selectedDay)] == true
                ? Colors.green // ✅ Present (Green)
                : Colors.red,   // ❌ Absent (Red)
            shape: BoxShape.circle, // ✅ Circular design for better UI
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent, // ✅ Highlight for today
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
        ),
      ),
    );
  }
}