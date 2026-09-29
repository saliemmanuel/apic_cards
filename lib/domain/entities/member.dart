/// Entité métier immuable représentant un membre de l'APIC titulaire d'une carte.
/// Dart pur : aucun import Flutter ni de package externe.
class Member {
  final String id;
  final String name;
  final String cniNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String residence;
  final String occupation;
  final String? photoBase64;
  final String regionCode;
  final DateTime createdAt;

  const Member({
    required this.id,
    required this.name,
    required this.cniNumber,
    this.issueDate,
    this.expiryDate,
    required this.residence,
    required this.occupation,
    this.photoBase64,
    required this.regionCode,
    required this.createdAt,
  });

  Member copyWith({
    String? id,
    String? name,
    String? cniNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? residence,
    String? occupation,
    String? photoBase64,
    String? regionCode,
    DateTime? createdAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      cniNumber: cniNumber ?? this.cniNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      residence: residence ?? this.residence,
      occupation: occupation ?? this.occupation,
      photoBase64: photoBase64 ?? this.photoBase64,
      regionCode: regionCode ?? this.regionCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          cniNumber == other.cniNumber &&
          issueDate == other.issueDate &&
          expiryDate == other.expiryDate &&
          residence == other.residence &&
          occupation == other.occupation &&
          photoBase64 == other.photoBase64 &&
          regionCode == other.regionCode;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      cniNumber.hashCode ^
      issueDate.hashCode ^
      expiryDate.hashCode ^
      residence.hashCode ^
      occupation.hashCode ^
      (photoBase64?.hashCode ?? 0) ^
      regionCode.hashCode;

  @override
  String toString() {
    return 'Member(id: $id, name: $name, region: $regionCode)';
  }
}
