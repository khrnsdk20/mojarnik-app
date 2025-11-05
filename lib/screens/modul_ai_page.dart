import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_layout.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../screens/riwayat_chat_page.dart';

class ModulAiPage extends StatefulWidget {
  final String idModul;
  final String namaModul;
  final String namaDosen;

  const ModulAiPage({
    super.key,
    required this.idModul,
    required this.namaModul,
    required this.namaDosen,
  });

  @override
  State<ModulAiPage> createState() => _ModulAiPageState();
}

class _ModulAiPageState extends State<ModulAiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  Future<void> _saveChatToSupabase({
    required String idSesi,
    required String konten,
    required String idRole,
  }) async {
    final idRiwayat =
        "chat_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}";
    await Supabase.instance.client.from('riwayat_chats').insert({
      'id_riwayat': idRiwayat,
      'id_sesi': idSesi,
      'konten': konten,
      'id_role': idRole,
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"isUser": true, "text": text});
      isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user');

      if (idUser == null) {
        throw Exception("User belum login atau data id_user hilang.");
      }

      // 🔹 Ambil atau buat id sesi
      final String idSesi = await ChatOllamaService.getOrCreateSession(
        idModul: widget.idModul,
        idUser: idUser,
      );

      if (idSesi.isEmpty) {
        throw Exception("Gagal membuat atau mengambil sesi chat.");
      }

      // 🔹 Pastikan sesi ada di Supabase
      final existingSession = await Supabase.instance.client
          .from('sesi_chats')
          .select('id_sesi')
          .eq('id_sesi', idSesi)
          .maybeSingle();

      if (existingSession == null) {
        await Supabase.instance.client.from('sesi_chats').insert({
          'id_sesi': idSesi,
          'id_modul': widget.idModul,
          'id_user': idUser,
        });
      }

      // 🔹 Ambil id_role user dari Supabase
      final userData = await Supabase.instance.client
          .from('users')
          .select('id_role')
          .eq('id_user', idUser)
          .maybeSingle();

      final idRoleUser = userData?['id_role'];
      if (idRoleUser == null) {
        throw Exception("Role user tidak ditemukan di database.");
      }

      // 🔹 Simpan pesan user
      await _saveChatToSupabase(
        idSesi: idSesi,
        konten: text,
        idRole: idRoleUser,
      );

      // 🔹 Kirim pertanyaan ke backend (tanpa timeout dan tanpa pesan error)
      final reply = await ChatOllamaService.chatWithPdf(
        idModul: widget.idModul,
        idUser: idUser,
        question: text,
      );

      // 🔹 Simpan balasan AI
      await _saveChatToSupabase(
        idSesi: idSesi,
        konten: reply,
        idRole: "AI_SYSTEM",
      );

      setState(() {
        messages.add({"isUser": false, "text": reply});
      });
    } catch (e) {
      // ⚠ Tidak menampilkan pesan error ke layar
      debugPrint("Error saat mengirim pesan: $e");
    } finally {
      setState(() => isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildChatBubble(bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color.fromARGB(255, 255, 17, 0)
              : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      showFab: false,
      content: Column(
        children: [
          // 🔹 Header bagian atas
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.namaModul,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.red),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RiwayatChatPage(
                          idModul: widget.idModul,
                          namaModul: widget.namaModul,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.grey),

          // 🔹 Area chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildChatBubble(msg["isUser"], msg["text"]);
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.red),
            ),

          // 🔹 Input chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Tulis pesan di sini...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 255, 17, 0),
                  ),
                  onPressed: isLoading ? null : _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
