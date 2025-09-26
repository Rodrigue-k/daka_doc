import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:daka_doc/features/pdf_editor/domain/entities/pdf_entities.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  final PdfDocumentEntity document;

  const PdfViewerWidget({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  late PdfViewerController _pdfViewerController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre d'informations du document
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.document.pageCount} pages • Modifié le ${_formatDate(widget.document.modifiedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Contrôles de zoom
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () => _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.25).clamp(0.5, 3.0),
                tooltip: 'Zoom arrière',
              ),
              Text(
                '${(_pdfViewerController.zoomLevel * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () => _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.25).clamp(0.5, 3.0),
                tooltip: 'Zoom avant',
              ),
            ],
          ),
        ),

        // Visionneuse PDF
        Expanded(
          child: SfPdfViewer.file(
            File(widget.document.path),
            controller: _pdfViewerController,
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
            onDocumentLoaded: (details) {
              setState(() {
                _currentPage = 1;
              });
            },
          ),
        ),

        // Barre de navigation des pages
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: () => _pdfViewerController.firstPage(),
                tooltip: 'Première page',
              ),
              IconButton(
                icon: const Icon(Icons.navigate_before),
                onPressed: () => _pdfViewerController.previousPage(),
                tooltip: 'Page précédente',
              ),
              Expanded(
                child: Text(
                  'Page $_currentPage / ${widget.document.pageCount}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: () => _pdfViewerController.nextPage(),
                tooltip: 'Page suivante',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: () => _pdfViewerController.lastPage(),
                tooltip: 'Dernière page',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
