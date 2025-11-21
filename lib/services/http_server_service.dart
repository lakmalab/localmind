import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../data/repositories/ai_model_repository.dart';
import 'web_ui_service.dart';

class HttpServerService {
  HttpServer? _server;
  final AIModelRepository _modelRepository;
  final Function(String) _onLog;

  HttpServerService({
    required AIModelRepository modelRepository,
    required Function(String) onLog,
  })  : _modelRepository = modelRepository,
        _onLog = onLog;

  bool get isRunning => _server != null;

  Future<void> start() async {
    try {
      final router = _createRouter();
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_corsMiddleware())
          .addHandler(router);

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        AppConstants.serverPort,
      );

      Logger.log('Server started on port ${AppConstants.serverPort}', tag: 'HTTP_SERVER');
      _onLog('Server started successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to start server', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    Logger.log('Server stopped', tag: 'HTTP_SERVER');
    _onLog('Server stopped');
  }

  Router _createRouter() {
    final router = Router();

    router.get(AppConstants.healthEndpoint, _handleHealth);
    router.post(AppConstants.generateEndpoint, _handleGenerate);
    router.get(AppConstants.modelEndpoint, _handleModelInfo);
    router.get(AppConstants.chatEndpoint, _handleChatUI);

    return router;
  }

  Response _handleHealth(Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'online',
        'model': _modelRepository.currentModelName ?? 'none',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleGenerate(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final prompt = payload['prompt'] as String?;

      if (prompt == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing prompt parameter'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final model = _modelRepository.currentModel;
      if (model == null) {
        return Response(
          503,
          body: jsonEncode({'error': 'No model loaded'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      _onLog('Processing prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');
      final response = await model.generate(prompt);

      return Response.ok(
        jsonEncode({
          'response': response,
          'model': _modelRepository.currentModelName,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      Logger.error('Generate endpoint error', error: e, stackTrace: stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Response _handleModelInfo(Request request) {
    return Response.ok(
      jsonEncode({
        'loaded': _modelRepository.currentModel != null,
        'model_name': _modelRepository.currentModelName ?? 'none',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleChatUI(Request request) {
    return Response.ok(
      WebUIService.getChatHTML(),
      headers: {'Content-Type': 'text/html'},
    );
  }

  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final response = await handler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        });
      };
    };
  }

  void dispose() {
    stop();
  }
}