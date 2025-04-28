// lib/screens/task_group_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Grupo de Tareas')),
      body: Center(child: Text('Pantalla de Grupo de Tareas')),
    );
  }
}
