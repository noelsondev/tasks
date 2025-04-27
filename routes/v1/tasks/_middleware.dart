import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:tasks/src/generated/prisma_client.dart';
import '../../../controller/tasks_controller.dart';
import '../../../controller/user_controller.dart';

Handler middleware(Handler handler) {
  return handler.use(providerUserAuth()).use(provideTaskController());
}

Middleware providerUserAuth() {
  return bearerAuthentication<String>(
    authenticator: (context, String token) {
      final userController = context.read<UserController>();
      return userController.setJwtUserToken(token);
    },
  );
}

Middleware provideTaskController() {
  return provider<TasksController>((context) {
    return TasksController(context.read<PrismaClient>());
  });
}
