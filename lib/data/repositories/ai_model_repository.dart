import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/ai_model.dart';
import '../../core/utils/logger.dart';

class AIModelRepository {
  AIModel? _currentModel;
  String? _currentModelName;
  final Dio _dio = Dio();

  AIModel? get currentModel => _currentModel;
  String? get currentModelName => _currentModelName;

  /// Downloads model from Hugging Face and loads it
  Future<void> downloadAndLoadModel(
      String url,
      Function(double) onProgress,
      ) async {
    try {
      // Extract model name from URL
      final modelName = url.split('/').last;
      Logger.log('Starting download: $modelName', tag: 'REPOSITORY');

      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${directory.path}/models');

      // Create models directory if it doesn't exist
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      final filePath = '${modelsDir.path}/$modelName';

      // Check if file already exists
      if (await File(filePath).exists()) {
        Logger.log('Model already exists, loading from cache', tag: 'REPOSITORY');
        await loadModel(filePath, modelName);
        return;
      }

      // Convert Hugging Face blob URL to resolve URL for direct download
      String downloadUrl = url;
      if (url.contains('huggingface.co') && url.contains('/blob/')) {
        downloadUrl = url.replaceAll('/blob/', '/resolve/');
        Logger.log('Converted to direct download URL: $downloadUrl', tag: 'REPOSITORY');
      }

      // Download with progress tracking
      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
            if (received % (10 * 1024 * 1024) == 0 || received == total) {
              Logger.log(
                'Download progress: ${(progress * 100).toStringAsFixed(1)}% (${(received / 1024 / 1024).toStringAsFixed(1)}MB / ${(total / 1024 / 1024).toStringAsFixed(1)}MB)',
                tag: 'REPOSITORY',
              );
            }
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      Logger.log('Download complete: $modelName', tag: 'REPOSITORY');

      // Verify file was downloaded
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Downloaded file not found at: $filePath');
      }

      final fileSize = await file.length();
      Logger.log('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB', tag: 'REPOSITORY');

      await loadModel(filePath, modelName);
    } catch (e, stackTrace) {
      Logger.error('Failed to download model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Loads a GGUF model from local path
  Future<void> loadModel(String path, String name) async {
    try {
      // Dispose previous model if exists
      _currentModel?.dispose();

      Logger.log('Loading GGUF model: $name', tag: 'REPOSITORY');

      // Try to load with llama_cpp_dart, fallback to mock if it fails
      try {
        _currentModel = LlamaGGUFModel(path);
        await _currentModel!.initialize();
        Logger.log('Real GGUF model loaded successfully', tag: 'REPOSITORY');
      } catch (e) {
        Logger.error('Failed to load real model, using mock', error: e);
        _currentModel = MockAIModel(path);
        await _currentModel!.initialize();
        Logger.log('Mock model loaded as fallback', tag: 'REPOSITORY');
      }

      _currentModelName = name;
      Logger.log('Model loaded: $name', tag: 'REPOSITORY');
    } catch (e, stackTrace) {
      Logger.error('Failed to load model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void dispose() {
    _currentModel?.dispose();
    _currentModel = null;
    _currentModelName = null;
  }
}
