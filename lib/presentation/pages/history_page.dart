import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_regions.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/member.dart';
import '../controllers/history_controller.dart';
import '../widgets/card_preview_dialog.dart';

/// Page d'historique des cartes enregistrées avec sélection multiple et réimpression A4.
class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Historique des Cartes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadMembers,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.members.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (controller.members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune carte enregistrée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saisissez des membres dans la grille pour générer vos premières cartes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Barre d'outils supérieure : Tout sélectionner + Compteur
              _buildSelectionBar(),

              // Liste des cartes enregistrées
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: controller.members.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final member = controller.members[index];
                    return _buildMemberCard(member);
                  },
                ),
              ),

              // Barre inférieure d'action : Imprimer les cartes cochées
              _buildBottomPrintBar(),
            ],
          );
        }),
      ),
    );
  }

  /// Barre d'outils supérieure avec case Tout sélectionner
  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Obx(
            () => Checkbox(
              value: controller.isAllSelected,
              activeColor: AppColors.primaryGreen,
              onChanged: (_) => controller.toggleSelectAll(),
            ),
          ),
          const Text(
            'Tout sélectionner',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const Spacer(),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.selectedMemberIds.length} / ${controller.members.length} sélectionnée(s)',
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Carte individuelle affichant les détails d'un membre
  Widget _buildMemberCard(Member member) {
    return Obx(() {
      final isSelected = controller.selectedMemberIds.contains(member.id);

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => controller.toggleMemberSelection(member.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Case à cocher
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (_) => controller.toggleMemberSelection(member.id),
                ),

                // Miniature photo
                _buildPhotoThumbnail(member),

                const SizedBox(width: 12),

                // Détails du membre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              member.id,
                              style: const TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppRegions.getRegionName(member.regionCode),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.occupation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CNI : ${member.cniNumber.isNotEmpty ? member.cniNumber : '-'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (member.issueDate != null || member.expiryDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${member.issueDate != null ? 'Délivrée le : ${DateFormatter.format(member.issueDate)}' : ''}${member.issueDate != null && member.expiryDate != null ? '  •  ' : ''}${member.expiryDate != null ? 'Expire le : ${DateFormatter.format(member.expiryDate)}' : ''}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions : Aperçu & Supprimer (compact pour mobile)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Aperçu de la carte',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      onPressed: () => Get.dialog(CardPreviewDialog(member: member)),
                    ),
                    IconButton(
                      tooltip: 'Supprimer cette carte',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () => controller.promptDelete(member),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Miniature de photo
  Widget _buildPhotoThumbnail(Member member) {
    if (member.photoBase64 != null && member.photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(member.photoBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            bytes,
            width: 44,
            height: 54,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }

    return Container(
      width: 44,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.person_outline,
        color: Colors.grey.shade500,
        size: 26,
      ),
    );
  }

  /// Barre inférieure pour régénérer le PDF
  Widget _buildBottomPrintBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.selectedMemberIds.isEmpty ||
                    controller.isGenerating.value
                ? null
                : controller.generatePdfForSelected,
            icon: controller.isGenerating.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              controller.isGenerating.value
                  ? 'Génération du PDF...'
                  : 'Générer le PDF A4 des cartes cochées (${controller.selectedMemberIds.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
