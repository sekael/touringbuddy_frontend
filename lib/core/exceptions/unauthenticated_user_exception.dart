class UnauthenticatedUserException implements Exception {
  final String message = 'User is not authenticated';

  const UnauthenticatedUserException();

  @override
  String toString() => message;
}
