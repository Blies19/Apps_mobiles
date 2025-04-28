import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_group.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Menú Principal')),
      body: ListView.builder(
        itemCount: taskProvider.taskGroups.length,
        itemBuilder: (context, index) {
          final group = taskProvider.taskGroups[index];
          return ListTile(
            title: Text(group.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditGroupDialog(context, group);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    taskProvider.deleteGroup(group);
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/task', arguments: group.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGroupDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo grupo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre del grupo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newGroup = TaskGroup(
                  id: DateTime.now().toString(),
                  name: controller.text.trim(),
                  tasks: [],
                );
                Provider.of<TaskProvider>(context, listen: false)
                    .addGroup(newGroup);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, TaskGroup group) {
    final TextEditingController controller =
        TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar grupo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<TaskProvider>(context, listen: false)
                    .editGroup(group.id, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
