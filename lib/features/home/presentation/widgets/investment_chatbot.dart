import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/features/home/data/models/chat_message.dart';
import 'package:fin/core/services/chat_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InvestmentChatbot extends StatefulWidget {
  const InvestmentChatbot({super.key});

  @override
  State<InvestmentChatbot> createState() => _InvestmentChatbotState();
}

class _InvestmentChatbotState extends State<InvestmentChatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _chatService.initialize();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    _messages.add(
      ChatMessage(
        text: "Hello! I'm your AI investment advisor. To provide targeted analysis, please tell me which market you'd like to analyze:\n\n"
             "• Stocks (Major indices, individual stocks)\n"
             "• Cryptocurrency\n"
             "• Forex (Currency pairs)\n"
             "• Commodities (Gold, Oil, etc.)\n\n"
             "Once you choose, I'll analyze the current market conditions and provide detailed risk assessment and recommendations.",
        isUser: false,
      ),
    );
  }

  void _addErrorMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: false));
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();

    try {
      final marketData = Provider.of<MarketDataProvider>(context, listen: false).marketData;
      if (marketData == null) {
        _addErrorMessage("I'm waiting for market data to be loaded. Please try again in a moment.");
        return;
      }

      final response = await _chatService.getInvestmentAdvice(text, marketData);
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
        });
      }
    } catch (e) {
      if (mounted) {
        _addErrorMessage("I encountered an error. Please check your connection and try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              return _buildMessage(message);
            },
          ),
        ),
        if (_isTyping)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        _buildInputField(),
      ],
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: message.isUser 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: message.isUser 
          ? Text(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            )
          : MarkdownBody(
              data: message.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                h2: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                h3: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                p: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                  height: 1.5,
                ),
                strong: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
                em: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                blockquote: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  height: 1.5,
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    ),
                  ),
                ),
                listBullet: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                listIndent: 24,
                blockSpacing: 16,
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
              ),
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final uri = Uri.parse(href);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                }
              },
            ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask about investment advice...',
                border: InputBorder.none,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_controller.text),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 