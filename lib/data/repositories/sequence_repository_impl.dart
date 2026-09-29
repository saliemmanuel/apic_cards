import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../datasources/member_local_data_source.dart';

/// Implémentation du repository de séquence avec persistance dans SharedPreferences.
class SequenceRepositoryImpl implements SequenceRepository {
  final MemberLocalDataSource _localDataSource;

  const SequenceRepositoryImpl(this._localDataSource);

  @override
  Future<int> getCurrentSequence(String regionCode, int year) async {
    try {
      return await _localDataSource.getSequence(regionCode, year);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (e) {
      throw StorageFailure('Erreur lors de la lecture du compteur : $e');
    }
  }

  @override
  Future<void> setSequence(String regionCode, int year, int nextSequence) async {
    try {
      await _localDataSource.setSequence(regionCode, year, nextSequence);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (e) {
      throw StorageFailure('Erreur lors de la mise à jour du compteur : $e');
    }
  }
}
