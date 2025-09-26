import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:daka_doc/features/pdf_editor/presentation/providers/pdf_providers.dart';
import 'package:daka_doc/features/pdf_editor/presentation/widgets/pdf_viewer_widget.dart';
import 'package:daka_doc/features/pdf_editor/presentation/widgets/annotation_toolbar.dart';
import 'package:daka_doc/core/widgets/custom_widgets.dart';
import 'package:daka_doc/core/utils/file_utils.dart';

class PdfEditorPage extends ConsumerStatefulWidget {
  const PdfEditorPage({super.key});

  @override
  ConsumerState<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends ConsumerState<PdfEditorPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentDocument = ref.watch(currentPdfDocumentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDocument?.name ?? 'PDF Editor'),
        actions: [
          if (currentDocument != null) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDocument,
              tooltip: 'Sauvegarder',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportDocument,
              tooltip: 'Exporter',
            ),
          ],
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: ListTile(
                  leading: Icon(Icons.folder_open),
                  title: Text('Ouvrir PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'merge',
                child: ListTile(
                  leading: Icon(Icons.merge),
                  title: Text('Fusionner PDFs'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'split',
                child: ListTile(
                  leading: Icon(Icons.splitscreen),
                  title: Text('Diviser PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu principal
          if (currentDocument != null)
            Column(
              children: [
                // Barre d'outils d'annotation
                const AnnotationToolbar(),

                // Visionneuse PDF
                Expanded(
                  child: PdfViewerWidget(
                    document: currentDocument,
                  ),
                ),
              ],
            )
          else
            // Écran d'accueil
            _buildWelcomeScreen(),

          // Loader
          if (_isLoading)
            const FullScreenLoader(message: 'Traitement du PDF...'),
        ],
      ),
      floatingActionButton: currentDocument == null
          ? FloatingActionButton.extended(
              onPressed: _pickPdfFile,
              icon: const Icon(Icons.add),
              label: const Text('Ouvrir PDF'),
            )
          : null,
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun PDF ouvert',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ouvrez un document PDF pour commencer à l\'éditer',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryActionButton(
            text: 'Sélectionner un PDF',
            icon: Icons.folder_open,
            onPressed: _pickPdfFile,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdfFile() async {
    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        // Vérifier que c'est bien un fichier PDF
        if (!FileUtils.isPdfFile(path)) {
          if (mounted) {
            CustomSnackBar.showError(context, 'Le fichier sélectionné n\'est pas un PDF');
          }
          return;
        }

        // Charger le document
        final loadPdfUseCase = ref.read(loadPdfDocumentProvider);
        final document = await loadPdfUseCase(path);

        // Mettre à jour l'état
        ref.read(currentPdfDocumentProvider.notifier).state = document;

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'PDF chargé avec succès');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors du chargement du PDF: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDocument() async {
    final currentDocument = ref.read(currentPdfDocumentProvider);

    if (currentDocument == null) return;

    setState(() => _isLoading = true);

    try {
      // Sauvegarder le document
      final savePath = await File(currentDocument.path).copy(
        '${FileUtils.getFileNameWithoutExtension(currentDocument.path)}_sauvegarde.pdf',
      );

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Document sauvegardé avec succès');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de la sauvegarde: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportDocument() async {
    final currentDocument = ref.read(currentPdfDocumentProvider);

    if (currentDocument == null) return;

    setState(() => _isLoading = true);

    try {
      // Exporter le document (copier vers un nouvel emplacement)
      final exportPath = '${FileUtils.getFileNameWithoutExtension(currentDocument.path)}_export.pdf';

      await File(currentDocument.path).copy(exportPath);

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Document exporté avec succès');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de l\'export: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'open':
        _pickPdfFile();
        break;
      case 'merge':
        _showMergeDialog();
        break;
      case 'split':
        _showSplitDialog();
        break;
    }
  }

  void _showMergeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fusionner des PDFs'),
        content: const Text('Fonctionnalité de fusion à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showSplitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diviser le PDF'),
        content: const Text('Fonctionnalité de division à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
