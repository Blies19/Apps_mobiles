import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_group.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskGroup> _groups = [];

  List<TaskGroup> get taskGroups => _groups; // ✅ Getter corregido

  List<Task> getTasksByGroup(String groupId) {
    return _groups.firstWhere((group) => group.id == groupId).tasks;
  }

  TaskGroup getGroupById(String groupId) {
    return _groups.firstWhere((group) => group.id == groupId);
  }

  Future<Task?> addTask(BuildContext context, TaskGroup group) async {
    TextEditingController controller = TextEditingController();
    Task? createdTask;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Agregar nueva tarea'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nombre de la tarea'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final newTask = Task(
                    id: DateTime.now().toString(),
                    title: controller.text.trim(),
                    isCompleted: false,
                    groupId: group.id,
                  );
                  group.tasks.add(newTask);
                  notifyListeners();
                  createdTask = newTask;
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );

    return createdTask;
  }

  void toggleTaskCompletion(TaskGroup group, Task task) {
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }

  void deleteTask(TaskGroup group, Task task) {
    group.tasks.remove(task);
    notifyListeners();
  }

  void addGroup(TaskGroup group) {
    _groups.add(group);
    notifyListeners();
  }

  void deleteGroup(TaskGroup group) {
    _groups.remove(group);
    notifyListeners();
  }

  void editGroup(String groupId, String newName) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.name = newName;
    notifyListeners();
  }
}
