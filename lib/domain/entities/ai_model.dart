import 'package:llama_flutter_android/llama_flutter_android.dart';
import '../../core/utils/logger.dart';
import '../../data/models/model_settings.dart';

abstract class AIModel {
  Future<void> initialize();
  Future<String> generate(String prompt, {ModelSettings? settings});
  Stream<String> generateStream(String prompt, {ModelSettings? settings}); // Add this
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
  Stream<String> generateStream(String prompt, {ModelSettings? settings}) async* {
    if (!_isInitialized) throw Exception('Model not initialized.');

    final currentSettings = settings ?? _settings;

    try {
      Logger.log('Generating streaming response', tag: 'LLAMA_MODEL');

      // Simple prompt format
      final formattedPrompt = "Q: $prompt\nA:";

      final outputStream = _llama.generate(
        prompt: formattedPrompt,
        maxTokens: 100, // Keep it short to prevent rambling
        temperature: currentSettings.temperature,
        topK: currentSettings.topK,
        topP: currentSettings.topP,
        repeatPenalty: currentSettings.repeatPenalty + 0.3, // Strong repetition penalty
      );

      final buffer = StringBuffer();
      final List<String> recentTokens = [];
      const int repetitionWindow = 8;
      bool gotCompleteAnswer = false;

      await for (final chunk in outputStream) {
        // Yield each chunk immediately for streaming
        yield chunk;
        buffer.write(chunk);

        // Add to recent tokens for repetition detection
        recentTokens.add(chunk);
        if (recentTokens.length > repetitionWindow) {
          recentTokens.removeAt(0);
        }

        // Check for repetition
        if (_hasRepetition(recentTokens)) {
          Logger.log('Repetition detected, stopping generation', tag: 'LLAMA_MODEL');
          break;
        }

        // Stop if we get a complete answer (ends with punctuation)
        if (!gotCompleteAnswer && (chunk.contains('.') || chunk.contains('?') || chunk.contains('!'))) {
          gotCompleteAnswer = true;
          // Continue for a bit more to get full context
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Stop if model starts generating new questions (rambling)
        if (chunk.contains('Q:') && buffer.length > 20) {
          Logger.log('Model started rambling, stopping generation', tag: 'LLAMA_MODEL');
          break;
        }
      }

      Logger.log('Streaming generation completed', tag: 'LLAMA_MODEL');
    } catch (e, stackTrace) {
      Logger.error('Failed to generate streaming response', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  bool _hasRepetition(List<String> recentTokens) {
    if (recentTokens.length < 6) return false;

    // Check for character-level repetition
    final text = recentTokens.join('');
    if (RegExp(r'(.)\1{5,}').hasMatch(text)) {
      return true;
    }

    return false;
  }
  @override
  Future<String> generate(String prompt, {ModelSettings? settings}) async {
    if (!_isInitialized) throw Exception('Model not initialized.');

    final currentSettings = settings ?? _settings;

    try {
      Logger.log('Generating response with settings: $currentSettings', tag: 'LLAMA_MODEL');

      final formattedPrompt = "Q: $prompt\nA:";

      final outputStream = _llama.generate(
        prompt: formattedPrompt,
        maxTokens: currentSettings.maxTokens,
        temperature: currentSettings.temperature,
        topK: currentSettings.topK,
        topP: currentSettings.topP,
        repeatPenalty: currentSettings.repeatPenalty,
      );

      final buffer = StringBuffer();
      final List<String> recentTokens = [];
      const int repetitionWindow = 10; // Check last 10 tokens for repetition

      await for (final chunk in outputStream) {
        buffer.write(chunk);

        // Add to recent tokens for repetition detection
        recentTokens.add(chunk);
        if (recentTokens.length > repetitionWindow) {
          recentTokens.removeAt(0);
        }

        // Check for repetition in recent tokens
        if (_hasRepetition(recentTokens)) {
          Logger.log('Repetition detected, stopping generation', tag: 'LLAMA_MODEL');
          break;
        }
      }

      String responseText = buffer.toString().trim();

      // Simple cleanup - just remove the initial "A:" if present
      responseText = responseText.replaceAll(RegExp(r'^A:\s*'), '');

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

  // ADDED: Implement generateStream for MockAIModel
  @override
  Stream<String> generateStream(String prompt, {ModelSettings? settings}) async* {
    final currentSettings = settings ?? _settings;
    Logger.log('Mock streaming response: $currentSettings', tag: 'MOCK_MODEL');

    // Simulate streaming by breaking the response into chunks
    final response = "This is a MOCK streaming response to: $prompt\n\nSettings used: temperature=${currentSettings.temperature}, maxTokens=${currentSettings.maxTokens}";

    // Split into words and yield them with delays to simulate streaming
    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield '${words[i]} ';
    }
  }

  @override
  void dispose() {
    Logger.log('Mock model disposed', tag: 'MOCK_MODEL');
  }
}