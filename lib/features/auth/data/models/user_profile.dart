class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String memberSince;
  final List<String> watchlist;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.memberSince,
    required this.watchlist,
    required this.preferences,
  });
} 