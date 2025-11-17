import 'package:flutter/material.dart';
import '../../data/models/huggingface_model.dart';

class ModelListItem extends StatelessWidget {
  final HuggingFaceModel model;
  final bool isDownloaded;
  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback? onDownload;
  final VoidCallback? onLoad;
  final VoidCallback? onDelete;

  const ModelListItem({
    super.key,
    required this.model,
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.onDownload,
    this.onLoad,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isValidForDownload = model.isValidForDownload;

    print('🔄 ModelListItem building - modelId: "${model.modelId}", filename: "${model.filename}", isValid: $isValidForDownload, isDownloading: $isDownloading, progress: $downloadProgress');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    model.modelId.isNotEmpty ? model.modelId : 'Unknown Model',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDownloading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: downloadProgress > 0 ? downloadProgress : null,
                      strokeWidth: 3,
                    ),
                  )
                else if (isDownloaded)
                  const Icon(Icons.download_done, color: Colors.green, size: 20)
                else if (!isValidForDownload)
                    const Icon(Icons.warning, color: Colors.orange, size: 20)
                  else
                    const Icon(Icons.download, color: Colors.blue, size: 20),
              ],
            ),
            const SizedBox(height: 8),

            // Show filename or warning
            if (model.filename != null && model.filename!.isNotEmpty)
              Text(
                'File: ${model.filename!}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              )
            else
              const Text(
                'No GGUF file available',
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ),

            const SizedBox(height: 4),

            // Download progress bar
            if (isDownloading) ...[
              LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(downloadProgress),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Downloading... ${(downloadProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model.formattedSize}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            Row(
              children: [
                _buildInfoChip(
                  Icons.storage,
                  model.formattedSize.isNotEmpty ? model.formattedSize : 'Unknown size',
                ),
                const SizedBox(width: 8),
                if (!isDownloaded && !isDownloading) ...[
                  _buildInfoChip(
                    Icons.download,
                    '${model.downloads} downloads',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.favorite,
                    '${model.likes} likes',
                  ),
                ] else if (isDownloaded) ...[
                  _buildInfoChip(
                    Icons.calendar_today,
                    'Downloaded',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            if (isDownloaded)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onLoad,
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      label: const Text('Load Model'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete Model',
                  ),
                ],
              )
            else if (isDownloading)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Downloading...'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      // TODO: Implement cancel download functionality
                      _showCancelDialog(context);
                    },
                    tooltip: 'Cancel Download',
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: isValidForDownload ? onDownload : null,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download & Load'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Download?'),
        content: const Text('Are you sure you want to cancel this download?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement cancel download logic
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Download'),
          ),
        ],
      ),
    );
  }
}