import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/task/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/task/presentation/pages/task_form_page.dart';
import 'package:task_manager/features/task/presentation/pages/task_list_page.dart';
import 'package:task_manager/injection_container.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: TaskListPage.routeName,
      name: 'taskList',
      builder:
          (context, state) => BlocProvider(
            create: (_) => sl<TaskBloc>()..add(GetTasksEvent()),
            child: const TaskListPage(),
          ),
    ),
    GoRoute(
      path: TaskFormPage.routeName,
      name: 'newTask',
      builder:
          (context, state) => BlocProvider(
            create: (_) => sl<TaskBloc>(),
            child: const TaskFormPage(),
          ),
    ),
  ],
);
