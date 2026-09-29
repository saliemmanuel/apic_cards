import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/member.dart';

/// Boîte de dialogue interactive pour prévisualiser fidèlement une carte (Recto & Verso).
class CardPreviewDialog extends StatefulWidget {
  final Member member;

  const CardPreviewDialog({super.key, required this.member});

  @override
  State<CardPreviewDialog> createState() => _CardPreviewDialogState();
}

class _CardPreviewDialogState extends State<CardPreviewDialog> {
  bool _showVerso = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête du dialogue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aperçu de la Carte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.member.id.isNotEmpty
                              ? 'N° ${widget.member.id}'
                              : 'Numéro prévisionnel',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sélecteur Recto / Verso
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFaceTab(
                      title: 'Recto',
                      isSelected: !_showVerso,
                      onTap: () => setState(() => _showVerso = false),
                    ),
                  ),
                  Expanded(
                    child: _buildFaceTab(
                      title: 'Verso',
                      isSelected: _showVerso,
                      onTap: () => setState(() => _showVerso = true),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rendu visuel fidèle de la carte (format CR80 ratio 85.6 : 54)
            AspectRatio(
              aspectRatio: 85.6 / 54.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.cuttingGuide, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 440,
                      height: 440 * (54.0 / 85.6),
                      child: _showVerso ? _buildVersoCard() : _buildRectoCard(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton pour basculer Recto / Verso
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showVerso = !_showVerso),
                icon: const Icon(Icons.flip_camera_android_outlined, size: 18),
                label: Text(
                  _showVerso ? 'Afficher le Recto' : 'Afficher le Verso',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  /// Rendu RECTO (Adapté fidèlement au modèle PDF)
  Widget _buildRectoCard() {
    final member = widget.member;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCCC), width: 0.8),
      ),
      child: Column(
        children: [
          // 1. Zone principale avec dégradé subtil blanc -> vert pastel et motif
          Expanded(
            child: Stack(
              children: [
                // Fond en dégradé
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF2F9F3),
                          Color(0xFFE2F2E6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Motif de sécurité circuit en fond
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.65,
                    child: Image.asset(
                      AppStrings.assetPattern,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Contenu principal
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 7, 13, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // En-tête : Nom association & Devise centrés
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            AppStrings.associationName,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B6038),
                              height: 1.15,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.8),
                          Text(
                            AppStrings.associationMotto,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF217346),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Corps : Photo (gauche) + Informations (centre) + Logo (droite) parfaitement alignés
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Photo avec bordure verte et coins arrondis
                            Container(
                              width: 113,
                              height: 144,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(5.5),
                                border: Border.all(
                                  color: const Color(0xFF217346),
                                  width: 1.8,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.5),
                                child: _buildPhotoWidget(member),
                              ),
                            ),

                            const SizedBox(width: 20.5),

                            // 2. Informations textuelles au centre (ajustées à la hauteur de la photo et justifiées)
                            Expanded(
                              child: SizedBox(
                                height: 144,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Titre de la carte
                                    const Text(
                                      AppStrings.cardTitle,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),

                                    // Name (tout en gras)
                                    RichText(
                                      maxLines: 2,
                                      text: TextSpan(
                                        text: '${AppStrings.labelName} ',
                                        style: const TextStyle(
                                          fontSize: 10.2,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: member.name.isNotEmpty
                                                ? member.name
                                                : 'Nom Complet',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Designation (tout en gras et totalement visible)
                                    RichText(
                                      text: TextSpan(
                                        text: '${AppStrings.labelDesignation} ',
                                        style: const TextStyle(
                                          fontSize: 9.1,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: member.occupation.isNotEmpty
                                                ? member.occupation
                                                : 'Occupation',
                                            style: const TextStyle(
                                              fontSize: 9.1,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // No CNI (en gras)
                                    if (member.cniNumber.isNotEmpty)
                                      Text(
                                        '${AppStrings.labelCni} ${member.cniNumber}',
                                        style: const TextStyle(
                                          fontSize: 8.7,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),

                                    // Date de délivrance (en gras)
                                    if (member.issueDate != null)
                                      Text(
                                        'Délivrée le : ${DateFormatter.format(member.issueDate)}',
                                        style: const TextStyle(
                                          fontSize: 8.0,
                                          color: Colors.black,
                                        ),
                                      ),

                                    // Date d'expiration (en gras)
                                    if (member.expiryDate != null)
                                      Text(
                                        'Expire le : ${DateFormatter.format(member.expiryDate)}',
                                        style: const TextStyle(
                                          fontSize: 8.0,
                                          color: Colors.black,
                                        ),
                                      ),

                                    // ID No. (en gras)
                                    Text(
                                      '${AppStrings.labelIdNo} ${member.id.isNotEmpty ? member.id : "00254"}',
                                      style: const TextStyle(
                                        fontSize: 11.2,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 15.4),

                            // 3. Logo officiel APIC (droite, parfaitement centré verticalement)
                            Image.asset(
                              AppStrings.assetLogo,
                              width: 113,
                              height: 113,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 113,
                                    height: 113,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF217346),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'APIC',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF217346),
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Bande verte horizontale inférieure avec mention de validité
          Container(
            height: 18,
            color: const Color(0xFF217346),
            alignment: Alignment.center,
            child: Text(
              AppStrings.getCardValidityNotice(member.createdAt),
              style: const TextStyle(
                fontSize: 8.7,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rendu VERSO (Adapté fidèlement au modèle PDF)
  Widget _buildVersoCard() {
    final member = widget.member;
    final qrContent =
        'APIC|${member.id}|${member.name}|\nCarte approuvée par Mr HASSANA A.';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCCC), width: 0.8),
      ),
      child: Column(
        children: [
          // 1. Bande verte supérieure
          Container(height: 18, color: const Color(0xFF217346)),

          // 2. Zone centrale du verso avec motif de fond
          Expanded(
            child: Stack(
              children: [
                // Motif de sécurité circuit en fond
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.65,
                    child: Image.asset(
                      AppStrings.assetPattern,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),

                // A. Ligne pointillée horizontale médiane
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      36,
                      (_) => Container(
                        width: 6.3,
                        height: 1.1,
                        color: const Color(0xFFBDBDBD),
                      ),
                    ),
                  ),
                ),

                // B. Cachet officiel et signature centrés
                Center(
                  child: Image.asset(
                    AppStrings.assetCachet,
                    width: 257,
                    height: 257,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF217346),
                          width: 1.8,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'LE PRÉSIDENT\nAPIC',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.1,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF217346),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // C. Textes et QR Code
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Haut : Mention de propriété à gauche, QR Code à droite
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 3.6),
                              child: Text(
                                AppStrings.versoPropertyNotice,
                                style: TextStyle(
                                  fontSize: 10.2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7.2),
                          Container(
                            width: 105,
                            height: 105,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomPaint(
                              painter: _QrCodePainter(qrContent),
                            ),
                          ),
                        ],
                      ),

                      // Bas : Mentions administratives et contact
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              AppStrings.versoFooterLine1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 1.5),
                            Text(
                              AppStrings.versoFooterLine2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Bande verte inférieure avec mention de validité
          Container(
            height: 18,
            color: const Color(0xFF217346),
            alignment: Alignment.center,
            child: Text(
              AppStrings.getCardValidityNotice(member.createdAt),
              style: const TextStyle(
                fontSize: 8.7,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(Member member) {
    if (member.photoBase64 != null && member.photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(member.photoBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.5),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      } catch (_) {}
    }

    return Center(
      child: Text(
        'PHOTO',
        style: TextStyle(
          fontSize: 9.1,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Peintre personnalisé pour rendre fidèlement le QR code identique au PDF
class _QrCodePainter extends CustomPainter {
  final String data;
  _QrCodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final bc = pw.Barcode.qrCode();
      final ops = bc.make(data, width: size.width, height: size.height);
      final paint = Paint()..color = Colors.black;
      for (final op in ops) {
        if (op is pw.BarcodeBar && op.black) {
          canvas.drawRect(
            Rect.fromLTWH(op.left, op.top, op.width, op.height),
            paint,
          );
        }
      }
    } catch (_) {}
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) =>
      oldDelegate.data != data;
}
