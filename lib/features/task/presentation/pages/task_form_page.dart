import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/presentation/blocs/add_task/add_task_bloc.dart';
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
      appBar: AppBar(
        key: const Key('taskFormPageAppBar'),
        title: Text('Add Task'),
      ),
      body: BlocConsumer<AddTaskBloc, AddTaskState>(
        listener: (context, state) {
          if (state is TaskAdded) {
            Navigator.pop(context);
          }
          if (state is AddTaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AddTaskLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 24.0,
              children: [
                TextFormField(
                  key: Key('titleField'),
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  key: Key('descriptionField'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                ElevatedButton(
                  key: Key('submitButton'),
                  onPressed: () {
                    final Task task = Task(
                      id: Uuid().v4(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      isCompleted: false,
                      createdAt: DateTime.now(),
                    );
                    context.read<AddTaskBloc>().add(SubmitTaskEvent(task));
                  },
                  child: Text('Add Task'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
