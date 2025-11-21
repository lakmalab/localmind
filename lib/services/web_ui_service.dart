class WebUIService {
  static String getChatHTML() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>LocalMind</title>
<style>
  body {
    font-family: 'Roboto', sans-serif;
    margin: 0;
    background: #f0f2f5;
    height: 100vh;
    display: flex;
    overflow: hidden;
  }

  .app-container {
    display: flex;
    width: 100%;
    height: 100%;
  }

  /* Sidebar */
  .sidebar {
    width: 280px;
    background: #fff;
    display: flex;
    flex-direction: column;
    border-right: 1px solid #e0e0e0;
    box-shadow: 2px 0 5px rgba(0,0,0,0.05);
  }

  .sidebar-header {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    border-bottom: 1px solid #e0e0e0;
  }

  .sidebar-header img {
    width: 36px;
    height: 36px;
    border-radius: 8px;
  }

  .new-chat-btn {
    background: #6200ee;
    color: white;
    border: none;
    border-radius: 24px;
    padding: 8px 16px;
    cursor: pointer;
    font-weight: 500;
    transition: 0.2s;
  }

  .new-chat-btn:hover {
    background: #4b00b5;
  }

  .sidebar-content {
    flex: 1;
    overflow-y: auto;
    padding: 12px;
  }

  .conversation-item {
    padding: 10px 12px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    transition: 0.2s;
  }

  .conversation-item:hover {
    background: #f5f5f5;
  }

  .conversation-item.active {
    background: #e0e0e0;
  }

  .sidebar-footer {
    padding: 16px;
    border-top: 1px solid #e0e0e0;
    font-size: 14px;
    color: #737373;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .sidebar-footer img {
    width: 32px;
    height: 32px;
    border-radius: 50%;
  }

  /* Chat area */
  .chat-area {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #f0f2f5;
  }

  .chat-header {
    background: #fff;
    padding: 16px 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #e0e0e0;
    box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  }

  .messages-container {
    flex: 1;
    padding: 24px 16px;
    overflow-y: auto;
  }

  .messages-wrapper {
    max-width: 720px;
    margin: 0 auto;
  }

  .message {
    display: flex;
    margin-bottom: 24px;
    align-items: flex-start;
    gap: 12px;
  }

  .message.user-message {
    justify-content: flex-end;
  }

  .message.bot-message {
    justify-content: flex-start;
  }

  .message-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 14px;
    color: white;
    margin-top: 4px;
  }

  .user-message .message-avatar { 
    background: #6200ee; 
    order: 2;
    margin-left: 12px;
  }
  
  .bot-message .message-avatar { 
    background: #03dac6; 
    order: 1;
    margin-right: 12px;
  }

  .message-content {
    max-width: 70%;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .user-message .message-content {
    align-items: flex-end;
    order: 1;
  }

  .bot-message .message-content {
    align-items: flex-start;
    order: 2;
  }

  .message-text {
    padding: 16px 20px;
    border-radius: 20px;
    font-size: 15px;
    line-height: 1.5;
    word-wrap: break-word;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    white-space: pre-wrap;
    max-width: 100%;
  }

  .user-message .message-text {
    background: linear-gradient(135deg, #6200ee, #7c4dff);
    color: white;
    border-bottom-right-radius: 6px;
  }

  .bot-message .message-text {
    background: #fff;
    color: #1a1a1a;
    border-bottom-left-radius: 6px;
    border: 1px solid #e0e0e0;
  }

  .streaming-cursor {
    display: inline-block;
    animation: blink 1s infinite;
    color: #6200ee;
    font-weight: bold;
    margin-left: 2px;
  }

  @keyframes blink {
    0%, 50% { opacity: 1; }
    51%, 100% { opacity: 0; }
  }

  .typing-indicator {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 16px 20px;
    background: #fff;
    border-radius: 20px;
    border-bottom-left-radius: 6px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    border: 1px solid #e0e0e0;
  }

  .typing-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #999;
    animation: typing 1.4s infinite ease-in-out;
  }

  .typing-dot:nth-child(1) { animation-delay: -0.32s; }
  .typing-dot:nth-child(2) { animation-delay: -0.16s; }

  @keyframes typing {
    0%, 80%, 100% { transform: scale(0.8); opacity: 0.5; }
    40% { transform: scale(1); opacity: 1; }
  }

  /* Input */
  .input-area {
    padding: 20px 24px;
    background: #fff;
    display: flex;
    justify-content: center;
    border-top: 1px solid #e0e0e0;
  }

  .input-container {
    max-width: 720px;
    width: 100%;
    display: flex;
    gap: 12px;
    background: #f8f9fa;
    padding: 12px 16px;
    border-radius: 24px;
    align-items: flex-end;
    border: 1px solid #e0e0e0;
    transition: all 0.2s ease;
  }

  .input-container:focus-within {
    border-color: #6200ee;
    box-shadow: 0 0 0 2px rgba(98, 0, 238, 0.1);
  }

  #messageInput {
    flex: 1;
    border: none;
    outline: none;
    background: transparent;
    font-size: 15px;
    line-height: 1.5;
    resize: none;
    font-family: inherit;
    max-height: 120px;
  }

  #sendButton {
    background: #6200ee;
    border: none;
    color: white;
    font-size: 20px;
    width: 44px;
    height: 44px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s ease;
    flex-shrink: 0;
  }

  #sendButton:hover:not(:disabled) {
    background: #4b00b5;
    transform: scale(1.05);
  }

  #sendButton:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    transform: none;
  }

  .welcome-state {
    text-align: center;
    margin-top: 120px;
    color: #737373;
  }

  .welcome-state h2 { 
    font-size: 28px; 
    margin-bottom: 12px; 
    font-weight: 300;
  }
  
  .welcome-state p { 
    font-size: 16px; 
    opacity: 0.8;
  }

  @media (max-width: 768px) {
    .sidebar { display: none; }
    .messages-wrapper { padding: 16px; }
    .input-area { padding: 16px; }
    
    .message-content {
      max-width: 85%;
    }
    
    .message-avatar {
      width: 32px;
      height: 32px;
      font-size: 12px;
    }
  }

  /* Scrollbar styling */
  .messages-container::-webkit-scrollbar {
    width: 6px;
  }

  .messages-container::-webkit-scrollbar-track {
    background: transparent;
  }

  .messages-container::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 3px;
  }

  .messages-container::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
  }
</style>
</head>
<body>
<div class="app-container">
  <div class="sidebar">
    <div class="sidebar-header">
      <img src="assets/icon.png" alt="Logo">
      <button class="new-chat-btn">New Chat</button>
    </div>
    <div class="sidebar-content" id="conversationList"></div>
    <div class="sidebar-footer">
      <img src="assets/icon.png" alt="User">
      <span>Lakmal Abeyrathne</span>
    </div>
  </div>

  <div class="chat-area">
    <div class="chat-header">
      <div></div>
      <div class="model-selector" id="modelSelector">LocalMind</div>
    </div>

    <div class="messages-container" id="messagesContainer">
      <div class="messages-wrapper" id="messagesWrapper">
        <div class="welcome-state">
          <h2>How can I help you today?</h2>
          <p>Ask me anything or let me assist you with your tasks</p>
        </div>
      </div>
    </div>

    <div class="input-area">
      <div class="input-container">
        <textarea id="messageInput" placeholder="Message LocalMind…" rows="1"></textarea>
        <button id="sendButton" disabled>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="22" y1="2" x2="11" y2="13"></line>
            <polygon points="22,2 15,22 11,13 2,9"></polygon>
          </svg>
        </button>
      </div>
    </div>
  </div>
</div>

<script>
const messagesContainer = document.getElementById("messagesContainer");
const messagesWrapper = document.getElementById("messagesWrapper");
const messageInput = document.getElementById("messageInput");
const sendButton = document.getElementById("sendButton");

let isFirstMessage = true;
let currentStreamingMessage = null;
let isStreaming = false;

messageInput.addEventListener('input', function() {
  this.style.height = 'auto';
  this.style.height = Math.min(this.scrollHeight, 120) + 'px';
  sendButton.disabled = !this.value.trim() || isStreaming;
});

function clearWelcome() {
  if (isFirstMessage) {
    const welcome = messagesWrapper.querySelector('.welcome-state');
    if (welcome) welcome.remove();
    isFirstMessage = false;
  }
}

function addMessage(content, isUser) {
  clearWelcome();
  const msg = document.createElement("div");
  msg.className = 'message ' + (isUser ? 'user-message' : 'bot-message');

  const avatar = document.createElement("div");
  avatar.className = "message-avatar";
  avatar.textContent = isUser ? "U" : "A";

  const contentDiv = document.createElement("div");
  contentDiv.className = "message-content";

  const textDiv = document.createElement("div");
  textDiv.className = "message-text";
  textDiv.textContent = content;

  contentDiv.appendChild(textDiv);
  msg.appendChild(avatar);
  msg.appendChild(contentDiv);

  messagesWrapper.appendChild(msg);
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
  return textDiv;
}

function showTypingIndicator() {
  clearWelcome();
  const msg = document.createElement("div");
  msg.className = 'message bot-message';

  const avatar = document.createElement("div");
  avatar.className = "message-avatar";
  avatar.textContent = "A";

  const contentDiv = document.createElement("div");
  contentDiv.className = "message-content";

  const typingDiv = document.createElement("div");
  typingDiv.className = "typing-indicator";
  typingDiv.innerHTML = `
    <div class="typing-dot"></div>
    <div class="typing-dot"></div>
    <div class="typing-dot"></div>
  `;

  contentDiv.appendChild(typingDiv);
  msg.appendChild(avatar);
  msg.appendChild(contentDiv);

  messagesWrapper.appendChild(msg);
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
  return contentDiv;
}

function updateStreamingMessage(content, isComplete = false) {
  if (!currentStreamingMessage) return;
  
  const textDiv = currentStreamingMessage.querySelector('.message-text');
  if (textDiv) {
    textDiv.textContent = content + (isComplete ? '' : '<span class="streaming-cursor">▊</span>');
    textDiv.innerHTML = textDiv.innerHTML;
  }
  
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

async function sendMessage() {
  const message = messageInput.value.trim();
  if (!message || isStreaming) return;

  addMessage(message, true);
  messageInput.value = "";
  messageInput.style.height = 'auto';
  sendButton.disabled = true;
  isStreaming = true;

  // Show typing indicator
  const typingElement = showTypingIndicator();
  let fullResponse = '';

  try {
    const httpResponse = await fetch("/generate-stream", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({ prompt: message }),
    });

    if (!httpResponse.ok) {
      throw new Error(`HTTP error!`);
    }

    const reader = httpResponse.body.getReader();
    const decoder = new TextDecoder();
    
    // Replace typing indicator with streaming message
    typingElement.remove();
    const messageElement = document.createElement("div");
    messageElement.className = "message-text";
    currentStreamingMessage = document.createElement("div");
    currentStreamingMessage.className = 'message bot-message';
    
    const avatar = document.createElement("div");
    avatar.className = "message-avatar";
    avatar.textContent = "A";

    const contentDiv = document.createElement("div");
    contentDiv.className = "message-content";
    contentDiv.appendChild(messageElement);

    currentStreamingMessage.appendChild(avatar);
    currentStreamingMessage.appendChild(contentDiv);
    messagesWrapper.appendChild(currentStreamingMessage);

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      fullResponse += chunk;
      updateStreamingMessage(fullResponse, false);
    }

    // Final update without cursor
    updateStreamingMessage(fullResponse, true);
    currentStreamingMessage = null;

  } catch (err) {
    console.error('Error:', err);
    // Remove typing indicator on error
    typingElement.remove();
    addMessage("Sorry, I encountered an error: " + err.message, false);
  } finally {
    isStreaming = false;
    sendButton.disabled = false;
    messageInput.focus();
  }
}

sendButton.addEventListener("click", sendMessage);
messageInput.addEventListener("keydown", e => {
  if (e.key === "Enter" && !e.shiftKey && !isStreaming) {
    e.preventDefault();
    sendMessage();
  }
});

// Focus input on load
messageInput.focus();
</script>
</body>
</html>
''';
  }
}