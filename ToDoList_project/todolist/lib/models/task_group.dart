import 'task.dart';

class TaskGroup {
  final String id;
  String name;
  List<Task> tasks; // ✅ Agregamos lista de tareas

  TaskGroup({
    required this.id,
    required this.name,
    required this.tasks,
  });
}
