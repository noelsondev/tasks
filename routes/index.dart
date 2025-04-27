import 'package:dart_frog/dart_frog.dart';

import '../config/app_text.dart';



Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'message': AppText.welcome,
      'status': true,
      'data': {
        'name': AppText.appName,
        'version': AppText.v1,
        'author': AppText.author,
        'description': AppText.description,
      },
      'v1': [
        {
          'auth': [
            {
              'post': '/login',
              'description': AppText.login,
            },
            {
              'post': '/register',
              'description': AppText.register,
            },
            // {
            //   'post': '/logout',
            //   'description': AppText.logout,
            // },
          ],
        },
        {
          'tasks': [
            {
              'post': '/tasks',
              'description': AppText.createTask,
            },
            {
              'patch': '/tasks',
              'description': AppText.updateTask,
            }
          ],
        },
      ],
    },
  );
}
