import '../../core/utils/clock.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';
import '../repositories/sequence_repository.dart';
import 'peek_next_sequence_usecase.dart';

/// Données préliminaires de saisie avant attribution définitive du numéro de carte.
class MemberDraft {
  final String name;
  final String cniNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String residence;
  final String occupation;
  final String? photoBase64;
  final String regionCode;

  const MemberDraft({
    required this.name,
    required this.cniNumber,
    this.issueDate,
    this.expiryDate,
    required this.residence,
    required this.occupation,
    this.photoBase64,
    required this.regionCode,
  });
}

/// Cas d'usage attribuant les numéros officiels séquentiels aux membres puis les enregistrant.
class AddMembersUseCase {
  final MemberRepository memberRepository;
  final SequenceRepository sequenceRepository;
  final Clock clock;

  const AddMembersUseCase({
    required this.memberRepository,
    required this.sequenceRepository,
    this.clock = const SystemClock(),
  });

  /// Attribue les numéros séquentiels dans l'ordre, persiste la séquence et sauvegarde les membres.
  Future<List<Member>> call({
    required List<MemberDraft> drafts,
    required String regionCode,
  }) async {
    if (drafts.isEmpty) return [];

    final year = clock.now().year;
    var currentSeq =
        await sequenceRepository.getCurrentSequence(regionCode, year);

    final now = clock.now();
    final createdMembers = <Member>[];

    for (final draft in drafts) {
      final cardId = PeekNextSequenceUseCase.formatCardId(
        regionCode,
        year,
        currentSeq,
      );

      final member = Member(
        id: cardId,
        name: draft.name.trim(),
        cniNumber: draft.cniNumber.trim(),
        issueDate: draft.issueDate,
        expiryDate: draft.expiryDate,
        residence: draft.residence.trim(),
        occupation: draft.occupation.trim(),
        photoBase64: draft.photoBase64,
        regionCode: regionCode,
        createdAt: now,
      );

      createdMembers.add(member);
      currentSeq++;
    }

    // Sauvegarde la nouvelle valeur du compteur (ne décrémente jamais)
    await sequenceRepository.setSequence(regionCode, year, currentSeq);

    // Persiste les membres
    await memberRepository.saveMembers(createdMembers);

    return createdMembers;
  }
}
