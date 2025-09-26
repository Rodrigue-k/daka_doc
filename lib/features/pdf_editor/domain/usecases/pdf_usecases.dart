import 'package:daka_doc/features/pdf_editor/domain/entities/pdf_entities.dart';
import 'package:daka_doc/features/pdf_editor/domain/repositories/pdf_repository.dart';

/// Use case pour charger un document PDF
class LoadPdfDocument {
  final PdfRepository repository;

  LoadPdfDocument(this.repository);

  Future<PdfDocumentEntity> call(String path) async {
    return await repository.loadPdfDocument(path);
  }
}

/// Use case pour sauvegarder un document PDF
class SavePdfDocument {
  final PdfRepository repository;

  SavePdfDocument(this.repository);

  Future<String> call(PdfDocumentEntity document) async {
    return await repository.savePdfDocument(document);
  }
}

/// Use case pour ajouter une annotation texte
class AddTextAnnotation {
  final PdfRepository repository;

  AddTextAnnotation(this.repository);

  Future<PdfDocumentEntity> call(PdfDocumentEntity document, TextAnnotation annotation) async {
    final updatedDocument = document.copyWith(
      modifiedAt: DateTime.now(),
    );
    return await repository.addTextAnnotation(updatedDocument, annotation);
  }
}

/// Use case pour ajouter une annotation image
class AddImageAnnotation {
  final PdfRepository repository;

  AddImageAnnotation(this.repository);

  Future<PdfDocumentEntity> call(PdfDocumentEntity document, ImageAnnotation annotation) async {
    final updatedDocument = document.copyWith(
      modifiedAt: DateTime.now(),
    );
    return await repository.addImageAnnotation(updatedDocument, annotation);
  }
}

/// Use case pour ajouter une annotation signature
class AddSignatureAnnotation {
  final PdfRepository repository;

  AddSignatureAnnotation(this.repository);

  Future<PdfDocumentEntity> call(PdfDocumentEntity document, SignatureAnnotation annotation) async {
    final updatedDocument = document.copyWith(
      modifiedAt: DateTime.now(),
    );
    return await repository.addSignatureAnnotation(updatedDocument, annotation);
  }
}

/// Use case pour supprimer une annotation
class RemoveAnnotation {
  final PdfRepository repository;

  RemoveAnnotation(this.repository);

  Future<PdfDocumentEntity> call(PdfDocumentEntity document, String annotationId) async {
    final updatedDocument = document.copyWith(
      modifiedAt: DateTime.now(),
    );
    return await repository.removeAnnotation(updatedDocument, annotationId);
  }
}

/// Use case pour fusionner des PDFs
class MergePdfDocuments {
  final PdfRepository repository;

  MergePdfDocuments(this.repository);

  Future<PdfDocumentEntity> call(List<PdfDocumentEntity> documents, String outputName) async {
    return await repository.mergePdfDocuments(documents, outputName);
  }
}

/// Use case pour diviser un PDF
class SplitPdfDocument {
  final PdfRepository repository;

  SplitPdfDocument(this.repository);

  Future<List<PdfDocumentEntity>> call(PdfDocumentEntity document, List<int> pageRanges) async {
    return await repository.splitPdfDocument(document, pageRanges);
  }
}

/// Use case pour obtenir les annotations d'un document
class GetDocumentAnnotations {
  final PdfRepository repository;

  GetDocumentAnnotations(this.repository);

  Future<List<PdfAnnotationEntity>> call(PdfDocumentEntity document) async {
    return await repository.getDocumentAnnotations(document);
  }
}
