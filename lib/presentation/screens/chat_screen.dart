import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../../data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  StreamSubscription<String>? _responseSubscription;
  String _currentStreamingResponse = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      content: 'Hello! I\'m your local AI assistant. How can I help you today?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServerProvider>(context);
    final hasModel = provider.status.currentModel != null;
    final isGenerating = provider.isGenerating || _isStreaming;
    final hasText = _messageController.text.trim().isNotEmpty;
    final canSend = hasModel && !isGenerating && hasText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        elevation: 2,
        actions: [
          if (hasModel)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
            const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(hasModel ? 'Model Loaded' : 'No Model'),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          if (!hasModel)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange[100],
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No AI model loaded',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/models');
                          },
                          child: Text(
                            'Tap here to download and load a model',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isStreaming ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isStreaming && index == _messages.length) {
                  // Show streaming response
                  return _buildMessageBubble(
                    ChatMessage(
                      content: _currentStreamingResponse,
                      isUser: false,
                    ),
                    isStreaming: true,
                  );
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (isGenerating)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    enabled: hasModel && !isGenerating,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: (value) {
                      if (canSend) {
                        _sendMessage(provider);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: canSend
                        ? Colors.blue.shade600
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: isGenerating
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(
                      Icons.send,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: canSend
                        ? () => _sendMessage(provider)
                        : null,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, {bool isStreaming = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 16,
                child: Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue.shade600
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content + (isStreaming ? '▊' : ''),
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                radius: 16,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sendMessage(ServerProvider provider) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userMessage = ChatMessage(content: message, isUser: true);
    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _currentStreamingResponse = '';
      _isStreaming = true;
    });
    _scrollToBottom();

    try {
      // Use streaming response
      _responseSubscription = provider.generateResponseStream(message).listen(
            (chunk) {
          setState(() {
            _currentStreamingResponse += chunk;
          });
          _scrollToBottom();
        },
        onError: (error) {
          print('Error in stream: $error');
          _finalizeResponse('Sorry, I encountered an error: ${error.toString()}');
        },
        onDone: () {
          _finalizeResponse(_currentStreamingResponse);
        },
      );
    } catch (e) {
      print('Error starting stream: $e');
      _finalizeResponse('Sorry, I encountered an error: ${e.toString()}');
    }
  }

  void _finalizeResponse(String finalResponse) {
    _responseSubscription?.cancel();
    setState(() {
      _isStreaming = false;
      if (finalResponse.isNotEmpty) {
        _messages.add(ChatMessage(
          content: finalResponse.trim(),
          isUser: false,
        ));
      }
      _currentStreamingResponse = '';
    });
    _scrollToBottom();
  }
}