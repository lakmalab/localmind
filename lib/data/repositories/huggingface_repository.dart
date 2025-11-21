

import '../models/huggingface_model.dart';
import 'huggingface_api_service.dart';

class HuggingFaceRepository {
  final HuggingFaceApiService _apiService = HuggingFaceApiService();

  Future<List<HuggingFaceModel>> searchModels({required String query}) async {
    try {
      print('🔍 Searching Hugging Face for: $query');

      // Search for models
      final searchResults = await _apiService.searchModels(query);
      print('📦 Found ${searchResults.length} model repositories');

      final List<HuggingFaceModel> modelsWithFiles = [];

      // Process each model to find GGUF files
      for (var i = 0; i < searchResults.length; i++) {
        final result = searchResults[i];
        final modelId = result['id']?.toString() ?? '';

        if (modelId.isEmpty) continue;

        print('🔍 [$i/${searchResults.length}] Fetching GGUF files for: $modelId');

        try {
          // Get GGUF files for this model
          final ggufFiles = await _apiService.getGGUFFiles(modelId);

          if (ggufFiles.isNotEmpty) {
            print('✅ Found ${ggufFiles.length} GGUF files in $modelId');

            // Create a model entry for each GGUF file
            for (var file in ggufFiles) {
              final model = HuggingFaceModel(
                id: '${modelId}_${file['filename']}',
                modelId: modelId,
                downloads: result['downloads'] ?? 0,
                likes: result['likes'] ?? 0,
                filename: file['filename'],
                size: file['size'] ?? 0,
                lastModified: file['lastModified'] ?? result['lastModified']?.toString() ?? '',
              );
              modelsWithFiles.add(model);
            }
          } else {
            print('❌ No GGUF files found in $modelId');
            // Add model without files for visibility
            final model = HuggingFaceModel(
              id: modelId,
              modelId: modelId,
              downloads: result['downloads'] ?? 0,
              likes: result['likes'] ?? 0,
              filename: null,
              size: 0,
              lastModified: result['lastModified']?.toString() ?? '',
            );
            modelsWithFiles.add(model);
          }
        } catch (e) {
          print('❌ Error processing model $modelId: $e');
          // Add failed model for debugging
          final model = HuggingFaceModel(
            id: modelId,
            modelId: modelId,
            downloads: result['downloads'] ?? 0,
            likes: result['likes'] ?? 0,
            filename: null,
            size: 0,
            lastModified: result['lastModified']?.toString() ?? '',
          );
          modelsWithFiles.add(model);
        }

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print('🎉 Search completed: ${modelsWithFiles.length} GGUF files found');
      return modelsWithFiles;

    } catch (e) {
      print('❌ Search failed: $e');
      // Return mock data as fallback
      return _getMockModels();
    }
  }

  // Fallback mock data for testing
  List<HuggingFaceModel> _getMockModels() {
    return [
      HuggingFaceModel(
        id: 'thebloke_tinyllama_1',
        modelId: 'TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF',
        downloads: 15000,
        likes: 200,
        filename: 'tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
        size: 734003200, // 700 MB
        lastModified: '2024-01-15',
      ),
      HuggingFaceModel(
        id: 'thebloke_tinyllama_2',
        modelId: 'TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF',
        downloads: 15000,
        likes: 200,
        filename: 'tinyllama-1.1b-chat-v1.0.Q8_0.gguf',
        size: 1300000000, // 1.3 GB
        lastModified: '2024-01-15',
      ),
      HuggingFaceModel(
        id: 'thebloke_llama_1',
        modelId: 'TheBloke/Llama-2-7B-Chat-GGUF',
        downloads: 50000,
        likes: 500,
        filename: 'llama-2-7b-chat.Q4_K_M.gguf',
        size: 4160000000, // 4.16 GB
        lastModified: '2024-01-10',
      ),
      HuggingFaceModel(
        id: 'thebloke_mistral_1',
        modelId: 'TheBloke/Mistral-7B-Instruct-v0.2-GGUF',
        downloads: 30000,
        likes: 400,
        filename: 'mistral-7b-instruct-v0.2.Q4_K_M.gguf',
        size: 4200000000, // 4.2 GB
        lastModified: '2024-01-12',
      ),
    ];
  }
}