import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:daka_doc/features/video_converter/domain/entities/video_entities.dart';
import 'package:daka_doc/features/video_converter/presentation/providers/video_providers.dart';
import 'package:daka_doc/core/widgets/custom_widgets.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

class VideoConverterPage extends ConsumerStatefulWidget {
  const VideoConverterPage({super.key});

  @override
  ConsumerState<VideoConverterPage> createState() => _VideoConverterPageState();
}

class _VideoConverterPageState extends ConsumerState<VideoConverterPage> {
  bool _isLoading = false;
  VideoFile? _selectedVideo;
  VideoFormat _selectedFormat = VideoFormat.mp4;
  ConversionSettings _conversionSettings = const ConversionSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Converter'),
        actions: [
          if (_selectedVideo != null) ...[
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startConversion,
              tooltip: 'Démarrer la conversion',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
              tooltip: 'Paramètres',
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          // Contenu principal
          _buildContent(),

          // Loader
          if (_isLoading)
            const FullScreenLoader(message: 'Traitement de la vidéo...'),
        ],
      ),
      floatingActionButton: _selectedVideo == null
          ? FloatingActionButton.extended(
              onPressed: _pickVideoFile,
              icon: const Icon(Icons.video_file),
              label: const Text('Sélectionner une vidéo'),
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_selectedVideo == null) {
      return _buildWelcomeScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations du fichier sélectionné
          _buildVideoInfoCard(),

          const SizedBox(height: 24),

          // Sélection du format de sortie
          _buildFormatSelection(),

          const SizedBox(height: 24),

          // Paramètres de conversion
          _buildConversionSettings(),

          const SizedBox(height: 24),

          // Estimation et actions
          _buildConversionActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_file,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune vidéo sélectionnée',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Sélectionnez une vidéo pour commencer la conversion',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryActionButton(
            text: 'Sélectionner une vidéo',
            icon: Icons.video_file,
            onPressed: _pickVideoFile,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.video_file,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedVideo!.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${FileUtils.formatFileSize(_selectedVideo!.size)} • ${_formatDuration(_selectedVideo!.duration)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  label: _selectedVideo!.format.displayName,
                  icon: Icons.movie_filter,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  label: '${_selectedVideo!.width}×${_selectedVideo!.height}',
                  icon: Icons.aspect_ratio,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  label: _formatDate(_selectedVideo!.modifiedAt),
                  icon: Icons.access_time,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format de sortie',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: VideoFormat.values.map((format) {
            return ChoiceChip(
              label: Text(format.displayName),
              selected: _selectedFormat == format,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFormat = format);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConversionSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres de conversion',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Qualité
                Row(
                  children: [
                    const Icon(Icons.high_quality),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qualité',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _conversionSettings.quality.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<VideoQuality>(
                      value: _conversionSettings.quality,
                      items: VideoQuality.values.map((quality) {
                        return DropdownMenuItem(
                          value: quality,
                          child: Text(quality.displayName),
                        );
                      }).toList(),
                      onChanged: (quality) {
                        if (quality != null) {
                          setState(() {
                            _conversionSettings = _conversionSettings.copyWith(
                              quality: quality,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Options audio et métadonnées
                SwitchListTile(
                  title: const Text('Conserver l\'audio'),
                  subtitle: const Text('Inclure la piste audio dans la conversion'),
                  value: _conversionSettings.preserveAudio,
                  onChanged: (value) {
                    setState(() {
                      _conversionSettings = _conversionSettings.copyWith(
                        preserveAudio: value,
                      );
                    });
                  },
                  secondary: const Icon(Icons.audio_file),
                ),
                SwitchListTile(
                  title: const Text('Conserver les métadonnées'),
                  subtitle: const Text('Inclure les informations du fichier original'),
                  value: _conversionSettings.preserveMetadata,
                  onChanged: (value) {
                    setState(() {
                      _conversionSettings = _conversionSettings.copyWith(
                        preserveMetadata: value,
                      );
                    });
                  },
                  secondary: const Icon(Icons.info),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversionActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Format: ${_selectedFormat.displayName}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qualité: ${_conversionSettings.quality.displayName}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PrimaryActionButton(
                      text: 'Convertir',
                      icon: Icons.play_arrow,
                      onPressed: _startConversion,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickVideoFile() async {
    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        // Vérifier que c'est bien un fichier vidéo
        if (!FileUtils.isVideoFile(path)) {
          if (mounted) {
            CustomSnackBar.showError(context, 'Le fichier sélectionné n\'est pas une vidéo');
          }
          return;
        }

        // Obtenir les informations du fichier
        final getVideoInfoUseCase = ref.read(getVideoInfoProvider);
        final videoFile = await getVideoInfoUseCase(path);

        setState(() {
          _selectedVideo = videoFile;
        });

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Vidéo chargée avec succès');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors du chargement de la vidéo: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startConversion() async {
    if (_selectedVideo == null) return;

    setState(() => _isLoading = true);

    try {
      // Créer la tâche de conversion
      final createTaskUseCase = ref.read(createConversionTaskProvider);
      final task = await createTaskUseCase(
        _selectedVideo!,
        _selectedFormat,
        _conversionSettings,
      );

      // Démarrer la conversion
      final startConversionUseCase = ref.read(startConversionProvider);
      final startedTask = await startConversionUseCase(task);

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Conversion démarrée');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors du démarrage de la conversion: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres de conversion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Ajouter des contrôles pour les paramètres avancés
            const Text('Paramètres avancés à implémenter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
