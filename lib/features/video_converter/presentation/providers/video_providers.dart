import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daka_doc/features/video_converter/domain/entities/video_entities.dart';
import 'package:daka_doc/features/video_converter/domain/repositories/video_repository.dart';
import 'package:daka_doc/features/video_converter/domain/usecases/video_usecases.dart';
import 'package:daka_doc/features/video_converter/data/repositories/video_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider pour le repository vidéo
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl();
});

/// Provider pour le fichier vidéo sélectionné
final selectedVideoProvider = StateProvider<VideoFile?>((ref) => null);

/// Provider pour les tâches de conversion
final conversionTasksProvider = StateProvider<List<VideoConversionTask>>((ref) => []);

/// Provider pour la tâche de conversion active
final activeConversionTaskProvider = StateProvider<VideoConversionTask?>((ref) => null);

/// Provider pour le use case de sélection de fichier vidéo
final pickVideoFileProvider = Provider<PickVideoFile>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return PickVideoFile(repository);
});

/// Provider pour le use case d'obtention d'informations vidéo
final getVideoInfoProvider = Provider<GetVideoInfo>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetVideoInfo(repository);
});

/// Provider pour le use case de création de tâche de conversion
final createConversionTaskProvider = Provider<CreateConversionTask>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return CreateConversionTask(repository);
});

/// Provider pour le use case de démarrage de conversion
final startConversionProvider = Provider<StartConversion>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return StartConversion(repository);
});

/// Provider pour le use case d'annulation de conversion
final cancelConversionProvider = Provider<CancelConversion>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return CancelConversion(repository);
});

/// Provider pour le use case d'obtention du statut de conversion
final getConversionStatusProvider = Provider<GetConversionStatus>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetConversionStatus(repository);
});

/// Provider pour le use case d'obtention de toutes les tâches
final getAllConversionTasksProvider = Provider<GetAllConversionTasks>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetAllConversionTasks(repository);
});

/// Provider pour le use case de suppression de tâche
final deleteConversionTaskProvider = Provider<DeleteConversionTask>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return DeleteConversionTask(repository);
});

/// Provider pour le use case d'obtention des formats disponibles
final getAvailableOutputFormatsProvider = Provider<GetAvailableOutputFormats>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetAvailableOutputFormats(repository);
});

/// Provider pour le use case de validation des paramètres
final validateConversionSettingsProvider = Provider<ValidateConversionSettings>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return ValidateConversionSettings(repository);
});

/// Provider pour le use case d'estimation de taille
final estimateOutputSizeProvider = Provider<EstimateOutputSize>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return EstimateOutputSize(repository);
});
