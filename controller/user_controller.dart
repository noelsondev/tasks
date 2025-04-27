import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:tasks/src/generated/prisma_client.dart';

import '../config/app_text.dart';
import 'generate_token.dart';



class UserController extends GenerateToken {
  UserController(this._prismaClient);
  final PrismaClient _prismaClient;

  // Create a new user in the database
  Future<User> createUser(
    String username,
    String email,
    String password,
  ) async {
    final user = await _prismaClient.user.create(
      data: PrismaUnion(
        zero: UserCreateInput(
          username: username,
          email: email,
          password: UserController(_prismaClient)
              .hashPassword(password), // Hash the password before storing
        ),
      ),
    );
    return user;
  }

  // Check if a user exists in the database by email
  Future<User?> checkUserExists(String email) async {
    try {
      final existingUser = await _prismaClient.user.findFirst(
        where: UserWhereInput(email: PrismaUnion(one: email)),
      );
      return existingUser;
    } catch (e) {
      // Handle error (e.g., log it)
      return null;
    }
  }

  // Hash the password using SHA-256 algorithm
  String hashPassword(String password) {
    final digest = utf8.encode(password); // Convert password to UTF-8 bytes
    final hash = sha256.convert(digest); // Generate SHA-256 hash

    return hash.toString(); // Return the hash as a string
  }

  // Retrieve all users from the database
  Future<List<User>> getallUser() async {
    final users = await _prismaClient.user.findMany();
    return users;
  }

  // Get a user by token and return user details
  Future<Map<String, dynamic>> getUserWithToken(String token) async {
    User? fuser;
    final users = await getallUser();

    if (users.isEmpty) {
      return {
        'error': AppText.userIsEmpty, // Use AppText constant
      };
    }

    for (final user in users) {
      if (token == await getUserByToken('${user.email}+${user.password}')) {
        fuser = user; // Match user by token
      }
    }
    return {
      'user': fuser, // Return the matched user
    };
  }

  // Verify and decode a JWT token
  Future<String> setJwtUserToken(String token) async {
    try {
      final jwt = JWT.verify(
        token,
        SecretKey('123456'),
      ); // Verify token with secret key
      final ftoken = jwt.payload; // Extract payload from token
      return ftoken.toString(); // Return payload as string
    } catch (e) {
      // Handle error (e.g., log it)
      return '${AppText.errorPrefix}$e'; // Use AppText constant
    }
  }

  Future<Map<String, dynamic>> logout() async {
    return {
      'message': AppText.userLoggedOut, // Use AppText constant
    };
  }
}
