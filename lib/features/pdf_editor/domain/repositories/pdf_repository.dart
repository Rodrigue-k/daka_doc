import 'package:daka_doc/features/pdf_editor/domain/entities/pdf_entities.dart';

/// Repository abstrait pour les opérations PDF
abstract class PdfRepository {
  /// Charge un document PDF depuis un chemin
  Future<PdfDocumentEntity> loadPdfDocument(String path);

  /// Sauvegarde un document PDF
  Future<String> savePdfDocument(PdfDocumentEntity document);

  /// Ajoute une annotation texte
  Future<PdfDocumentEntity> addTextAnnotation(PdfDocumentEntity document, TextAnnotation annotation);

  /// Ajoute une annotation image
  Future<PdfDocumentEntity> addImageAnnotation(PdfDocumentEntity document, ImageAnnotation annotation);

  /// Ajoute une annotation signature
  Future<PdfDocumentEntity> addSignatureAnnotation(PdfDocumentEntity document, SignatureAnnotation annotation);

  /// Supprime une annotation
  Future<PdfDocumentEntity> removeAnnotation(PdfDocumentEntity document, String annotationId);

  /// Fusionne plusieurs documents PDF
  Future<PdfDocumentEntity> mergePdfDocuments(List<PdfDocumentEntity> documents, String outputName);

  /// Divise un document PDF selon des plages de pages
  Future<List<PdfDocumentEntity>> splitPdfDocument(PdfDocumentEntity document, List<int> pageRanges);

  /// Obtient toutes les annotations d'un document
  Future<List<PdfAnnotationEntity>> getDocumentAnnotations(PdfDocumentEntity document);
}
