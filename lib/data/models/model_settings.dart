class ModelSettings {
  final double temperature;
  final int maxTokens;
  final double topP;
  final int topK;
  final double repeatPenalty;
  final String systemPrompt;

  const ModelSettings({
    this.temperature = 0.2,
    this.maxTokens = 512,
    this.topP = 0.8,
    this.topK = 40,
    this.repeatPenalty = 1.0,
    this.systemPrompt = 'You are a helpful assistant. Answer concisely and stay on topic.',
  });

  ModelSettings copyWith({
    double? temperature,
    int? maxTokens,
    double? topP,
    int? topK,
    double? repeatPenalty,
    String? systemPrompt,
  }) {
    return ModelSettings(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
      repeatPenalty: repeatPenalty ?? this.repeatPenalty,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'topK': topK,
      'repeatPenalty': repeatPenalty,
      'systemPrompt': systemPrompt,
    };
  }

  factory ModelSettings.fromJson(Map<String, dynamic> json) {
    return ModelSettings(
      temperature: json['temperature'] ?? 0.2,
      maxTokens: json['maxTokens'] ?? 512,
      topP: json['topP'] ?? 0.8,
      topK: json['topK'] ?? 40,
      repeatPenalty: json['repeatPenalty'] ?? 1.0,
      systemPrompt: json['systemPrompt'] ?? 'You are a helpful assistant. Answer concisely and stay on topic.',
    );
  }
}