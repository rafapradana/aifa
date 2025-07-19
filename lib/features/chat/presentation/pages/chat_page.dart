import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "Hi there! I'm AIFA, your financial companion. How can I help you today?\n\nYou can ask me things like:\n• \"How much can I save this month?\"\n• \"Help me cut down on food spending\"\n• \"Create a saving plan for a trip\"",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _generateAIResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('save') || message.contains('saving')) {
      return "Based on your current spending patterns, you could potentially save around Rp 500,000 this month! Here are some suggestions:\n\n• Reduce dining out by 2-3 times (save ~Rp 200k)\n• Use public transport more often (save ~Rp 150k)\n• Set a weekly grocery budget (save ~Rp 150k)\n\nWould you like me to help you create a specific savings plan?";
    }

    if (message.contains('food') || message.contains('dining')) {
      return "I see you're spending quite a bit on food! Here are some friendly tips:\n\n• Try meal prepping on Sundays\n• Set a daily food budget of Rp 75,000\n• Cook at home 4-5 times a week\n• Use food delivery apps sparingly\n\nYour current food spending is 35% of your budget. The ideal range is 20-25%. You're doing okay, but there's room for improvement!";
    }

    if (message.contains('trip') || message.contains('vacation')) {
      return "Exciting! Let's plan for your trip. 🌴\n\nTo help you save effectively, I need to know:\n• Where are you planning to go?\n• When is your target date?\n• Estimated budget needed?\n\nBased on your current savings rate, you could save about Rp 500k per month. For a Rp 3M trip, you'd need about 6 months of consistent saving.";
    }

    if (message.contains('budget')) {
      return "Your budget looks pretty good! Here's a quick overview:\n\n✅ Income: Rp 5,000,000\n📊 Expenses: Rp 2,550,000 (51%)\n💰 Savings: Rp 2,450,000 (49%)\n\nYou're doing great with a 49% savings rate! The 50/30/20 rule suggests 20% savings, so you're exceeding expectations. Keep it up!";
    }

    return "That's a great question! I'm here to help you with your finances. Based on your spending patterns, I can see you're generally doing well with money management.\n\nIs there something specific about your finances you'd like to discuss? I can help with budgeting, saving strategies, or analyzing your spending habits.";
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF4CAF50),
              radius: 16,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AIFA', style: TextStyle(fontSize: 16)),
                Text(
                  'Your Financial Companion',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              backgroundColor: Color(0xFF4CAF50),
              radius: 16,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    message.isUser ? const Color(0xFF4CAF50) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF4CAF50),
            radius: 16,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[600]!,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('AIFA is typing...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask AIFA anything about your finances...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF4CAF50),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
