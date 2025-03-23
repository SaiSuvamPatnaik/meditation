import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meditation/views/home_page.dart';
import 'package:meditation/views/login_page.dart';
import 'package:meditation/services/storage_service.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Check login status from local storage
  bool isLoggedIn = await StorageService.getLoginStatus();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Start the app with the SplashScreen
      home: SplashScreen(isLoggedIn: isLoggedIn),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;

  const SplashScreen({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay splash screen for 8 seconds
    Future.delayed(Duration(seconds: 2), () {
      // Navigate to HomePage or LoginPage based on login status
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.isLoggedIn ? const HomePage() : const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height dynamically
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Light cream background color
          color: Color(0xFFF7F0E6),  // The updated background color
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lottie Animation for Meditation (scaled dynamically)
              Lottie.asset(
                'assets/animation/meditation_lottie.json', // Path to your Lottie file
                width: screenWidth * 0.6, // Set width to 60% of the screen width
                height: screenHeight * 0.4, // Set height to 40% of the screen height
                fit: BoxFit.contain, // Maintain the aspect ratio
              ),
              // Elegant Quote Text (No gap between Lottie and the text)
              Text(
                'What we are actually seeking\nare found in our own depths',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Dark color for text to contrast the background
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Optional: A nice loading spinner (if you want)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
