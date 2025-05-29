part of 'add_task_bloc.dart';

@immutable
sealed class AddTaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AddTaskInitial extends AddTaskState {}

final class AddTaskLoading extends AddTaskState {}

final class TaskAdded extends AddTaskState {}

final class AddTaskError extends AddTaskState {
  final String message;
  AddTaskError({required this.message});

  @override
  List<Object?> get props => [message];
}
