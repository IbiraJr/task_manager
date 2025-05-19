import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/usecases/add_task.dart';
import 'package:task_manager/features/task/domain/usecases/get_tasks.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  TaskBloc({required this.getTasks, required this.addTask})
    : super(TaskInitial()) {
    on<GetTasksEvent>(_onGetTasksEvent);

    on<AddTaskEvent>(_onAddTaskEvent);
  }

  Future<void> _onGetTasksEvent(
    GetTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    await Future.delayed(const Duration(seconds: 3));
    final List<Task> tasks = await getTasks.call();
    emit(TaskLoaded(tasks: tasks));
  }

  Future<void> _onAddTaskEvent(
    AddTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    await addTask.call(event.task);
  }
}
