# LocalMind - Local AI Chatbot Server

<div align="center">

![LocalMind](https://img.shields.io/badge/LocalMind-AI%20Chatbot-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)
![Android](https://img.shields.io/badge/Platform-Android-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

**Run AI models locally on your Android device and serve them over your network with a beautiful web interface**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture) • [API](#-api)

</div>

## 📖 Overview

LocalMind is a production-ready Flutter Android application that enables you to run local AI models on your Android device and access them from any device on your local network through a beautiful web interface. Perfect for creating your own private AI assistant without relying on cloud services.

## 🚀 Features

- **🔒 Local AI Processing**: Run AI models completely offline on your Android device
- **🌐 Web Interface**: Beautiful chat UI accessible from any device on your network
- **📱 Cross-Platform Access**: Use from PC, tablet, or other phones via browser
- **⬇️ Model Download**: Direct download from Hugging Face with progress tracking
- **📊 Real-time Monitoring**: Live server logs and status updates
- **🔄 REST API**: Full HTTP API for integration with other applications
- **🎯 Clean Architecture**: Maintainable and scalable codebase
- **🚦 CORS Enabled**: Ready for web application integration

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # Application constants
│   └── utils/
│       └── logger.dart               # Logging utility
├── data/
│   ├── models/
│   │   ├── chat_message.dart         # Chat message data model
│   │   └── server_status.dart        # Server status data model
│   └── repositories/
│       └── ai_model_repository.dart  # Model management repository
├── domain/
│   ├── entities/
│   │   └── ai_model.dart             # AI model interface & implementation
│   └── usecases/
│       └── generate_response_usecase.dart  # Business logic
├── presentation/
│   ├── providers/
│   │   └── server_provider.dart      # State management with Provider
│   ├── screens/
│   │   └── server_home_screen.dart   # Main screen
│   └── widgets/
│       ├── logs_card.dart            # Logs display widget
│       ├── model_card.dart           # Model management widget
│       └── server_card.dart          # Server control widget
└── services/
    ├── http_server_service.dart      # HTTP server implementation
    ├── network_service.dart          # Network utilities
    └── web_ui_service.dart           # Web UI HTML template
```

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

- **Presentation Layer**: UI components (screens, widgets) and state management (Provider)
- **Domain Layer**: Business logic and entities (interfaces, use cases)
- **Data Layer**: Data models and repositories
- **Services Layer**: External services (HTTP server, network)
- **Core Layer**: Utilities and constants

### Design Patterns Used:
- **Repository Pattern**: Abstracts data source operations
- **Provider Pattern**: State management across the app
- **Dependency Injection**: Through constructor injection
- **Single Responsibility**: Each class has one clear purpose

## 🚀 Features

- ✅ HTTP REST API server running on Android
- ✅ Beautiful web chat interface accessible from any device
- ✅ Download models directly from Hugging Face
- ✅ Real-time server logs and monitoring
- ✅ Clean architecture with best practices
- ✅ Type-safe state management with Provider
- ✅ CORS enabled for cross-origin requests
- ✅ Error handling and logging throughout

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Android device or emulator (API level 21+)

## 🛠️ Installation

### 1. Clone and Setup

```bash
# Navigate to your project directory
cd your_project

# Install dependencies
flutter pub get
```

### 2. Configure Android Permissions

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <application
        ...
        android:usesCleartextTraffic="true">  <!-- Add this -->
        ...
    </application>
</manifest>
```

### 3. Choose and Add AI Model Package

Choose one based on your needs:

**Option A: LLaMA Models (Recommended)**
```yaml
dependencies:
  llama_cpp_dart: ^0.1.0
```

**Option B: TensorFlow Lite**
```yaml
dependencies:
  tensorflow_lite_flutter: ^0.10.0
```

### 4. Implement Real AI Model

Replace the `MockAIModel` in `lib/domain/entities/ai_model.dart` with your chosen implementation:

```dart
// Example with llama_cpp_dart
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LlamaAIModel implements AIModel {
  final String modelPath;
  late LlamaCpp _llama;
  
  LlamaAIModel(this.modelPath);
  
  @override
  Future<void> initialize() async {
    _llama = LlamaCpp();
    await _llama.loadModel(modelPath);
  }
  
  @override
  Future<String> generate(String prompt) async {
    return await _llama.generate(prompt);
  }
  
  @override
  void dispose() {
    _llama.dispose();
  }
}
```

Then update `AIModelRepository` to use your implementation:

```dart
// In ai_model_repository.dart
_currentModel = LlamaAIModel(path);  // Instead of MockAIModel
```

## 🎮 Usage

### Running the App

```bash
flutter run
```

### Starting the Server

1. Open the app on your Android device
2. Wait for the IP address to load
3. Tap "Start Server"
4. Note your IP address (e.g., `192.168.1.100`)

### Loading a Model

1. Find a GGUF model on Hugging Face (e.g., `https://huggingface.co/.../model.gguf`)
2. Paste the URL in the "Hugging Face Model URL" field
3. Tap "Download & Load Model"
4. Wait for download and initialization

### Using the Web Interface

From any device on the same WiFi network:

1. Open a web browser
2. Navigate to: `http://YOUR_PHONE_IP:8080/chat`
3. Start chatting with your AI!

### Using the API

**Health Check:**
```bash
curl http://192.168.1.100:8080/health
```

**Generate Response:**
```bash
curl -X POST http://192.168.1.100:8080/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello, how are you?"}'
```

**Check Model Info:**
```bash
curl http://192.168.1.100:8080/model
```

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server health check |
| POST | `/generate` | Generate AI response |
| GET | `/model` | Get loaded model info |
| GET | `/chat` | Web chat interface |

## 🎨 Customization

### Change Server Port

Edit `lib/core/constants/app_constants.dart`:

```dart
static const int serverPort = 8080;  // Change to your preferred port
```

### Customize Web UI

Edit `lib/services/web_ui_service.dart` to modify the chat interface design.

### Add New Endpoints

Add routes in `lib/services/http_server_service.dart`:

```dart
router.get('/your-endpoint', _handleYourEndpoint);
```

## 🐛 Troubleshooting

### Server won't start
- Check if another app is using port 8080
- Ensure you have INTERNET permission in AndroidManifest.xml
- Try restarting the app

### Can't access from PC
- Ensure both devices are on the same WiFi network
- Check your phone's firewall settings
- Verify the IP address is correct
- Try disabling VPN if enabled

### Model download fails
- Check internet connection
- Verify the Hugging Face URL is correct and public
- Ensure you have storage permission
- Check available storage space

### Model loading is slow
- Large models (>1GB) take time to load
- Use quantized models (GGUF format) for faster loading
- Consider using smaller models for testing

## 📚 Further Development

### Adding Authentication
Implement authentication middleware in `http_server_service.dart`

### Adding Database
Add a database layer using `sqflite` or `hive`

### Adding More Features
- Chat history persistence
- Multiple model support
- System prompts customization
- Response streaming
- File upload support

## 🤝 Contributing

This is a template project. Feel free to:
- Fork and modify
- Add new features
- Improve documentation
- Share your implementations

## 📄 License

This project structure is provided as-is for educational and development purposes.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hugging Face for model hosting
- Shelf package for HTTP server capabilities
- Provider package for state management

---

**Note**: Replace the mock AI model with a real implementation before production use. The current implementation is for demonstration purposes only.