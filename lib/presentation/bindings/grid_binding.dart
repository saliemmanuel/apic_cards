import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/clock.dart';
import '../../data/datasources/member_local_data_source.dart';
import '../../data/repositories/member_repository_impl.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../data/services/card_pdf_generator_impl.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../../domain/services/card_pdf_generator.dart';
import '../../domain/usecases/add_members_usecase.dart';
import '../../domain/usecases/generate_cards_pdf_usecase.dart';
import '../../domain/usecases/peek_next_sequence_usecase.dart';
import '../controllers/grid_controller.dart';

/// Injection de dépendances pour la page de saisie (GridPage).
class GridBinding extends Bindings {
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
    if (!Get.isRegistered<SequenceRepository>()) {
      Get.lazyPut<SequenceRepository>(
        () => SequenceRepositoryImpl(Get.find<MemberLocalDataSource>()),
      );
    }
    if (!Get.isRegistered<CardPdfGenerator>()) {
      Get.lazyPut<CardPdfGenerator>(() => CardPdfGeneratorImpl());
    }

    // Horloge système
    if (!Get.isRegistered<Clock>()) {
      Get.lazyPut<Clock>(() => const SystemClock());
    }

    // Use cases
    Get.lazyPut<PeekNextSequenceUseCase>(
      () => PeekNextSequenceUseCase(
        Get.find<SequenceRepository>(),
        clock: Get.find<Clock>(),
      ),
    );
    Get.lazyPut<AddMembersUseCase>(
      () => AddMembersUseCase(
        memberRepository: Get.find<MemberRepository>(),
        sequenceRepository: Get.find<SequenceRepository>(),
        clock: Get.find<Clock>(),
      ),
    );
    Get.lazyPut<GenerateCardsPdfUseCase>(
      () => GenerateCardsPdfUseCase(Get.find<CardPdfGenerator>()),
    );

    // Controller
    Get.lazyPut<GridController>(
      () => GridController(
        peekNextSequenceUseCase: Get.find<PeekNextSequenceUseCase>(),
        addMembersUseCase: Get.find<AddMembersUseCase>(),
        generateCardsPdfUseCase: Get.find<GenerateCardsPdfUseCase>(),
      ),
    );
  }
}
