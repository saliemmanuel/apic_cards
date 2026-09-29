/// Exceptions levées dans la couche data.
class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Erreur de stockage']);

  @override
  String toString() => message;
}

class PdfException implements Exception {
  final String message;
  const PdfException([this.message = 'Erreur PDF']);

  @override
  String toString() => message;
}
