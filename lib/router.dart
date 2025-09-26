import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daka_doc/features/pdf_editor/presentation/pages/pdf_editor_page.dart';
import 'package:daka_doc/features/signature/presentation/pages/signature_page.dart';
import 'package:daka_doc/features/video_converter/presentation/pages/video_converter_page.dart';

/// Configuration du système de navigation
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pdf-editor',
        builder: (context, state) => const PdfEditorPage(),
      ),
      GoRoute(
        path: '/signature',
        builder: (context, state) => const SignaturePage(),
      ),
      GoRoute(
        path: '/video-converter',
        builder: (context, state) => const VideoConverterPage(),
      ),
    ],
  );
});

/// Page d'accueil avec navigation principale
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daka Doc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const HomeContent(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de Daka Doc'),
        content: const Text(
          'Daka Doc est une application professionnelle de gestion de médias et documents. '
          'Elle vous permet de modifier des PDFs, créer des signatures numériques '
          'et convertir des vidéos de manière simple et intuitive.',
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
}

/// Contenu principal de la page d'accueil
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de bienvenue
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Text(
              'Bienvenue dans Daka Doc',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Text(
              'Gérez vos documents et médias en toute simplicité',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Cartes des fonctionnalités
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
              children: [
                _FeatureCard(
                  title: 'PDF Editor',
                  subtitle: 'Modifier et annoter vos PDFs',
                  icon: Icons.picture_as_pdf,
                  color: Colors.red.shade600,
                  onTap: () => context.push('/pdf-editor'),
                ),
                _FeatureCard(
                  title: 'Signature',
                  subtitle: 'Créer votre signature numérique',
                  icon: Icons.edit,
                  color: Colors.blue.shade600,
                  onTap: () => context.push('/signature'),
                ),
                _FeatureCard(
                  title: 'Video Converter',
                  subtitle: 'Convertir vos vidéos',
                  icon: Icons.video_file,
                  color: Colors.purple.shade600,
                  onTap: () => context.push('/video-converter'),
                ),
                _FeatureCard(
                  title: 'Gestion Fichiers',
                  subtitle: 'Organiser vos documents',
                  icon: Icons.folder,
                  color: Colors.green.shade600,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

/// Carte de fonctionnalité
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size:30,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drawer de navigation latéral
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.document_scanner,
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  'Daka Doc',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestion de médias',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF Editor'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/pdf-editor');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Signature'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/signature');
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_file),
            title: const Text('Video Converter'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/video-converter');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Implémenter les paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            onTap: () {
              Navigator.of(context).pop();
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de Daka Doc'),
        content: const Text(
          'Daka Doc est une application professionnelle de gestion de médias et documents. '
          'Elle vous permet de modifier des PDFs, créer des signatures numériques '
          'et convertir des vidéos de manière simple et intuitive.',
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
}
