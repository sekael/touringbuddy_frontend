class NoUserProfileException implements Exception {
  final String userId;

  const NoUserProfileException({required this.userId});

  @override
  String toString() => 'User profile not found for user $userId';
}
