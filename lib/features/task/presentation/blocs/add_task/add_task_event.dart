part of 'add_task_bloc.dart';

@immutable
sealed class AddTaskEvent {}

final class SubmitTaskEvent extends AddTaskEvent {
  final Task task;
  SubmitTaskEvent(this.task);
}
