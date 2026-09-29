import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/member_local_data_source.dart';
import '../../data/repositories/member_repository_impl.dart';
import '../../data/services/card_pdf_generator_impl.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/services/card_pdf_generator.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/generate_cards_pdf_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../controllers/history_controller.dart';

/// Injection de dépendances pour la page d'historique (HistoryPage).
class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    // DataSource & Services Data
    if (!Get.isRegistered<MemberLocalDataSource>()) {
      final prefs = Get.find<SharedPreferences>();
      Get.lazyPut<MemberLocalDataSource>(() => MemberLocalDataSourceImpl(prefs));
    }

    // Repositories
    if (!Get.isRegistered<MemberRepository>()) {
      Get.lazyPut<MemberRepository>(
        () => MemberRepositoryImpl(Get.find<MemberLocalDataSource>()),
      );
    }
    if (!Get.isRegistered<CardPdfGenerator>()) {
      Get.lazyPut<CardPdfGenerator>(() => CardPdfGeneratorImpl());
    }

    // Use cases
    Get.lazyPut<GetMembersUseCase>(
      () => GetMembersUseCase(Get.find<MemberRepository>()),
    );
    Get.lazyPut<DeleteMemberUseCase>(
      () => DeleteMemberUseCase(Get.find<MemberRepository>()),
    );
    if (!Get.isRegistered<GenerateCardsPdfUseCase>()) {
      Get.lazyPut<GenerateCardsPdfUseCase>(
        () => GenerateCardsPdfUseCase(Get.find<CardPdfGenerator>()),
      );
    }

    // Controller
    Get.lazyPut<HistoryController>(
      () => HistoryController(
        getMembersUseCase: Get.find<GetMembersUseCase>(),
        deleteMemberUseCase: Get.find<DeleteMemberUseCase>(),
        generateCardsPdfUseCase: Get.find<GenerateCardsPdfUseCase>(),
      ),
    );
  }
}
