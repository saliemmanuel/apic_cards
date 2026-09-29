import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '../models/member_model.dart';

/// Interface de la source de données locale (SharedPreferences).
abstract class MemberLocalDataSource {
  Future<List<MemberModel>> getMembers();
  Future<void> saveMembers(List<MemberModel> members);
  Future<void> deleteMember(String id);
  Future<int> getSequence(String regionCode, int year);
  Future<void> setSequence(String regionCode, int year, int nextSequence);
}

/// Implémentation basée sur [SharedPreferences].
///
/// ⚠️ AVERTISSEMENT DE SÉCURITÉ CONCERNANT LES DONNÉES SENSIBLES :
/// Les numéros de Carte Nationale d'Identité (N° CNI) sont actuellement stockés
/// en clair dans le JSON local via SharedPreferences.
/// Recommandations pour une future mise en production renforcée :
/// 1. Utiliser un chiffrement symétrique (ex: AES-256 via le package 'encrypt')
///    avant la sérialisation, avec clé stockée dans le Keystore Android / Keychain iOS.
/// 2. Utiliser 'flutter_secure_storage' pour les données d'identité sensibles.
/// 3. Protéger l'accès à l'application par un code PIN ou une authentification biométrique.
class MemberLocalDataSourceImpl implements MemberLocalDataSource {
  static const String _membersKey = 'apic_members_storage_key';
  static const String _seqPrefix = 'seq_';

  final SharedPreferences _prefs;

  const MemberLocalDataSourceImpl(this._prefs);

  @override
  Future<List<MemberModel>> getMembers() async {
    try {
      final jsonString = _prefs.getString(_membersKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => MemberModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Échec de la lecture des membres : $e');
    }
  }

  @override
  Future<void> saveMembers(List<MemberModel> newMembers) async {
    try {
      final currentList = await getMembers();
      // On met à jour ou ajoute les nouveaux membres
      final Map<String, MemberModel> map = {
        for (final m in currentList) m.id: m,
      };
      for (final m in newMembers) {
        map[m.id] = m;
      }
      final encoded = jsonEncode(map.values.map((m) => m.toJson()).toList());
      await _prefs.setString(_membersKey, encoded);
    } catch (e) {
      throw StorageException('Échec de l\'enregistrement des membres : $e');
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    try {
      final currentList = await getMembers();
      currentList.removeWhere((m) => m.id == id);
      final encoded =
          jsonEncode(currentList.map((m) => m.toJson()).toList());
      await _prefs.setString(_membersKey, encoded);
    } catch (e) {
      throw StorageException('Échec de la suppression du membre : $e');
    }
  }

  @override
  Future<int> getSequence(String regionCode, int year) async {
    try {
      final key = '$_seqPrefix${regionCode}_$year';
      return _prefs.getInt(key) ?? 1;
    } catch (e) {
      throw StorageException('Échec de la lecture du compteur : $e');
    }
  }

  @override
  Future<void> setSequence(String regionCode, int year, int nextSequence) async {
    try {
      final key = '$_seqPrefix${regionCode}_$year';
      await _prefs.setInt(key, nextSequence);
    } catch (e) {
      throw StorageException('Échec de l\'enregistrement du compteur : $e');
    }
  }
}
