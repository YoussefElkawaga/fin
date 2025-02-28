import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fin/features/home/data/models/market_data.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  late final GenerativeModel _model;
  late final ChatSession? _chat;

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  Future<void> initialize() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('GEMINI_API_KEY not found in environment variables');
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Enhanced investment context with market selection focus
      _chat = _model.startChat(history: [
        Content.text(
          'You are an AI investment advisor specializing in market analysis. '
          'First, ask the user which market they want to analyze (e.g., Stocks, Crypto, Forex, Commodities). '
          'Then provide detailed risk analysis and investment recommendations based on: '
          '- Current market conditions and volatility '
          '- Short-term (1-3 months) and medium-term (6-12 months) outlook '
          '- Risk-reward ratio for different time horizons '
          '- Specific entry/exit points and risk management strategies '
          'Always include a clear risk rating (1-10) and confidence score for predictions.'
        ),
      ]);
    } catch (e) {
      throw Exception('Failed to initialize ChatService: ${e.toString()}');
    }
  }

  Future<String> getInvestmentAdvice(String query, MarketData marketData) async {
    try {
      if (_chat == null) {
        throw Exception('Chat session not initialized');
      }

      final prompt = '''
Market Analysis Request: $query

Current Market Metrics:
- Price: \$${marketData.currentPrice.toStringAsFixed(2)}
- 24h Change: ${marketData.percentageChange.toStringAsFixed(2)}%
- Market Sentiment: ${marketData.marketSentiment}
- VIX (Volatility): ${marketData.volatilityIndex.toStringAsFixed(2)}
- Risk Level: ${marketData.riskScore.toStringAsFixed(1)}/10
- Market Health: ${marketData.advancingStocks} advancing vs ${marketData.decliningStocks} declining
- Volume: ${marketData.totalVolume.toStringAsFixed(0)}

Please format your response using Markdown:
- Use # for main headings
- Use ## for subheadings
- Use **bold** for important points
- Use bullet points for lists
- Use > for important warnings or notes

If this is the first message, ask which market type they want to analyze.
Otherwise, provide a detailed analysis including:
1. Risk Rating (1-10) for different time horizons
2. Market trend analysis and key levels
3. Entry/exit recommendations
4. Position sizing and risk management
5. Confidence score for the analysis (%)
6. Specific warnings based on current metrics
''';

      final response = await _chat!.sendMessage(Content.text(prompt));
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('Received empty response from Gemini');
      }

      return responseText;
    } catch (e) {
      throw Exception('Failed to get investment advice: ${e.toString()}');
    }
  }

  void dispose() {
    _chat = null;
  }
}