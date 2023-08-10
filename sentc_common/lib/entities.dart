class UserMfaLogin {
  final String masterKey;
  final String authKey;
  final String deviceIdentifier;

  const UserMfaLogin({
    required this.masterKey,
    required this.authKey,
    required this.deviceIdentifier,
  });
}

sealed class LoginUser {}

class MfaLogin extends LoginUser {
  final UserMfaLogin u;

  MfaLogin(this.u);
}

class UserLogin<T> extends LoginUser {
  final T u;

  UserLogin(this.u);
}
