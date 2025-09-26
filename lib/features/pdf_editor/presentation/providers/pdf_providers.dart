import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daka_doc/features/pdf_editor/domain/entities/pdf_entities.dart';
import 'package:daka_doc/features/pdf_editor/domain/repositories/pdf_repository.dart';
import 'package:daka_doc/features/pdf_editor/domain/usecases/pdf_usecases.dart';
import 'package:daka_doc/features/pdf_editor/data/repositories/pdf_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider pour le repository PDF
final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  return PdfRepositoryImpl();
});

/// Provider pour l'état du document PDF actuel
final currentPdfDocumentProvider = StateProvider<PdfDocumentEntity?>((ref) => null);

/// Provider pour la liste des annotations du document actuel
final pdfAnnotationsProvider = StateProvider<List<PdfAnnotationEntity>>((ref) => []);

/// Provider pour le use case de chargement de PDF
final loadPdfDocumentProvider = Provider<LoadPdfDocument>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return LoadPdfDocument(repository);
});

/// Provider pour le use case d'ajout d'annotation texte
final addTextAnnotationProvider = Provider<AddTextAnnotation>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return AddTextAnnotation(repository);
});

/// Provider pour le use case d'ajout d'annotation image
final addImageAnnotationProvider = Provider<AddImageAnnotation>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return AddImageAnnotation(repository);
});

/// Provider pour le use case d'ajout d'annotation signature
final addSignatureAnnotationProvider = Provider<AddSignatureAnnotation>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return AddSignatureAnnotation(repository);
});

/// Provider pour le use case de suppression d'annotation
final removeAnnotationProvider = Provider<RemoveAnnotation>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return RemoveAnnotation(repository);
});

/// Provider pour le use case de fusion de PDFs
final mergePdfDocumentsProvider = Provider<MergePdfDocuments>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return MergePdfDocuments(repository);
});

/// Provider pour le use case de division de PDF
final splitPdfDocumentProvider = Provider<SplitPdfDocument>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return SplitPdfDocument(repository);
});

/// Provider pour le use case d'obtention des annotations
final getDocumentAnnotationsProvider = Provider<GetDocumentAnnotations>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return GetDocumentAnnotations(repository);
});
