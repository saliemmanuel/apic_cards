import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../controllers/grid_controller.dart';

/// Widget de fiche / carte individuelle optimisée pour écran mobile.
class MobileGridCardItem extends StatelessWidget {
  final GridRowItem row;
  final int index;
  final GridController controller;

  const MobileGridCardItem({
    super.key,
    required this.row,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8E4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. En-tête de la carte : Numéro, badge ID prévisionnel et actions
          _buildCardHeader(context),

          const Divider(height: 1, color: Color(0xFFECEFEF)),

          // 2. Corps du formulaire avec champs adaptés pour le tactile
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo d'identité
                _buildPhotoSection(context),

                const SizedBox(height: 12),

                // Champ Nom et Prénom(s)
                _buildFormField(
                  label: AppStrings.colName,
                  controller: row.nameController,
                  hintText: AppStrings.placeholderName,
                  icon: Icons.person_outline,
                  isRequired: true,
                  textCapitalization: TextCapitalization.characters,
                ),

                const SizedBox(height: 10),

                // Champ N° CNI
                _buildFormField(
                  label: AppStrings.colCni,
                  controller: row.cniController,
                  hintText: AppStrings.placeholderCni,
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 10),

                // Dates de Délivrance et Expiration côte à côte
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        context: context,
                        label: AppStrings.colIssueDate,
                        dateRx: row.issueDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDateField(
                        context: context,
                        label: AppStrings.colExpiryDate,
                        dateRx: row.expiryDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Lieu de Résidence
                _buildFormField(
                  label: AppStrings.colResidence,
                  controller: row.residenceController,
                  hintText: AppStrings.placeholderResidence,
                  icon: Icons.location_city_outlined,
                ),

                const SizedBox(height: 10),

                // Occupation / Fonction
                _buildFormField(
                  label: AppStrings.colOccupation,
                  controller: row.occupationController,
                  hintText: AppStrings.placeholderOccupation,
                  icon: Icons.work_outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// En-tête avec index, ID prévisionnel et boutons d'action
  Widget _buildCardHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FBFA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Badge numéro de ligne
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '#${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.darkGreen,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Badge ID prévisionnel
          Expanded(
            child: Obx(() {
              final id = row.previewCardId.value;
              if (id.isEmpty) {
                return Text(
                  'Ligne non assignée',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                );
              }
              return Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'N° $id',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          // Bouton Aperçu de la carte
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: AppColors.primaryGreen,
              size: 20,
            ),
            tooltip: 'Aperçu de la carte',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => controller.previewRowCard(row, index),
          ),

          const SizedBox(width: 4),

          // Bouton Supprimer / Vider la ligne
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            tooltip: 'Supprimer cette carte',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  /// Section photo d'identité interactive
  Widget _buildPhotoSection(BuildContext context) {
    return Obx(() {
      final photoBase64 = row.photoBase64.value;
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8E4)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(
                  base64Decode(photoBase64),
                  width: 50,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Photo d\'identité chargée',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Format 4x4 conforme',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.pickPhoto(row),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Changer', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                tooltip: 'Retirer la photo',
                onPressed: () => controller.removePhoto(row),
              ),
            ],
          ),
        );
      }

      return InkWell(
        onTap: () => controller.pickPhoto(row),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FBF8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.35),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Ajouter la photo d\'identité (4x4)',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Champ de texte avec étiquette au-dessus
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FBFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDE3DF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDE3DF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Sélecteur de date responsive
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required Rxn<DateTime> dateRx,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          final date = dateRx.value;
          final hasDate = date != null;

          return InkWell(
            onTap: () => controller.pickDate(context, dateRx),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasDate
                      ? AppColors.primaryGreen.withValues(alpha: 0.5)
                      : const Color(0xFFDDE3DF),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: hasDate
                        ? AppColors.primaryGreen
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasDate ? DateFormatter.format(date) : 'jj/mm/aaaa',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: hasDate
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: hasDate ? Colors.black87 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  if (hasDate)
                    InkWell(
                      onTap: () => dateRx.value = null,
                      child: const Icon(
                        Icons.close,
                        size: 15,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    if (!row.hasName) {
      controller.removeRow(index);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la ligne'),
        content: Text(
          'Voulez-vous supprimer la ligne #${index + 1} (${row.nameController.text.trim()}) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeRow(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
