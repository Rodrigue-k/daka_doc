import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daka_doc/features/signature/domain/entities/signature_entities.dart';
import 'package:daka_doc/features/signature/domain/repositories/signature_repository.dart';
import 'package:daka_doc/features/signature/domain/usecases/signature_usecases.dart';
import 'package:daka_doc/features/signature/data/repositories/signature_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider pour le repository de signature
final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepositoryImpl();
});

/// Provider pour la signature actuelle en cours d'édition
final currentSignatureProvider = StateProvider<SignatureEntity?>((ref) => null);

/// Provider pour les strokes actuels du pad de signature
final currentStrokesProvider = StateProvider<List<Stroke>>((ref) => []);

/// Provider pour la liste des signatures sauvegardées
final savedSignaturesProvider = StateProvider<List<SignatureEntity>>((ref) => []);

/// Provider pour le use case de création de signature
final createSignatureProvider = Provider<CreateSignature>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return CreateSignature(repository);
});

/// Provider pour le use case de sauvegarde de signature
final saveSignatureProvider = Provider<SaveSignature>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return SaveSignature(repository);
});

/// Provider pour le use case de chargement de signature
final loadSignatureProvider = Provider<LoadSignature>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return LoadSignature(repository);
});

/// Provider pour le use case d'export de signature
final exportSignatureProvider = Provider<ExportSignatureToPng>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return ExportSignatureToPng(repository);
});

/// Provider pour le use case d'obtention de toutes les signatures
final getAllSignaturesProvider = Provider<GetAllSignatures>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return GetAllSignatures(repository);
});

/// Provider pour le use case de suppression de signature
final deleteSignatureProvider = Provider<DeleteSignature>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return DeleteSignature(repository);
});

/// Provider pour le use case d'ajout de trait
final addStrokeToSignatureProvider = Provider<AddStrokeToSignature>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return AddStrokeToSignature(repository);
});

/// Provider pour le use case d'effacement de signature
final clearSignatureProvider = Provider<ClearSignature>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return ClearSignature(repository);
});

/// Provider pour le use case de conversion en image
final convertSignatureToImageProvider = Provider<ConvertSignatureToImage>((ref) {
  final repository = ref.watch(signatureRepositoryProvider);
  return ConvertSignatureToImage(repository);
});
