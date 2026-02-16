class UnauthorizedUserException implements Exception {
  String message = 'User is not authorized';

  UnauthorizedUserException(this.message);

  @override
  String toString() => message;
}
