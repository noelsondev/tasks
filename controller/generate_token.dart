import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class GenerateToken {
  // Generate a JWT tokenss
  // This method takes a token string, signs it with a secret key, and returns
  //the signed token
  Future<String> getUserByToken(String token) async {
    final jwt = JWT(token);
    final ftoken =
        jwt.sign(SecretKey('123456'), expiresIn: const Duration(seconds: 10));
    return ftoken;
  }
}
