class SocialMarketAdvice {
  final String platform;
  final String author;
  final String content;
  final String sentiment;
  final int likes;
  final int shares;
  final DateTime timestamp;
  final String? profileImage;
  final List<String> tags;

  SocialMarketAdvice({
    required this.platform,
    required this.author,
    required this.content,
    required this.sentiment,
    required this.likes,
    required this.shares,
    required this.timestamp,
    this.profileImage,
    required this.tags,
  });
} 