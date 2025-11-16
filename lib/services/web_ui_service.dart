class WebUIService {
  static String getChatHTML() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>LocalMind Chat</title>

<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
        height: 100vh;
        padding: 20px;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    /* Glass Container */
    .chat-container {
        width: 100%;
        max-width: 850px;
        height: 90vh;
        max-height: 720px;

        background: rgba(255, 255, 255, 0.18);
        backdrop-filter: blur(22px);
        -webkit-backdrop-filter: blur(22px);
        
        border-radius: 28px;
        padding: 0;
        overflow: hidden;
        display: flex;
        flex-direction: column;

        border: 1px solid rgba(255,255,255,0.25);
        box-shadow: 0 20px 60px rgba(0,0,0,0.25);
    }

    /* Header */
    .chat-header {
        text-align: center;
        padding: 22px 10px;
        background: rgba(255,255,255,0.06);
        border-bottom: 1px solid rgba(255,255,255,0.25);
        backdrop-filter: blur(30px);
    }

    .chat-header h1 {
        font-size: 26px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 4px;
        letter-spacing: -0.5px;
    }

    .status {
        color: rgba(255,255,255,0.85);
        font-size: 14px;
    }

    /* Messages Area */
    .messages-container {
        flex: 1;
        padding: 24px;
        overflow-y: auto;
        scroll-behavior: smooth;
    }

    /* Message */
    .message {
        display: flex;
        gap: 12px;
        margin-bottom: 18px;
        animation: fadeIn 0.35s ease-out;
    }

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Avatars */
    .avatar {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        flex-shrink: 0;
        background-size: cover;
        background-position: center;
    }

    .user-avatar {
        background-image: url('https://i.imgur.com/3XjzG9C.png');
    }
    .bot-avatar {
        background-image: url('https://i.imgur.com/9q6xXGv.png');
    }

    /* Message Bubble */
    .message-content {
        max-width: 70%;
        padding: 14px 18px;
        border-radius: 20px;
        line-height: 1.45;
        font-size: 15px;
    }

    .user-message { justify-content: flex-end; }
    .user-message .message-content {
        background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
        color: white;
        border-bottom-right-radius: 6px;
    }

    .bot-message { justify-content: flex-start; }
    .bot-message .message-content {
        background: rgba(255,255,255,0.6);
        color: #333;
        border-bottom-left-radius: 6px;
    }

    /* Input Bar */
    .input-container {
        padding: 18px 22px;
        display: flex;
        align-items: center;
        gap: 12px;

        background: rgba(255,255,255,0.15);
        border-top: 1px solid rgba(255,255,255,0.2);
        backdrop-filter: blur(15px);
    }

    #messageInput {
        flex: 1;
        padding: 14px 18px;
        font-size: 15px;

        background: rgba(255,255,255,0.35);
        border: 1px solid rgba(255,255,255,0.35);
        color: #222;

        border-radius: 22px;
        outline: none;

        transition: border-color .28s ease;
    }

    #messageInput:focus {
        border-color: #fff;
        background: rgba(255,255,255,0.55);
    }

    #sendButton {
        width: 48px;
        height: 48px;

        display: flex;
        align-items: center;
        justify-content: center;

        border: none;
        border-radius: 50%;
        cursor: pointer;

        font-size: 18px;

        background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
        color: white;

        transition: transform .2s;
    }

    #sendButton:hover {
        transform: scale(1.07);
    }

    /* Loading Dots */
    .loading {
        display: none;
        text-align: center;
        padding: 6px;
        font-size: 14px;
        color: #fff;
    }
    .loading.active { display: block; }
    
    .loading-dots span {
        animation: blink 1.4s infinite;
    }
    .loading-dots span:nth-child(2) { animation-delay: .2s; }
    .loading-dots span:nth-child(3) { animation-delay: .4s; }

    @keyframes blink {
        0%, 60%, 100% { opacity: 0.25; }
        30% { opacity: 1; }
    }

    /* Error box */
    .error-message {
        display: none;
        background: rgba(255,0,0,0.2);
        color: #fff;
        margin: 12px 20px;
        padding: 10px;
        border-radius: 10px;
        text-align: center;
        font-size: 14px;
        backdrop-filter: blur(10px);
    }
    .error-message.active { display: block; }
</style>

</head>
<body>

<div class="chat-container">
    <div class="chat-header">
        <h1>✨ LocalMind Chat</h1>
        <div class="status" id="modelStatus">Loading model…</div>
    </div>

    <div class="error-message" id="errorMessage"></div>

    <div class="messages-container" id="messagesContainer">
        <div class="message bot-message">
            <div class="avatar bot-avatar"></div>
            <div class="message-content">Hello! I'm your LocalMind assistant. How can I help you today?</div>
        </div>
    </div>

    <div class="loading" id="loading">
        <div class="loading-dots">AI is thinking<span>.</span><span>.</span><span>.</span></div>
    </div>

    <div class="input-container">
        <input type="text" id="messageInput" placeholder="Type your message…" />
        <button id="sendButton">➤</button>
    </div>
</div>

<script>
    const messagesContainer = document.getElementById("messagesContainer");
    const messageInput = document.getElementById("messageInput");
    const sendButton = document.getElementById("sendButton");
    const loading = document.getElementById("loading");
    const errorMessage = document.getElementById("errorMessage");
    const modelStatus = document.getElementById("modelStatus");

    async function loadModelInfo() {
        try {
            const r = await fetch("/model");
            const data = await r.json();
            modelStatus.textContent = data.loaded ? \`Model: \${data.model_name}\` : "No model loaded";
        } catch {
            modelStatus.textContent = "Model status unknown";
        }
    }

    function addMessage(content, isUser) {
        const msg = document.createElement("div");
        msg.className = \`message \${isUser ? "user-message" : "bot-message"}\`;

        const avatar = document.createElement("div");
        avatar.className = \`avatar \${isUser ? "user-avatar" : "bot-avatar"}\`;

        const bubble = document.createElement("div");
        bubble.className = "message-content";
        bubble.textContent = content;

        if (isUser) {
            msg.appendChild(bubble);
            msg.appendChild(avatar);
        } else {
            msg.appendChild(avatar);
            msg.appendChild(bubble);
        }

        messagesContainer.appendChild(msg);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function showError(msg) {
        errorMessage.textContent = msg;
        errorMessage.classList.add("active");
        setTimeout(() => errorMessage.classList.remove("active"), 4500);
    }

    async function sendMessage() {
        const message = messageInput.value.trim();
        if (!message) return;

        addMessage(message, true);

        messageInput.value = "";
        sendButton.disabled = true;
        loading.classList.add("active");

        try {
            const r = await fetch("/generate", {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({ prompt: message }),
            });

            if (!r.ok) {
                const err = await r.json();
                throw new Error(err.error || "Request failed");
            }

            const data = await r.json();
            addMessage(data.response, false);

        } catch (err) {
            showError("Error: " + err.message);
            addMessage("Sorry, I encountered an error.", false);
        } finally {
            loading.classList.remove("active");
            sendButton.disabled = false;
            messageInput.focus();
        }
    }

    sendButton.addEventListener("click", sendMessage);
    messageInput.addEventListener("keypress", (e) => { if (e.key === "Enter") sendMessage(); });

    loadModelInfo();
</script>
</body>
</html>
''';
  }

}