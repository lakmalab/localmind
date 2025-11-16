import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/huggingface_model.dart';
import '../providers/server_provider.dart';
import '../widgets/model_list_item.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    // Load initial models after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchModels('gguf');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounced search - wait 500ms after user stops typing
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty && _tabController.index == 0) {
        _searchModels(query);
      }
    });
  }

  void _searchModels(String query) {
    final provider = Provider.of<ServerProvider>(context, listen: false);
    provider.searchModels(query);
  }

  Future<void> _refreshDownloadedModels() async {
    final provider = Provider.of<ServerProvider>(context, listen: false);
    // This will trigger a rebuild when models are loaded
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing downloaded models...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Models'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.cloud_download),
              text: 'Available',
            ),
            Tab(
              icon: Icon(Icons.storage),
              text: 'Downloaded',
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 1) // Only show refresh button for downloaded models
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDownloadedModels,
              tooltip: 'Refresh Downloaded Models',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Hugging Face Models',
                hintText: 'Search for GGUF models...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _tabController.index == 0
                    ? IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      _searchModels(query);
                    }
                  },
                )
                    : null,
              ),
              onSubmitted: _tabController.index == 0
                  ? (query) {
                if (query.isNotEmpty) {
                  _searchModels(query);
                }
              }
                  : null,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableModels(),
                _buildDownloadedModels(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableModels() {
    return Consumer<ServerProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Searching Hugging Face...'),
              ],
            ),
          );
        }

        if (provider.availableModels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No models found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Try searching for GGUF models',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final query = _searchController.text.trim();
            if (query.isNotEmpty) {
              _searchModels(query);
            } else {
              _searchModels('gguf');
            }
          },
          child: ListView.builder(
            itemCount: provider.availableModels.length,
            itemBuilder: (context, index) {
              final model = provider.availableModels[index];
              return ModelListItem(
                model: model,
                onDownload: () => _downloadModel(provider, model),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDownloadedModels() {
    return Consumer<ServerProvider>(
      builder: (context, provider, child) {
        if (provider.downloadedModels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No downloaded models',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Download models from the Available tab',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshDownloadedModels,
          child: ListView.builder(
            itemCount: provider.downloadedModels.length,
            itemBuilder: (context, index) {
              final model = provider.downloadedModels[index];
              return ModelListItem(
                model: model,
                isDownloaded: true,
                onLoad: () => _loadModel(provider, model),
                onDelete: () => _deleteModel(provider, model),
              );
            },
          ),
        );
      },
    );
  }

  void _downloadModel(ServerProvider provider, HuggingFaceModel model) async {
    // Check storage permission first
    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to download models'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    try {
      await provider.downloadAndLoadModel(model);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${model.modelId} downloaded and loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _loadModel(ServerProvider provider, HuggingFaceModel model) async {
    try {
      await provider.loadLocalModel(model);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${model.modelId} loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load model: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteModel(ServerProvider provider, HuggingFaceModel model) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${model.modelId}"?'),
            const SizedBox(height: 8),
            if (model.filename != null)
              Text(
                'File: ${model.filename!}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            Text(
              'Size: ${model.formattedSize}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone and the model file will be permanently deleted from your device.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await provider.deleteLocalModel(model);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${model.modelId} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete model: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}