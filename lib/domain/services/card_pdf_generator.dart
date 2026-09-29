import '../entities/member.dart';

/// Interface du service de génération de document PDF pour les cartes APIC.
abstract class CardPdfGenerator {
  /// Génère les octets du PDF A4 (10 cartes par page, rectos puis versos inversés).
  Future<List<int>> generatePdf(List<Member> members);
}
