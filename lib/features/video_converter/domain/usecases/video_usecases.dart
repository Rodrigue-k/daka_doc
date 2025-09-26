import 'package:daka_doc/features/video_converter/domain/entities/video_entities.dart';
import 'package:daka_doc/features/video_converter/domain/repositories/video_repository.dart';

/// Use case pour sélectionner un fichier vidéo
class PickVideoFile {
  final VideoRepository repository;

  PickVideoFile(this.repository);

  Future<VideoFile?> call() async {
    return await repository.pickVideoFile();
  }
}

/// Use case pour obtenir les informations d'un fichier vidéo
class GetVideoInfo {
  final VideoRepository repository;

  GetVideoInfo(this.repository);

  Future<VideoFile> call(String path) async {
    return await repository.getVideoInfo(path);
  }
}

/// Use case pour créer une tâche de conversion
class CreateConversionTask {
  final VideoRepository repository;

  CreateConversionTask(this.repository);

  Future<VideoConversionTask> call(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  ) async {
    return await repository.createConversionTask(inputFile, outputFormat, settings);
  }
}

/// Use case pour démarrer une conversion
class StartConversion {
  final VideoRepository repository;

  StartConversion(this.repository);

  Future<VideoConversionTask> call(VideoConversionTask task) async {
    return await repository.startConversion(task);
  }
}

/// Use case pour annuler une conversion
class CancelConversion {
  final VideoRepository repository;

  CancelConversion(this.repository);

  Future<VideoConversionTask> call(VideoConversionTask task) async {
    return await repository.cancelConversion(task);
  }
}

/// Use case pour obtenir le statut d'une conversion
class GetConversionStatus {
  final VideoRepository repository;

  GetConversionStatus(this.repository);

  Future<VideoConversionTask> call(String taskId) async {
    return await repository.getConversionStatus(taskId);
  }
}

/// Use case pour obtenir toutes les tâches de conversion
class GetAllConversionTasks {
  final VideoRepository repository;

  GetAllConversionTasks(this.repository);

  Future<List<VideoConversionTask>> call() async {
    return await repository.getAllConversionTasks();
  }
}

/// Use case pour supprimer une tâche de conversion terminée
class DeleteConversionTask {
  final VideoRepository repository;

  DeleteConversionTask(this.repository);

  Future<void> call(String taskId) async {
    return await repository.deleteConversionTask(taskId);
  }
}

/// Use case pour obtenir les formats de sortie disponibles
class GetAvailableOutputFormats {
  final VideoRepository repository;

  GetAvailableOutputFormats(this.repository);

  Future<List<VideoFormat>> call(VideoFile inputFile) async {
    return await repository.getAvailableOutputFormats(inputFile);
  }
}

/// Use case pour valider les paramètres de conversion
class ValidateConversionSettings {
  final VideoRepository repository;

  ValidateConversionSettings(this.repository);

  Future<bool> call(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  ) async {
    return await repository.validateConversionSettings(
      inputFile,
      outputFormat,
      settings,
    );
  }
}

/// Use case pour estimer la taille de sortie
class EstimateOutputSize {
  final VideoRepository repository;

  EstimateOutputSize(this.repository);

  Future<int> call(
    VideoFile inputFile,
    VideoFormat outputFormat,
    ConversionSettings settings,
  ) async {
    return await repository.estimateOutputSize(
      inputFile,
      outputFormat,
      settings,
    );
  }
}
