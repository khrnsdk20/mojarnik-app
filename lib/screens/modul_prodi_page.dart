import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'modul_matakuliah_page.dart';
import 'main_layout.dart';

class ModulProdiPage extends StatefulWidget {
  final String namaProdi; // nama program studi yang dikirim saat ditekan
  final String idProdi; // ubah dari int -> String ✅

  const ModulProdiPage({
    super.key,
    required this.namaProdi,
    required this.idProdi,
  });

  @override
  State<ModulProdiPage> createState() => _ModulProdiPageState();
}

class _ModulProdiPageState extends State<ModulProdiPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<dynamic> semesters = [];

  @override
  void initState() {
    super.initState();
    fetchSemesters();
  }

  Future<void> fetchSemesters() async {
    try {
      final response = await supabase
          .from('semesters')
          .select('id_semester, no_semester')
          .eq('id_prodi', widget.idProdi)
          .order('no_semester', ascending: true);

      setState(() {
        semesters = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch semesters: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======= SEARCH BAR =======
              buildSearchBar(
                hintText: "Cari modul...",
                onChanged: (query) {
                  // nanti bisa dipakai buat fitur filter modul
                  print("Cari modul: $query");
                },
              ),
              const SizedBox(height: 20),

              // ======= TITLE =======
              Text(
                "Semester",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // ======= SEMESTER LIST =======
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (semesters.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Belum ada data semester untuk ${widget.namaProdi}",
                      style: GoogleFonts.montserrat(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: semesters.map((sem) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModulMatakuliahPage(
                                idSemester: sem['id_semester'].toString(),
                                namaSemester: sem['no_semester'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Semester ${sem['no_semester']}",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
