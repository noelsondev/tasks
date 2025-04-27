import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../compoment/check_content_type.dart';
import '../../../config/app_text.dart';
import '../../../controller/register_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _register(context),
    _ => Response.json(
        body: {
          'error': AppText.methodnotallowed,
        },
        statusCode: HttpStatus.methodNotAllowed,
      ),
  };
}

Future<Response> _register(RequestContext context) async {
  try {
    // check content Type
    check(context);
    // get json from request
    final json = await context.request.json() as Map<String, dynamic>;

    // set variables from json
    final username = json['username']?.toString().trim() ?? '';
    final email = json['email']?.toString().trim() ?? '';
    final password = json['password']?.toString().trim() ?? '';

    // get the register controller from the context
    final registerController = context.read<RegisterController>();
    // Call the registerUser method from the RegisterController
    final result = await registerController.registerUser(
      username,
      email,
      password,
    );
    // // Check if the result contains an error
    // if (result.containsKey('error')) {
    //   return Response.json(
    //     body: result,
    //     statusCode: HttpStatus.badRequest,
    //   );
    // }
    // Return the success response with the user data
    return Response.json(
      body: result,
      statusCode: HttpStatus.created,
    );
  } on FormatException catch (e) {
    return Response.json(
      body: {'error': e.message},
      statusCode: HttpStatus.noContent,
    );
  }
}
