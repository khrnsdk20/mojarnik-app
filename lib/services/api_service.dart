import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ChatOllamaService {
  static const String _baseUrl = "http://10.0.2.2:8888";

  // --- 1️⃣ Ambil atau buat sesi chat ---
  static Future<String> getOrCreateSession({
    required String idModul,
    required String idUser,
  }) async {
    final url = Uri.parse("$_baseUrl/getOrCreateChatSession");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "id_modul": idModul,
              "id_user": idUser,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["session"] != null) {
          return data["session"]["id_sesi"];
        } else {
          throw Exception("Respons server tidak valid: ${response.body}");
        }
      } else {
        throw Exception("Gagal membuat sesi chat: ${response.body}");
      }
    } on TimeoutException {
      throw Exception("Koneksi ke server terlalu lama (timeout).");
    } catch (e) {
      throw Exception("Kesalahan getOrCreateSession: $e");
    }
  }

  // --- 2️⃣ Kirim pertanyaan ke AI ---
  static Future<String> chatWithPdf({
    required String idModul,
    required String idUser,
    required String question,
  }) async {
    final url = Uri.parse("$_baseUrl/chatWithPdf");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "id_modul": idModul,
              "id_user": idUser,
              "question": question,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final reply = data["reply"];
        if (reply is String) {
          return reply;
        } else if (reply is Map || reply is List) {
          return jsonEncode(reply);
        } else {
          return reply?.toString() ?? "⚠ Tidak ada jawaban dari AI.";
        }
      } else {
        throw Exception(
            "Gagal memproses chat (${response.statusCode}): ${response.body}");
      }
    } on TimeoutException {
      return "⚠ AI terlalu lama merespons (timeout). Coba lagi.";
    } catch (e) {
      return "⚠ Kesalahan chatWithPdf: $e";
    }
  }
}
