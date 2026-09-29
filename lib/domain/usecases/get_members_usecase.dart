import '../entities/member.dart';
import '../repositories/member_repository.dart';

/// Cas d'usage permettant de récupérer la liste des membres enregistrés.
class GetMembersUseCase {
  final MemberRepository _repository;

  const GetMembersUseCase(this._repository);

  Future<List<Member>> call() async {
    return await _repository.getMembers();
  }
}
