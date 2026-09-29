import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/generate_cards_pdf_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';

/// Contrôleur GetX pour la page d'historique des cartes enregistrées.
class HistoryController extends GetxController {
  final GetMembersUseCase getMembersUseCase;
  final DeleteMemberUseCase deleteMemberUseCase;
  final GenerateCardsPdfUseCase generateCardsPdfUseCase;

  HistoryController({
    required this.getMembersUseCase,
    required this.deleteMemberUseCase,
    required this.generateCardsPdfUseCase,
  });

  final RxList<Member> members = <Member>[].obs;
  final RxSet<String> selectedMemberIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  /// Charge tous les membres depuis le stockage
  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      final result = await getMembersUseCase();
      // Trier par ordre antéchronologique (les plus récents en premier)
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      members.assignAll(result);
      // Nettoyer les sélections obsolètes
      selectedMemberIds.retainAll(result.map((m) => m.id));
    } on Failure catch (e) {
      Get.snackbar(
        'Erreur',
        e.message,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Bascule la sélection d'un membre individuel
  void toggleMemberSelection(String id) {
    if (selectedMemberIds.contains(id)) {
      selectedMemberIds.remove(id);
    } else {
      selectedMemberIds.add(id);
    }
  }

  /// Sélectionne ou désélectionne l'ensemble des membres
  void toggleSelectAll() {
    if (selectedMemberIds.length == members.length) {
      selectedMemberIds.clear();
    } else {
      selectedMemberIds.assignAll(members.map((m) => m.id));
    }
  }

  bool get isAllSelected =>
      members.isNotEmpty && selectedMemberIds.length == members.length;

  /// Demande confirmation avant de supprimer un membre (boîte de dialogue GetX)
  void promptDelete(Member member) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment supprimer la carte de ${member.name} (${member.id}) ?\n\n'
          '⚠️ Règle stricte : ce numéro (${member.id}) ne sera JAMAIS réattribué à un autre membre.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await _executeDelete(member.id);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDelete(String id) async {
    try {
      isLoading.value = true;
      await deleteMemberUseCase(id);
      selectedMemberIds.remove(id);
      await loadMembers();
      Get.snackbar(
        'Succès',
        'Carte supprimée avec succès.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.lightGreen,
        colorText: AppColors.darkGreen,
      );
    } on Failure catch (e) {
      Get.snackbar(
        'Erreur',
        e.message,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Génère le PDF A4 pour les cartes cochées
  Future<void> generatePdfForSelected() async {
    final selectedMembers =
        members.where((m) => selectedMemberIds.contains(m.id)).toList();

    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Sélection vide',
        'Veuillez cocher au moins une carte à imprimer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
      );
      return;
    }

    try {
      isGenerating.value = true;
      final pdfBytes = await generateCardsPdfUseCase(selectedMembers);

      Get.toNamed(
        AppRoutes.pdfPreview,
        arguments: {
          'pdfBytes': pdfBytes,
          'title': 'Cartes Sélectionnées (${selectedMembers.length})',
        },
      );
    } on Failure catch (e) {
      Get.snackbar(
        'Erreur PDF',
        e.message,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGenerating.value = false;
    }
  }
}
