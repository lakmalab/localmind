class WebUIService {
  static String getChatHTML() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Local AI Chat</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .chat-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 800px;
            height: 90vh;
            max-height: 700px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }
        .chat-header h1 { font-size: 24px; margin-bottom: 5px; }
        .chat-header .status { font-size: 14px; opacity: 0.9; }
        .messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .message {
            margin-bottom: 16px;
            animation: fadeIn 0.3s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .message-content {
            max-width: 70%;
            padding: 12px 16px;
            border-radius: 18px;
            word-wrap: break-word;
            line-height: 1.4;
        }
        .user-message {
            display: flex;
            justify-content: flex-end;
        }
        .user-message .message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-bottom-right-radius: 4px;
        }
        .bot-message {
            display: flex;
            justify-content: flex-start;
        }
        .bot-message .message-content {
            background: white;
            color: #333;
            border-bottom-left-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .input-container {
            padding: 20px;
            background: white;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 10px;
        }
        #messageInput {
            flex: 1;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 25px;
            font-size: 15px;
            outline: none;
            transition: border-color 0.3s;
        }
        #messageInput:focus { border-color: #667eea; }
        #sendButton {
            padding: 12px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            transition: transform 0.2s;
        }
        #sendButton:hover { transform: translateY(-2px); }
        #sendButton:disabled { opacity: 0.6; cursor: not-allowed; }
        .loading {
            display: none;
            text-align: center;
            padding: 10px;
            color: #666;
        }
        .loading.active { display: block; }
        .loading-dots span {
            animation: blink 1.4s infinite;
            display: inline-block;
        }
        .loading-dots span:nth-child(2) { animation-delay: 0.2s; }
        .loading-dots span:nth-child(3) { animation-delay: 0.4s; }
        @keyframes blink {
            0%, 60%, 100% { opacity: 0.3; }
            30% { opacity: 1; }
        }
        .error-message {
            background: #fee;
            color: #c33;
            padding: 12px;
            border-radius: 8px;
            margin: 10px 20px;
            display: none;
        }
        .error-message.active { display: block; }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-header">
            <h1>🤖 Local AI Chat</h1>
            <div class="status" id="modelStatus">Loading...</div>
        </div>
        <div class="error-message" id="errorMessage"></div>
        <div class="messages-container" id="messagesContainer">
            <div class="message bot-message">
                <div class="message-content">
                    Hello! I'm your local AI assistant. How can I help you today?
                </div>
            </div>
        </div>
        <div class="loading" id="loading">
            <div class="loading-dots">AI is thinking<span>.</span><span>.</span><span>.</span></div>
        </div>
        <div class="input-container">
            <input type="text" id="messageInput" placeholder="Type your message..." autocomplete="off" />
            <button id="sendButton">Send</button>
        </div>
    </div>
    <script>
        const messagesContainer = document.getElementById('messagesContainer');
        const messageInput = document.getElementById('messageInput');
        const sendButton = document.getElementById('sendButton');
        const loading = document.getElementById('loading');
        const errorMessage = document.getElementById('errorMessage');
        const modelStatus = document.getElementById('modelStatus');

        async function loadModelInfo() {
            try {
                const response = await fetch('/model');
                const data = await response.json();
                modelStatus.textContent = data.loaded ? `Model: \${data.model_name}` : 'No model loaded';
            } catch (error) {
                modelStatus.textContent = 'Model status unknown';
            }
        }

        function addMessage(content, isUser) {
            const messageDiv = document.createElement('div');
            messageDiv.className = `message \${isUser ? 'user-message' : 'bot-message'}`;
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.textContent = content;
            messageDiv.appendChild(contentDiv);
            messagesContainer.appendChild(messageDiv);
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }

        function showError(message) {
            errorMessage.textContent = message;
            errorMessage.classList.add('active');
            setTimeout(() => errorMessage.classList.remove('active'), 5000);
        }

        async function sendMessage() {
            const message = messageInput.value.trim();
            if (!message) return;

            addMessage(message, true);
            messageInput.value = '';
            sendButton.disabled = true;
            loading.classList.add('active');

            try {
                const response = await fetch('/generate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ prompt: message })
                });

                if (!response.ok) {
                    const error = await response.json();
                    throw new Error(error.error || 'Failed to get response');
                }

                const data = await response.json();
                addMessage(data.response, false);
            } catch (error) {
                showError(`Error: \${error.message}`);
                addMessage('Sorry, I encountered an error.', false);
            } finally {
                loading.classList.remove('active');
                sendButton.disabled = false;
                messageInput.focus();
            }
        }

        sendButton.addEventListener('click', sendMessage);
        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });
        loadModelInfo();
    </script>
</body>
</html>
    ''';
  }
}