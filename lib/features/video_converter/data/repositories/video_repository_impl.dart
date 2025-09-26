import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:uuid/uuid.dart';
import 'package:daka_doc/features/video_converter/domain/entities/video_entities.dart';
import 'package:daka_doc/features/video_converter/domain/repositories/video_repository.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

/// Implémentation du repository vidéo avec FFmpeg
class VideoRepositoryImpl implements VideoRepository {
  final Uuid _uuid = const Uuid();

  @override
  Future<VideoFile?> pickVideoFile() async {
    // TODO: Implémenter la sélection de fichier avec file_picker
    // Pour l'instant, retourne null
    throw UnimplementedError('Sélection de fichier à implémenter');
  }

  @override
  Future<VideoFile> getVideoInfo(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Fichier vidéo non trouvé: $path');
    }

    // Obtenir les informations de base du fichier
    final stat = await file.stat();
    final extension = FileUtils.getFileExtension(path);
    final format = VideoFormat.fromExtension(extension);

    // Utiliser FFprobe pour obtenir les informations détaillées
    final ffprobeCommand = '-i "$path" -v quiet -print_format json -show_format -show_streams';

    await FFprobeKit.execute(ffprobeCommand).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // Les informations sont disponibles dans session.getOutput()
        // TODO: Parser le JSON de FFprobe pour des informations plus précises
      } else {
        throw Exception('Impossible d\'obtenir les informations vidéo');
      }
    });

    // Parser les informations (simplification)
    // Dans une implémentation complète, on parserait le JSON de FFprobe
    final duration = Duration(seconds: 30); // Valeur par défaut
    final width = 1920; // Valeur par défaut
    final height = 1080; // Valeur par défaut

    return VideoFile(
      id: _uuid.v4(),
      name: path.split('/').last,
      path: path,
      size: stat.size,
      duration: duration,
      format: format,
      width: width,
      height: height,
      createdAt: stat.changed,
      modifiedAt: stat.modified,
    );
  }

  @override
  Future<VideoConversionTask> createConversionTask(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  ) async {
    final task = VideoConversionTask(
      id: _uuid.v4(),
      inputFile: inputFile,
      outputFormat: outputFormat,
      settings: settings,
      status: ConversionStatus.pending,
      progress: 0.0,
      createdAt: DateTime.now(),
    );

    return task;
  }

  @override
  Future<VideoConversionTask> startConversion(VideoConversionTask task) async {
    // Construire la commande FFmpeg
    final command = await _buildFFmpegCommand(task);

    // Démarrer la conversion
    await FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // Conversion réussie
        final outputPath = await _getOutputPath(task);
        final outputFile = File(outputPath);

        // Créer le fichier de sortie s'il n'existe pas
        if (!await outputFile.exists()) {
          throw Exception('Fichier de sortie non créé');
        }

        // Mettre à jour la tâche
        task = task.copyWith(
          status: ConversionStatus.completed,
          progress: 1.0,
          outputPath: outputPath,
          completedAt: DateTime.now(),
        );

        // TODO: Notifier les observers de la mise à jour
      } else {
        // Échec de la conversion
        task = task.copyWith(
          status: ConversionStatus.failed,
          errorMessage: 'Erreur lors de la conversion',
        );

        // TODO: Notifier les observers de l'échec
      }
    });

    // Retourner la tâche mise à jour avec le statut "en cours"
    return task.copyWith(
      status: ConversionStatus.converting,
      startedAt: DateTime.now(),
    );
  }

  @override
  Future<VideoConversionTask> cancelConversion(VideoConversionTask task) async {
    // TODO: Implémenter l'annulation de la conversion
    return task.copyWith(
      status: ConversionStatus.cancelled,
    );
  }

  @override
  Future<VideoConversionTask> getConversionStatus(String taskId) async {
    // TODO: Implémenter la récupération du statut depuis un cache/persistance
    throw UnimplementedError('Récupération du statut à implémenter');
  }

  @override
  Future<List<VideoConversionTask>> getAllConversionTasks() async {
    // TODO: Implémenter la récupération de toutes les tâches
    return [];
  }

  @override
  Future<void> deleteConversionTask(String taskId) async {
    // TODO: Implémenter la suppression de la tâche
  }

  @override
  Future<List<VideoFormat>> getAvailableOutputFormats(VideoFile inputFile) async {
    // Retourner tous les formats supportés
    return VideoFormat.values;
  }

  @override
  Future<bool> validateConversionSettings(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  ) async {
    // Validation basique
    if (inputFile.format == outputFormat) {
      return false; // Pas besoin de conversion
    }

    if (settings.width != null && settings.width! <= 0) {
      return false;
    }

    if (settings.height != null && settings.height! <= 0) {
      return false;
    }

    return true;
  }

  @override
  Future<int> estimateOutputSize(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  ) async {
    // Estimation basique basée sur la qualité
    final baseSize = inputFile.size;

    switch (settings.quality) {
      case VideoQuality.low:
        return (baseSize * 0.3).round();
      case VideoQuality.medium:
        return (baseSize * 0.6).round();
      case VideoQuality.high:
        return (baseSize * 0.9).round();
      case VideoQuality.ultra:
        return (baseSize * 1.2).round();
    }
  }

  // Méthodes privées
  Future<String> _buildFFmpegCommand(VideoConversionTask task) async {
    final inputPath = task.inputFile.path;
    final outputPath = await _getOutputPath(task);

    // Commande de base
    var command = '-i "$inputPath"';

    // Paramètres de qualité
    switch (task.settings.quality) {
      case VideoQuality.low:
        command += ' -vf scale=480:-2';
        command += ' -b:v 500k';
        break;
      case VideoQuality.medium:
        command += ' -vf scale=720:-2';
        command += ' -b:v 1500k';
        break;
      case VideoQuality.high:
        command += ' -vf scale=1080:-2';
        command += ' -b:v 3000k';
        break;
      case VideoQuality.ultra:
        command += ' -vf scale=2160:-2';
        command += ' -b:v 8000k';
        break;
    }

    // Paramètres personnalisés
    if (task.settings.width != null && task.settings.height != null) {
      command += ' -vf scale=${task.settings.width}:${task.settings.height}';
    }

    if (task.settings.bitrate != null) {
      command += ' -b:v ${task.settings.bitrate}k';
    }

    if (task.settings.framerate != null) {
      command += ' -r ${task.settings.framerate}';
    }

    // Supprimer l'audio si demandé
    if (!task.settings.preserveAudio) {
      command += ' -an';
    }

    // Supprimer les métadonnées si demandé
    if (!task.settings.preserveMetadata) {
      command += ' -map_metadata -1';
    }

    // Format de sortie
    command += ' -f ${task.outputFormat.extension}';

    // Chemin de sortie
    command += ' "$outputPath"';

    return command;
  }

  Future<String> _getOutputPath(VideoConversionTask task) async {
    final outputDir = task.settings.outputDirectory ??
        File(task.inputFile.path).parent.path;

    final outputName = '${task.inputFile.nameWithoutExtension}_converted.${task.outputFormat.extension}';

    return '$outputDir/$outputName';
  }
}
