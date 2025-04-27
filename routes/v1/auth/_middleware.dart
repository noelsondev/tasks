import 'package:dart_frog/dart_frog.dart';
import 'package:tasks/src/generated/prisma_client.dart';

import '../../../controller/login_controller.dart';
import '../../../controller/register_controller.dart';

Handler middleware(Handler handler) {
  return handler.use(provideRegister()).use(provideLogin());
}

Middleware provideRegister() {
  return provider<RegisterController>((context) {
    return RegisterController(PrismaClient());
  });
}

Middleware provideLogin() {
  return provider<LoginController>((context) {
    return LoginController(PrismaClient());
  });
}
