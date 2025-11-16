import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/huggingface_model.dart';

class HuggingFaceRepository {
  final Dio _dio = Dio();

  Future<List<HuggingFaceModel>> searchModels({
    String query = 'gguf',
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'https://huggingface.co/api/models',
        queryParameters: {
          'search': query,
          'limit': limit,
          'sort': 'downloads',
          'direction': -1,
        },
      );

      final List<dynamic> modelsData = response.data;
      return modelsData.map((modelData) {
        return HuggingFaceModel.fromJson(modelData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search models: $e');
    }
  }

  Future<List<HuggingFaceModel>> getModelFiles(String modelId) async {
    try {
      final response = await _dio.get(
        'https://huggingface.co/api/models/$modelId',
      );

      final siblings = response.data['siblings'] as List<dynamic>;
      final ggufFiles = siblings.where((file) {
        final filename = file['rfilename'] as String;
        return filename.endsWith('.gguf');
      }).toList();

      return ggufFiles.map((file) {
        return HuggingFaceModel(
          id: modelId,
          modelId: modelId,
          downloads: response.data['downloads'] ?? 0,
          likes: response.data['likes'] ?? 0,
          filename: file['rfilename'],
          size: file['size'] ?? 0,
          lastModified: file['lastModified'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get model files: $e');
    }
  }
}