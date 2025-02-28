import 'package:flutter/material.dart';
import 'package:fin/features/home/presentation/widgets/investment_chatbot.dart';

class InvestmentChatPage extends StatelessWidget {
  const InvestmentChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Advisor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: const InvestmentChatbot(),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Investment Advisor'),
        content: const Text(
          'This AI-powered chatbot can help you make informed investment decisions based on current market data and your personal goals. Ask questions about market trends, risk assessment, or investment strategies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
} 