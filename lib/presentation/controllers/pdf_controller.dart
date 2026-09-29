import 'dart:typed_data';
import 'package:get/get.dart';

/// Contrôleur GetX pour la page d'aperçu et d'impression PDF.
class PdfController extends GetxController {
  final Rx<Uint8List> pdfData = Uint8List(0).obs;
  final RxString title = 'Aperçu du document PDF'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['pdfBytes'] is Uint8List) {
        pdfData.value = args['pdfBytes'] as Uint8List;
      } else if (args['pdfBytes'] is List<int>) {
        pdfData.value = Uint8List.fromList(args['pdfBytes'] as List<int>);
      }
      if (args['title'] is String) {
        title.value = args['title'] as String;
      }
    }
  }
}
