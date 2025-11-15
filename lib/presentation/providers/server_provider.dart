import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/server_status.dart';
import '../../data/repositories/ai_model_repository.dart';
import '../../services/http_server_service.dart';
import '../../services/network_service.dart';

class ServerProvider with ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  final AIModelRepository _modelRepository = AIModelRepository();
  late final HttpServerService _httpServerService;

  ServerStatus _status = ServerStatus(
    isRunning: false,
    port: AppConstants.serverPort,
  );

  final List<String> _logs = [];
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

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

  Future<void> _initialize() async {
    await _requestPermissions();
    await _loadIPAddress();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _loadIPAddress() async {
    final ip = await _networkService.getLocalIPAddress();
    _status = _status.copyWith(ipAddress: ip ?? 'Unable to get IP');
    notifyListeners();
  }

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

  Future<void> downloadAndLoadModel(String url) async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      await _modelRepository.downloadAndLoadModel(
        url,
            (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
      );

      _status = _status.copyWith(
        currentModel: _modelRepository.currentModelName,
      );
      _addLog('Model loaded: ${_modelRepository.currentModelName}');
    } catch (e) {
      Logger.error('Failed to download model', error: e);
      _addLog('Error: Failed to download model');
      rethrow;
    } finally {
      _isDownloading = false;
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
