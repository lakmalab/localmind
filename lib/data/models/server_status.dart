class ServerStatus {
  final bool isRunning;
  final String? ipAddress;
  final int port;
  final String? currentModel;

  ServerStatus({
    required this.isRunning,
    this.ipAddress,
    required this.port,
    this.currentModel,
  });

  ServerStatus copyWith({
    bool? isRunning,
    String? ipAddress,
    int? port,
    String? currentModel,
  }) {
    return ServerStatus(
      isRunning: isRunning ?? this.isRunning,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      currentModel: currentModel ?? this.currentModel,
    );
  }
}