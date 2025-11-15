import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';

class ModelCard extends StatefulWidget {
  const ModelCard({super.key});

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  final TextEditingController _modelUrlController = TextEditingController();

  @override
  void dispose() {
    _modelUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerProvider>(
      builder: (context, provider, child) {
        final status = provider.status;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Model',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Current Model: ${status.currentModel ?? "None"}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _modelUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Hugging Face Model URL',
                    hintText: 'https://huggingface.co/.../model.gguf',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !provider.isDownloading,
                ),
                const SizedBox(height: 8),
                if (provider.isDownloading) ...[
                  LinearProgressIndicator(value: provider.downloadProgress),
                  const SizedBox(height: 8),
                  Text(
                    '${(provider.downloadProgress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: provider.isDownloading
                      ? null
                      : () async {
                    if (_modelUrlController.text.isNotEmpty) {
                      try {
                        await provider.downloadAndLoadModel(
                          _modelUrlController.text,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Model loaded successfully!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to load model: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download & Load Model'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}