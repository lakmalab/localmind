import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import '../../core/utils/logger.dart';

abstract class AIModel {
  Future<void> initialize();
  Future<String> generate(String prompt);
  void dispose();
}

class LlamaGGUFModel implements AIModel {
  final String modelPath;
  Llama? _llamaInstance;
  bool _isInitialized = false;

  LlamaGGUFModel(this.modelPath);

  @override
  Future<void> initialize() async {
    try {
      Logger.log('Initializing GGUF model from: $modelPath', tag: 'LLAMA_MODEL');

      // Correct ContextParams fields
      final contextParams = ContextParams()
        ..nCtx = 2048
        ..nBatch = 512
        ..nThreads = 4;

      // Correct ModelParams fields
      final modelParams = ModelParams()
        ..nGpuLayers = 0;

      // Initialize Llama
      _llamaInstance = Llama(
        modelPath,
        modelParams,
        contextParams,
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
    if (!_isInitialized || _llamaInstance == null) {
      throw Exception('Model not initialized. Call initialize() first.');
    }

    try {
      Logger.log('Generating response for prompt length: ${prompt.length}', tag: 'LLAMA_MODEL');

      // Format prompt for Gemma (adjust based on model)
      final formattedPrompt = '''<start_of_turn>user
$prompt<end_of_turn>
<start_of_turn>model
''';

      // Set the prompt
      _llamaInstance!.setPrompt(formattedPrompt);

      // Generate response by collecting tokens
      final responseBuffer = StringBuffer();
      int tokenCount = 0;
      final maxTokens = 512;

      while (tokenCount < maxTokens) {
        final (token, done) = _llamaInstance!.getNext();

        if (done) break;

        // Stop on special tokens
        if (token.contains('<end_of_turn>') || token.contains('<start_of_turn>')) {
          break;
        }

        responseBuffer.write(token);
        tokenCount++;
      }

      final response = responseBuffer.toString().trim();
      Logger.log('Response generated successfully: $tokenCount tokens', tag: 'LLAMA_MODEL');
      return response;

    } catch (e, stackTrace) {
      Logger.error('Failed to generate response', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  void dispose() {
    try {
      _llamaInstance?.dispose();
      _llamaInstance = null;
      _isInitialized = false;
      Logger.log('Model disposed', tag: 'LLAMA_MODEL');
    } catch (e) {
      Logger.error('Error disposing model', error: e);
    }
  }
}

// Fallback mock model for testing
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
    return "This is a MOCK response to: $prompt\n\nTo use real AI, ensure llama_cpp_dart is properly installed.";
  }

  @override
  void dispose() {
    Logger.log('Mock model disposed', tag: 'MOCK_MODEL');
  }
}