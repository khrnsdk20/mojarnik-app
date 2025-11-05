import 'package:flutter/material.dart';
import 'reset_password_page.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController otpController = TextEditingController();

  void _verifyOTP() {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode OTP terlebih dahulu!'),
          backgroundColor: Color.fromARGB(255, 255, 17, 0),
        ),
      );
    } else {
      // Setelah OTP valid, arahkan ke halaman reset password
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifikasi OTP"),
        backgroundColor: Color.fromARGB(255, 255, 17, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              "Masukkan Kode OTP",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Kode OTP",
                filled: true,
                fillColor: Colors.red.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 17, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Verifikasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
