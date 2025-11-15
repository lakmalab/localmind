import 'dart:developer' as Logger;

abstract class AIModel {
  Future<void> initialize();
  Future<String> generate(String prompt);
  void dispose();
}

class MockAIModel implements AIModel {
  final String modelPath;

  MockAIModel(this.modelPath);

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    Logger.log('Model initialized: $modelPath', name: 'AI_MODEL');
  }

  @override
  Future<String> generate(String prompt) async {
    Logger.log('Generating response for: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...', name: 'AI_MODEL');
    await Future.delayed(const Duration(seconds: 1));
    return "This is a mock response to: $prompt\n\nReplace with actual model inference.";
  }

  @override
  void dispose() {
    Logger.log('Model disposed', name: 'AI_MODEL');
  }
}