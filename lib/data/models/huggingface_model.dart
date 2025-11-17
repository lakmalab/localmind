class HuggingFaceModel {
  final String id;
  final String modelId;
  final int downloads;
  final int likes;
  final String? filename;
  final int size;
  final String lastModified;

  HuggingFaceModel({
    required this.id,
    required this.modelId,
    required this.downloads,
    required this.likes,
    this.filename,
    required this.size,
    required this.lastModified,
  });

  factory HuggingFaceModel.fromJson(Map<String, dynamic> json) {
    // Try multiple possible filename fields from Hugging Face API
    final filename = json['rfilename'] ??
        json['filename'] ??
        json['key'] ??
        json['name'];

    return HuggingFaceModel(
      id: json['_id'] ?? json['id'] ?? '',
      modelId: json['modelId'] ?? json['id'] ?? '',
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
      filename: filename, // This could still be null
      size: json['size'] ?? 0,
      lastModified: json['lastModified'] ?? '',
    );
  }

  String get downloadUrl {
    if (filename == null || filename!.isEmpty) {
      return '';
    }
    return 'https://huggingface.co/$modelId/resolve/main/$filename';
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Add a validation method
  bool get isValidForDownload {
    return modelId.isNotEmpty &&
        filename != null &&
        filename!.isNotEmpty &&
        !filename!.toLowerCase().contains('null');
  }
}