part of 'task_bloc.dart';

@immutable
sealed class TaskEvent {}

final class GetTasksEvent extends TaskEvent {}

final class AddTaskEvent extends TaskEvent {
  final Task task;
  AddTaskEvent(this.task);
}
