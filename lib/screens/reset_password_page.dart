import 'package:flutter/material.dart';
import 'login_screen.dart'; // ✅ tambahkan ini untuk navigasi ke login

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _resetPassword() {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom harus diisi!'),
          backgroundColor: Color.fromARGB(255, 255, 17, 0),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak sama!'),
          backgroundColor: Color.fromARGB(255, 255, 17, 0),
        ),
      );
      return;
    }

    // ✅ Jika password berhasil diubah
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password berhasil diubah! Silakan login kembali.'),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ Arahkan langsung ke halaman Login dan hapus semua halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Password Baru"),
        backgroundColor: Color.fromARGB(255, 255, 17, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              "Masukkan Password Baru Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Input Password Baru
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Baru",
                filled: true,
                fillColor: Colors.red.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Input Konfirmasi Password
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Konfirmasi Password",
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
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 17, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Simpan Password",
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
