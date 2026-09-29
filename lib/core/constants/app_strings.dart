import '../utils/date_formatter.dart';

/// Textes fixes, mentions légales et chemins des assets de l'association APIC.
class AppStrings {
  AppStrings._();

  // Association
  static const String appTitle = 'APIC - Cartes Professionnelles';
  static const String associationName =
      "ASSOCIATION DES PROPAGATEURS DE L'ISLAM AU CAMEROUN";
  static const String associationAcronym = 'APIC';
  static const String associationMotto = 'ISLAM FOI ET SOUMISSION';

  // Recto de la carte
  static const String cardTitle = "CARTE D'IDENTITÉ PROFESSIONNELLE";
  static const String labelName = 'Name:';
  static const String labelDesignation = 'Designation:';
  static const String labelCni = 'No CNI:';
  static const String labelIdNo = 'ID No.';

  // Verso de la carte
  static const String versoPropertyNotice =
      "Cette carte est une Propriétée D’APIC";
  static const String cardValidityNotice = "Cette carte a une validité d'un an";
  static const String pageFooterValidityNotice =
      "Cette carte a une validité d'un an à compter de sa date d'émission.";

  static String getCardValidityNotice(DateTime? date) {
    if (date != null) {
      return "Valable 1 an — Émise le : ${DateFormatter.format(date)}";
    }
    return cardValidityNotice;
  }
  static const String versoFooterLine1 =
      "N° EN/REC/2025 Bureau: N° A2-3 Carrefour Schell";
  static const String versoFooterLine2 =
      "BP: 945 Maroua Cameroun   Tél: 699 3690 86";
  static const String versoFooterNotice =
      "$versoFooterLine1\n$versoFooterLine2";

  // Rappel d'impression
  static const String printAdvisoryNotice =
      '⚠️ IMPORTANT : Imprimer à 100 % / taille réelle, ne pas choisir « Ajuster à la page » pour respecter les 85,6 x 54 mm.';

  // Placeholders pour la saisie
  static const String placeholderName = 'Nom Complet';
  static const String placeholderCni = '0000000000000';
  static const String placeholderResidence = 'Ville, Pays';
  static const String placeholderOccupation = 'Occupation';

  // Colonnes de la grille
  static const String colNumber = 'N°';
  static const String colName = 'NOM';
  static const String colCni = 'N° CNI';
  static const String colIssueDate = 'Date de délivrance';
  static const String colExpiryDate = "Date d'expiration";
  static const String colResidence = 'Résidence';
  static const String colOccupation = 'Occupation';
  static const String colPhoto = 'Photo';

  // Assets
  static const String assetLogo = 'assets/logo.png';
  static const String assetCachet = 'assets/cachet.png';
  static const String assetPattern = 'assets/card_pattern.png';
  static const String assetFontRegular = 'assets/fonts/Roboto-Regular.ttf';
  static const String assetFontBold = 'assets/fonts/Roboto-Bold.ttf';
  static const String assetFontItalic = 'assets/fonts/Roboto-Italic.ttf';
}
