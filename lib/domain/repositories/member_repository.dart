import '../entities/member.dart';

/// Interface du repository gérant la persistance des membres.
abstract class MemberRepository {
  /// Récupère la liste de tous les membres enregistrés.
  Future<List<Member>> getMembers();

  /// Enregistre ou met à jour une liste de membres.
  Future<void> saveMembers(List<Member> members);

  /// Supprime un membre par son identifiant unique.
  Future<void> deleteMember(String id);
}
