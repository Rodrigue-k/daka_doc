import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart' as signature_pad;
import 'package:daka_doc/features/signature/domain/entities/signature_entities.dart';
import 'package:daka_doc/features/signature/presentation/providers/signature_providers.dart';

class SignaturePad extends ConsumerStatefulWidget {
  const SignaturePad({super.key});

  @override
  ConsumerState<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends ConsumerState<SignaturePad> {
  late signature_pad.SignatureController _signatureController;
  bool _isDrawing = false;
  final GlobalKey _padKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _signatureController = signature_pad.SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    // Écouter les changements du controller et mettre à jour le provider
    _signatureController.addListener(_onSignatureChanged);
  }

  void _onSignatureChanged() async {
    if (_signatureController.points.isNotEmpty) {
      final strokes = await getStrokes();
      ref.read(currentStrokesProvider.notifier).state = strokes;
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currentSignatureProvider);
    ref.watch(currentStrokesProvider);

    // Si une signature est chargée, afficher le pad vide pour permettre de continuer à dessiner
    return GestureDetector(
      onPanStart: (_) => _isDrawing = true,
      onPanEnd: (_) => _isDrawing = false,
      child: Container(
        key: _padKey,
        child: signature_pad.Signature(
          controller: _signatureController,
          backgroundColor: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  // Méthodes pour interagir avec le pad
  void clear() {
    _signatureController.clear();
    ref.read(currentStrokesProvider.notifier).state = [];
  }

  bool get isEmpty => _signatureController.isEmpty;

  Future<List<Stroke>> getStrokes() async {
    // Convertir les points de signature en entités Stroke
    final points = _signatureController.points;

    if (points.isEmpty) return [];

    // Obtenir la taille réelle du pad pour la normalisation
    final renderBox = _padKey.currentContext?.findRenderObject() as RenderBox?;
    final padWidth = renderBox?.size.width ?? 400.0; // Fallback si non disponible
    final padHeight = renderBox?.size.height ?? 400.0; // Carré maintenant

    // Debug logging
    print('📐 Pad size: ${padWidth}x${padHeight}, Points count: ${points.length}');
    print('📐 Pad aspect ratio: ${padWidth/padHeight} (target: 1.0)');

    final strokes = <Stroke>[];
    final strokePoints = <Point>[];
    DateTime? lastPointTime;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Normaliser : x/y en 0-1 basé sur la taille réelle du pad
      final normalizedX = point.offset.dx / padWidth;
      final normalizedY = point.offset.dy / padHeight;

      strokePoints.add(Point(
        x: normalizedX,
        y: normalizedY,
        timestamp: DateTime.now(), // Simplification
      ));

      // Créer un nouveau trait si :
      // 1. C'est le dernier point
      // 2. OU le délai depuis le dernier point est trop long (> 500ms = nouveau trait)
      bool shouldCreateNewStroke = (i == points.length - 1);

      if (!shouldCreateNewStroke && lastPointTime != null) {
        final timeDiff = DateTime.now().difference(lastPointTime!).inMilliseconds;
        // Si plus de 500ms entre deux points, c'est probablement un nouveau trait
        shouldCreateNewStroke = timeDiff > 500;
      }

      lastPointTime = DateTime.now();

      if (shouldCreateNewStroke) {
        if (strokePoints.isNotEmpty) {
          print('✏️ New stroke created with ${strokePoints.length} points');
          strokes.add(Stroke(
            points: strokePoints.toList(),
            settings: StrokeSettings(),
          ));
          strokePoints.clear();
        }
      }
    }

    print('📊 Total strokes created: ${strokes.length}');

    return strokes;
  }
}
