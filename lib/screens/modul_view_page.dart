import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/modul_ai_page.dart';
import '../screens/main_layout.dart';
import '../screens/modul_state.dart';

class ModulViewPage extends StatefulWidget {
  final String judulModul;
  final String namaDosen;
  final String idModul;
  final String fileUrl;

  const ModulViewPage({
    super.key,
    required this.judulModul,
    required this.namaDosen,
    required this.idModul,
    required this.fileUrl,
  });

  @override
  State<ModulViewPage> createState() => _ModulViewPageState();
}

class _ModulViewPageState extends State<ModulViewPage> {
  @override
  void initState() {
    super.initState();

    // Aktifkan FAB AI merah
    ModulState.setSelected(
      idModul: widget.idModul,
      namaModul: widget.judulModul,
      namaDosen: widget.namaDosen,
    );
  }

  @override
  void dispose() {
    // Reset FAB AI ketika keluar dari halaman ini
    ModulState.clear();
    super.dispose();
  }

  Future<void> openPDF(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL file tidak tersedia")),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka file PDF")),
      );
    }
  }

  Future<void> downloadFile(String url) async {
    // TODO: implementasi download file (misalnya pakai dio)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur download belum diaktifkan")),
    );
  }

  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.judulModul,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dosen Pengampu: ${widget.namaDosen}",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            // ====== BUTTON ROW ======
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => openPDF(widget.fileUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text(
                    "Open",
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => downloadFile(widget.fileUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.download, color: Colors.black87),
                  label: Text(
                    "Download",
                    style: GoogleFonts.montserrat(color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorited = !isFavorited;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isFavorited
                            ? "Ditambahkan ke favorit"
                            : "Dihapus dari favorit"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // Info FAB
            Center(
              child: Text(
                "Gunakan tombol AI merah di bawah untuk menganalisis modul ini",
                style: GoogleFonts.montserrat(
                  color: Colors.black54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
