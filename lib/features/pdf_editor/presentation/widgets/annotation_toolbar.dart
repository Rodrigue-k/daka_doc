import 'package:daka_doc/features/pdf_editor/domain/entities/pdf_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:daka_doc/features/pdf_editor/presentation/providers/pdf_providers.dart';
import 'package:daka_doc/core/widgets/custom_widgets.dart';
import 'package:uuid/uuid.dart';

enum AnnotationTool {
  text,
  image,
  signature,
  select,
}

class AnnotationToolbar extends ConsumerStatefulWidget {
  const AnnotationToolbar({super.key});

  @override
  ConsumerState<AnnotationToolbar> createState() => _AnnotationToolbarState();
}

class _AnnotationToolbarState extends ConsumerState<AnnotationToolbar> {
  AnnotationTool _selectedTool = AnnotationTool.select;
  bool _showTextDialog = false;
  bool _showImageDialog = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Barre d'outils principale
          Row(
            children: [
              // Outil sélection
              _buildToolButton(
                icon: Icons.select_all,
                label: 'Sélection',
                isSelected: _selectedTool == AnnotationTool.select,
                onPressed: () => setState(() => _selectedTool = AnnotationTool.select),
              ),

              const SizedBox(width: 8),

              // Outil texte
              _buildToolButton(
                icon: Icons.text_fields,
                label: 'Texte',
                isSelected: _selectedTool == AnnotationTool.text,
                onPressed: () => _showTextAnnotationDialog(),
              ),

              const SizedBox(width: 8),

              // Outil image
              _buildToolButton(
                icon: Icons.image,
                label: 'Image',
                isSelected: _selectedTool == AnnotationTool.image,
                onPressed: () => _showImageAnnotationDialog(),
              ),

              const SizedBox(width: 8),

              // Outil signature
              _buildToolButton(
                icon: Icons.edit,
                label: 'Signature',
                isSelected: _selectedTool == AnnotationTool.signature,
                onPressed: () => _showSignatureAnnotationDialog(),
              ),

              const Spacer(),

              // Bouton d'annulation
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _undoLastAnnotation,
                tooltip: 'Annuler la dernière annotation',
              ),

              // Bouton de suppression
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _clearAllAnnotations,
                tooltip: 'Supprimer toutes les annotations',
              ),
            ],
          ),

          // Dialogues d'ajout d'annotations
          if (_showTextDialog)
            _buildTextAnnotationDialog(),

          if (_showImageDialog)
            _buildImageAnnotationDialog(),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextAnnotationDialog() {
    final textController = TextEditingController();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajouter du texte',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Texte à ajouter',
              hintText: 'Saisissez votre texte...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _showTextDialog = false),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addTextAnnotation(textController.text),
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnnotationDialog() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajouter une image',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez une image à ajouter au PDF',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _showImageDialog = false),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pickImageForAnnotation,
                child: const Text('Sélectionner'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTextAnnotationDialog() {
    setState(() {
      _selectedTool = AnnotationTool.text;
      _showTextDialog = true;
      _showImageDialog = false;
    });
  }

  void _showImageAnnotationDialog() {
    setState(() {
      _selectedTool = AnnotationTool.image;
      _showTextDialog = false;
      _showImageDialog = true;
    });
  }

  void _showSignatureAnnotationDialog() {
    setState(() {
      _selectedTool = AnnotationTool.signature;
      _showTextDialog = false;
      _showImageDialog = false;
    });

    // Naviguer vers la page de signature
    Navigator.of(context).pushNamed('/signature');
  }

  Future<void> _addTextAnnotation(String text) async {
    if (text.trim().isEmpty) return;

    final currentDocument = ref.read(currentPdfDocumentProvider);
    if (currentDocument == null) return;

    setState(() => _showTextDialog = false);

    try {
      final annotation = TextAnnotation(
        id: const Uuid().v4(),
        pageNumber: 1, // TODO: Obtenir la page actuelle du viewer
        createdAt: DateTime.now(),
        text: text,
        x: 100.0, // TODO: Obtenir la position du clic
        y: 100.0,
        fontSize: 12.0,
        fontColor: '#000000',
      );

      final addTextUseCase = ref.read(addTextAnnotationProvider);
      final updatedDocument = await addTextUseCase(currentDocument, annotation);

      ref.read(currentPdfDocumentProvider.notifier).state = updatedDocument;

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Texte ajouté avec succès');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de l\'ajout du texte: $e');
      }
    }
  }

  Future<void> _pickImageForAnnotation() async {
    setState(() => _showImageDialog = false);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final imagePath = result.files.single.path!;

        final currentDocument = ref.read(currentPdfDocumentProvider);
        if (currentDocument == null) return;

        final annotation = ImageAnnotation(
          id: const Uuid().v4(),
          pageNumber: 1, // TODO: Obtenir la page actuelle
          createdAt: DateTime.now(),
          imagePath: imagePath,
          x: 100.0, // TODO: Obtenir la position
          y: 100.0,
          width: 200.0,
          height: 150.0,
        );

        final addImageUseCase = ref.read(addImageAnnotationProvider);
        final updatedDocument = await addImageUseCase(currentDocument, annotation);

        ref.read(currentPdfDocumentProvider.notifier).state = updatedDocument;

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Image ajoutée avec succès');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de l\'ajout de l\'image: $e');
      }
    }
  }

  void _undoLastAnnotation() {
    // TODO: Implémenter l'annulation de la dernière annotation
    CustomSnackBar.showInfo(context, 'Fonctionnalité à implémenter');
  }

  void _clearAllAnnotations() {
    // TODO: Implémenter la suppression de toutes les annotations
    CustomSnackBar.showInfo(context, 'Fonctionnalité à implémenter');
  }
}
