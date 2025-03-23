import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'zoom_meeting_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF7F0E6),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black, // ✅ White text for better visibility
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Set the back arrow color to black
          onPressed: () {
            Navigator.pop(context);  // Custom action on back button press
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F0E6),
        iconTheme: const IconThemeData(color: Colors.black), // ✅ White icons
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.black), // ✅ White Icon
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ZoomMeetingPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black), // ✅ White Icon
            onPressed: () => AuthController.logoutUser(context),
          ),
        ],
        elevation: 4,
      ),
      body: Center(
        child: Text(
          "🎉 Welcome to Home Page!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF203A43), // ✅ Dark text for better contrast
          ),
        ),
      ),
    );
  }
}
