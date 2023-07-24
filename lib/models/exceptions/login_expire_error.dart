class LoginExpiredException implements Exception {
  String cause;
  LoginExpiredException(this.cause);
}
