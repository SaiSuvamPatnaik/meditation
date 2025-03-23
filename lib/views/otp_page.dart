import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../views/home_page.dart';
import 'quiz_screen.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  const OTPPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendOTP(); // 📌 Send OTP when the screen opens
  }

  /// 📌 Send OTP to User
  _sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91${widget.phoneNumber}",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _verificationCode = verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationCode = verificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Auto-retrieval timeout. Please enter OTP manually.")),
        );
      },
    );
  }

  /// 📌 Verify OTP Manually
  _verifyOTP() async {
    if (_otpController.text.length == 6) {
      setState(() => _isLoading = true);

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationCode!,
          smsCode: _otpController.text.trim(),
        );

        await _auth.signInWithCredential(credential);
        _navigateToHome();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Please try again!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP.")),
      );
    }
  }

  /// 📌 Navigate to Quiz Page After Successful Login
  _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _otpController.dispose(); // Clean up controller
    super.dispose();
  }

  /// 📌 UI for OTP Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      appBar: AppBar(
        title: const Text("OTP Verification"),
        centerTitle: true,
        backgroundColor: const Color(0xFF203A43),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildOTPInput(),
              const SizedBox(height: 20),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.lock, size: 80, color: Color(0xFF203A43)),
        const SizedBox(height: 10),
        Text("Verify +91-${widget.phoneNumber}",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF203A43))),
        Text("Enter the OTP sent to your phone",
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF555555))),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Pinput(
      length: 6,
      controller: _otpController,
      pinAnimationType: PinAnimationType.fade,
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF203A43), Color(0xFF2C5364)], // Stylish dark blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 5), // Elegant shadow effect
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Gradient handles color
          foregroundColor: Colors.white, // Ensures text is visible
          shadowColor: Colors.transparent, // Removes default shadow
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            Text(
              _isLoading ? "Verifying..." : "Verify OTP",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1, // Adds a professional touch
                color: Colors.white, // High contrast for readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}
