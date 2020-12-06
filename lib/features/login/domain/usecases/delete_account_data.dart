import 'package:communicaid/core/error/failures.dart';
import 'package:communicaid/core/usecases/usecase.dart';
import 'package:communicaid/features/login/domain/entities/user.dart';
import 'package:communicaid/features/login/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

class DeleteAccountData extends UseCase<String, User> {
  final LoginRepository repository;

  DeleteAccountData({@required this.repository});

  @override
  Future<Either<Failure, String>> call(User user) {
    return repository.deleteAccount(user);
  }
}
