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
















// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ZoomMeetingPage extends StatelessWidget {
//   final String zoomMeetingId = "82921302998";
//   final String zoomPassword = "iampeace";
//
//   const ZoomMeetingPage({Key? key}) : super(key: key);
//
//   /// ✅ Function to Open Zoom App
//   _joinZoomMeeting() async {
//     final Uri zoomAppUri = Uri.parse("zoommtg://zoom.us/join?confno=$zoomMeetingId&pwd=$zoomPassword");
//     final Uri zoomWebUri = Uri.parse("https://us02web.zoom.us/j/$zoomMeetingId?pwd=$zoomPassword");
//
//     // Check if Zoom app is installed
//     if (await canLaunchUrl(zoomAppUri)) {
//       await launchUrl(zoomAppUri);
//     } else {
//       // Open in browser if Zoom app is not installed
//       await launchUrl(zoomWebUri);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F0E6), // Background color
//       appBar: AppBar(
//         title: const Text(
//           "Join Zoom Meeting",
//           style: TextStyle(
//             color: Colors.white, // ✅ White text for better visibility
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF203A43),
//         iconTheme: const IconThemeData(color: Colors.white), // ✅ White icons
//         elevation: 5,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 20),
//                 _buildMeetingDetails(),
//                 const SizedBox(height: 20),
//                 _buildJoinButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// 🎯 **Header Section with Icon & Title**
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         const Icon(Icons.video_call, size: 70, color: Color(0xFF203A43)),
//         const SizedBox(height: 10),
//         Text(
//           "Zoom Meeting",
//           style: GoogleFonts.poppins(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF203A43),
//           ),
//         ),
//         Text(
//           "Join your scheduled meeting",
//           style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
//         ),
//       ],
//     );
//   }
//
//   /// 🎯 **Meeting Details Card**
//   Widget _buildMeetingDetails() {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE3F2FD),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildDetailRow(Icons.meeting_room, "Meeting ID: $zoomMeetingId"),
//           const SizedBox(height: 10),
//           _buildDetailRow(Icons.lock, "Password: $zoomPassword"),
//         ],
//       ),
//     );
//   }
//
//   /// 🎯 **Meeting Detail Row with Icon**
//   Widget _buildDetailRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, color: const Color(0xFF203A43), size: 20),
//         const SizedBox(width: 10),
//         Text(
//           text,
//           style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
//
//   /// 🎯 **Stylish Join Button**
//   Widget _buildJoinButton() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF203A43), Color(0xFF2C5364)], // Dark blue gradient
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(2, 5),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: _joinZoomMeeting,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           foregroundColor: Colors.white,
//           shadowColor: Colors.transparent,
//           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.video_call, color: Colors.white),
//             const SizedBox(width: 10),
//             Text(
//               "Join Meeting",
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.1,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
