import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              const SizedBox(height: 20),
              _buildPhoneInput(),
              const SizedBox(height: 15),
              _buildSubmitButton(context),
              const SizedBox(height: 15),
              _buildGoogleLoginButton(context),
              const SizedBox(height: 20),
              _buildFooter(), //
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 **App Logo**
  Widget _buildLogo() {
    return Column(
      children: [
        const Icon(Icons.lock_outline, size: 100, color: Color(0xFF203A43)),
        const SizedBox(height: 10),
        Text("Welcome Back",
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFFDC4108))),
      ],
    );
  }

  /// 📌 **Phone Input Field**
  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixText: "+91 ",
        labelText: "Phone Number",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  /// 📌 **Submit Button for Phone Login**
  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_phoneController.text.isNotEmpty) {
          AuthController.loginWithPhone(context, _phoneController.text);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a valid phone number")),
          );
        }
      },
      icon: const Icon(Icons.phone, color: Colors.white),  // Icon for the phone
      label: Text(
        "Login with Phone",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF203A43),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }


  /// 📌 **Google Login Button**
  Widget _buildGoogleLoginButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => AuthController.loginWithGoogle(context),
      icon: const Icon(Icons.g_mobiledata, color: Colors.white),
      label: Text("Login with Google",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF203A43),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }

  /// 📌 **Footer (Terms & Conditions)**
  Widget _buildFooter() {
    return Text(
      "By continuing, you agree to our Terms & Conditions",
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF555555)),
    );
  }
}
