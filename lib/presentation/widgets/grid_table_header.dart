import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// En-tête vert (#217346) de la grille de saisie façon tableau Excel.
class GridTableHeader extends StatelessWidget {
  const GridTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildHeaderCell(AppStrings.colNumber, width: 100),
            _buildHeaderCell(AppStrings.colName, width: 200),
            _buildHeaderCell(AppStrings.colCni, width: 140),
            _buildHeaderCell(AppStrings.colIssueDate, width: 130),
            _buildHeaderCell(AppStrings.colExpiryDate, width: 130),
            _buildHeaderCell(AppStrings.colResidence, width: 150),
            _buildHeaderCell(AppStrings.colOccupation, width: 150),
            _buildHeaderCell(AppStrings.colPhoto, width: 110, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String title, {
    required double width,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
