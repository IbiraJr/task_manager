import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  AuthBloc({required this.signInUseCase, required this.signUpUseCase})
    : super(AuthInitial()) {
    on<SignInEvent>(_signInEvent);
  }

  FutureOr<void> _signInEvent(SignInEvent event, Emitter<AuthState> emit) {
    // TODO: implement signInEvent
    throw UnimplementedError();
  }
}
