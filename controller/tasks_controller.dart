import 'package:tasks/src/generated/prisma_client.dart';

import '../config/app_text.dart';
import 'user_controller.dart';

/// Controller class for managing tasks
class TasksController {
  TasksController(this._prismaClient);
  final PrismaClient _prismaClient;

  /// GET ALL USER TASKS
  /// Retrieves all tasks associated with a user based on their token.
  /// Returns a `User` object if the user is found, otherwise `null`.
  Future<User?> getUserTasks(String token) async {
    final result = await UserController(_prismaClient).getUserWithToken(token);

    if (result.containsKey('user')) {
      return result.values.first as User;
    }
    return null;
  }

  /// CREATE TASK
  /// Creates a new task for a user based on the provided title, description,
  /// and token.
  /// Returns a map containing the created task and user, or an error message if
  ///  the operation fails.
  Future<Map<String, dynamic>> createTasks(
    String title,
    String description,
    String token,
  ) async {
    // Check if the required fields are present and not empty
    if (title.isEmpty || description.isEmpty) {
      return {'error': AppText.allfieldsrequired};
    }
    try {
      final task = await _prismaClient.task.create(
        data: PrismaUnion(
          zero: TaskCreateInput(
            title: title,
            description: description,
            user: UserCreateNestedOneWithoutTasksInput(
              connect: UserWhereUniqueInput(
                email: (await getUserTasks(token))?.email,
              ),
            ),
          ),
        ),
      );

      return {'task': task, 'user': await getUserTasks(token)};
    } catch (e) {
      return {'error': '${AppText.failedToCreateTask} $e'};
    }
  }

  /// MARK TASK AS COMPLETED OR NOT
  /// Toggles the completion status of a task based on its ID and the user's
  /// token.
  /// Returns a success message or an error message if the operation fails.
  // ignore: lines_longer_than_80_chars
  Future<Map<String, dynamic>> completedTaskOrNot(
    String token,
    int id,
  ) async {
    final user = await getUserTasks(token);
    final findtask = await findTask(id);
    final task = findtask['task'] as Task?;
    if (task == null) {
      return {'error': AppText.taskNotFound};
    }

    // Check if the user is authorized to modify the task
    if (task.userId != user!.id) {
      return {'error': AppText.unauthorizedTask};
    }

    // Toggle the completion status of the task
    if (task.completed == false) {
      await updateTask(token, id, task.title, task.description, true);
      return {'message': AppText.taskCompletedSuccess};
    } else {
      await updateTask(token, id, task.title, task.description, false);
      return {'message': AppText.taskNotCompletedSuccess};
    }
  }

  /// UPDATE TASK
  /// Updates the details of a task based on its ID, the user's token, and the
  /// provided fields.
  /// Returns the updated task or an error message if the operation fails.
  Future<Map<String, dynamic>> updateTask(
    String token,
    int id,
    String title,
    String description,
    // ignore: avoid_positional_boolean_parameters
    bool completed,
  ) async {
    try {
      final user = await getUserTasks(token);
      final findtask = await findTask(id);
      final task = findtask['task'] as Task;

      // Check if the user is authorized to modify the task
      if (task.userId != user!.id) {
        return {'error': AppText.unauthorizedTask};
      }

      // Validate input fields
      if (title.isEmpty ||
          description.isEmpty ||
          (completed != true && completed != false)) {
        return {
          'error': AppText.allFieldsRequired,
        };
      }

      // Check if the task is already marked as completed
      if (task.completed == true && completed == true) {
        return {
          'error': AppText.taskAlreadyCompleted,
        };
      }

      // Update the task in the database
      final taskUpdated = await _prismaClient.task.update(
        data: PrismaUnion(
          zero: TaskUpdateInput(
            title: PrismaUnion(zero: title),
            description: PrismaUnion(zero: description),
            completed: PrismaUnion(zero: completed),
          ),
        ),
        where: TaskWhereUniqueInput(id: id),
      );

      return {
        'task': taskUpdated,
      };
    } catch (e) {
      return {
        'error': '${AppText.failedToUpdateTask} $e',
      };
    }
  }

  /// FIND TASK
  /// Finds a task based on its ID.
  /// Returns the task if found, or an error message if the task does not exist.
  Future<Map<String, dynamic>> findTask(int id) async {
    final task = await _prismaClient.task
        .findUnique(where: TaskWhereUniqueInput(id: id));
    if (task == null) {
      return {'error': AppText.taskNotFound};
    }

    return {'task': task};
  }
}
