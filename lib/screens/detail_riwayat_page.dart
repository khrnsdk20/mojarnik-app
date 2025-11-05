import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailRiwayatPage extends StatefulWidget {
  final String idSesi;
  const DetailRiwayatPage({super.key, required this.idSesi});

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final data = await Supabase.instance.client
        .from('riwayat_chats')
        .select()
        .eq('id_sesi', widget.idSesi)
        .order('created_at', ascending: true);
    setState(() {
      chats = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  Widget _buildBubble(Map<String, dynamic> chat) {
    final isUser = chat['id_role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color.fromARGB(255, 255, 17, 0)
              : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          chat['konten'],
          style: GoogleFonts.montserrat(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Riwayat Chat")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chats.length,
              itemBuilder: (context, index) => _buildBubble(chats[index]),
            ),
    );
  }
}