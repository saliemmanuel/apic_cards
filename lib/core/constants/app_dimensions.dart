/// Dimensions exactes et calcul de mise en page A4 pour les cartes professionnelles.
/// Toutes les valeurs sont définies en millimètres réels (mm).
class AppDimensions {
  AppDimensions._();

  /// Largeur standard d'une carte CR80 en mm
  static const double cardWidthMm = 85.6;

  /// Hauteur standard d'une carte CR80 en mm
  static const double cardHeightMm = 54.0;

  /// Espacement (gap) entre les cartes en mm
  static const double gapMm = 0.0;

  /// Largeur d'une feuille A4 en portrait (mm)
  static const double a4WidthMm = 210.0;

  /// Hauteur d'une feuille A4 en portrait (mm)
  static const double a4HeightMm = 297.0;

  /// Nombre de colonnes par page A4
  static const int columnsPerPage = 2;

  /// Nombre de lignes par page A4
  static const int rowsPerPage = 5;

  /// Nombre total de cartes par page A4 (10 cartes au total)
  static const int cardsPerPage = columnsPerPage * rowsPerPage;

  /// Largeur totale occupée par les cartes et les espacements
  static double get totalCardsWidthMm =>
      (columnsPerPage * cardWidthMm) + ((columnsPerPage - 1) * gapMm);

  /// Hauteur totale occupée par les cartes et les espacements
  static double get totalCardsHeightMm =>
      (rowsPerPage * cardHeightMm) + ((rowsPerPage - 1) * gapMm);

  /// Marge horizontale calculée (gauche et droite) pour centrer les cartes
  static double get horizontalMarginMm =>
      (a4WidthMm - totalCardsWidthMm) / 2.0;

  /// Marge verticale calculée (haut et bas) pour centrer les cartes
  static double get verticalMarginMm =>
      (a4HeightMm - totalCardsHeightMm) / 2.0;

  /// Valide que les 10 cartes tiennent sur la page A4 avec les dimensions configurées
  static bool validateA4Fit() {
    assert(
      totalCardsWidthMm <= a4WidthMm,
      'Erreur de mise en page : $totalCardsWidthMm mm dépasse la largeur A4 ($a4WidthMm mm)',
    );
    assert(
      totalCardsHeightMm <= a4HeightMm,
      'Erreur de mise en page : $totalCardsHeightMm mm dépasse la hauteur A4 ($a4HeightMm mm)',
    );
    return totalCardsWidthMm <= a4WidthMm && totalCardsHeightMm <= a4HeightMm;
  }
}
