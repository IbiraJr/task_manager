import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/usecases/get_tasks.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  TaskBloc({required this.getTasks}) : super(TaskInitial()) {
    on<GetTasksEvent>(_onGetTasksEvent);
  }

  Future<void> _onGetTasksEvent(
    GetTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    final dartz.Either<Failure, List<Task>> result = await getTasks.call();
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(TaskLoaded(tasks: tasks)),
    );
  }
}
