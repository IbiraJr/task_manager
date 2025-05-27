import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
    required this.signInUseCase,
    required this.signUpUseCase,
  }) : super(Unauthenticated()) {
    on<SignInEvent>(_signInEvent);
    on<SignUpEvent>(_signUpEvent);
    on<SignOutEvent>(_signOutEvent);
    on<CheckAuthStatusEvent>(_checkAuthStatusEvent);
  }

  Future<void> _signInEvent(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInUseCase.call(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(Authenticated()),
    );
  }

  Future<void> _signUpEvent(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUseCase.call(
      event.email,
      event.password,
      event.name,
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(Authenticated()),
    );
  }

  FutureOr<void> _signOutEvent(SignOutEvent event, Emitter<AuthState> emit) {}

  Future<void> _checkAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: implement error handling
    final User? user = await getCurrentUserUseCase.call();
    if (user != null) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }
}
