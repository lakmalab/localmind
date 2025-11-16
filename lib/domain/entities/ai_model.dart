import 'package:llama_flutter_android/llama_flutter_android.dart';
import '../../core/utils/logger.dart';

abstract class AIModel {
  Future<void> initialize();
  Future<String> generate(String prompt);
  void dispose();
}

class LlamaGGUFModel implements AIModel {
  final String modelPath;
  late final LlamaController _llama;
  bool _isInitialized = false;

  LlamaGGUFModel(this.modelPath);

  @override
  Future<void> initialize() async {
    try {
      Logger.log('Initializing GGUF model from: $modelPath', tag: 'LLAMA_MODEL');

      // Create the controller and load the model
      _llama = LlamaController();
      await _llama.loadModel(
        modelPath: modelPath,
        threads: 4,
        contextSize: 2048,
        //batchSize: 512,
      );

      _isInitialized = true;
      Logger.log('GGUF model initialized successfully', tag: 'LLAMA_MODEL');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize GGUF model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> generate(String prompt) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized. Call initialize() first.');
    }

    try {
      Logger.log('Generating response for prompt length: ${prompt.length}', tag: 'LLAMA_MODEL');

      final outputStream = _llama.generate(
        prompt: prompt,
        maxTokens: 64,      // small responses
        temperature: 0.3,   // less random
        topK: 20,
        topP: 0.8,
        repeatPenalty: 1.0,
      );


      // Collect tokens into a single string
      final buffer = StringBuffer();
      await for (final chunk in outputStream) {
        buffer.write(chunk);

      }

      final responseText = buffer.toString();
      Logger.log('Response generated: ${responseText.length} chars', tag: 'LLAMA_MODEL');
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

  MockAIModel(this.modelPath);

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    Logger.log('Mock model initialized: $modelPath', tag: 'MOCK_MODEL');
  }

  @override
  Future<String> generate(String prompt) async {
    Logger.log('Mock generating response', tag: 'MOCK_MODEL');
    await Future.delayed(const Duration(seconds: 1));
    return "This is a MOCK response to: $prompt\n\nTo use real AI, ensure flutter_llama is properly installed and a model is loaded.";
  }

  @override
  void dispose() {
    Logger.log('Mock model disposed', tag: 'MOCK_MODEL');
  }
}
