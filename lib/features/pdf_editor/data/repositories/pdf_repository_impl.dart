import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:daka_doc/features/pdf_editor/domain/entities/pdf_entities.dart';
import 'package:daka_doc/features/pdf_editor/domain/repositories/pdf_repository.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

/// Implémentation du repository PDF avec Syncfusion
class PdfRepositoryImpl implements PdfRepository {
  final Uuid _uuid = const Uuid();

  @override
  Future<PdfDocumentEntity> loadPdfDocument(String path) async {
    final file = File(path);
    if (!await file.exists()) {
    }

    // Charger le document PDF avec Syncfusion
    final document = PdfDocument(inputBytes: await file.readAsBytes());

    // Créer l'entité PdfDocument
    final pdfDocument = PdfDocumentEntity(
      id: _uuid.v4(),
      name: FileUtils.getFileNameWithoutExtension(path),
      path: path,
      pageCount: document.pages.count,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    // Fermer le document
    document.dispose();

    return pdfDocument;
  }

  @override
  Future<String> savePdfDocument(PdfDocumentEntity document) async {
    // Pour l'instant, retourne le chemin existant
    // Dans une implémentation complète, on sauvegarderait les modifications
    return document.path;
  }

  @override
  Future<PdfDocumentEntity> addTextAnnotation(PdfDocumentEntity document, TextAnnotation annotation) async {
    // Charger le document
    final pdfDoc = PdfDocument(inputBytes: await File(document.path).readAsBytes());

    // Obtenir la page
    if (annotation.pageNumber > pdfDoc.pages.count || annotation.pageNumber < 1) {
      throw Exception('Numéro de page invalide');
    }

    final page = pdfDoc.pages[annotation.pageNumber - 1];

    // Créer l'annotation texte
    final textElement = PdfTextElement(
      text: annotation.text,
      font: PdfStandardFont(PdfFontFamily.helvetica, annotation.fontSize),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
    );

    // Dessiner le texte à la position spécifiée
    textElement.draw(
      page: page,
      bounds: Rect.fromLTWH(
        annotation.x,
        annotation.y,
        page.getClientSize().width - annotation.x,
        page.getClientSize().height - annotation.y,
      ),
    );

    // Sauvegarder temporairement (dans une implémentation complète, on sauvegarderait les annotations)
    final tempDir = await FileUtils.getAppTemporaryDirectory();
    final outputPath = '${tempDir.path}/${document.name}_annotated.pdf';

    // Sauvegarder le document modifié
    final outputBytes = await pdfDoc.save();
    await File(outputPath).writeAsBytes(outputBytes);

    pdfDoc.dispose();

    // Retourner le document mis à jour
    return document.copyWith(
      path: outputPath,
      modifiedAt: DateTime.now(),
    );
  }

  @override
  Future<PdfDocumentEntity> addImageAnnotation(PdfDocumentEntity document, ImageAnnotation annotation) async {
    // Charger le document
    final pdfDoc = PdfDocument(inputBytes: await File(document.path).readAsBytes());

    // Obtenir la page
    if (annotation.pageNumber > pdfDoc.pages.count || annotation.pageNumber < 1) {
      throw Exception('Numéro de page invalide');
    }

    final page = pdfDoc.pages[annotation.pageNumber - 1];

    // Charger l'image
    final imageFile = File(annotation.imagePath);
    if (!await imageFile.exists()) {
      throw Exception('Fichier image non trouvé');
    }

    final imageBytes = await imageFile.readAsBytes();
    final pdfImage = PdfBitmap(imageBytes);

    // Dessiner l'image à la position spécifiée
    page.graphics.drawImage(
      pdfImage,
      Rect.fromLTWH(
        annotation.x,
        annotation.y,
        annotation.width,
        annotation.height,
      ),
    );

    // Sauvegarder temporairement
    final tempDir = await FileUtils.getAppTemporaryDirectory();
    final outputPath = '${tempDir.path}/${document.name}_annotated.pdf';

    final outputBytes = await pdfDoc.save();
    await File(outputPath).writeAsBytes(outputBytes);

    pdfDoc.dispose();

    // Retourner le document mis à jour
    return document.copyWith(
      path: outputPath,
      modifiedAt: DateTime.now(),
    );
  }

  @override
  Future<PdfDocumentEntity> addSignatureAnnotation(PdfDocumentEntity document, SignatureAnnotation annotation) async {
    // Charger le document
    final pdfDoc = PdfDocument(inputBytes: await File(document.path).readAsBytes());

    // Obtenir la page
    if (annotation.pageNumber > pdfDoc.pages.count || annotation.pageNumber < 1) {
      throw Exception('Numéro de page invalide');
    }

    final page = pdfDoc.pages[annotation.pageNumber - 1];

    // Charger l'image de signature
    final signatureFile = File(annotation.signaturePath);
    if (!await signatureFile.exists()) {
      throw Exception('Fichier de signature non trouvé');
    }

    final signatureBytes = await signatureFile.readAsBytes();
    final pdfImage = PdfBitmap(signatureBytes);

    // Dessiner la signature à la position spécifiée
    page.graphics.drawImage(
      pdfImage,
      Rect.fromLTWH(
        annotation.x,
        annotation.y,
        annotation.width,
        annotation.height,
      ),
    );

    // Sauvegarder temporairement
    final tempDir = await FileUtils.getAppTemporaryDirectory();
    final outputPath = '${tempDir.path}/${document.name}_signed.pdf';

    final outputBytes = await pdfDoc.save();
    await File(outputPath).writeAsBytes(outputBytes);

    pdfDoc.dispose();

    return document.copyWith(
      path: outputPath,
      modifiedAt: DateTime.now(),
    );
  }

  @override
  Future<PdfDocumentEntity> removeAnnotation(PdfDocumentEntity document, String annotationId) async {
    // Dans une implémentation complète, on supprimerait l'annotation
    // Pour l'instant, on retourne le document inchangé
    return document.copyWith(
      modifiedAt: DateTime.now(),
    );
  }

  @override
  Future<PdfDocumentEntity> mergePdfDocuments(List<PdfDocumentEntity> documents, String outputName) async {
    if (documents.isEmpty) {
      throw Exception('Aucun document à fusionner');
    }

    // Charger le premier document
    final mergedDocument = PdfDocument(inputBytes: await File(documents[0].path).readAsBytes());

    // Ajouter les pages des autres documents
    for (int i = 1; i < documents.length; i++) {
      final doc = PdfDocument(inputBytes: await File(documents[i].path).readAsBytes());

      for (int pageIndex = 0; pageIndex < doc.pages.count; pageIndex++) {
        mergedDocument.pages.add().graphics.drawPdfTemplate(
          doc.pages[pageIndex].createTemplate(),
          Offset.zero,
        );
      }

      doc.dispose();
    }

    // Sauvegarder le document fusionné
    final tempDir = await FileUtils.getAppTemporaryDirectory();
    final outputPath = '${tempDir.path}/$outputName.pdf';

    final outputBytes = await mergedDocument.save();
    await File(outputPath).writeAsBytes(outputBytes);

    mergedDocument.dispose();

    return PdfDocumentEntity(
      id: _uuid.v4(),
      name: outputName,
      path: outputPath,
      pageCount: documents.fold(0, (sum, doc) => sum + doc.pageCount),
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  @override
  Future<List<PdfDocumentEntity>> splitPdfDocument(PdfDocumentEntity document, List<int> pageRanges) async {
    // Dans une implémentation complète, on diviserait le document selon les plages
    // Pour l'instant, on retourne une liste avec le document original
    return [document];
  }

  @override
  Future<List<PdfAnnotationEntity>> getDocumentAnnotations(PdfDocumentEntity document) async {
    // Dans une implémentation complète, on récupérerait les annotations du document
    // Pour l'instant, on retourne une liste vide
    return [];
  }
}
