import 'package:get/get.dart';
import '../../presentation/bindings/grid_binding.dart';
import '../../presentation/bindings/history_binding.dart';
import '../../presentation/bindings/pdf_binding.dart';
import '../../presentation/pages/grid_page.dart';
import '../../presentation/pages/history_page.dart';
import '../../presentation/pages/pdf_preview_page.dart';
import 'app_routes.dart';

/// Déclaration des pages de l'application avec leurs Bindings GetX.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.grid;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.grid,
      page: () => const GridPage(),
      binding: GridBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.pdfPreview,
      page: () => const PdfPreviewPage(),
      binding: PdfBinding(),
    ),
  ];
}
