/// Interface du repository gérant la séquence d'incrémentation des numéros de carte.
/// Un compteur distinct est maintenu par région et par année (ex: seq_EN_2026).
abstract class SequenceRepository {
  /// Retourne le prochain numéro de séquence pour une région et une année données (défaut : 1).
  Future<int> getCurrentSequence(String regionCode, int year);

  /// Met à jour la valeur de la prochaine séquence pour une région et une année données.
  Future<void> setSequence(String regionCode, int year, int nextSequence);
}
