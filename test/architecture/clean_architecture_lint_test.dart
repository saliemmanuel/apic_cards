import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Critères de validation - Respect strict de la Clean Architecture', () {
    test('Le dossier domain/ ne contient aucun import de flutter, get, shared_preferences ou pdf', () {
      final domainDir = Directory('lib/domain');
      expect(domainDir.existsSync(), isTrue, reason: 'Le dossier lib/domain doit exister');

      final forbiddenPatterns = [
        'package:flutter',
        'package:get',
        'package:shared_preferences',
        'package:pdf',
        'package:printing',
        'dart:ui',
      ];

      final dartFiles = domainDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        for (final forbidden in forbiddenPatterns) {
          expect(
            content.contains(forbidden),
            isFalse,
            reason:
                'Le fichier ${file.path} viole la règle du domaine pur en important "$forbidden"',
          );
        }
      }
    });

    test('Aucun controller GetX n\'importe un fichier du dossier data/', () {
      final controllersDir = Directory('lib/presentation/controllers');
      expect(
        controllersDir.existsSync(),
        isTrue,
        reason: 'Le dossier lib/presentation/controllers doit exister',
      );

      final dartFiles = controllersDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(
          content.contains('data/'),
          isFalse,
          reason:
              'Le controller ${file.path} ne doit JAMAIS importer la couche data directe.',
        );
      }
    });
  });
}
