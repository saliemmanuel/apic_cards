import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../controllers/pdf_controller.dart';

/// Page d'aperçu et d'impression du document PDF A4.
class PdfPreviewPage extends GetView<PdfController> {
  const PdfPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.title.value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bandeau d'avertissement d'échelle d'impression (point critique)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: const Color(0xFFFFF3CD),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF856404),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.printAdvisoryNotice,
                      style: const TextStyle(
                        color: Color(0xFF856404),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Composant d'aperçu et d'export du PDF
            Expanded(
              child: Obx(() {
                final bytes = controller.pdfData.value;
                if (bytes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune donnée PDF à afficher.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  );
                }

                return PdfPreview(
                  pdfFileName: 'cartes_APIC.pdf',
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  dynamicLayout: false,
                  previewPageMargin: const EdgeInsets.all(6),
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  build: (format) async => bytes,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
