import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_layout.dart';
import 'modul_view_page.dart';

class ModulDosenPage extends StatefulWidget {
  final String idDosen;
  final String namaDosen;
  final String idMatakuliah;
  final String namaMatakuliah;

  const ModulDosenPage({
    super.key,
    required this.idDosen,
    required this.namaDosen,
    required this.idMatakuliah,
    required this.namaMatakuliah,
  });

  @override
  State<ModulDosenPage> createState() => _ModulDosenPageState();
}

class _ModulDosenPageState extends State<ModulDosenPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<dynamic> moduls = [];

  @override
  void initState() {
    super.initState();
    fetchModuls();
  }

  Future<void> fetchModuls() async {
    try {
      final response = await supabase
          .from('moduls')
          .select(
              'id_modul, judul_modul, file_url, uploaded_by, uploaded_at, download, detail_matakuliahs!inner(id_dosen, id_matakuliah)')
          .eq('detail_matakuliahs.id_dosen', widget.idDosen)
          .eq('detail_matakuliahs.id_matakuliah', widget.idMatakuliah);

      setState(() {
        moduls = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching modul dosen: $e");
      setState(() => isLoading = false);
    }
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

  Widget _buildModulList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (moduls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Belum ada modul untuk mata kuliah ${widget.namaMatakuliah}",
            style: GoogleFonts.montserrat(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moduls.length,
      itemBuilder: (context, index) {
        final modul = moduls[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModulViewPage(
                  idModul: modul['id_modul'],
                  judulModul: modul['judul_modul'] ?? 'Tanpa Judul',
                  namaDosen: widget.namaDosen,
                  fileUrl: modul['file_url'] ?? '',
                ),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
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
              title: Text(
                modul['judul_modul'] ?? 'Tanpa Judul',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                "Uploaded by ${modul['uploaded_by'] ?? widget.namaDosen}",
                style: GoogleFonts.montserrat(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      content: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(
              hintText: "Cari modul ${widget.namaDosen}...",
              onChanged: (query) {},
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Modul ${widget.namaMatakuliah} oleh ${widget.namaDosen}",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildModulList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
