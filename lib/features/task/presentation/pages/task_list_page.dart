import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/task/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/features/task/presentation/components/task_card.dart';
import 'package:task_manager/features/task/presentation/pages/task_form_page.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});
  static const routeName = '/';
  // static const routeName = '/task/list';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Task List - ${state.user.name}'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutEvent());
                  },
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await context.push(TaskFormPage.routeName);
                context.read<TaskBloc>().add(GetTasksEvent());
              },
              child: Icon(Icons.add),
            ),
            body: TaskListWidget(),
          );
        } else {
          return Center(child: Text('Something went wrong'));
        }
      },
    );
  }
}

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({super.key});

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaskLoaded) {
          if (state.tasks.isEmpty) {
            return Center(child: Text('No tasks found'));
          }
          return ListView.separated(
            itemCount: state.tasks.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return TaskCard(
                title: state.tasks[index].title,
                description: state.tasks[index].description,
                isCompleted: state.tasks[index].isCompleted,
              );
            },
          );
        }
        if (state is TaskError) {
          return Center(child: Text(state.message));
        }
        return Center(child: SizedBox(child: Text('Something went wrong')));
      },
    );
  }
}
