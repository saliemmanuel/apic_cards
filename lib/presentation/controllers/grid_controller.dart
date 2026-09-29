import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_regions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/add_members_usecase.dart';
import '../../domain/usecases/generate_cards_pdf_usecase.dart';
import '../../domain/usecases/peek_next_sequence_usecase.dart';
import '../widgets/card_preview_dialog.dart';

/// Représente l'état réactif et les contrôleurs d'une ligne de la grille de saisie.
class GridRowItem {
  final TextEditingController nameController;
  final TextEditingController cniController;
  final Rxn<DateTime> issueDate;
  final Rxn<DateTime> expiryDate;
  final TextEditingController residenceController;
  final TextEditingController occupationController;
  final RxnString photoBase64;
  final RxString previewCardId;

  GridRowItem({
    String initialName = '',
    String initialCni = '',
    DateTime? initialIssueDate,
    DateTime? initialExpiryDate,
    String initialResidence = '',
    String initialOccupation = '',
    String? initialPhotoBase64,
  }) : nameController = TextEditingController(text: initialName),
       cniController = TextEditingController(text: initialCni),
       issueDate = Rxn<DateTime>(initialIssueDate),
       expiryDate = Rxn<DateTime>(initialExpiryDate),
       residenceController = TextEditingController(text: initialResidence),
       occupationController = TextEditingController(text: initialOccupation),
       photoBase64 = RxnString(initialPhotoBase64),
       previewCardId = ''.obs;

  void dispose() {
    nameController.dispose();
    cniController.dispose();
    residenceController.dispose();
    occupationController.dispose();
  }

  bool get hasName => nameController.text.trim().isNotEmpty;
}

/// Contrôleur GetX pour la grille de saisie Excel.
class GridController extends GetxController {
  final PeekNextSequenceUseCase peekNextSequenceUseCase;
  final AddMembersUseCase addMembersUseCase;
  final GenerateCardsPdfUseCase generateCardsPdfUseCase;

  GridController({
    required this.peekNextSequenceUseCase,
    required this.addMembersUseCase,
    required this.generateCardsPdfUseCase,
  });

  /// Région sélectionnée (une seule région par feuille)
  final RxString selectedRegion = AppRegions.defaultRegionCode.obs;

  /// Liste réactive des lignes du tableau (10 au départ)
  final RxList<GridRowItem> rows = <GridRowItem>[].obs;

  /// État de chargement lors de la sauvegarde et génération PDF
  final RxBool isLoading = false.obs;

  /// Mode d'affichage (false: Tableau Excel, true: Fiches mobiles)
  final RxBool isCardViewMode = false.obs;

  /// Contrôleur de défilement horizontal pour le tableau Excel
  final ScrollController horizontalScrollController = ScrollController();

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initDefaultRows();
    updateCardIdPreviews();
  }

  @override
  void onClose() {
    horizontalScrollController.dispose();
    for (final row in rows) {
      row.dispose();
    }
    super.onClose();
  }

  /// Bascule entre le mode tableau et le mode fiches
  void toggleViewMode() {
    isCardViewMode.value = !isCardViewMode.value;
  }

  /// Initialise 10 lignes par défaut (= 1 page A4)
  void _initDefaultRows() {
    for (int i = 0; i < 10; i++) {
      _addNewRowInternal();
    }
  }

  /// Ajoute une nouvelle ligne à la grille et attache les écouteurs de saisie
  void addRow() {
    _addNewRowInternal();
    updateCardIdPreviews();
  }

  /// Supprime une ligne par son index
  void removeRow(int index) {
    if (index >= 0 && index < rows.length) {
      if (rows.length > 1) {
        final removed = rows.removeAt(index);
        removed.dispose();
      } else {
        clearRow(index);
      }
      updateCardIdPreviews();
    }
  }

  /// Réinitialise les champs d'une ligne
  void clearRow(int index) {
    if (index >= 0 && index < rows.length) {
      final row = rows[index];
      row.nameController.clear();
      row.cniController.clear();
      row.residenceController.clear();
      row.occupationController.clear();
      row.issueDate.value = null;
      row.expiryDate.value = null;
      row.photoBase64.value = null;
      row.previewCardId.value = '';
      updateCardIdPreviews();
    }
  }

  void _addNewRowInternal() {
    final row = GridRowItem();
    row.nameController.addListener(() {
      updateCardIdPreviews();
    });
    rows.add(row);
  }

  /// Change la région active et met à jour l'aperçu des numéros de carte
  void onRegionChanged(String? newRegion) {
    if (newRegion != null && newRegion != selectedRegion.value) {
      selectedRegion.value = newRegion;
      updateCardIdPreviews();
    }
  }

  /// Met à jour de façon réactive le numéro prévisionnel (colonne N°) pour chaque ligne remplie
  Future<void> updateCardIdPreviews() async {
    try {
      int filledCount = 0;
      for (final row in rows) {
        if (row.hasName) {
          final previewId = await peekNextSequenceUseCase(
            selectedRegion.value,
            offset: filledCount,
          );
          row.previewCardId.value = previewId;
          filledCount++;
        } else {
          row.previewCardId.value = '';
        }
      }
    } catch (_) {
      // Ignoré lors des saisies rapides
    }
  }

  /// Sélectionne une photo depuis la galerie (maxWidth 500, qualité 80)
  Future<void> pickPhoto(GridRowItem row) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        imageQuality: 80,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        row.photoBase64.value = base64Encode(bytes);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur Image',
        'Impossible de charger la photo : $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Supprime la photo d'une ligne
  void removePhoto(GridRowItem row) {
    row.photoBase64.value = null;
  }

  /// Sélectionne une date avec le DatePicker natif
  Future<void> pickDate(
    BuildContext context,
    Rxn<DateTime> targetDate, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate.value ?? initialDate ?? now,
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      targetDate.value = picked;
    }
  }

  /// Enregistre les membres saisis, attribue les numéros officiels et ouvre le PDF A4
  Future<void> saveAndGeneratePdf() async {
    // 1. Filtrer les lignes non vides (au moins un nom saisi)
    final filledRows = rows.where((r) => r.hasName).toList();

    if (filledRows.isEmpty) {
      Get.snackbar(
        'Grille vide',
        'Veuillez renseigner au moins une ligne avec un nom complet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 2. Transformer en MemberDraft
      final drafts = filledRows.map((r) {
        return MemberDraft(
          name: r.nameController.text.trim(),
          cniNumber: r.cniController.text.trim(),
          issueDate: r.issueDate.value,
          expiryDate: r.expiryDate.value,
          residence: r.residenceController.text.trim(),
          occupation: r.occupationController.text.trim(),
          photoBase64: r.photoBase64.value,
          regionCode: selectedRegion.value,
        );
      }).toList();

      // 3. Consommation des numéros séquentiels et enregistrement en base
      final createdMembers = await addMembersUseCase(
        drafts: drafts,
        regionCode: selectedRegion.value,
      );

      // 4. Génération du document PDF A4
      final pdfBytes = await generateCardsPdfUseCase(createdMembers);

      // 5. Réinitialisation de la grille (10 lignes vierges)
      _resetGrid();

      // 6. Navigation vers l'écran d'aperçu PDF
      await Get.toNamed(
        AppRoutes.pdfPreview,
        arguments: {
          'pdfBytes': pdfBytes,
          'title': 'Cartes APIC (${createdMembers.length})',
        },
      );
    } on Failure catch (e) {
      Get.snackbar(
        'Erreur',
        e.message,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur inattendue',
        'Une erreur est survenue : $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      updateCardIdPreviews();
    }
  }

  /// Affiche l'aperçu individuel de la carte (Recto & Verso) pour une ligne donnée
  Future<void> previewRowCard(GridRowItem row, int index) async {
    final name = row.nameController.text.trim();
    final previewId = row.previewCardId.value.isNotEmpty
        ? row.previewCardId.value
        : await peekNextSequenceUseCase(selectedRegion.value, offset: index);

    final member = Member(
      id: previewId,
      name: name.isNotEmpty ? name : 'Nom Complet',
      cniNumber: row.cniController.text.trim().isNotEmpty
          ? row.cniController.text.trim()
          : '0000000000000',
      issueDate: row.issueDate.value,
      expiryDate: row.expiryDate.value,
      residence: row.residenceController.text.trim().isNotEmpty
          ? row.residenceController.text.trim()
          : 'Ville, Pays',
      occupation: row.occupationController.text.trim().isNotEmpty
          ? row.occupationController.text.trim()
          : 'Occupation',
      photoBase64: row.photoBase64.value,
      regionCode: selectedRegion.value,
      createdAt: DateTime.now(),
    );

    Get.dialog(CardPreviewDialog(member: member));
  }

  /// Prévisualise la planche A4 complète sans consommer les numéros et sans sauvegarder
  Future<void> previewA4Pdf() async {
    final filledRows = rows.where((r) => r.hasName).toList();

    if (filledRows.isEmpty) {
      Get.snackbar(
        'Grille vide',
        'Veuillez renseigner au moins une ligne avec un nom pour prévisualiser le PDF.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
      );
      return;
    }

    try {
      isLoading.value = true;
      final previewMembers = <Member>[];

      for (int i = 0; i < filledRows.length; i++) {
        final r = filledRows[i];
        final id = r.previewCardId.value.isNotEmpty
            ? r.previewCardId.value
            : await peekNextSequenceUseCase(selectedRegion.value, offset: i);

        previewMembers.add(
          Member(
            id: id,
            name: r.nameController.text.trim(),
            cniNumber: r.cniController.text.trim(),
            issueDate: r.issueDate.value,
            expiryDate: r.expiryDate.value,
            residence: r.residenceController.text.trim(),
            occupation: r.occupationController.text.trim(),
            photoBase64: r.photoBase64.value,
            regionCode: selectedRegion.value,
            createdAt: DateTime.now(),
          ),
        );
      }

      final pdfBytes = await generateCardsPdfUseCase(previewMembers);

      await Get.toNamed(
        AppRoutes.pdfPreview,
        arguments: {
          'pdfBytes': pdfBytes,
          'title': 'Aperçu A4 (${previewMembers.length} carte(s))',
        },
      );
    } on Failure catch (e) {
      Get.snackbar(
        'Erreur',
        e.message,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'aperçu : $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Vide la grille et recrée 10 lignes vierges
  void _resetGrid() {
    for (final r in rows) {
      r.dispose();
    }
    rows.clear();
    _initDefaultRows();
  }
}
