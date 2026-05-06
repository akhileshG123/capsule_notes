import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to localhost
  static const String baseUrl = 'http://10.0.0.100:3000/api'; 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Future<bool> transcribeAudio(String noteId, String userId, String audioUrl) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voice/transcribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'noteId': noteId,
          'userId': userId,
          'audioUrl': audioUrl,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Transcribe API Error: $e');
      return false;
    }
  }

  Future<bool> extractText(String noteId, String userId, String imageUrl) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan/extract'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'noteId': noteId,
          'userId': userId,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Extract API Error: $e');
      return false;
    }
  }
}
