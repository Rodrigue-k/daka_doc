import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utilitaires pour la gestion des fichiers et dossiers
class FileUtils {
  /// Obtient le répertoire de documents de l'application
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Obtient le répertoire temporaire de l'application
  static Future<Directory> getAppTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Obtient le répertoire de téléchargements si disponible
  static Future<Directory?> getDownloadsDirectory() async {
    try {
      return await getDownloadsDirectory();
    } catch (e) {
      return null;
    }
  }

  /// Crée un fichier dans le répertoire temporaire
  static Future<File> createTempFile(String fileName, String extension) async {
    final tempDir = await getAppTemporaryDirectory();
    final filePath = path.join(tempDir.path, '$fileName.$extension');
    return File(filePath);
  }

  /// Sauvegarde un fichier avec un nom unique
  static Future<File> saveFileWithUniqueName(
    Directory directory,
    String baseName,
    String extension,
    List<int> bytes,
  ) async {
    int counter = 1;
    String fileName = '$baseName.$extension';

    while (await File(path.join(directory.path, fileName)).exists()) {
      fileName = '${baseName}_$counter.$extension';
      counter++;
    }

    final file = File(path.join(directory.path, fileName));
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Formate la taille d'un fichier en format lisible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Obtient l'extension d'un fichier
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  /// Obtient le nom du fichier sans extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Vérifie si un fichier est une vidéo
  static bool isVideoFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv', 'wmv'].contains(extension);
  }

  /// Vérifie si un fichier est un PDF
  static bool isPdfFile(String filePath) {
    return getFileExtension(filePath) == 'pdf';
  }

  /// Vérifie si un fichier est une image
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'].contains(extension);
  }
}

/// Utilitaires pour les chaînes de caractères
class StringUtils {
  /// Met en majuscule la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Tronque le texte avec des points de suspension
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
}

/// Utilitaires pour les validations
class ValidationUtils {
  /// Valide une adresse email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Valide un nom de fichier (pas de caractères spéciaux)
  static bool isValidFileName(String fileName) {
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(fileName) && fileName.trim().isNotEmpty;
  }
}
