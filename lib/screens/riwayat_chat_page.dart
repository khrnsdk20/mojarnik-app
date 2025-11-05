import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/detail_riwayat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatChatPage extends StatefulWidget {
  final String idModul;
  final String namaModul;
  const RiwayatChatPage({
    super.key,
    required this.idModul,
    required this.namaModul,
  });

  @override
  State<RiwayatChatPage> createState() => _RiwayatChatPageState();
}

class _RiwayatChatPageState extends State<RiwayatChatPage> {
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idUser = prefs.getString('id_user');

    print('🟢 ID USER (SharedPref): $idUser');
    print('🟢 ID MODUL: ${widget.idModul}');

    if (idUser == null) {
      setState(() {
        sessions = [];
        isLoading = false;
      });
      return;
    }

    final data = await Supabase.instance.client
        .from('sesi_chats')
        .select()
        .eq('id_modul', widget.idModul)
        .eq('id_user', idUser);

    print('📦 HASIL QUERY SESI_CHATS: $data');

    setState(() {
      sessions = List<Map<String, dynamic>>.from(data);
      sessions.sort((a, b) => b['id_sesi'].compareTo(a['id_sesi']));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Chat - ${widget.namaModul}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final sesi = sessions[index];
                return ListTile(
                  title: Text(
                    sesi['id_sesi'],
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(sesi['created_at'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailRiwayatPage(
                          idSesi: sesi['id_sesi'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
