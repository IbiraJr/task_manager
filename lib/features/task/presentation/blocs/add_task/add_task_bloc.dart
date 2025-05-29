import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/usecases/add_task.dart';

part 'add_task_event.dart';
part 'add_task_state.dart';

class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
  final AddTask addTask;
  AddTaskBloc({required this.addTask}) : super(AddTaskInitial()) {
    on<SubmitTaskEvent>(_onAddTaskEvent);
  }

  Future<void> _onAddTaskEvent(
    SubmitTaskEvent event,
    Emitter<AddTaskState> emit,
  ) async {
    emit(AddTaskLoading());
    final result = await addTask.call(event.task);
    result.fold(
      (failure) => emit(AddTaskError(message: failure.message)),
      (_) => emit(TaskAdded()),
    );
  }
}
