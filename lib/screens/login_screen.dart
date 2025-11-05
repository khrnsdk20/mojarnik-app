import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_page.dart'; // Pastikan file ini ada
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap isi username dan password terlebih dahulu!',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        ),
      );
      return;
    }

    try {
      // Debug: tampilkan input
      debugPrint('LOGIN ATTEMPT -> username: $username');

      // Query: tambahkan filter id_role = 'R03' agar hanya mahasiswa yang boleh login
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .eq('id_role', 'R03') // filter role mahasiswa
          .maybeSingle();

      debugPrint('SUPABASE RESPONSE: $response');

      // maybeSingle() -> response bisa null, Map<String, dynamic>, atau error
      if (response == null) {
        // Cek apakah user ada tapi role beda atau password salah
        final checkUser = await Supabase.instance.client
            .from('users')
            .select()
            .eq('username', username)
            .maybeSingle();

        debugPrint('CHECK USER (by username) -> $checkUser');

        if (checkUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User tidak ditemukan.',
                  style: GoogleFonts.montserrat()),
              backgroundColor: const Color.fromARGB(255, 255, 17, 0),
            ),
          );
        } else {
          // User ada => kemungkinan password salah atau role bukan R03
          if (checkUser['id_role'] != 'R03') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Akun ini bukan akun mahasiswa.',
                    style: GoogleFonts.montserrat()),
                backgroundColor: const Color.fromARGB(255, 255, 17, 0),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Username atau password salah.',
                    style: GoogleFonts.montserrat()),
                backgroundColor: const Color.fromARGB(255, 255, 17, 0),
              ),
            );
          }
        }
        return;
      }

      // Pastikan response adalah Map dan memiliki id_users
      if (response is Map && response.containsKey('id_user')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_user', response['id_user']);
        // (Opsional) Simpan info lain yang sering dipakai
        if (response.containsKey('nama')) {
          await prefs.setString('nama_user', response['nama'] ?? '');
        }
        if (response.containsKey('id_role')) {
          await prefs.setString('id_role', response['id_role'] ?? '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login berhasil!', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
        return;
      } else {
        // Unexpected response shape
        debugPrint('Unexpected response shape: ${response.runtimeType}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat memproses login.',
                style: GoogleFonts.montserrat()),
            backgroundColor: const Color.fromARGB(255, 255, 17, 0),
          ),
        );
        return;
      }
    } catch (e, st) {
      debugPrint('Error saat login: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat login: $e',
              style: GoogleFonts.montserrat()),
          backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [UPDATE]: Menggunakan warna putih sebagai background default
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            // [UPDATE]: Menyesuaikan padding, terutama padding atas dan bawah
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 80),
                // [UPDATE]: Mengurangi jarak antara logo dan title
                const SizedBox(height: 8),
                Text(
                  "LOGIN",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Colors.black,
                  ),
                ),
                // [UPDATE]: Menambah jarak dari title ke form
                const SizedBox(height: 60),

                // Input Username
                TextField(
                  controller: usernameController,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    // [UPDATE]: Mengganti labelText menjadi hintText
                    hintText: "Username",
                    // [UPDATE]: Mengganti labelStyle menjadi hintStyle
                    hintStyle: GoogleFonts.montserrat(
                        color: Color.fromARGB(255, 255, 17, 0)),
                    filled: true,
                    fillColor: Colors.red.shade100,
                    border: OutlineInputBorder(
                      // [UPDATE]: Menambah radius lengkungan
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                ),
                // [UPDATE]: Mengurangi jarak antar text field
                const SizedBox(height: 20),

                // Input Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    // [UPDATE]: Mengganti labelText menjadi hintText
                    hintText: "Password",
                    // [UPDATE]: Mengganti labelStyle menjadi hintStyle
                    hintStyle: GoogleFonts.montserrat(
                        color: Color.fromARGB(255, 255, 17, 0)),
                    filled: true,
                    fillColor: Colors.red.shade100,
                    border: OutlineInputBorder(
                      // [UPDATE]: Menambah radius lengkungan
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                ),
                // [UPDATE]: Menambah jarak sedikit sebelum "Lupa password?"
                const SizedBox(height: 10),

                // Lupa Password?
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    // [UPDATE]: Mengurangi padding default dari TextButton
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Lupa password?",
                      style: GoogleFonts.montserrat(
                        color: Color.fromARGB(255, 255, 17, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // [UPDATE]: Menambah jarak ke tombol LOGIN
                const SizedBox(height: 30),

                // Tombol LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50, // [UPDATE]: Sedikit menambah tinggi tombol
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 17, 0),
                      shape: RoundedRectangleBorder(
                        // [UPDATE]: Menyamakan radius lengkungan
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _login,
                    child: Text(
                      "LOGIN",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // [UPDATE]: Menambah jarak
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: GoogleFonts.montserrat(
                        // [UPDATE]: Menghapus bold agar sesuai desain
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Tambahkan navigasi ke halaman daftar
                      },
                      child: Text(
                        "Daftar",
                        style: GoogleFonts.montserrat(
                          color: Color.fromARGB(255, 255, 17, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  "Atau lanjutkan dengan",
                  style: GoogleFonts.montserrat(
                    // [UPDATE]: Menghapus bold agar sesuai desain
                    fontWeight: FontWeight.normal,
                  ),
                ),
                // [UPDATE]: Menambah jarak
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton("assets/google.png"),
                    const SizedBox(width: 15),
                    _buildSocialButton("assets/fb.png"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        // [UPDATE]: Menyamakan radius lengkungan
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        // [UPDATE]: Mengurangi ukuran ikon di dalam tombol
        child: Image.asset(assetPath, width: 30, height: 30),
      ),
    );
  }
}
