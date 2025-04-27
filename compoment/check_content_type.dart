import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../config/app_text.dart';

Map<String, dynamic> check(RequestContext context) {
  // Check if the request is a JSON request
  if (context.request.headers['Content-Type'] != 'application/json') {
    return {
      'error': AppText.invalidcontenttype,
      'statusCode': HttpStatus.badRequest,
    };
  }
  return {};
}
