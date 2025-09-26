import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daka_doc/features/signature/domain/entities/signature_entities.dart' as signature_entities;
import 'package:daka_doc/features/signature/presentation/providers/signature_providers.dart';
import 'package:daka_doc/features/signature/presentation/widgets/signature_pad.dart';
import 'package:daka_doc/core/widgets/custom_widgets.dart';
import 'package:go_router/go_router.dart';

class SignaturePage extends ConsumerStatefulWidget {
  const SignaturePage({super.key});

  @override
  ConsumerState<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends ConsumerState<SignaturePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _showSavedSignatures = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSignature = ref.watch(currentSignatureProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Signature numérique'),
        actions: [
          if (currentSignature != null) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportSignature,
              tooltip: 'Exporter PNG',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => setState(() => _showSavedSignatures = !_showSavedSignatures),
            tooltip: 'Signatures sauvegardées',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu principal
          if (_showSavedSignatures)
            _buildSavedSignaturesView()
          else
            _buildSignatureCreationView(),

          // Loader
          if (_isLoading)
            const FullScreenLoader(message: 'Traitement de la signature...'),
        ],
      ),
      floatingActionButton: currentSignature == null
          ? FloatingActionButton.extended(
              onPressed: _createNewSignature,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle signature'),
            )
          : null,
    );
  }

  Widget _buildSignatureCreationView() {
    final currentSignature = ref.watch(currentSignatureProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Créez votre signature',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Signez avec votre doigt ou une souris',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 32),

          // Zone de signature
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0, // Carré 1:1
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SignaturePad(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contrôles
          if (currentSignature != null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la signature',
                      hintText: 'Ma signature',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSignature,
                      tooltip: 'Effacer',
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: _undoLastStroke,
                      tooltip: 'Annuler le dernier trait',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryActionButton(
                    text: 'Réessayer',
                    icon: Icons.refresh,
                    onPressed: _clearSignature,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryActionButton(
                    text: 'Sauvegarder',
                    icon: Icons.save,
                    onPressed: _saveSignature,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Utilisez le bouton + pour créer une nouvelle signature',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedSignaturesView() {
    final savedSignatures = ref.watch(savedSignaturesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Text(
                'Signatures sauvegardées',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showSavedSignatures = false),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Liste des signatures
          Expanded(
            child: savedSignatures.isEmpty
                ? _buildEmptySignaturesView()
                : _buildSignaturesList(savedSignatures),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySignaturesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_off,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune signature sauvegardée',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première signature',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturesList(List<signature_entities.SignatureEntity> signatures) {
    return ListView.builder(
      itemCount: signatures.length,
      itemBuilder: (context, index) {
        final signature = signatures[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, size: 20),
            ),
            title: Text(signature.name),
            subtitle: Text(
              '${signature.strokeCount} trait(s) • Modifié le ${_formatDate(signature.modifiedAt)}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleSignatureAction(signature, action),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'load',
                  child: ListTile(
                    leading: Icon(Icons.open_in_new),
                    title: Text('Charger'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Exporter'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            onTap: () => _loadSignature(signature),
          ),
        );
      },
    );
  }

  Future<void> _createNewSignature() async {
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = 'Signature ${DateTime.now().millisecondsSinceEpoch}';
    }

    setState(() => _isLoading = true);

    try {
      final createSignatureUseCase = ref.read(createSignatureProvider);
      final signature = await createSignatureUseCase(_nameController.text);

      ref.read(currentSignatureProvider.notifier).state = signature;

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Nouvelle signature créée');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de la création: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSignature() async {
    final currentSignature = ref.read(currentSignatureProvider);

    if (currentSignature == null) {
      CustomSnackBar.showError(context, 'Créez une nouvelle signature d\'abord');
      return;
    }

    if (currentSignature.id.isEmpty) {
      CustomSnackBar.showError(context, 'Signature invalide - ID manquant');
      return;
    }

    // Vérifier que la signature a des strokes
    final currentStrokes = ref.read(currentStrokesProvider);
    if (currentStrokes.isEmpty) {
      CustomSnackBar.showError(context, 'Dessinez une signature d\'abord');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mettre à jour la signature avec les strokes actuels
      final updatedSignature = currentSignature.copyWith(
        strokes: currentStrokes,
        modifiedAt: DateTime.now(),
      );

      // Sauvegarde JSON
      final saveSignatureUseCase = ref.read(saveSignatureProvider);
      await saveSignatureUseCase(updatedSignature);

      // Export PNG automatique
      final exportSignatureUseCase = ref.read(exportSignatureProvider);
      final pngPath = await exportSignatureUseCase(updatedSignature);

      // Mettre à jour provider
      ref.read(currentSignatureProvider.notifier).state = updatedSignature;

      // Recharger liste
      await _loadSavedSignatures();

      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Signature sauvegardée et exportée vers: $pngPath',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de la sauvegarde/export: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportSignature() async {
    final currentSignature = ref.read(currentSignatureProvider);

    if (currentSignature == null) return;

    setState(() => _isLoading = true);

    try {
      final exportSignatureUseCase = ref.read(exportSignatureProvider);
      final exportPath = await exportSignatureUseCase(currentSignature);

      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Signature exportée vers: $exportPath',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de l\'export: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearSignature() async {
    final currentSignature = ref.read(currentSignatureProvider);

    if (currentSignature == null) return;

    try {
      final clearSignatureUseCase = ref.read(clearSignatureProvider);
      final clearedSignature = await clearSignatureUseCase(currentSignature);

      ref.read(currentSignatureProvider.notifier).state = clearedSignature;

      if (mounted) {
        CustomSnackBar.showInfo(context, 'Signature effacée');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de l\'effacement: $e');
      }
    }
  }

  Future<void> _undoLastStroke() async {
    // TODO: Implémenter l'annulation du dernier trait
    CustomSnackBar.showInfo(context, 'Fonctionnalité à implémenter');
  }

  Future<void> _loadSavedSignatures() async {
    try {
      final getAllSignaturesUseCase = ref.read(getAllSignaturesProvider);
      final signatures = await getAllSignaturesUseCase();

      ref.read(savedSignaturesProvider.notifier).state = signatures;
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors du chargement: $e');
      }
    }
  }

  Future<void> _loadSignature(signature_entities.SignatureEntity signature) async {
    setState(() => _isLoading = true);

    try {
      final loadSignatureUseCase = ref.read(loadSignatureProvider);
      final loadedSignature = await loadSignatureUseCase(signature.id);

      ref.read(currentSignatureProvider.notifier).state = loadedSignature;

      setState(() => _showSavedSignatures = false);

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Signature chargée avec succès');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors du chargement: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSignatureAction(signature_entities.SignatureEntity signature, String action) {
    switch (action) {
      case 'load':
        _loadSignature(signature);
        break;
      case 'export':
        _exportSignatureFromSaved(signature);
        break;
      case 'delete':
        _deleteSignature(signature);
        break;
    }
  }

  Future<void> _exportSignatureFromSaved(signature_entities.SignatureEntity signature) async {
    setState(() => _isLoading = true);

    try {
      final exportSignatureUseCase = ref.read(exportSignatureProvider);
      final exportPath = await exportSignatureUseCase(signature);

      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Signature exportée vers: $exportPath',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erreur lors de l\'export: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSignature(signature_entities.SignatureEntity signature) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Supprimer la signature',
        message: 'Êtes-vous sûr de vouloir supprimer "${signature.name}" ?',
        confirmText: 'Supprimer',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final deleteSignatureUseCase = ref.read(deleteSignatureProvider);
        await deleteSignatureUseCase(signature.id);

        // Recharger la liste
        await _loadSavedSignatures();

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Signature supprimée avec succès');
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Erreur lors de la suppression: $e');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
