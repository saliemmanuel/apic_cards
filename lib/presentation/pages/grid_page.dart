import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_regions.dart';
import '../../core/constants/app_strings.dart';
import '../controllers/grid_controller.dart';
import '../widgets/grid_row_widget.dart';
import '../widgets/grid_table_header.dart';
import '../widgets/mobile_grid_card_item.dart';

/// Écran principal : Grille de saisie Excel et Fiches mobiles des cartes APIC.
class GridPage extends GetView<GridController> {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                AppStrings.appTitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Historique des cartes',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.toNamed(AppRoutes.history),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800 ||
                MediaQuery.of(context).size.shortestSide < 600;

            return Column(
              children: [
                // 1. Barre supérieure : Région, Compteur et Bascule Tableau/Fiches
                _buildTopControlBar(context, isMobile),

                // 2. Zone centrale : Vue Fiches (toujours sans grille sur mobile) OU Vue au choix sur Desktop
                Expanded(
                  child: isMobile
                      ? _buildCardListView()
                      : Obx(() {
                          final isCardMode = controller.isCardViewMode.value;
                          if (isCardMode) {
                            return _buildCardListView();
                          } else {
                            return _buildTableView(context, isMobile);
                          }
                        }),
                ),

                // 3. Barre d'actions inférieure (responsive)
                _buildBottomActionBar(context, isMobile),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Barre supérieure adaptative
  Widget _buildTopControlBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          children: [
            // Sélecteur de région pleine largeur (mode sans grille automatique sur mobile)
            _buildRegionDropdown(isMobile: true),
            const SizedBox(height: 8),
            // Compteur de cartes
            _buildCountBadge(),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Sélecteur de région
          _buildRegionDropdown(isMobile: false),

          const SizedBox(width: 16),

          // Compteur de cartes
          Expanded(child: _buildCountBadge()),

          const SizedBox(width: 16),

          // Bouton bascule de vue (Tableau / Fiches)
          _buildViewModeToggle(isMobile: false),
        ],
      ),
    );
  }

  /// Menu déroulant de choix de Région
  Widget _buildRegionDropdown({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.primaryGreen,
            size: 18,
          ),
          const SizedBox(width: 6),
          const Text(
            'Région : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.darkGreen,
            ),
          ),
          if (isMobile)
            Expanded(
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedRegion.value,
                    borderRadius: BorderRadius.circular(8),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryGreen,
                    ),
                    items: AppRegions.regions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          '${entry.key} - ${entry.value}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: controller.onRegionChanged,
                  ),
                ),
              ),
            )
          else
            Obx(
              () => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedRegion.value,
                  borderRadius: BorderRadius.circular(8),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primaryGreen,
                  ),
                  items: AppRegions.regions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        '${entry.key} - ${entry.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: controller.onRegionChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Badge du nombre de cartes renseignées
  Widget _buildCountBadge() {
    return Obx(() {
      final filledCount = controller.rows.where((r) => r.hasName).length;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightGreen.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 17,
                  color: AppColors.darkGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  '$filledCount / ${controller.rows.length} carte(s) renseignée(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '1 feuille = 10 cartes',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkGreen.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Bascule entre le mode Tableau Excel et le mode Fiches mobiles
  Widget _buildViewModeToggle({required bool isMobile}) {
    return Obx(() {
      final isCardMode = controller.isCardViewMode.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDE3DF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton Tableau
            InkWell(
              onTap: isCardMode ? controller.toggleViewMode : null,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(7),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: !isCardMode
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 16,
                      color: !isCardMode ? Colors.white : Colors.grey.shade700,
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Tableau',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !isCardMode ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bouton Fiches
            InkWell(
              onTap: !isCardMode ? controller.toggleViewMode : null,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(7),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCardMode
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.view_agenda_outlined,
                      size: 16,
                      color: isCardMode ? Colors.white : Colors.grey.shade700,
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Fiches',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCardMode ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Vue en liste de Fiches mobiles (Mobile-First)
  Widget _buildCardListView() {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: controller.rows.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Bouton Ajouter une carte à la fin de la liste
          if (index == controller.rows.length) {
            return OutlinedButton.icon(
              onPressed: controller.addRow,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                'Ajouter une carte',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          final row = controller.rows[index];
          return MobileGridCardItem(
            key: ObjectKey(row),
            row: row,
            index: index,
            controller: controller,
          );
        },
      ),
    );
  }

  /// Vue en Tableau Excel traditionnel défilable
  Widget _buildTableView(BuildContext context, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Astuce de défilement horizontal sur écran mobile
          if (isMobile)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.swipe_outlined,
                    size: 14,
                    color: AppColors.darkGreen,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Glissez horizontalement pour voir toutes les colonnes',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Tableau Excel avec barre de défilement visible
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFDDE3DF)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Scrollbar(
                  controller: controller.horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: controller.horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête vert fixe
                          const GridTableHeader(),

                          // Lignes défilables verticalement
                          Expanded(
                            child: Obx(
                              () => ListView.builder(
                                itemCount: controller.rows.length,
                                itemBuilder: (context, index) {
                                  final row = controller.rows[index];
                                  return GridRowWidget(
                                    key: ObjectKey(row),
                                    row: row,
                                    index: index,
                                    controller: controller,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre inférieure avec actions principales (Responsive)
  Widget _buildBottomActionBar(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isMobile ? 10 : 12,
      ),
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
      child: isMobile
          // Disposition Mobile : 2 rangées optimisées
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Bouton Ajouter une ligne
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.addRow,
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text('Ajouter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bouton Prévisualiser PDF A4
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.previewA4Pdf,
                        icon: const Icon(Icons.visibility_outlined, size: 17),
                        label: const Text('Aperçu A4'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bouton Principal Enregistrer & Générer PDF A4
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveAndGeneratePdf,
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined, size: 19),
                      label: Text(
                        controller.isLoading.value
                            ? 'Génération en cours...'
                            : 'Enregistrer & Générer le PDF A4',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          // Disposition Desktop / Tablette large
          : Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Bouton Ajouter une ligne
                OutlinedButton.icon(
                  onPressed: controller.addRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une ligne'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Bouton Prévisualiser le PDF A4
                OutlinedButton.icon(
                  onPressed: controller.previewA4Pdf,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Prévisualiser le PDF A4'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Bouton Enregistrer et générer le PDF A4
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveAndGeneratePdf,
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: Text(
                      controller.isLoading.value
                          ? 'Génération en cours...'
                          : 'Enregistrer et générer le PDF A4',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
