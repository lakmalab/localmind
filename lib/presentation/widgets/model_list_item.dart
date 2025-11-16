import 'package:flutter/material.dart';
import '../../data/models/huggingface_model.dart';

class ModelListItem extends StatelessWidget {
  final HuggingFaceModel model;
  final bool isDownloaded;
  final VoidCallback? onDownload;
  final VoidCallback? onLoad;
  final VoidCallback? onDelete;

  const ModelListItem({
    super.key,
    required this.model,
    this.isDownloaded = false,
    this.onDownload,
    this.onLoad,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                    model.modelId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDownloaded)
                  const Icon(Icons.download_done, color: Colors.green, size: 20)
                else
                  const Icon(Icons.download, color: Colors.blue, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            if (model.filename != null) ...[
              Text(
                'File: ${model.filename!}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                _buildInfoChip(
                  Icons.storage,
                  model.formattedSize,
                ),
                const SizedBox(width: 8),
                if (!isDownloaded) ...[
                  _buildInfoChip(
                    Icons.download,
                    '${model.downloads} downloads',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.favorite,
                    '${model.likes} likes',
                  ),
                ] else ...[
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
            else
              ElevatedButton.icon(
                onPressed: onDownload,
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
}