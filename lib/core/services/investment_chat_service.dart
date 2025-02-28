import 'package:fin/features/home/data/models/chat_message.dart';
import 'package:fin/features/home/data/models/market_data.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class InvestmentChatService {
  final String _apiKey = 'AIzaSyCVU5h0JZrqe3yC0OHydQfnJkvRxGPMUJk';  // Replace with your API key
  late final GenerativeModel _model;

  InvestmentChatService() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.0-pro',  // Updated model name
        apiKey: _apiKey,
      );
    } catch (e) {
      print('Error initializing chat service: $e');
    }
  }

  Future<ChatMessage> generateResponse(String userMessage, MarketData? marketData) async {
    try {
      if (marketData == null) {
        return ChatMessage(
          text: "I'm unable to provide market-specific advice at the moment as market data is unavailable.",
          isUser: false,
        );
      }

      final prompt = '''
Context: You are analyzing market data with:
- Risk Score: ${marketData.riskScore}/10
- Market Sentiment: ${marketData.marketSentiment}
- Price Change: ${marketData.percentageChange}%
- Volume: ${marketData.totalVolume}
- Advancing/Declining: ${marketData.advancingStocks}/${marketData.decliningStocks}
- VIX: ${marketData.volatilityIndex}

User Question: $userMessage

Provide specific investment advice based on this data.
''';

      final response = await _model.generateContent([
        Content.text(prompt)
      ]);
      
      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from Gemini');
      }
      
      return ChatMessage(
        text: responseText,
        isUser: false,
      );
    } catch (e) {
      print('Chat error: $e');
      return ChatMessage(
        text: "I apologize, but I'm having trouble analyzing the data right now. Please try again later.",
        isUser: false,
      );
    }
  }
} 