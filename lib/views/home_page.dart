import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'zoom_meeting_page.dart';
import 'wisdom_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ZoomMeetingPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WisdomScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: const Color(0xFFda461b),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: const Color(0xFFda461b)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: const Color(0xFFda461b)),
            onPressed: () => AuthController.logoutUser(context),
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xFFf7f0e6),
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          "🎉 Welcome to Home Page!",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDD4C1B),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF7F0E6),
        selectedItemColor: const Color(0xFFDD4C1B),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Zoom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Wisdom',
          ),
        ],
      ),
    );
  }
}
