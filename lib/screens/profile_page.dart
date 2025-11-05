import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_layout.dart';
import 'splash_screen.dart'; // <-- BARIS INI DITAMBAHKAN

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
      content: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 17, 0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.edit,
                              color: Color.fromARGB(255, 255, 17, 0), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'KHAERUN SODIK',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'D3 TEKNIK INFORMATIKA',
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black),
              title: Text('Detail Profil',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.black),
              title: Text('Disimpan',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.black),
              title: Text('Pengaturan',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              onTap: () {},
            ),
            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout,
                  color: Color.fromARGB(255, 255, 17, 0)),
              title: Text(
                'Keluar',
                style: GoogleFonts.montserrat(
                  color: Color.fromARGB(255, 255, 17, 0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              // --- FUNGSI ONTAP DIUBAH DI SINI ---
              onTap: () {
                // Navigasi ke SplashScreen dan hapus semua rute sebelumnya
                // Pastikan nama class di splash_screen.dart adalah SplashScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              // --- AKHIR PERUBAHAN ---
            ),
          ],
        ),
      ),
    );
  }
}