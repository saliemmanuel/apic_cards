import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../controllers/grid_controller.dart';

/// Ligne individuelle de la grille de saisie Excel avec cellules interactives.
class GridRowWidget extends StatelessWidget {
  final GridRowItem row;
  final int index;
  final GridController controller;

  const GridRowWidget({
    super.key,
    required this.row,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    final rowBackground = isEven ? Colors.white : const Color(0xFFF9FBFA);

    return Container(
      decoration: BoxDecoration(
        color: rowBackground,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8E4), width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 1. Colonne N° (non modifiable, mise à jour réactive dès saisie du nom)
            _buildNumberCell(width: 100),

            // 2. Colonne NOM
            _buildTextCell(
              controller: row.nameController,
              hintText: AppStrings.placeholderName,
              width: 200,
              isBold: true,
            ),

            // 3. Colonne N° CNI
            _buildTextCell(
              controller: row.cniController,
              hintText: AppStrings.placeholderCni,
              width: 140,
              keyboardType: TextInputType.number,
            ),

            // 4. Colonne Date de délivrance (sélecteur jj/mm/aaaa)
            _buildDateCell(
              context: context,
              dateRx: row.issueDate,
              width: 130,
            ),

            // 5. Colonne Date d'expiration (sélecteur jj/mm/aaaa)
            _buildDateCell(
              context: context,
              dateRx: row.expiryDate,
              width: 130,
            ),

            // 6. Colonne Résidence
            _buildTextCell(
              controller: row.residenceController,
              hintText: AppStrings.placeholderResidence,
              width: 150,
            ),

            // 7. Colonne Occupation
            _buildTextCell(
              controller: row.occupationController,
              hintText: AppStrings.placeholderOccupation,
              width: 150,
            ),

            // 8. Colonne Photo
            _buildPhotoCell(width: 110, isLast: true),
          ],
        ),
      ),
    );
  }

  /// Cellule N° automatique non modifiable
  Widget _buildNumberCell({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8E4), width: 1),
        ),
      ),
      child: Center(
        child: Obx(() {
          final id = row.previewCardId.value;
          if (id.isEmpty) {
            return Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            );
          }
          return Tooltip(
            message: 'Appuyez pour prévisualiser la carte',
            child: InkWell(
              onTap: () => controller.previewRowCard(row, index),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      id,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.visibility_outlined,
                      size: 12,
                      color: AppColors.darkGreen,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Cellule de saisie textuelle avec texte d'exemple grisé
  Widget _buildTextCell({
    required TextEditingController controller,
    required String hintText,
    required double width,
    bool isBold = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8E4), width: 1),
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  /// Cellule de date avec sélecteur jj/mm/aaaa
  Widget _buildDateCell({
    required BuildContext context,
    required Rxn<DateTime> dateRx,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8E4), width: 1),
        ),
      ),
      child: InkWell(
        onTap: () => controller.pickDate(context, dateRx),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() {
                  final date = dateRx.value;
                  if (date == null) {
                    return Text(
                      'jj/mm/aaaa',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }
                  return Text(
                    DateFormatter.format(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  );
                }),
              ),
              Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cellule Photo avec miniature et sélection depuis la galerie
  Widget _buildPhotoCell({required double width, bool isLast = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8E4), width: 1),
        ),
      ),
      child: Center(
        child: Obx(() {
          final photoBase64 = row.photoBase64.value;
          if (photoBase64 != null && photoBase64.isNotEmpty) {
            try {
              final bytes = base64Decode(photoBase64);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      bytes,
                      width: 44,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.removePhoto(row),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } catch (_) {
              return const Icon(Icons.broken_image, size: 24, color: Colors.grey);
            }
          }

          return InkWell(
            onTap: () => controller.pickPhoto(row),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Photo',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
