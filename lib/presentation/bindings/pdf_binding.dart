import 'package:get/get.dart';
import '../controllers/pdf_controller.dart';

/// Injection de dépendances pour la page d'aperçu PDF (PdfPreviewPage).
class PdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfController>(() => PdfController());
  }
}
