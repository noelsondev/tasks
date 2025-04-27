import 'package:dart_frog/dart_frog.dart';
import 'package:tasks/src/generated/prisma_client.dart';

import '../controller/user_controller.dart';

final PrismaClient _prisma = PrismaClient();

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler.use(providePrismaClient()).use(provideUserController());
}

Middleware providePrismaClient() {
  return provider<PrismaClient>((context) {
    return _prisma;
  });
}

Middleware provideUserController() {
  return provider<UserController>((context) {
    return UserController(_prisma);
  });
}
