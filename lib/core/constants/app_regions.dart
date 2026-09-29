/// Définition des 10 régions du Cameroun et de leurs codes officiels.
class AppRegions {
  AppRegions._();

  /// Map des codes de région vers leurs libellés officiels
  static const Map<String, String> regions = {
    'EN': 'Extrême-Nord',
    'NO': 'Nord',
    'AD': 'Adamaoua',
    'CE': 'Centre',
    'ES': 'Est',
    'LT': 'Littoral',
    'NW': 'Nord-Ouest',
    'OU': 'Ouest',
    'SU': 'Sud',
    'SW': 'Sud-Ouest',
  };

  /// Code par défaut
  static const String defaultRegionCode = 'EN';

  /// Obtenir le libellé d'une région à partir de son code
  static String getRegionName(String code) {
    return regions[code] ?? code;
  }
}
