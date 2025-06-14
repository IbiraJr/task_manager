// Mocks generated by Mockito 5.4.6 from annotations
// in task_manager/test/features/auth/domain/usecases/get_current_user_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:dartz/dartz.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:task_manager/core/error/failures.dart' as _i5;
import 'package:task_manager/features/auth/domain/entities/user.dart' as _i6;
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeEither_0<L, R> extends _i1.SmartFake implements _i2.Either<L, R> {
  _FakeEither_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [AuthRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthRepository extends _i1.Mock implements _i3.AuthRepository {
  MockAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.User>> signIn(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#signIn, [email, password]),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i6.User>>.value(
              _FakeEither_0<_i5.Failure, _i6.User>(
                this,
                Invocation.method(#signIn, [email, password]),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.User>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.User>> signUp(
    String? email,
    String? password,
    String? name,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#signUp, [email, password, name]),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i6.User>>.value(
              _FakeEither_0<_i5.Failure, _i6.User>(
                this,
                Invocation.method(#signUp, [email, password, name]),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.User>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, void>> signOut() =>
      (super.noSuchMethod(
            Invocation.method(#signOut, []),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, void>>.value(
              _FakeEither_0<_i5.Failure, void>(
                this,
                Invocation.method(#signOut, []),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, void>>);
}
