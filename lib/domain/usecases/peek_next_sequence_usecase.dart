import '../../core/utils/clock.dart';
import '../repositories/sequence_repository.dart';

/// Cas d'usage permettant d'obtenir l'aperçu du prochain numéro de carte sans le consommer.
/// Utilise une horloge injectée pour obtenir l'année courante et la règle de formatage domaine.
class PeekNextSequenceUseCase {
  final SequenceRepository _sequenceRepository;
  final Clock _clock;

  const PeekNextSequenceUseCase(
    this._sequenceRepository, {
    this._clock = const SystemClock(),
  });

  /// Retourne le numéro de carte prévisionnel pour [regionCode] avec un éventuel [offset].
  /// Exemple : regionCode='EN', offset=0 -> 'EN2026001'
  Future<String> call(String regionCode, {int offset = 0}) async {
    final year = _clock.now().year;
    final currentSeq =
        await _sequenceRepository.getCurrentSequence(regionCode, year);
    final targetSeq = currentSeq + offset;
    return formatCardId(regionCode, year, targetSeq);
  }

  /// Règle métier de formatage du numéro : CODE_REGION + ANNEE + séquence (3 chiffres min, 4 si >=1000).
  static String formatCardId(String regionCode, int year, int sequence) {
    final seqStr = sequence < 1000
        ? sequence.toString().padLeft(3, '0')
        : sequence.toString();
    return '$regionCode$year$seqStr';
  }
}
