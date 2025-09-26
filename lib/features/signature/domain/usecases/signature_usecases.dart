import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:daka_doc/features/signature/domain/entities/signature_entities.dart';
import 'package:daka_doc/features/signature/domain/repositories/signature_repository.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

/// Use case pour créer une nouvelle signature
class CreateSignature {
  final SignatureRepository repository;

  CreateSignature(this.repository);

  Future<SignatureEntity> call(String name) async {
    return await repository.createSignature(name);
  }
}

/// Use case pour sauvegarder une signature
class SaveSignature {
  final SignatureRepository repository;

  SaveSignature(this.repository);

  Future<String> call(SignatureEntity signature) async {
    return await repository.saveSignature(signature);
  }
}

/// Use case pour charger une signature
class LoadSignature {
  final SignatureRepository repository;

  LoadSignature(this.repository);

  Future<SignatureEntity> call(String signatureId) async {
    return await repository.loadSignature(signatureId);
  }
}

/// Use case pour exporter une signature en PNG
class ExportSignatureToPng {
  final SignatureRepository repository;

  ExportSignatureToPng(this.repository);

  Future<String> call(SignatureEntity signature) async {
    return await repository.exportSignatureToPng(signature);
  }
}

/// Use case pour obtenir toutes les signatures sauvegardées
class GetAllSignatures {
  final SignatureRepository repository;

  GetAllSignatures(this.repository);

  Future<List<SignatureEntity>> call() async {
    return await repository.getAllSignatures();
  }
}

/// Use case pour supprimer une signature
class DeleteSignature {
  final SignatureRepository repository;

  DeleteSignature(this.repository);

  Future<void> call(String signatureId) async {
    return await repository.deleteSignature(signatureId);
  }
}

/// Use case pour ajouter un trait à une signature
class AddStrokeToSignature {
  final SignatureRepository repository;

  AddStrokeToSignature(this.repository);

  Future<SignatureEntity> call(SignatureEntity signature, Stroke stroke) async {
    final updatedSignature = signature.copyWith(
      strokes: [...signature.strokes, stroke],
      modifiedAt: DateTime.now(),
    );
    return await repository.updateSignature(updatedSignature);
  }
}

/// Use case pour effacer une signature
class ClearSignature {
  final SignatureRepository repository;

  ClearSignature(this.repository);

  Future<SignatureEntity> call(SignatureEntity signature) async {
    final clearedSignature = signature.copyWith(
      strokes: [],
      modifiedAt: DateTime.now(),
    );
    return await repository.updateSignature(clearedSignature);
  }
}

/// Use case pour convertir une signature en image
class ConvertSignatureToImage {
  final SignatureRepository repository;

  ConvertSignatureToImage(this.repository);

  Future<ui.Image> call(SignatureEntity signature) async {
    return await repository.convertSignatureToImage(signature);
  }
}
