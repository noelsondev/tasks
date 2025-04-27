import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../compoment/check_content_type.dart';
import '../../../config/app_text.dart';
import '../../../controller/login_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _login(context),
    _ => Response.json(
        body: {
          'error': AppText.methodnotallowed,
        },
        statusCode: HttpStatus.methodNotAllowed,
      ),
  };
}

Future<Response> _login(RequestContext context) async {
  try {
    // check content Type
    check(context);
    // Get json from context
    final json = await context.request.json() as Map<String, dynamic>;
    // set variables from json
    final email = json['email']?.toString().trim() ?? '';
    final password = json['password']?.toString().trim() ?? '';
    // get LoginController form context
    final loginController = context.read<LoginController>();
    // call login method from login register
    final result = await loginController.login(email, password);
    return Response.json(body: result);
  } on FormatException catch (e) {
    return Response.json(
      body: {'error': e.message},
      statusCode: HttpStatus.noContent,
    );
  }
}
