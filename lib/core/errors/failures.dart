/// Classe de base pour toutes les erreurs gérées dans l'application.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Erreur survenue lors du stockage ou de la lecture des données locales.
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Erreur de stockage local']);
}

/// Erreur survenue lors de la génération ou du rendu du document PDF.
class PdfFailure extends Failure {
  const PdfFailure([super.message = 'Erreur lors de la génération du PDF']);
}

/// Erreur de validation des données d'un membre ou des dimensions.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides']);
}
