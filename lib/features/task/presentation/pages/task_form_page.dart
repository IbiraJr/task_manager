import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/presentation/bloc/task_bloc.dart';
import 'package:uuid/uuid.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});
  static const routeName = '/task/form';

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 24.0,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            ElevatedButton(
              onPressed: () {
                final Task task = Task(
                  id: Uuid().v4(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  isCompleted: false,
                  createdAt: DateTime.now(),
                );
                context.read<TaskBloc>().add(AddTaskEvent(task));
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
