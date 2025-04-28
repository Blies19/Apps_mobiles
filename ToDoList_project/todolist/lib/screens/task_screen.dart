import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/task_group.dart';
import '../services/my_bluetooth_service.dart';
import '../services/notification_service.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupId = ModalRoute.of(context)?.settings.arguments as String?;
    final taskProvider = Provider.of<TaskProvider>(context);

    if (groupId == null) {
      return Scaffold(
        body: Center(child: Text('Error: No se encontró el grupo')),
      );
    }

    final group = taskProvider.getGroupById(groupId);
    final tasks = taskProvider.getTasksByGroup(groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    taskProvider.toggleTaskCompletion(group, task);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    taskProvider.deleteTask(group, task);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_add",
            onPressed: () async {
              final newTask = await taskProvider.addTask(context, group);
              if (newTask != null) {
                await NotificationService.showNotification(
                  'Nueva tarea creada',
                  newTask.title,
                );
              }
            },
            child: Icon(Icons.add),
            tooltip: 'Agregar Tarea',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn_bluetooth",
            onPressed: () async {
              final tasks = taskProvider.getTasksByGroup(groupId);

              List<BluetoothDevice> devices =
                  await MyBluetoothService.scanDevices();

              if (devices.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('No se encontraron dispositivos Bluetooth.')));
                return;
              }

              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(devices[index].name.isEmpty
                            ? 'Dispositivo desconocido'
                            : devices[index].name),
                        subtitle: Text(devices[index].id.id),
                        onTap: () async {
                          Navigator.pop(context); // Cierra modal
                          await MyBluetoothService.sendTasksToDevice(
                              devices[index], tasks);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('¡Tareas enviadas exitosamente!')));
                        },
                      );
                    },
                  );
                },
              );
            },
            child: Icon(Icons.bluetooth),
            tooltip: 'Enviar Tareas por Bluetooth',
          ),
        ],
      ),
    );
  }
}
