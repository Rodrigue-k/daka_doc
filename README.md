# Daka Doc

Une application Flutter professionnelle de gestion de médias et documents, conçue pour être simple et intuitive même pour les utilisateurs peu familiarisés avec les outils numériques.

## Fonctionnalités

### PDF Editor
- **Modification de PDFs** : Ouvrez et modifiez vos documents PDF existants
- **Annotations** : Ajoutez du texte, des images et des signatures numériques
- **Outils d'édition** : Fusionnez ou divisez des PDFs selon vos besoins
- **Interface intuitive** : Outils visuels pour une utilisation facile

### Signature numérique
- **Création de signature** : Dessinez votre signature avec le doigt ou la souris
- **Export transparent** : Exportez votre signature en PNG avec fond transparent
- **Réutilisation** : Utilisez votre signature sur tous vos documents et PDFs
- **Gestion** : Sauvegardez et organisez plusieurs signatures

### Video Converter
- **Conversion vidéo** : Convertissez vos vidéos entre différents formats (WebM → MP4, etc.)
- **Qualité réglable** : Choisissez la qualité de sortie selon vos besoins
- **Conversion rapide** : Traitement optimisé sans perte de qualité
- **Formats supportés** : MP4, AVI, MOV, MKV, WebM, FLV, WMV, M4V

### Gestion de fichiers
- **Sélection intuitive** : Utilisez l'explorateur de fichiers intégré
- **Sauvegarde locale** : Tous vos fichiers sont stockés localement
- **Organisation** : Structure claire pour vos documents et médias

## Design & UX

### Principes de design
- **Minimaliste et professionnel** : Interface épurée sans distractions
- **Couleurs sobres** : Palette élégante de gris, blanc et bleu discret
- **Typographie lisible** : Polices adaptatives pour une lecture optimale
- **Navigation claire** : Menu latéral et navigation intuitive

### Expérience utilisateur
- **Feedback immédiat** : Indicateurs de chargement et messages de confirmation
- **Barres de progression** : Visualisation du progrès pour les conversions vidéo
- **Messages d'erreur** : Alertes claires et constructives
- **Design adaptatif** : Interface optimisée pour tous les âges

## Architecture & Technologie

### Architecture Clean
lib/
├── core/                    # Composants partagés
│   ├── theme/              # Thème et couleurs
│   ├── utils/              # Utilitaires et helpers
│   └── widgets/            # Widgets réutilisables
├── features/               # Fonctionnalités modulaires
│   ├── pdf_editor/         # Éditeur PDF
│   ├── signature/          # Signature numérique
│   └── video_converter/    # Convertisseur vidéo
├── main.dart              # Point d'entrée
└── router.dart            # Configuration de navigation

### Technologies utilisées
- **Flutter 3.9+** : Framework moderne pour applications multiplateformes
- **Riverpod** : Gestion d'état simple et réactive
- **Go Router** : Navigation déclarative et typée
- **Syncfusion PDF** : Manipulation avancée de PDFs
- **Signature** : Capture de signature tactile
- **File Picker** : Sélection de fichiers intuitive
- **Path Provider** : Gestion des chemins de fichiers
- **FFmpeg Kit** : Conversion vidéo professionnelle

## Installation

### Prérequis
- Flutter SDK 3.9.2 ou supérieur
- Android Studio / VS Code avec extensions Flutter
- Git

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-repo/daka-doc.git
   cd daka-doc
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configuration**
   ```bash
   # Pour Android
   flutter create --org com.koudatek --project-name daka_doc .

   # Installer les packages
   flutter pub add flutter_riverpod syncfusion_flutter_pdf signature file_picker path_provider ffmpeg_kit_flutter flutter_hooks
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## Utilisation

### Navigation
- **Menu latéral** : Accédez aux différentes fonctionnalités
- **Page d'accueil** : Vue d'ensemble avec accès rapide aux outils
- **Navigation fluide** : Transitions animées entre les écrans

### PDF Editor
1. Ouvrez un PDF depuis le menu ou la page d accueil
2. Utilisez la barre d'outils pour ajouter des annotations
3. Sauvegardez ou exportez votre document modifié

### Signature numérique
1. Créez une nouvelle signature ou chargez une existante
2. Dessinez votre signature avec précision
3. Exportez en PNG transparent pour utilisation ultérieure

### Video Converter
1. Sélectionnez une vidéo à convertir
2. Choisissez le format de sortie et la qualité
3. Lancez la conversion et suivez la progression

## Développement

### Structure des features
Chaque fonctionnalité suit l'architecture Clean Architecture :
- **Domain** : Entités et cas d'usage métier
- **Data** : Implémentations des repositories
- **Presentation** : Interface utilisateur et gestion d'état

### Tests
```bash
# Lancer les tests
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests de widgets
flutter test --widget
```

### Build
```bash
# Build Android
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web
```

## Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Consultez la documentation
- Contactez l'équipe de développement