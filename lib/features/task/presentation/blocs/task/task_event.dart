part of 'task_bloc.dart';

@immutable
sealed class TaskEvent {}

final class GetTasksEvent extends TaskEvent {}
