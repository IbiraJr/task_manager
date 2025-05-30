part of 'add_task_bloc.dart';

@immutable
sealed class AddTaskEvent extends Equatable {}

final class SubmitTaskEvent extends AddTaskEvent {
  final Task task;
  SubmitTaskEvent(this.task);

  @override
  // TODO: implement props
  List<Object?> get props => [task];
}
