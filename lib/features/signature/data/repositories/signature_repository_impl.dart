import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:daka_doc/features/signature/domain/entities/signature_entities.dart';
import 'package:daka_doc/features/signature/domain/repositories/signature_repository.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

/// Implémentation du repository de signature
/// Sauvegarde dans répertoire interne pour JSON, public (Downloads) pour PNG.
class SignatureRepositoryImpl implements SignatureRepository {
  final Uuid _uuid = const Uuid();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Obtient le répertoire interne pour JSON
  Future<Directory> _getInternalSignaturesDirectory() async {
    try {
      final appDir = await FileUtils.getAppDocumentsDirectory();
      final signaturesDir = Directory('${appDir.path}/signatures');

      if (!await signaturesDir.exists()) {
        await signaturesDir.create(recursive: true);
      }

      _logger.i('📁 Répertoire interne: ${signaturesDir.path}');
      return signaturesDir;
    } catch (e) {
      _logger.e('❌ Erreur répertoire interne: $e');
      rethrow;
    }
  }

  /// Obtient le répertoire public pour PNG (Downloads)
  Future<Directory> _getPublicSignaturesDirectory() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Répertoire Downloads non disponible');
      }
      final signaturesDir = Directory('${downloadsDir.path}/DakaDoc/Signatures');

      if (!await signaturesDir.exists()) {
        await signaturesDir.create(recursive: true);
      }

      _logger.i('📁 Répertoire public: ${signaturesDir.path}');
      return signaturesDir;
    } catch (e) {
      _logger.e('❌ Erreur répertoire public: $e');
      rethrow;
    }
  }

  /// Demande permissions (Android uniquement)
  Future<bool> _requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      _logger.i('✅ Pas de permissions needed sur iOS');
      return true;
    }

    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        if (Platform.isAndroid) Permission.manageExternalStorage,
      ].request();

      bool hasAccess = statuses[Permission.storage]?.isGranted == true ||
          statuses[Permission.manageExternalStorage]?.isGranted == true;

      if (!hasAccess) {
        _logger.w('⚠️ Permissions refusées: $statuses');
        if (statuses.values.any((status) => status.isPermanentlyDenied)) {
          _logger.i('🔧 Permission refusée, ouverture paramètres');
          await openAppSettings();
        }
      } else {
        _logger.i('✅ Accès accordé');
      }

      return hasAccess;
    } catch (e) {
      _logger.e('❌ Erreur permissions: $e');
      return false;
    }
  }

  @override
  Future<SignatureEntity> createSignature(String name) async {
    final id = _uuid.v4();
    _logger.i('🔄 Génération UUID: $id');

    if (id.isEmpty) {
      _logger.e('❌ UUID généré est vide, nouvelle tentative...');
      // Nouvelle tentative avec un UUID différent
      final newId = _uuid.v4();
      if (newId.isEmpty) {
        throw Exception('Impossible de générer un UUID valide');
      }
      _logger.i('✅ UUID de secours généré: $newId');
      return _createSignatureWithId(newId, name);
    }

    return _createSignatureWithId(id, name);
  }

  SignatureEntity _createSignatureWithId(String id, String name) {
    _logger.i('📝 Création signature avec ID: $id');
    return SignatureEntity(
      id: id,
      name: name.isEmpty ? 'Signature_${id.substring(0, 8)}' : name,
      strokes: [],
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      settings: SignatureSettings(),
    );
  }

  /// Valide une signature avant sauvegarde
  void _validateSignature(SignatureEntity signature) {
    _logger.i('🔍 Validation signature: ${signature.name}');

    if (signature.id.isEmpty) {
      _logger.e('❌ ID manquant: "${signature.id}"');
      throw Exception('ID signature manquant');
    }

    if (signature.name.isEmpty) {
      _logger.w('⚠️ Nom vide, utilisation de l\'ID: ${signature.id}');
    }

    if (signature.settings.width <= 0 || signature.settings.height <= 0) {
      _logger.w('⚠️ Dimensions invalides: ${signature.settings.width}x${signature.settings.height}');
    }

    _logger.i('✅ Signature validée: ${signature.id}');
  }

  @override
  Future<String> saveSignature(SignatureEntity signature) async {
    try {
      _logger.i('💾 Tentative de sauvegarde signature: ${signature.name}');

      // Valider la signature avant sauvegarde
      _validateSignature(signature);

      await _requestStoragePermissions();

      final signaturesDir = await _getInternalSignaturesDirectory();
      final signatureFile = File('${signaturesDir.path}/${signature.id}.json');
      final signatureJson = jsonEncode(_signatureToMap(signature));

      _logger.i('📁 Sauvegarde dans: ${signatureFile.path}');
      _logger.i('📊 Taille JSON: ${signatureJson.length} caractères');

      await signatureFile.writeAsString(signatureJson);
      _logger.i('💾 Signature JSON sauvegardée: ${signatureFile.path}');

      return signatureFile.path;
    } catch (e) {
      _logger.e('❌ Erreur sauvegarde: $e');
      throw Exception('Impossible de sauvegarder. Vérifiez permissions. Erreur: $e');
    }
  }

  @override
  Future<SignatureEntity> loadSignature(String signatureId) async {
    try {
      await _requestStoragePermissions();

      final signaturesDir = await _getInternalSignaturesDirectory();
      final signatureFile = File('${signaturesDir.path}/$signatureId.json');

      if (!await signatureFile.exists()) {
        throw Exception('Signature non trouvée: $signatureId');
      }

      final signatureJson = await signatureFile.readAsString();
      final signatureMap = jsonDecode(signatureJson) as Map<String, dynamic>;
      return _signatureFromMap(signatureMap);
    } catch (e) {
      _logger.e('❌ Erreur chargement: $e');
      throw Exception('Impossible de charger. Erreur: $e');
    }
  }

  @override
  Future<SignatureEntity> updateSignature(SignatureEntity signature) async {
    _logger.i('🔄 Mise à jour signature: ${signature.name} (ID: ${signature.id})');

    if (signature.id.isEmpty) {
      _logger.e('❌ Impossible de mettre à jour une signature sans ID');
      throw Exception('Signature sans ID ne peut pas être mise à jour');
    }

    signature = signature.copyWith(modifiedAt: DateTime.now());
    await saveSignature(signature);
    _logger.i('✅ Signature mise à jour: ${signature.id}');
    return signature;
  }

  @override
  Future<void> deleteSignature(String signatureId) async {
    try {
      await _requestStoragePermissions();

      final signaturesDir = await _getInternalSignaturesDirectory();
      final signatureFile = File('${signaturesDir.path}/$signatureId.json');
      if (await signatureFile.exists()) {
        await signatureFile.delete();
      }

      final publicDir = await _getPublicSignaturesDirectory();
      final pngFile = File('${publicDir.path}/$signatureId.png');
      if (await pngFile.exists()) {
        await pngFile.delete();
      }
    } catch (e) {
      _logger.e('❌ Erreur suppression: $e');
      throw Exception('Impossible de supprimer. Erreur: $e');
    }
  }

  @override
  Future<List<SignatureEntity>> getAllSignatures() async {
    try {
      await _requestStoragePermissions();

      final signaturesDir = await _getInternalSignaturesDirectory();
      if (!await signaturesDir.exists()) {
        return [];
      }

      final files = await signaturesDir.list().where((entity) => entity is File && entity.path.endsWith('.json')).toList();
      final signatures = <SignatureEntity>[];

      for (final file in files) {
        try {
          final jsonStr = await (file as File).readAsString();
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          signatures.add(_signatureFromMap(map));
        } catch (e) {
          _logger.w('⚠️ Fichier corrompu ${file.path}: $e');
        }
      }

      _logger.i('📋 ${signatures.length} signatures chargées');
      return signatures;
    } catch (e) {
      _logger.e('❌ Erreur liste: $e');
      return [];
    }
  }

  @override
  Future<String> exportSignatureToPng(SignatureEntity signature) async {
    try {
      if (signature.id.isEmpty) {
        throw Exception('ID signature vide');
      }

      await _requestStoragePermissions();

      final signaturesDir = await _getPublicSignaturesDirectory();
      final outputPath = '${signaturesDir.path}/${signature.id}.png';

      final image = await convertSignatureToImage(signature);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await File(outputPath).writeAsBytes(pngBytes);
      _logger.i('🖼️ Signature PNG exportée: $outputPath');

      // Ouvrir le fichier pour l'utilisateur
      final result = await OpenFile.open(outputPath);
      if (result.type != ResultType.done) {
        _logger.w('⚠️ Impossible d\'ouvrir le fichier: ${result.message}');
      }

      return outputPath;
    } catch (e) {
      _logger.e('❌ Erreur export: $e');
      throw Exception('Impossible d\'exporter. Erreur: $e');
    }
  }

  @override
  Future<ui.Image> convertSignatureToImage(SignatureEntity signature) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, signature.settings.width, signature.settings.height));

    if (!signature.settings.transparentBackground) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, signature.settings.width, signature.settings.height),
        Paint()..color = signature.settings.backgroundColor,
      );
    }

    for (final stroke in signature.strokes) {
      if (stroke.points.isEmpty) continue;

      final path = Path();
      // Scaler : points relatifs (0-1) * taille export
      final firstPoint = stroke.points.first;
      path.moveTo(firstPoint.x * signature.settings.width, firstPoint.y * signature.settings.height);

      // Debug logging
      print('✏️ Stroke: first point (${firstPoint.x}, ${firstPoint.y}) -> scaled (${firstPoint.x * signature.settings.width}, ${firstPoint.y * signature.settings.height})');

      for (int i = 1; i < stroke.points.length; i++) {
        final point = stroke.points[i];
        path.lineTo(point.x * signature.settings.width, point.y * signature.settings.height);
      }

      final paint = Paint()
        ..color = stroke.settings.color
        ..strokeWidth = stroke.settings.width
        ..strokeCap = stroke.settings.strokeCap
        ..strokeJoin = stroke.settings.strokeJoin
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    return picture.toImage(
      signature.settings.width.toInt(),
      signature.settings.height.toInt(),
    );
  }

  // JSON Mappings
  Map<String, dynamic> _signatureToMap(SignatureEntity signature) {
    return {
      'id': signature.id,
      'name': signature.name,
      'strokes': signature.strokes.map(_strokeToMap).toList(),
      'createdAt': signature.createdAt.toIso8601String(),
      'modifiedAt': signature.modifiedAt.toIso8601String(),
      'settings': _signatureSettingsToMap(signature.settings),
    };
  }

  SignatureEntity _signatureFromMap(Map<String, dynamic> map) {
    return SignatureEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      strokes: (map['strokes'] as List<dynamic>).map((s) => _strokeFromMap(s as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      modifiedAt: DateTime.parse(map['modifiedAt'] as String),
      settings: _signatureSettingsFromMap(map['settings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> _strokeToMap(Stroke stroke) {
    return {
      'points': stroke.points.map(_pointToMap).toList(),
      'settings': _strokeSettingsToMap(stroke.settings),
    };
  }

  Stroke _strokeFromMap(Map<String, dynamic> map) {
    return Stroke(
      points: (map['points'] as List<dynamic>).map((p) => _pointFromMap(p as Map<String, dynamic>)).toList(),
      settings: _strokeSettingsFromMap(map['settings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> _pointToMap(Point point) {
    return {
      'x': point.x,
      'y': point.y,
      'timestamp': point.timestamp.toIso8601String(),
    };
  }

  Point _pointFromMap(Map<String, dynamic> map) {
    return Point(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> _signatureSettingsToMap(SignatureSettings settings) {
    return {
      'width': settings.width,
      'height': settings.height,
      'backgroundColor': settings.backgroundColor.toARGB32(),
      'transparentBackground': settings.transparentBackground,
      'defaultStrokeSettings': _strokeSettingsToMap(settings.defaultStrokeSettings),
    };
  }

  SignatureSettings _signatureSettingsFromMap(Map<String, dynamic> map) {
    return SignatureSettings(
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      backgroundColor: Color(map['backgroundColor'] as int),
      transparentBackground: map['transparentBackground'] as bool,
      defaultStrokeSettings: _strokeSettingsFromMap(map['defaultStrokeSettings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> _strokeSettingsToMap(StrokeSettings settings) {
    return {
      'width': settings.width,
      'color': settings.color.toARGB32(),
      'strokeCap': settings.strokeCap.name,
      'strokeJoin': settings.strokeJoin.name,
    };
  }

  StrokeSettings _strokeSettingsFromMap(Map<String, dynamic> map) {
    return StrokeSettings(
      width: (map['width'] as num).toDouble(),
      color: Color(map['color'] as int),
      strokeCap: StrokeCap.values.firstWhere((e) => e.name == (map['strokeCap'] as String)),
      strokeJoin: StrokeJoin.values.firstWhere((e) => e.name == (map['strokeJoin'] as String)),
    );
  }
}