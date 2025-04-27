import 'package:tasks/src/generated/prisma_client.dart';

import '../config/app_text.dart';
import 'generate_token.dart';
import 'user_controller.dart';

class RegisterController extends GenerateToken {
  /// Constructor for [RegisterController] that takes a [PrismaClient] instance.
  RegisterController(this._prismaClient);
  final PrismaClient _prismaClient;

  /// Registers a new user with the provided 
  /// [username], [email], and [password].
  /// Returns a map containing either the success message and user data or an e
  /// rror message.
  Future<Map<String, dynamic>> registerUser(
    String username,
    String email,
    String password,
  ) async {
    // Check if the required fields are present and not empty
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return {'error': AppText.allfieldsrequired};
    }

    // Validate the email format using a regular expression
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      return {'error': AppText.invalidemail};
    }

    try {
      // Check if the user already exists by email
      final existingUser =
          await UserController(_prismaClient).checkUserExists(email);
      // If the user already exists, return an error message
      if (existingUser != null) {
        return {
          'error': AppText.userexists,
        };
      }

      // Create a new user in the database
      final newUser = await UserController(_prismaClient).createUser(
        username,
        email,
        password,
      );

      // Return the newly created user data along with a generated token
      return {
        'message': AppText.userregistered,
        'user': newUser,
        'token': await getUserByToken('${newUser.email}+${newUser.password}'),
      };
    } catch (e) {
      // Handle any errors that occur during the registration process
      return {
        'error': '${AppText.errorPrefix} $e',
      };
    }
  }
}
