import 'package:flutter_test/flutter_test.dart';
import 'package:apic_cards/core/constants/app_dimensions.dart';
import 'package:apic_cards/domain/entities/member.dart';
import 'package:apic_cards/domain/usecases/generate_cards_pdf_usecase.dart';
import 'mock_repositories.dart';

void main() {
  group('Critères de validation - Mise en page A4 et calcul des marges', () {
    test('Format de carte et dimensions A4', () {
      expect(AppDimensions.cardWidthMm, 85.6);
      expect(AppDimensions.cardHeightMm, 54.0);
      expect(AppDimensions.gapMm, 0.0);
      expect(AppDimensions.a4WidthMm, 210.0);
      expect(AppDimensions.a4HeightMm, 297.0);
      expect(AppDimensions.columnsPerPage, 2);
      expect(AppDimensions.rowsPerPage, 5);
      expect(AppDimensions.cardsPerPage, 10);
    });

    test('Calcul précis des marges centrées (19.4 mm et 13.5 mm)', () {
      // 2 x 85.6 = 171.2 mm
      expect(AppDimensions.totalCardsWidthMm, 171.2);
      // (210 - 171.2) / 2 = 19.4 mm
      expect(AppDimensions.horizontalMarginMm, closeTo(19.4, 0.001));

      // 5 x 54 = 270.0 mm
      expect(AppDimensions.totalCardsHeightMm, 270.0);
      // (297 - 270) / 2 = 13.5 mm
      expect(AppDimensions.verticalMarginMm, closeTo(13.5, 0.001));
    });

    test('Validation de tenue dans la page (assert sans exception)', () {
      expect(AppDimensions.validateA4Fit(), isTrue);
    });

    test('10 cartes donnent 2 pages (recto + verso) ; 11 cartes donnent 4 pages', () async {
      final fakePdfGen = FakeCardPdfGenerator();
      final useCase = GenerateCardsPdfUseCase(fakePdfGen);

      Member createDummyMember(int i) => Member(
            id: 'EN2026${i.toString().padLeft(3, '0')}',
            name: 'Nom $i',
            cniNumber: 'CNI$i',
            residence: 'Ville',
            occupation: 'Occupation',
            regionCode: 'EN',
            createdAt: DateTime.now(),
          );

      // Cas 1 : 10 cartes -> 1 lot -> 2 pages (1 recto + 1 verso)
      final members10 = List.generate(10, createDummyMember);
      final pdfBytes10 = await useCase(members10);
      // FakeCardPdfGenerator crée 100 octets par page
      expect(pdfBytes10.length, 2 * 100);

      // Cas 2 : 11 cartes -> 2 lots -> 4 pages (2 rectos + 2 versos)
      final members11 = List.generate(11, createDummyMember);
      final pdfBytes11 = await useCase(members11);
      expect(pdfBytes11.length, 4 * 100);
    });
  });
}
