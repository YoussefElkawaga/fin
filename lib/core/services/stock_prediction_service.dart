import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fin/features/prediction/data/models/stock_prediction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Price Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockPredictionScreen(),
    );
  }
}

class StockPredictionScreen extends StatefulWidget {
  @override
  _StockPredictionScreenState createState() => _StockPredictionScreenState();
}

class _StockPredictionScreenState extends State<StockPredictionScreen> {
  TextEditingController _symbolController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<double> _futurePrices = [];
  double? _confidence;
  String? _trend;
  String? _riskLevel;

  Future<void> _fetchPrediction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _futurePrices.clear();
    });

    String stockSymbol = _symbolController.text.trim().toUpperCase();
    if (stockSymbol.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Please enter a stock symbol.";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://35.184.132.232:5000/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"symbol": stockSymbol, "future_days": 30}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("error")) {
          setState(() {
            _errorMessage = data["error"];
            _isLoading = false;
          });
          return;
        }

        List<dynamic> rawPrices = data["future_prices"] ?? [];
        List<double> parsedPrices = rawPrices.map((p) => (p as num?)?.toDouble() ?? 0.0).toList();

        setState(() {
          _futurePrices = parsedPrices;
          _confidence = (data["confidence"] as num?)?.toDouble() ?? 0.0;
          _trend = data["metrics"]["trend"] ?? "Unknown";
          _riskLevel = data["metrics"]["risk_level"] ?? "Unknown";
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch predictions. Server error.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Price Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: 'Enter Stock Symbol (e.g., AAPL)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchPrediction,
              child: Text('Predict Prices'),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (_futurePrices.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Predicted Future Prices:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _futurePrices.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              'Day ${index + 1}: \$${_futurePrices[index].toStringAsFixed(2)}',
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Confidence: ${(_confidence ?? 0.0) * 100}%'),
                    Text('Trend: $_trend'),
                    Text('Risk Level: $_riskLevel'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StockPredictionService {
  static const String _baseUrl = 'http://35.184.132.232:5000';

  Future<StockPrediction> predictStockPrice(String symbol) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'symbol': symbol,
          'future_days': 30,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return StockPrediction.fromJson(jsonResponse);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to predict price');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
