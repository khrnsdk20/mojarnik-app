import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_layout.dart';
import 'modul_prodi_page.dart';

class ModulPage extends StatefulWidget {
  const ModulPage({super.key});

  @override
  State<ModulPage> createState() => _ModulPageState();
}

class _ModulPageState extends State<ModulPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> moduls = [];
  List<dynamic> prodis = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final modulsResponse = await supabase
          .from('moduls')
          .select('judul_modul, file_url, uploaded_by, uploaded_at');
      final prodisResponse =
          await supabase.from('prodis').select('id_prodi, nama_prodi, jenjang');

      if (mounted) {
        setState(() {
          moduls = modulsResponse;
          prodis = prodisResponse;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetch data: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
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

  // [ADD]: Implementasi buildSearchBar sesuai desain
  Widget buildSearchBar(
      {required String hintText, required Function(String) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Membuatnya bulat
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.montserrat(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none, // Menghilangkan border default
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  // =================== REKOMENDASI ===================
  Widget _buildRekomendasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // [UPDATE]: Padding disesuaikan agar sejajar dengan card
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            "Rekomendasi",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (moduls.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Belum ada modul tersedia",
                style: GoogleFonts.montserrat(color: Colors.black54),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moduls.length,
            itemBuilder: (context, index) {
              final modul = moduls[index];
              return Card(
                elevation: 1.5, // [UPDATE]: Mengurangi elevasi sedikit
                shadowColor: Colors.grey.shade200,
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
                    "Uploaded by ${modul['uploaded_by'] ?? '-'}",
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // [UPDATE]: Merapikan TextButton
                      TextButton(
                        onPressed: () => openPDF(modul['file_url'] ?? ''),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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
                      // [UPDATE]: Mengganti IconButton menjadi InkWell
                      InkWell(
                        onTap: () {
                          // TODO: fitur download
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(Icons.download,
                              color: Colors.grey.shade600, size: 22),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // TODO: fitur bookmark
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
            },
          ),
      ],
    );
  }

  // =================== PROGRAM STUDI ===================
  // Bagian ini sudah terlihat rapi dan sesuai desain
  Widget _buildProgramStudi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Program Studi",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: prodis.map((prodi) {
              IconData icon;
              if (prodi['nama_prodi'].toString().contains('Informatika')) {
                icon = LucideIcons.monitor;
              } else if (prodi['nama_prodi'].toString().contains('Listrik')) {
                icon = LucideIcons.zap;
              } else {
                icon = LucideIcons.slidersHorizontal;
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModulProdiPage(
                          namaProdi: prodi['nama_prodi'],
                          idProdi: prodi['id_prodi'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${prodi['jenjang']} ${prodi['nama_prodi']}",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(icon, color: Colors.white, size: 26),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // =================== BUILD ===================
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      // [UPDATE]: Menghapus Padding global dari content
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [UPDATE]: Menambahkan kontainer merah untuk search bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 17, 0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: buildSearchBar(
                hintText: "Cari modul...",
                onChanged: (query) {
                  print("Cari modul: $query");
                },
              ),
            ),
            const SizedBox(height: 10), // Mengurangi Sizedbox
            _buildRekomendasi(),
            const SizedBox(height: 12),
            _buildProgramStudi(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
