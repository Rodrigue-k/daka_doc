import 'package:daka_doc/features/video_converter/domain/entities/video_entities.dart';

/// Repository abstrait pour les opérations vidéo
abstract class VideoRepository {
  /// Sélectionne un fichier vidéo via le picker
  Future<VideoFile?> pickVideoFile();

  /// Obtient les informations d'un fichier vidéo
  Future<VideoFile> getVideoInfo(String path);

  /// Crée une tâche de conversion
  Future<VideoConversionTask> createConversionTask(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  );

  /// Démarre une conversion
  Future<VideoConversionTask> startConversion(VideoConversionTask task);

  /// Annule une conversion
  Future<VideoConversionTask> cancelConversion(VideoConversionTask task);

  /// Obtient le statut d'une conversion
  Future<VideoConversionTask> getConversionStatus(String taskId);

  /// Obtient toutes les tâches de conversion
  Future<List<VideoConversionTask>> getAllConversionTasks();

  /// Supprime une tâche de conversion terminée
  Future<void> deleteConversionTask(String taskId);

  /// Obtient les formats de sortie disponibles pour un fichier
  Future<List<VideoFormat>> getAvailableOutputFormats(VideoFile inputFile);

  /// Valide les paramètres de conversion
  Future<bool> validateConversionSettings(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  );

  /// Estime la taille de sortie
  Future<int> estimateOutputSize(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  );
}
