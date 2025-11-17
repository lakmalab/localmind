// huggingface_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceApiService {
  static const String baseUrl = 'https://huggingface.co';
  static const String apiUrl = 'https://huggingface.co/api';

  // Search for models with GGUF files
  Future<List<dynamic>> searchModels(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/models?search=$query+gguf&sort=downloads&limit=20'),
        headers: {
          'User-Agent': 'LocalMind-App/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search models: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Search error: $e');
      throw Exception('Failed to search models: $e');
    }
  }

  // Get files for a specific model repository
  Future<List<dynamic>> getModelFiles(String modelId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/models/$modelId/tree/main'),
        headers: {
          'User-Agent': 'LocalMind-App/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Some models might use different branches or have no files
        return [];
      }
    } catch (e) {
      print('❌ File fetch error for $modelId: $e');
      return [];
    }
  }

  // Get specific GGUF files with their details
  Future<List<Map<String, dynamic>>> getGGUFFiles(String modelId) async {
    try {
      final files = await getModelFiles(modelId);
      final ggufFiles = <Map<String, dynamic>>[];

      for (var file in files) {
        final path = file['path']?.toString() ?? '';
        final size = file['size'] ?? 0;

        // Look for GGUF files
        if (path.toLowerCase().endsWith('.gguf')) {
          ggufFiles.add({
            'filename': path,
            'size': size,
            'downloadUrl': '$baseUrl/$modelId/resolve/main/$path',
            'lastModified': file['lastModified']?.toString() ?? '',
          });
        }
      }

      return ggufFiles;
    } catch (e) {
      print('❌ GGUF file fetch error for $modelId: $e');
      return [];
    }
  }
}