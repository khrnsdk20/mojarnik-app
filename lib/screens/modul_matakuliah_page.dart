import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'modul_dosen_page.dart';
import 'main_layout.dart';

class ModulMatakuliahPage extends StatefulWidget {
  final String idSemester;
  final String namaSemester;

  const ModulMatakuliahPage({
    super.key,
    required this.idSemester,
    required this.namaSemester,
  });

  @override
  State<ModulMatakuliahPage> createState() => _ModulMatakuliahPageState();
}

class _ModulMatakuliahPageState extends State<ModulMatakuliahPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> mataKuliahs = [];
  Map<String, List<Map<String, dynamic>>> dosenPerMatkul = {};
  Map<String, String?> selectedDosenPerMatkul =
      {}; // id_matakuliah -> id_dosen terpilih
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatakuliah();
  }

  Future<void> fetchMatakuliah() async {
    try {
      // Ambil mata kuliah berdasarkan semester yang dipilih
      final mataKuliahRes = await supabase
          .from('mata_kuliahs')
          .select('id_matakuliah, nama_matakuliah')
          .eq('id_semester', widget.idSemester);

      // Ambil semua detail matakuliah + dosen
      final detailRes = await supabase
          .from('detail_matakuliahs')
          .select('id_matakuliah, kelas, dosens(id_dosen, nama_dosen)');

      Map<String, List<Map<String, dynamic>>> groupedDosen = {};

      for (final detail in detailRes) {
        final idMatkul = detail['id_matakuliah'];
        final dosen = detail['dosens'];

        if (idMatkul != null && dosen != null) {
          // [FIX]: Logika untuk menghindari duplikat dosen
          var list = groupedDosen.putIfAbsent(idMatkul, () => []);
          bool exists =
              list.any((existing) => existing['id_dosen'] == dosen['id_dosen']);
          if (!exists) {
            list.add(dosen);
          }
        }
      }

      if (mounted) {
        setState(() {
          mataKuliahs = List<Map<String, dynamic>>.from(mataKuliahRes);
          dosenPerMatkul = groupedDosen;
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      content: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 0, vertical: 10), // [UPDATE] Padding horizontal di 0
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [UPDATE] Membungkus Search Bar dengan Container merah
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 17, 0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: buildSearchBar(
                  hintText: "Cari modul...",
                  onChanged: (query) {
                    // TODO: tambahkan filter pencarian nanti
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                // [UPDATE] Tambahkan padding untuk judul
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Pilih Matakuliah",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (mataKuliahs.isEmpty)
                Center(
                  child: Text(
                    "Belum ada mata kuliah untuk semester ini",
                    style: GoogleFonts.montserrat(color: Colors.black54),
                  ),
                )
              else
                Padding(
                  // [UPDATE] Tambahkan padding untuk list
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: mataKuliahs.map((matkul) {
                      final dosens =
                          dosenPerMatkul[matkul['id_matakuliah']] ?? [];
                      return _buildMatkulItem(
                        matkul['id_matakuliah'], // tambahkan idMatkul
                        matkul['nama_matakuliah'],
                        dosens,
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatkulItem(
      String idMatkul, String namaMatkul, List<Map<String, dynamic>> dosens) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 17, 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          namaMatkul,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            // [UPDATE] Warna anak (children) harusnya putih agar kontras
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pilih Dosen:",
                  style: GoogleFonts.montserrat(
                    // [UPDATE] Warna teks menjadi hitam
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // Dropdown dosen
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    // [UPDATE] Beri border atau warna beda
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDosenPerMatkul[idMatkul],
                      isExpanded: true, // [UPDATE] Buat dropdown jadi penuh
                      hint: Text(
                        "Pilih Dosen",
                        style: GoogleFonts.montserrat(color: Colors.black54),
                      ),
                      items: dosens.map((dosen) {
                        return DropdownMenuItem<String>(
                          value: dosen['id_dosen'],
                          child: Text(
                            dosen['nama_dosen'] ?? "-",
                            style: GoogleFonts.montserrat(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDosenPerMatkul[idMatkul] = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tombol Open (hanya muncul jika dosen sudah dipilih)
                if (selectedDosenPerMatkul[idMatkul] != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // [UPDATE] Ganti style tombol agar lebih jelas
                        backgroundColor:
                            const Color.fromARGB(255, 255, 17, 0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final selectedId = selectedDosenPerMatkul[idMatkul];
                        final selectedDosen = dosens.firstWhere(
                          (d) => d['id_dosen'] == selectedId,
                          orElse: () =>
                              {}, // Pengaman jika data tidak ketemu
                        );

                        if (selectedDosen.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModulDosenPage(
                                idDosen: selectedDosen['id_dosen'],
                                namaDosen: selectedDosen['nama_dosen'],
                                idMatakuliah: idMatkul,
                                namaMatakuliah: namaMatkul,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Open",
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
