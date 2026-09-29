import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apic_cards/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ApicCardsApp démarre et affiche la grille de saisie', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    await tester.pumpWidget(const ApicCardsApp());
    await tester.pumpAndSettle();

    expect(find.text('APIC - Cartes Professionnelles'), findsOneWidget);
    expect(find.text('Ajouter une ligne'), findsOneWidget);
    expect(find.text('Enregistrer et générer le PDF A4'), findsOneWidget);
  });
}
