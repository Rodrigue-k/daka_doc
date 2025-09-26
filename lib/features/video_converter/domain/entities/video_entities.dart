import 'package:equatable/equatable.dart';

/// Entité représentant un fichier vidéo
class VideoFile extends Equatable {
  final String id;
  final String name;
  final String path;
  final int size;
  final Duration duration;
  final VideoFormat format;
  final int width;
  final int height;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const VideoFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.duration,
    required this.format,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    size,
    duration,
    format,
    width,
    height,
    createdAt,
    modifiedAt,
  ];

  VideoFile copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    Duration? duration,
    VideoFormat? format,
    int? width,
    int? height,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return VideoFile(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  /// Obtient le nom du fichier sans extension
  String get nameWithoutExtension => name.split('.').sublist(0, name.split('.').length - 1).join('.');

  /// Obtient l'extension du fichier
  String get extension => name.split('.').last.toLowerCase();
}

/// Formats vidéo supportés
enum VideoFormat {
  mp4('MP4', 'mp4'),
  avi('AVI', 'avi'),
  mov('MOV', 'mov'),
  mkv('MKV', 'mkv'),
  webm('WebM', 'webm'),
  flv('FLV', 'flv'),
  wmv('WMV', 'wmv'),
  m4v('M4V', 'm4v');

  const VideoFormat(this.displayName, this.extension);

  final String displayName;
  final String extension;

  static VideoFormat fromExtension(String extension) {
    return VideoFormat.values.firstWhere(
      (format) => format.extension == extension.toLowerCase(),
      orElse: () => VideoFormat.mp4,
    );
  }
}

/// Entité représentant une tâche de conversion vidéo
class VideoConversionTask extends Equatable {
  final String id;
  final VideoFile inputFile;
  final VideoFormat outputFormat;
  final ConversionSettings settings;
  final ConversionStatus status;
  final double progress;
  final String? outputPath;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;

  const VideoConversionTask({
    required this.id,
    required this.inputFile,
    required this.outputFormat,
    required this.settings,
    required this.status,
    required this.progress,
    this.outputPath,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    id,
    inputFile,
    outputFormat,
    settings,
    status,
    progress,
    outputPath,
    createdAt,
    startedAt,
    completedAt,
    errorMessage,
  ];

  VideoConversionTask copyWith({
    String? id,
    VideoFile? inputFile,
    VideoFormat? outputFormat,
    ConversionSettings? settings,
    ConversionStatus? status,
    double? progress,
    String? outputPath,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return VideoConversionTask(
      id: id ?? this.id,
      inputFile: inputFile ?? this.inputFile,
      outputFormat: outputFormat ?? this.outputFormat,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      outputPath: outputPath ?? this.outputPath,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Durée estimée de la conversion
  Duration? get estimatedDuration {
    if (status != ConversionStatus.converting || startedAt == null) {
      return null;
    }

    final elapsed = DateTime.now().difference(startedAt!);
    final estimatedTotal = elapsed * (1 / progress);
    return estimatedTotal;
  }

  /// Temps restant estimé
  Duration? get remainingTime {
    final estimatedTotal = estimatedDuration;
    if (estimatedTotal == null) return null;

    final elapsed = startedAt != null ? DateTime.now().difference(startedAt!) : Duration.zero;
    return estimatedTotal - elapsed;
  }
}

/// Statut d'une conversion
enum ConversionStatus {
  pending('En attente'),
  converting('Conversion en cours'),
  completed('Terminée'),
  failed('Échec'),
  cancelled('Annulée');

  const ConversionStatus(this.displayName);

  final String displayName;
}

/// Paramètres de conversion vidéo
class ConversionSettings extends Equatable {
  final VideoQuality quality;
  final int? width;
  final int? height;
  final int? bitrate;
  final int? framerate;
  final bool preserveAudio;
  final bool preserveMetadata;
  final String? outputDirectory;

  const ConversionSettings({
    this.quality = VideoQuality.medium,
    this.width,
    this.height,
    this.bitrate,
    this.framerate,
    this.preserveAudio = true,
    this.preserveMetadata = true,
    this.outputDirectory,
  });

  @override
  List<Object?> get props => [
    quality,
    width,
    height,
    bitrate,
    framerate,
    preserveAudio,
    preserveMetadata,
    outputDirectory,
  ];

  ConversionSettings copyWith({
    VideoQuality? quality,
    int? width,
    int? height,
    int? bitrate,
    int? framerate,
    bool? preserveAudio,
    bool? preserveMetadata,
    String? outputDirectory,
  }) {
    return ConversionSettings(
      quality: quality ?? this.quality,
      width: width ?? this.width,
      height: height ?? this.height,
      bitrate: bitrate ?? this.bitrate,
      framerate: framerate ?? this.framerate,
      preserveAudio: preserveAudio ?? this.preserveAudio,
      preserveMetadata: preserveMetadata ?? this.preserveMetadata,
      outputDirectory: outputDirectory ?? this.outputDirectory,
    );
  }
}

/// Qualité de conversion vidéo
enum VideoQuality {
  low('Basse', 480),
  medium('Moyenne', 720),
  high('Haute', 1080),
  ultra('Ultra', 2160);

  const VideoQuality(this.displayName, this.defaultHeight);

  final String displayName;
  final int defaultHeight;
}
