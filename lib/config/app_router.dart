import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/pages/sign_in.dart';
import 'package:task_manager/features/auth/presentation/pages/sign_up.dart';
import 'package:task_manager/features/task/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/task/presentation/pages/task_form_page.dart';
import 'package:task_manager/features/task/presentation/pages/task_list_page.dart';
import 'package:task_manager/injection_container.dart';

final router = GoRouter(
  initialLocation: TaskListPage.routeName,
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();
    final goingToLogin = state.matchedLocation == SignInPage.routeName;
    final goingToSignUp = state.matchedLocation == SignUpPage.routeName;
    if (authBloc.state is Unauthenticated && !goingToLogin && !goingToSignUp) {
      return SignInPage.routeName;
    }
    return null;
  },
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
    GoRoute(
      path: SignInPage.routeName,
      name: 'signIn',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: SignUpPage.routeName,
      name: 'signUp',
      builder: (context, state) => const SignUpPage(),
    ),
  ],
);
