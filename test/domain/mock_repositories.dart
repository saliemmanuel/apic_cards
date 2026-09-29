import 'package:apic_cards/core/utils/clock.dart';
import 'package:apic_cards/domain/entities/member.dart';
import 'package:apic_cards/domain/repositories/member_repository.dart';
import 'package:apic_cards/domain/repositories/sequence_repository.dart';
import 'package:apic_cards/domain/services/card_pdf_generator.dart';

/// Horloge simulée pour piloter l'année courante dans les tests.
class MockClock implements Clock {
  DateTime _current;

  MockClock(this._current);

  void setYear(int year) {
    _current = DateTime(year, _current.month, _current.day, _current.hour);
  }

  void setDateTime(DateTime dateTime) {
    _current = dateTime;
  }

  @override
  DateTime now() => _current;
}

/// Faux repository de séquence en mémoire (sans aucune dépendance Flutter ou GetX).
class FakeSequenceRepository implements SequenceRepository {
  final Map<String, int> _sequences = {};

  String _buildKey(String regionCode, int year) => '${regionCode}_$year';

  @override
  Future<int> getCurrentSequence(String regionCode, int year) async {
    return _sequences[_buildKey(regionCode, year)] ?? 1;
  }

  @override
  Future<void> setSequence(String regionCode, int year, int nextSequence) async {
    _sequences[_buildKey(regionCode, year)] = nextSequence;
  }
}

/// Faux repository de membres en mémoire.
class FakeMemberRepository implements MemberRepository {
  final List<Member> _members = [];

  @override
  Future<List<Member>> getMembers() async {
    return List.unmodifiable(_members);
  }

  @override
  Future<void> saveMembers(List<Member> members) async {
    for (final m in members) {
      _members.removeWhere((existing) => existing.id == m.id);
      _members.add(m);
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m.id == id);
  }
}

/// Faux générateur PDF pour les tests unitaires purs.
class FakeCardPdfGenerator implements CardPdfGenerator {
  @override
  Future<List<int>> generatePdf(List<Member> members) async {
    // 10 cartes par page -> 1 page recto + 1 page verso = 2 pages
    final int pages = members.isEmpty ? 2 : ((members.length / 10).ceil() * 2);
    return List.filled(pages * 100, 42);
  }
}
