import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/member_local_data_source.dart';
import '../models/member_model.dart';

/// Implémentation du repository des membres avec gestion des erreurs via Failure.
class MemberRepositoryImpl implements MemberRepository {
  final MemberLocalDataSource _localDataSource;

  const MemberRepositoryImpl(this._localDataSource);

  @override
  Future<List<Member>> getMembers() async {
    try {
      final models = await _localDataSource.getMembers();
      return models;
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (e) {
      throw StorageFailure('Erreur imprévue lors de la récupération : $e');
    }
  }

  @override
  Future<void> saveMembers(List<Member> members) async {
    try {
      final models = members.map((m) => MemberModel.fromEntity(m)).toList();
      await _localDataSource.saveMembers(models);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (e) {
      throw StorageFailure('Erreur imprévue lors de la sauvegarde : $e');
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    try {
      await _localDataSource.deleteMember(id);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (e) {
      throw StorageFailure('Erreur imprévue lors de la suppression : $e');
    }
  }
}
