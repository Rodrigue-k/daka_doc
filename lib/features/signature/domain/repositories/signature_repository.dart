import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import 'package:daka_doc/features/signature/domain/entities/signature_entities.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

/// Repository abstrait pour les opérations de signature
abstract class SignatureRepository {
  /// Crée une nouvelle signature vide
  Future<SignatureEntity> createSignature(String name);

  /// Sauvegarde une signature
  Future<String> saveSignature(SignatureEntity signature);

  /// Charge une signature depuis un identifiant
  Future<SignatureEntity> loadSignature(String signatureId);

  /// Met à jour une signature existante
  Future<SignatureEntity> updateSignature(SignatureEntity signature);

  /// Supprime une signature
  Future<void> deleteSignature(String signatureId);

  /// Obtient toutes les signatures sauvegardées
  Future<List<SignatureEntity>> getAllSignatures();

  /// Exporte une signature en PNG
  Future<String> exportSignatureToPng(SignatureEntity signature);

  /// Convertit une signature en image UI
  Future<ui.Image> convertSignatureToImage(SignatureEntity signature);
}
