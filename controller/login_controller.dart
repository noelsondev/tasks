import 'package:tasks/src/generated/prisma_client.dart';

import '../config/app_text.dart';
import 'generate_token.dart';
import 'user_controller.dart';

class LoginController extends GenerateToken {
  LoginController(this._prismaClient);

  final PrismaClient _prismaClient;

  // Method to handle user login
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Check if the required fields are present and not empty
    if (email.isEmpty || password.isEmpty) {
      return {
        'error': AppText.allfieldsrequired,
      }; // Return error if fields are empty
    }

    // Validate email format using a regular expression
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      return {
        'error': AppText.invalidemail,
      }; // Return error if email is invalid
    }

    try {
      final userController = UserController(_prismaClient);
      // Check if a user with the given email exists
      final existUser = await userController.checkUserExists(email);

      if (existUser == null) {
        return {
          'error': AppText.loginusernotexist,
        }; // Return error if user does not exist
      }

      // Verify the password
      if (existUser.password == userController.hashPassword(password)) {
        return {
          'message': AppText.userlogin, // Success message
          'user': existUser, // Return user details
          'token': await getUserByToken(
            '${existUser.email}+${existUser.password}',
          ), // Generate and return token
        };
      }

      return {
        'error': AppText.badpassword, // Return error if password is incorrect
      };
    } catch (e) {
      return {'error': e}; // Handle and return any exceptions
    }
  }
}
