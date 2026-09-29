import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' hide PdfException;
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/member.dart';
import '../../domain/services/card_pdf_generator.dart';

/// Implémentation du générateur PDF A4 respectant les dimensions CR80 (85,6 x 54 mm)
/// et l'inversion des colonnes au verso pour l'impression recto-verso bord long.
class CardPdfGeneratorImpl implements CardPdfGenerator {
  @override
  Future<List<int>> generatePdf(List<Member> members) async {
    try {
      AppDimensions.validateA4Fit();

      final pdf = pw.Document(
        title: 'Cartes Professionnelles APIC',
        author: 'APIC Cameroun',
      );

      // Chargement sécurisé des polices (accents français hors-ligne)
      pw.Font? ttfRegular;
      pw.Font? ttfBold;
      pw.Font? ttfItalic;

      try {
        final regData = await rootBundle.load(AppStrings.assetFontRegular);
        ttfRegular = pw.Font.ttf(regData);
        final boldData = await rootBundle.load(AppStrings.assetFontBold);
        ttfBold = pw.Font.ttf(boldData);
        final itaData = await rootBundle.load(AppStrings.assetFontItalic);
        ttfItalic = pw.Font.ttf(itaData);
      } catch (_) {
        // En cas d'absence des fichiers de police, pdf utilise les polices standard
        ttfRegular = pw.Font.helvetica();
        ttfBold = pw.Font.helveticaBold();
        ttfItalic = pw.Font.helveticaOblique();
      }

      final theme = pw.ThemeData.withFont(
        base: ttfRegular,
        bold: ttfBold,
        italic: ttfItalic,
      );

      // Chargement sécurisé du logo, du cachet et du motif de fond
      pw.MemoryImage? logoImage;
      try {
        final logoBytes = await rootBundle.load(AppStrings.assetLogo);
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (_) {
        logoImage = null;
      }

      pw.MemoryImage? cachetImage;
      try {
        final cachetBytes = await rootBundle.load(AppStrings.assetCachet);
        cachetImage = pw.MemoryImage(cachetBytes.buffer.asUint8List());
      } catch (_) {
        cachetImage = null;
      }

      pw.MemoryImage? patternImage;
      try {
        final patternBytes = await rootBundle.load(AppStrings.assetPattern);
        patternImage = pw.MemoryImage(patternBytes.buffer.asUint8List());
      } catch (_) {
        patternImage = null;
      }

      // Découpage des membres par paquets de 10 (une page A4 = 10 cartes)
      const batchSize = AppDimensions.cardsPerPage;
      final int totalBatches = (members.isEmpty)
          ? 1
          : (members.length / batchSize).ceil();

      for (int b = 0; b < totalBatches; b++) {
        final startIndex = b * batchSize;
        final endIndex = (startIndex + batchSize > members.length)
            ? members.length
            : startIndex + batchSize;

        final batchMembers = (startIndex < members.length)
            ? members.sublist(startIndex, endIndex)
            : <Member>[];

        // 1. PAGE DE RECTOS (2 cols x 5 rows)
        pdf.addPage(
          pw.Page(
            theme: theme,
            pageFormat: const PdfPageFormat(
              AppDimensions.a4WidthMm * PdfPageFormat.mm,
              AppDimensions.a4HeightMm * PdfPageFormat.mm,
              marginAll: 0,
            ),
            build: (context) {
              return _buildPageLayout(
                isVerso: false,
                batchMembers: batchMembers,
                logoImage: logoImage,
                cachetImage: cachetImage,
                patternImage: patternImage,
              );
            },
          ),
        );

        // 2. PAGE DE VERSOS (Colonnes inversées pour correspondance recto-verso)
        pdf.addPage(
          pw.Page(
            theme: theme,
            pageFormat: const PdfPageFormat(
              AppDimensions.a4WidthMm * PdfPageFormat.mm,
              AppDimensions.a4HeightMm * PdfPageFormat.mm,
              marginAll: 0,
            ),
            build: (context) {
              return _buildPageLayout(
                isVerso: true,
                batchMembers: batchMembers,
                logoImage: logoImage,
                cachetImage: cachetImage,
                patternImage: patternImage,
              );
            },
          ),
        );
      }

      return await pdf.save();
    } catch (e) {
      throw PdfException('Échec lors de la génération du document PDF : $e');
    }
  }

  /// Construit la grille 2 colonnes x 5 lignes centrée avec les marges calculées.
  pw.Widget _buildPageLayout({
    required bool isVerso,
    required List<Member> batchMembers,
    required pw.MemoryImage? logoImage,
    required pw.MemoryImage? cachetImage,
    required pw.MemoryImage? patternImage,
  }) {
    final rows = <pw.Widget>[];

    for (int r = 0; r < AppDimensions.rowsPerPage; r++) {
      final cols = <pw.Widget>[];

      for (int c = 0; c < AppDimensions.columnsPerPage; c++) {
        // En recto : col 0 -> index r*2 + 0, col 1 -> index r*2 + 1
        // En verso : inversion des colonnes ! Col 0 reçoit le membre 1, col 1 reçoit le membre 0
        final int targetCol = isVerso ? (1 - c) : c;
        final int memberIndex = (r * AppDimensions.columnsPerPage) + targetCol;

        final member = (memberIndex < batchMembers.length)
            ? batchMembers[memberIndex]
            : null;

        cols.add(
          pw.Container(
            width: AppDimensions.cardWidthMm * PdfPageFormat.mm,
            height: AppDimensions.cardHeightMm * PdfPageFormat.mm,
            child: member != null
                ? (isVerso
                      ? _buildCardVerso(member, cachetImage, patternImage)
                      : _buildCardRecto(member, logoImage, patternImage))
                : _buildEmptyCardSlot(),
          ),
        );

        if (c < AppDimensions.columnsPerPage - 1 && AppDimensions.gapMm > 0) {
          cols.add(pw.SizedBox(width: AppDimensions.gapMm * PdfPageFormat.mm));
        }
      }

      rows.add(
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: cols),
      );

      if (r < AppDimensions.rowsPerPage - 1 && AppDimensions.gapMm > 0) {
        rows.add(pw.SizedBox(height: AppDimensions.gapMm * PdfPageFormat.mm));
      }
    }

    return pw.Container(
      width: AppDimensions.a4WidthMm * PdfPageFormat.mm,
      height: AppDimensions.a4HeightMm * PdfPageFormat.mm,
      child: pw.Stack(
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(
              horizontal: AppDimensions.horizontalMarginMm * PdfPageFormat.mm,
              vertical: AppDimensions.verticalMarginMm * PdfPageFormat.mm,
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: rows,
            ),
          ),
          pw.Positioned(
            bottom: 4 * PdfPageFormat.mm,
            left: 0,
            right: 0,
            child: pw.Center(
              child: pw.Text(
                AppStrings.pageFooterValidityNotice,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Emplacement vide (pour les pages incomplètes) avec fin repère de découpe
  pw.Widget _buildEmptyCardSlot() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFE0E0E0),
          width: 0.3 * PdfPageFormat.point,
        ),
      ),
    );
  }

  /// RECTO DE LA CARTE (85,6 x 54 mm) - Adapté fidèlement au modèle
  pw.Widget _buildCardRecto(
    Member member,
    pw.MemoryImage? logoImage,
    pw.MemoryImage? patternImage,
  ) {
    pw.MemoryImage? memberPhoto;
    if (member.photoBase64 != null && member.photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(member.photoBase64!);
        memberPhoto = pw.MemoryImage(bytes);
      } catch (_) {
        memberPhoto = null;
      }
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFCCCCCC),
          width: 0.4 * PdfPageFormat.point,
        ),
      ),
      child: pw.Column(
        children: [
          // 1. Zone principale avec dégradé subtil blanc -> vert pastel et motif
          pw.Expanded(
            child: pw.Stack(
              children: [
                // Fond en dégradé
                pw.Positioned.fill(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        begin: pw.Alignment.centerLeft,
                        end: pw.Alignment.centerRight,
                        colors: [
                          PdfColor.fromInt(0xFFFFFFFF),
                          PdfColor.fromInt(0xFFF2F9F3),
                          PdfColor.fromInt(0xFFE2F2E6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Motif de sécurité circuit en fond
                if (patternImage != null)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.65,
                      child: pw.Image(patternImage, fit: pw.BoxFit.cover),
                    ),
                  ),

                // Contenu principal
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(7, 4, 7, 3),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // En-tête : Nom association & Devise centrés
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            AppStrings.associationName,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF1B6038),
                            ),
                            maxLines: 2,
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            AppStrings.associationMotto,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontStyle: pw.FontStyle.italic,
                              color: const PdfColor.fromInt(0xFF217346),
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 3),

                      // Corps : Photo (gauche) + Informations (centre) + Logo (droite) parfaitement alignés
                      pw.Expanded(
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // 1. Photo avec bordure verte et coins arrondis
                            pw.Container(
                              width: 22 * PdfPageFormat.mm,
                              height: 28 * PdfPageFormat.mm,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: const PdfColor.fromInt(0xFF217346),
                                  width: 1.2,
                                ),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(3),
                                ),
                                color: const PdfColor.fromInt(0xFFEEEEEE),
                              ),
                              child: pw.ClipRRect(
                                horizontalRadius: 2.5,
                                verticalRadius: 2.5,
                                child: memberPhoto != null
                                    ? pw.Image(
                                        memberPhoto,
                                        fit: pw.BoxFit.cover,
                                      )
                                    : pw.Center(
                                        child: pw.Text(
                                          'PHOTO',
                                          style: const pw.TextStyle(
                                            fontSize: 5,
                                            color: PdfColors.grey600,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            pw.SizedBox(width: 4 * PdfPageFormat.mm),

                            // 2. Informations textuelles au centre (ajustées à la hauteur de la photo et justifiées)
                            pw.Expanded(
                              child: pw.Container(
                                height: 28 * PdfPageFormat.mm,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Titre de la carte
                                    pw.Text(
                                      AppStrings.cardTitle,
                                      style: pw.TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: pw.FontWeight.bold,
                                        fontStyle: pw.FontStyle.italic,
                                        color: const PdfColor.fromInt(
                                          0xFF1F2937,
                                        ),
                                      ),
                                    ),

                                    // Name (tout en gras)
                                    pw.RichText(
                                      maxLines: 2,
                                      text: pw.TextSpan(
                                        text: '${AppStrings.labelName} ',
                                        style: pw.TextStyle(
                                          fontSize: 5.6,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                        children: [
                                          pw.TextSpan(
                                            text: member.name,
                                            style: pw.TextStyle(
                                              fontSize: 5.8,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Designation (tout en gras et totalement visible)
                                    pw.RichText(
                                      text: pw.TextSpan(
                                        text: '${AppStrings.labelDesignation} ',
                                        style: pw.TextStyle(
                                          fontSize: 5.0,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                        children: [
                                          pw.TextSpan(
                                            text: member.occupation,
                                            style: pw.TextStyle(
                                              fontSize: 5.0,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // No CNI (en gras)
                                    if (member.cniNumber.isNotEmpty)
                                      pw.Text(
                                        '${AppStrings.labelCni} ${member.cniNumber}',
                                        style: pw.TextStyle(
                                          fontSize: 4.8,
                                          color: PdfColors.black,
                                        ),
                                      ),

                                    // Date de délivrance (en gras)
                                    if (member.issueDate != null)
                                      pw.Text(
                                        'Délivrée le : ${DateFormatter.format(member.issueDate)}',
                                        style: pw.TextStyle(
                                          fontSize: 4.4,
                                          color: PdfColors.black,
                                        ),
                                      ),

                                    // Date d'expiration (en gras)
                                    if (member.expiryDate != null)
                                      pw.Text(
                                        'Expire le : ${DateFormatter.format(member.expiryDate)}',
                                        style: pw.TextStyle(
                                          fontSize: 4.4,
                                          color: PdfColors.black,
                                        ),
                                      ),

                                    // ID No. (en gras)
                                    pw.Text(
                                      '${AppStrings.labelIdNo} ${member.id}',
                                      style: pw.TextStyle(
                                        fontSize: 6.2,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            pw.SizedBox(width: 3 * PdfPageFormat.mm),

                            // 3. Logo officiel APIC (droite, parfaitement centré verticalement)
                            if (logoImage != null)
                              pw.Container(
                                width: 22 * PdfPageFormat.mm,
                                height: 22 * PdfPageFormat.mm,
                                child: pw.Image(
                                  logoImage,
                                  fit: pw.BoxFit.contain,
                                ),
                              )
                            else
                              pw.SizedBox(width: 19 * PdfPageFormat.mm),
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
          pw.Container(
            height: 3.5 * PdfPageFormat.mm,
            color: const PdfColor.fromInt(0xFF217346),
            alignment: pw.Alignment.center,
            child: pw.Text(
              AppStrings.getCardValidityNotice(member.createdAt),
              style: pw.TextStyle(
                fontSize: 4.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// VERSO DE LA CARTE (85,6 x 54 mm) - Adapté fidèlement au modèle Image 2
  pw.Widget _buildCardVerso(
    Member member,
    pw.MemoryImage? cachetImage,
    pw.MemoryImage? patternImage,
  ) {
    final qrContent =
        'APIC|${member.id}|${member.name}|\nCarte approuvée par Mr HASSANA A.';

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFCCCCCC),
          width: 0.4 * PdfPageFormat.point,
        ),
      ),
      child: pw.Column(
        children: [
          // 1. Bande verte supérieure
          pw.Container(
            height: 3.5 * PdfPageFormat.mm,
            color: const PdfColor.fromInt(0xFF217346),
          ),

          // 2. Zone centrale du verso avec motif de fond
          pw.Expanded(
            child: pw.Stack(
              children: [
                // Motif de sécurité circuit en fond
                if (patternImage != null)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.65,
                      child: pw.Image(patternImage, fit: pw.BoxFit.cover),
                    ),
                  ),

                // A. Ligne pointillée horizontale médiane
                pw.Center(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      36,
                      (_) => pw.Container(
                        width: 3.5,
                        height: 0.6,
                        color: const PdfColor.fromInt(0xFFBDBDBD),
                      ),
                    ),
                  ),
                ),

                // B. Cachet officiel et signature centrés
                if (cachetImage != null)
                  pw.Center(
                    child: pw.Container(
                      width: 50 * PdfPageFormat.mm,
                      height: 50 * PdfPageFormat.mm,
                      child: pw.Image(cachetImage, fit: pw.BoxFit.contain),
                    ),
                  )
                else
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.35,
                      child: pw.Container(
                        width: 25 * PdfPageFormat.mm,
                        height: 25 * PdfPageFormat.mm,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF217346),
                            width: 1,
                          ),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'LE PRÉSIDENT\nAPIC',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 5,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF217346),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // C. Textes et QR Code
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3.5,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Haut : Mention de propriété à gauche, QR Code à droite
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 2),
                              child: pw.Text(
                                AppStrings.versoPropertyNotice,
                                style: pw.TextStyle(
                                  fontSize: 5.6,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Container(
                            width: 20.5 * PdfPageFormat.mm,
                            height: 20.5 * PdfPageFormat.mm,
                            child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: qrContent,
                              drawText: false,
                            ),
                          ),
                        ],
                      ),

                      // Bas : Mentions administratives et contact
                      pw.Container(
                        width: double.infinity,
                        alignment: pw.Alignment.center,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              AppStrings.versoFooterLine1,
                              style: const pw.TextStyle(
                                fontSize: 4.4,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 0.8),
                            pw.Text(
                              AppStrings.versoFooterLine2,
                              style: const pw.TextStyle(fontSize: 4.4),
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
          pw.Container(
            height: 3.5 * PdfPageFormat.mm,
            color: const PdfColor.fromInt(0xFF217346),
            alignment: pw.Alignment.center,
            child: pw.Text(
              AppStrings.getCardValidityNotice(member.createdAt),
              style: pw.TextStyle(
                fontSize: 4.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
