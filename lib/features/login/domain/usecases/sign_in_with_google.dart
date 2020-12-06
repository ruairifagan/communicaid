import 'package:communicaid/core/error/failures.dart';
import 'package:communicaid/core/usecases/usecase.dart';
import 'package:communicaid/features/login/domain/entities/user.dart';
import 'package:communicaid/features/login/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

class SignInWithGoogle extends UseCase<User, NoParam> {
  final LoginRepository repository;

  SignInWithGoogle({@required this.repository});

  @override
  Future<Either<Failure, User>> call(NoParam params) {
    return repository.signInWithGoogle();
  }
}
