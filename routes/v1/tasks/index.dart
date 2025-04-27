import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../compoment/check_content_type.dart';
import '../../../controller/tasks_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _createTask(context),
    HttpMethod.patch => await _updateTaskStatus(context),
    _ => Response.json(body: {})
  };
}

Future<Response> _createTask(RequestContext context) async {
  try {
    // check content Type
    check(context);

    final json = await context.request.json() as Map<String, dynamic>;
    final authHeader = context.request.headers['Authorization'] ?? '';
    final token = authHeader.startsWith('Bearer ')
        ? authHeader.replaceFirst('Bearer ', '')
        : authHeader;

    final title = json['title']?.toString().trim() ?? '';
    final description = json['description']?.toString().trim() ?? '';

    final tasksController = context.read<TasksController>();

    final task = await tasksController.createTasks(title, description, token);

    return Response.json(body: task);
  } on FormatException catch (e) {
    return Response.json(
      body: {'error': e.message},
      statusCode: HttpStatus.noContent,
    );
  }
}

Future<Response> _updateTaskStatus(RequestContext context) async {
  try {
    check(context);
    final json = await context.request.json() as Map<String, dynamic>;
    final authHeader = context.request.headers['Authorization'] ?? '';
    final token = authHeader.startsWith('Bearer ')
        ? authHeader.replaceFirst('Bearer ', '')
        : authHeader;
    final id = int.parse(json['id'].toString());
    final tasksController = context.read<TasksController>();
    final upTask = await tasksController.completedTaskOrNot(token, id);
    return Response.json(body: upTask);
  } on FormatException catch (e) {
    return Response.json(
      body: {'error': e.message},
      statusCode: HttpStatus.noContent,
    );
  }
}
