import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/server_status.dart';
import '../../data/models/model_settings.dart';
import '../../data/models/huggingface_model.dart';
import '../../data/repositories/ai_model_repository.dart';
import '../../data/repositories/huggingface_repository.dart';
import '../../services/http_server_service.dart';
import '../../services/network_service.dart';

class ServerProvider with ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  final AIModelRepository _modelRepository = AIModelRepository();
  final HuggingFaceRepository _hfRepository = HuggingFaceRepository();
  late final HttpServerService _httpServerService;

  ServerStatus _status = ServerStatus(
    isRunning: false,
    port: AppConstants.serverPort,
  );

  final List<String> _logs = [];
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  ModelSettings _modelSettings = const ModelSettings();
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  // For models screen
  List<HuggingFaceModel> _availableModels = [];
  List<HuggingFaceModel> _downloadedModels = [];
  bool _isSearching = false;

  ServerProvider() {
    _httpServerService = HttpServerService(
      modelRepository: _modelRepository,
      onLog: _addLog,
    );
    _initialize();
  }

  // Getters
  ServerStatus get status => _status;
  List<String> get logs => List.unmodifiable(_logs);
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  ModelSettings get modelSettings => _modelSettings;
  List<HuggingFaceModel> get availableModels => _availableModels;
  List<HuggingFaceModel> get downloadedModels => _downloadedModels;
  bool get isSearching => _isSearching;

  Future<void> _initialize() async {
    await _requestPermissions();
    await _loadIPAddress();
    await loadDownloadedModels();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _loadIPAddress() async {
    final ip = await _networkService.getLocalIPAddress();
    _status = _status.copyWith(ipAddress: ip ?? 'Unable to get IP');
    notifyListeners();
  }

  Future<void> loadDownloadedModels() async {
    try {
      _addLog('Scanning for downloaded models...');

      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${directory.path}/${AppConstants.modelStorageDir}');

      // Create models directory if it doesn't exist
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
        _addLog('Created models directory');
        _downloadedModels = [];
        notifyListeners();
        return;
      }

      // List all files in the models directory
      final List<FileSystemEntity> files = await modelsDir.list().toList();

      // Filter for GGUF files and create HuggingFaceModel objects
      final List<HuggingFaceModel> downloadedModels = [];

      for (final file in files) {
        if (file is File) {
          final fileName = file.uri.pathSegments.last;

          // Check if it's a GGUF file
          if (fileName.toLowerCase().endsWith('.gguf')) {
            final fileStat = await file.stat();
            final fileSize = fileStat.size;
            final modifiedTime = fileStat.modified;

            // Extract model name from filename (remove .gguf extension)
            String modelName = fileName.replaceAll('.gguf', '');

            // Try to extract more meaningful name from filename
            // Remove common suffixes and clean up the name
            modelName = _cleanModelName(modelName);

            final model = HuggingFaceModel(
              id: fileName, // Use filename as ID for local models
              modelId: modelName,
              downloads: 0, // Local models don't have download counts
              likes: 0,     // Local models don't have likes
              filename: fileName,
              size: fileSize,
              lastModified: modifiedTime.toString(),
            );

            downloadedModels.add(model);
            _addLog('Found local model: $modelName (${model.formattedSize})');
          }
        }
      }

      // Sort by filename alphabetically
      downloadedModels.sort((a, b) => a.filename!.compareTo(b.filename!));

      _downloadedModels = downloadedModels;
      _addLog('Found ${_downloadedModels.length} downloaded models');
      notifyListeners();

    } catch (e, stackTrace) {
      Logger.error('Failed to load downloaded models', error: e, stackTrace: stackTrace);
      _addLog('Error: Failed to scan for downloaded models');
      _downloadedModels = [];
      notifyListeners();
    }
  }

  String _cleanModelName(String name) {
    // Remove common GGUF model suffixes and clean up the name
    final patternsToRemove = [
      '-q4_0', '-q4_1', '-q5_0', '-q5_1', '-q8_0', '-f16',
      '-Q4_0', '-Q4_1', '-Q5_0', '-Q5_1', '-Q8_0', '-F16',
      '-q4_k_m', '-q5_k_m', '-q6_k', '-q8_0',
      '_q4_0', '_q4_1', '_q5_0', '_q5_1', '_q8_0', '_f16',
    ];

    String cleanedName = name;

    // Remove quantization suffixes
    for (final pattern in patternsToRemove) {
      cleanedName = cleanedName.replaceAll(pattern, '');
    }

    // Replace underscores and dashes with spaces for readability
    cleanedName = cleanedName.replaceAll('_', ' ').replaceAll('-', ' ');

    // Capitalize first letter of each word
    cleanedName = cleanedName.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    // Remove extra spaces
    cleanedName = cleanedName.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleanedName.isEmpty ? name : cleanedName;
  }

  // Server methods
  Future<void> startServer() async {
    try {
      await _httpServerService.start();
      _status = _status.copyWith(isRunning: true);
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to start server', error: e);
      _addLog('Error: Failed to start server');
      rethrow;
    }
  }

  Future<void> stopServer() async {
    try {
      await _httpServerService.stop();
      _status = _status.copyWith(isRunning: false);
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to stop server', error: e);
      _addLog('Error: Failed to stop server');
    }
  }

  // Model management methods
  Future<void> searchModels(String query) async {
    _isSearching = true;
    notifyListeners();

    try {
      _availableModels = await _hfRepository.searchModels(query: query);
    } catch (e) {
      Logger.error('Failed to search models', error: e);
      _addLog('Error: Failed to search models');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> downloadAndLoadModel(HuggingFaceModel model) async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      await _modelRepository.downloadAndLoadModel(
        model.downloadUrl,
            (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
      );

      _status = _status.copyWith(
        currentModel: _modelRepository.currentModelName,
      );
      _addLog('Model loaded: ${_modelRepository.currentModelName}');

      // Reload downloaded models list to include the new model
      await loadDownloadedModels();

    } catch (e) {
      Logger.error('Failed to download model', error: e);
      _addLog('Error: Failed to download model');
      rethrow;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocalModel(HuggingFaceModel model) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/${AppConstants.modelStorageDir}/${model.filename}';

      await _modelRepository.loadModel(modelPath, model.modelId);
      _status = _status.copyWith(currentModel: model.modelId);
      _addLog('Model loaded: ${model.modelId}');
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load local model', error: e);
      _addLog('Error: Failed to load model: ${model.modelId}');
      rethrow;
    }
  }

  Future<void> deleteLocalModel(HuggingFaceModel model) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/${AppConstants.modelStorageDir}/${model.filename}';
      final file = File(modelPath);

      if (await file.exists()) {
        await file.delete();
        _addLog('Deleted model: ${model.modelId}');

        // Remove from downloaded models list
        _downloadedModels.removeWhere((m) => m.filename == model.filename);
        notifyListeners();

        // If the deleted model was currently loaded, unload it
        if (_status.currentModel == model.modelId) {
          _modelRepository.dispose();
          _status = _status.copyWith(currentModel: null);
          _addLog('Unloaded deleted model');
          notifyListeners();
        }
      }
    } catch (e) {
      Logger.error('Failed to delete model', error: e);
      _addLog('Error: Failed to delete model: ${model.modelId}');
      rethrow;
    }
  }

  // Settings methods
  void updateModelSettings(ModelSettings newSettings) {
    _modelSettings = newSettings;
    if (_modelRepository.currentModel != null) {
      _modelRepository.currentModel!.settings = newSettings;
    }
    notifyListeners();
  }

  // Chat methods
  Future<String> generateResponse(String prompt) async {
    if (_isGenerating) {
      throw Exception('Already generating a response');
    }

    _isGenerating = true;
    notifyListeners();

    try {
      final model = _modelRepository.currentModel;
      if (model == null) {
        throw Exception('No model loaded');
      }

      final response = await model.generate(prompt);
      return response;
    } catch (e) {
      Logger.error('Failed to generate response', error: e);
      rethrow;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }


  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logs.insert(0, '$timestamp - $message');
    if (_logs.length > AppConstants.maxLogs) {
      _logs.removeLast();
    }
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _httpServerService.dispose();
    _modelRepository.dispose();
    super.dispose();
  }
}