import '../../domain/entities/member.dart';

/// Modèle de données pour la sérialisation / désérialisation JSON d'un membre.
class MemberModel extends Member {
  const MemberModel({
    required super.id,
    required super.name,
    required super.cniNumber,
    super.issueDate,
    super.expiryDate,
    required super.residence,
    required super.occupation,
    super.photoBase64,
    required super.regionCode,
    required super.createdAt,
  });

  /// Crée une instance de [MemberModel] depuis une entité métier [Member].
  factory MemberModel.fromEntity(Member member) {
    return MemberModel(
      id: member.id,
      name: member.name,
      cniNumber: member.cniNumber,
      issueDate: member.issueDate,
      expiryDate: member.expiryDate,
      residence: member.residence,
      occupation: member.occupation,
      photoBase64: member.photoBase64,
      regionCode: member.regionCode,
      createdAt: member.createdAt,
    );
  }

  /// Décode un dictionnaire JSON en [MemberModel].
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cniNumber: json['cniNumber'] as String? ?? '',
      issueDate: json['issueDate'] != null
          ? DateTime.tryParse(json['issueDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
      residence: json['residence'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      photoBase64: json['photoBase64'] as String?,
      regionCode: json['regionCode'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convertit l'instance en dictionnaire JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cniNumber': cniNumber,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'residence': residence,
      'occupation': occupation,
      'photoBase64': photoBase64,
      'regionCode': regionCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
