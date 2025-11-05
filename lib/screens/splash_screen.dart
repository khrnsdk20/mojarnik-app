import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 1), // spasi atas
            // Logo MOJARNIK di tengah layar
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/logo_depan.png',
                  width: 210,
                ),
              ),
            ),
            // Tombol LOGIN selalu di bawah
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 350,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 17, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "LOGIN",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
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
