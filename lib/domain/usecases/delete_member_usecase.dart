import '../repositories/member_repository.dart';

/// Cas d'usage permettant de supprimer un membre.
/// Important : le compteur de séquence n'est jamais décrémenté lors d'une suppression.
class DeleteMemberUseCase {
  final MemberRepository _repository;

  const DeleteMemberUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteMember(id);
  }
}
