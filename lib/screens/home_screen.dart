import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // [NEW]: untuk simpan file
import 'package:http/http.dart' as http; // [NEW]: untuk download file

import 'main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> modulList = [];

  @override
  void initState() {
    super.initState();
    fetchModul();
  }

  Future<void> fetchModul() async {
    try {
      final response = await supabase.from('moduls').select(
          'id_modul, judul_modul, file_url, uploaded_by, uploaded_at, download, id_detail');

      if (mounted) {
        setState(() {
          modulList = response;
        });
      }
    } catch (e) {
      debugPrint('Error fetch modul: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mengambil data: $e')),
        );
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_user');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> openPDF(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL file tidak tersedia")),
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka file PDF")),
      );
    }
  }

  /// [NEW] Fungsi download file + update status di Supabase
  Future<void> downloadFile(String url, String idModul) async {
    try {
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("URL file tidak tersedia")),
        );
        return;
      }

      // 1️⃣ Download file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final fileName = url.split('/').last;
        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // 2️⃣ Update kolom download di Supabase
        await supabase
            .from('moduls')
            .update({'download': '1'}).eq('id_modul', idModul);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File berhasil diunduh: $fileName")),
          );
        }
      } else {
        throw Exception("Gagal download, kode: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error download file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh file: $e')),
        );
      }
    }
  }

  Widget buildSearchBar(
      {required String hintText, required Function(String) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.montserrat(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 17, 0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  buildSearchBar(
                    hintText: "Cari modul...",
                    onChanged: (value) {
                      // logika filter bisa ditambahkan nanti
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBox("${modulList.length}", "MODUL"),
                      _buildStatBox("2.345", "VIEW"),
                      _buildStatBox("1.234", "UNDUH"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Modul Baru",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: modulList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: modulList.length,
                      itemBuilder: (context, index) {
                        final modul = modulList[index];
                        return _buildModulItem(
                          modul['id_modul'] ?? '',
                          modul['judul_modul'] ?? 'Tanpa Judul',
                          "Upload by ${modul['uploaded_by'] ?? '-'}",
                          modul['file_url'] ?? '',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulItem(
      String idModul, String title, String subtitle, String fileUrl) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 17, 0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "PDF",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(title,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.montserrat(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => openPDF(fileUrl),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Open",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
            InkWell(
              onTap: () => downloadFile(fileUrl, idModul),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child:
                    Icon(Icons.download, color: Colors.grey.shade600, size: 22),
              ),
            ),
            InkWell(
              onTap: () {
                // logika bookmark
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(Icons.bookmark_border,
                    color: Colors.grey.shade600, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
