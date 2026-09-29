import 'package:flutter_test/flutter_test.dart';
import 'package:apic_cards/domain/usecases/add_members_usecase.dart';
import 'package:apic_cards/domain/usecases/delete_member_usecase.dart';
import 'package:apic_cards/domain/usecases/peek_next_sequence_usecase.dart';
import 'mock_repositories.dart';

void main() {
  late MockClock clock;
  late FakeSequenceRepository sequenceRepository;
  late FakeMemberRepository memberRepository;
  late PeekNextSequenceUseCase peekUseCase;
  late AddMembersUseCase addMembersUseCase;
  late DeleteMemberUseCase deleteMemberUseCase;

  setUp(() {
    clock = MockClock(DateTime(2026, 1, 15));
    sequenceRepository = FakeSequenceRepository();
    memberRepository = FakeMemberRepository();

    peekUseCase = PeekNextSequenceUseCase(
      sequenceRepository,
      clock: clock,
    );

    addMembersUseCase = AddMembersUseCase(
      memberRepository: memberRepository,
      sequenceRepository: sequenceRepository,
      clock: clock,
    );

    deleteMemberUseCase = DeleteMemberUseCase(memberRepository);
  });

  group('Critères de validation - Numérotation automatique et séquence', () {
    test(
      'Saisir 3 noms en région EN donne EN2026001, EN2026002, EN2026003 ; puis NO donne NO2026001',
      () async {
        // Aperçu préalable sans consommer
        expect(await peekUseCase('EN', offset: 0), 'EN2026001');
        expect(await peekUseCase('EN', offset: 1), 'EN2026002');
        expect(await peekUseCase('EN', offset: 2), 'EN2026003');

        // Saisie de 3 membres en région EN
        final draftsEN = [
          const MemberDraft(
            name: 'Ali Bachir',
            cniNumber: '111111111',
            residence: 'Maroua',
            occupation: 'Enseignant',
            regionCode: 'EN',
          ),
          const MemberDraft(
            name: 'Ousmanou Daouda',
            cniNumber: '222222222',
            residence: 'Mora',
            occupation: 'Commerçant',
            regionCode: 'EN',
          ),
          const MemberDraft(
            name: 'Aissatou Bouba',
            cniNumber: '333333333',
            residence: 'Kousseri',
            occupation: 'Infirmière',
            regionCode: 'EN',
          ),
        ];

        final membersEN = await addMembersUseCase(
          drafts: draftsEN,
          regionCode: 'EN',
        );

        expect(membersEN.length, 3);
        expect(membersEN[0].id, 'EN2026001');
        expect(membersEN[1].id, 'EN2026002');
        expect(membersEN[2].id, 'EN2026003');

        // Saisie ensuite en région NO -> doit donner NO2026001 (compteur distinct)
        expect(await peekUseCase('NO', offset: 0), 'NO2026001');

        final draftsNO = [
          const MemberDraft(
            name: 'Ibrahim Sali',
            cniNumber: '444444444',
            residence: 'Garoua',
            occupation: 'Mécanicien',
            regionCode: 'NO',
          ),
        ];

        final membersNO = await addMembersUseCase(
          drafts: draftsNO,
          regionCode: 'NO',
        );

        expect(membersNO.length, 1);
        expect(membersNO[0].id, 'NO2026001');
      },
    );

    test(
      'Après suppression d\'EN2026002, la saisie suivante en EN donne EN2026004 (séquence jamais réattribuée)',
      () async {
        // Enregistrement de 3 membres EN (EN2026001, EN2026002, EN2026003)
        final drafts = [
          const MemberDraft(
            name: 'Membre 1',
            cniNumber: '111',
            residence: 'Maroua',
            occupation: 'Occ 1',
            regionCode: 'EN',
          ),
          const MemberDraft(
            name: 'Membre 2',
            cniNumber: '222',
            residence: 'Maroua',
            occupation: 'Occ 2',
            regionCode: 'EN',
          ),
          const MemberDraft(
            name: 'Membre 3',
            cniNumber: '333',
            residence: 'Maroua',
            occupation: 'Occ 3',
            regionCode: 'EN',
          ),
        ];

        await addMembersUseCase(drafts: drafts, regionCode: 'EN');

        // Suppression de EN2026002
        await deleteMemberUseCase('EN2026002');

        // Vérification de la suppression dans le repository
        final remaining = await memberRepository.getMembers();
        expect(remaining.any((m) => m.id == 'EN2026002'), isFalse);
        expect(remaining.length, 2);

        // La saisie suivante en EN DOIT donner EN2026004 (le compteur ne décrémente JAMAIS)
        expect(await peekUseCase('EN', offset: 0), 'EN2026004');

        final nextDraft = [
          const MemberDraft(
            name: 'Membre 4',
            cniNumber: '444',
            residence: 'Maroua',
            occupation: 'Occ 4',
            regionCode: 'EN',
          ),
        ];

        final nextMembers = await addMembersUseCase(
          drafts: nextDraft,
          regionCode: 'EN',
        );

        expect(nextMembers.first.id, 'EN2026004');
      },
    );

    test(
      'Avec l\'horloge simulée sur 2027, la première carte EN est EN2027001 (réinitialisation annuelle)',
      () async {
        // Consommer 3 séquences en 2026
        final drafts2026 = [
          const MemberDraft(
            name: 'Test 2026',
            cniNumber: '111',
            residence: 'Maroua',
            occupation: 'Cadre',
            regionCode: 'EN',
          ),
        ];
        await addMembersUseCase(drafts: drafts2026, regionCode: 'EN');

        // Simulation du passage à l'année 2027 via l'horloge
        clock.setYear(2027);

        // La première carte EN en 2027 doit être EN2027001
        expect(await peekUseCase('EN', offset: 0), 'EN2027001');

        final drafts2027 = [
          const MemberDraft(
            name: 'Premier Membre 2027',
            cniNumber: '999',
            residence: 'Maroua',
            occupation: 'Professeur',
            regionCode: 'EN',
          ),
        ];

        final members2027 = await addMembersUseCase(
          drafts: drafts2027,
          regionCode: 'EN',
        );

        expect(members2027.first.id, 'EN2027001');
      },
    );

    test('Si la séquence dépasse 999, continuer avec 4 chiffres (ex: EN20261000)', () async {
      await sequenceRepository.setSequence('EN', 2026, 1000);

      expect(await peekUseCase('EN', offset: 0), 'EN20261000');

      final drafts = [
        const MemberDraft(
          name: 'Membre Millionième',
          cniNumber: '123456789',
          residence: 'Mora',
          occupation: 'Directeur',
          regionCode: 'EN',
        ),
      ];

      final members = await addMembersUseCase(drafts: drafts, regionCode: 'EN');
      expect(members.first.id, 'EN20261000');
    });

    test('PeekNextSequenceUseCase ne consomme pas la séquence', () async {
      final preview1 = await peekUseCase('EN');
      final preview2 = await peekUseCase('EN');
      expect(preview1, 'EN2026001');
      expect(preview2, 'EN2026001');

      final seqInRepo = await sequenceRepository.getCurrentSequence('EN', 2026);
      expect(seqInRepo, 1);
    });
  });
}
