class LoginExpiredError extends Error {
  final String message;

  LoginExpiredError({this.message = '로그인 만료됨'});

  @override
  String toString() {
    return message;
  }
}
