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
    margin-bottom: 16px;
    align-items: flex-end;
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
  }

  .user-message .message-avatar { background: #6200ee; }
  .bot-message .message-avatar { background: #03dac6; }

  .message-content {
    max-width: 70%;
    display: flex;
    flex-direction: column;
  }

  .message-text {
    padding: 12px 16px;
    border-radius: 16px;
    font-size: 15px;
    line-height: 1.5;
    word-wrap: break-word;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  }

  .user-message .message-text {
    background: #6200ee;
    color: white;
    border-bottom-right-radius: 4px;
  }

  .bot-message .message-text {
    background: #fff;
    color: #1a1a1a;
    border-bottom-left-radius: 4px;
  }

  /* Input */
  .input-area {
    padding: 16px 24px;
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
    background: #f0f2f5;
    padding: 8px 12px;
    border-radius: 24px;
    align-items: center;
  }

  #messageInput {
    flex: 1;
    border: none;
    outline: none;
    background: transparent;
    font-size: 15px;
    line-height: 1.5;
    resize: none;
  }

  #sendButton {
    background: #6200ee;
    border: none;
    color: white;
    font-size: 18px;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  #sendButton:hover:not(:disabled) {
    background: #4b00b5;
  }

  #sendButton:disabled {
    opacity: 0.4;
    cursor: not-allowed;
  }

  .welcome-state {
    text-align: center;
    margin-top: 100px;
    color: #737373;
  }

  .welcome-state h2 { font-size: 24px; margin-bottom: 8px; }
  .welcome-state p { font-size: 15px; }

  @media (max-width: 768px) {
    .sidebar { display: none; }
    .messages-wrapper { padding: 16px; }
    .input-area { padding: 12px; }
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
      <span>Andrew Neilson</span>
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
        <button id="sendButton" disabled>→</button>
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

messageInput.addEventListener('input', function() {
  this.style.height = 'auto';
  this.style.height = Math.min(this.scrollHeight, 200) + 'px';
  sendButton.disabled = !this.value.trim();
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
}

async function sendMessage() {
  const message = messageInput.value.trim();
  if (!message) return;

  addMessage(message, true);
  messageInput.value = "";
  messageInput.style.height = 'auto';
  sendButton.disabled = true;

  try {
    const r = await fetch("/generate", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({ prompt: message }),
    });
    const data = await r.json();
    addMessage(data.response, false);
  } catch (err) {
    addMessage("Sorry, I encountered an error.", false);
  } finally {
    messageInput.focus();
  }
}

sendButton.addEventListener("click", sendMessage);
messageInput.addEventListener("keydown", e => {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
});
</script>
</body>
</html>
''';
  }
}
