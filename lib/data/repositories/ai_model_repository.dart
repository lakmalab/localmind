import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/ai_model.dart';
import '../../core/utils/logger.dart';

class AIModelRepository {
  AIModel? _currentModel;
  String? _currentModelName;

  AIModel? get currentModel => _currentModel;
  String? get currentModelName => _currentModelName;

  Future<void> downloadAndLoadModel(
      String url,
      Function(double) onProgress,
      ) async {
    try {
      final modelName = url.split('/').last;
      Logger.log('Starting download: $modelName', tag: 'REPOSITORY');

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$modelName';

      final request = await http.Client().send(
          http.Request('GET', Uri.parse(url))
      );
      final contentLength = request.contentLength ?? 0;

      final file = File(filePath);
      final sink = file.openWrite();
      var downloaded = 0;

      await for (var chunk in request.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (contentLength > 0) {
          onProgress(downloaded / contentLength);
        }
      }

      await sink.close();
      Logger.log('Download complete: $modelName', tag: 'REPOSITORY');

      await loadModel(filePath, modelName);
    } catch (e, stackTrace) {
      Logger.error('Failed to download model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> loadModel(String path, String name) async {
    try {
      _currentModel?.dispose();
      _currentModel = MockAIModel(path);
      await _currentModel!.initialize();
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
