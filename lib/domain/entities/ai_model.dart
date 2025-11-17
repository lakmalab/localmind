import 'package:llama_flutter_android/llama_flutter_android.dart';
import '../../core/utils/logger.dart';
import '../../data/models/model_settings.dart';

abstract class AIModel {
  Future<void> initialize();
  Future<String> generate(String prompt, {ModelSettings? settings});
  void dispose();
  ModelSettings get settings;
  set settings(ModelSettings newSettings);
}

class LlamaGGUFModel implements AIModel {
  final String modelPath;
  late final LlamaController _llama;
  bool _isInitialized = false;
  ModelSettings _settings;

  LlamaGGUFModel(this.modelPath, {ModelSettings? settings})
      : _settings = settings ?? const ModelSettings();

  @override
  ModelSettings get settings => _settings;

  @override
  set settings(ModelSettings newSettings) {
    _settings = newSettings;
  }

  @override
  Future<void> initialize() async {
    try {
      Logger.log('Initializing GGUF model from: $modelPath', tag: 'LLAMA_MODEL');

      _llama = LlamaController();
      await _llama.loadModel(
        modelPath: modelPath,
        threads: 4,
        contextSize: 2048,
      );

      _isInitialized = true;
      Logger.log('GGUF model initialized successfully', tag: 'LLAMA_MODEL');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize GGUF model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> generate(String prompt, {ModelSettings? settings}) async {
    if (!_isInitialized) throw Exception('Model not initialized.');

    final currentSettings = settings ?? _settings;

    try {
      Logger.log('Generating response with settings: $currentSettings', tag: 'LLAMA_MODEL');

      // ALTERNATIVE PROMPT FORMAT - Much simpler
      final formattedPrompt = "Q: $prompt\nA:";

      final outputStream = _llama.generate(
        prompt: formattedPrompt,
        maxTokens: currentSettings.maxTokens,
        temperature: currentSettings.temperature, // Try increasing temperature
        topK: currentSettings.topK,
        topP: currentSettings.topP,
        repeatPenalty: currentSettings.repeatPenalty + 0.2, // Increase repetition penalty
      );

      final buffer = StringBuffer();
      int consecutiveRepeats = 0;
      String? lastChunk;

      await for (final chunk in outputStream) {
        // Stop if we see the question being repeated
        if (chunk.contains('Q:') || chunk.contains(prompt.split(' ').take(3).join(' '))) {
          break;
        }

        // Stop if we see repeated chunks
        if (chunk == lastChunk) {
          consecutiveRepeats++;
          if (consecutiveRepeats > 3) break;
        } else {
          consecutiveRepeats = 0;
        }

        buffer.write(chunk);
        lastChunk = chunk;

        // Stop if we see natural ending
        if (chunk.contains('.') || chunk.contains('?') || chunk.contains('!')) {
          await Future.delayed(const Duration(milliseconds: 50));
          // Continue to get complete sentence
        }
      }

      String responseText = buffer.toString().trim();

      // Remove any Q: prefixes that might have been generated
      responseText = responseText.replaceAll(RegExp(r'^Q:\s*'), '');

      Logger.log('Response generated: $responseText', tag: 'LLAMA_MODEL');
      return responseText;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate response', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }



  @override
  void dispose() {
    try {
      _isInitialized = false;
      Logger.log('Model disposed', tag: 'LLAMA_MODEL');
    } catch (e) {
      Logger.error('Error disposing model', error: e);
    }
  }
}

class MockAIModel implements AIModel {
  final String modelPath;
  ModelSettings _settings;

  MockAIModel(this.modelPath, {ModelSettings? settings})
      : _settings = settings ?? const ModelSettings();

  @override
  ModelSettings get settings => _settings;

  @override
  set settings(ModelSettings newSettings) {
    _settings = newSettings;
  }

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    Logger.log('Mock model initialized: $modelPath', tag: 'MOCK_MODEL');
  }

  @override
  Future<String> generate(String prompt, {ModelSettings? settings}) async {
    final currentSettings = settings ?? _settings;
    Logger.log('Something Is wrong Please restart the application: $currentSettings', tag: 'MOCK_MODEL');
    await Future.delayed(const Duration(seconds: 1));
    return "This is a MOCK response to: $prompt\n\nSettings used: temperature=${currentSettings.temperature}, maxTokens=${currentSettings.maxTokens}";
  }

  @override
  void dispose() {
    Logger.log('Mock model disposed', tag: 'MOCK_MODEL');
  }
}