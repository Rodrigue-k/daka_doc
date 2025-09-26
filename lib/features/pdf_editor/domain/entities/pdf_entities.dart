import 'package:equatable/equatable.dart';

/// Entité représentant un document PDF
class PdfDocumentEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final int pageCount;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const PdfDocumentEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.pageCount,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  List<Object?> get props => [id, name, path, pageCount, createdAt, modifiedAt];

  PdfDocumentEntity copyWith({
    String? id,
    String? name,
    String? path,
    int? pageCount,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return PdfDocumentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}

/// Entité représentant une annotation sur un PDF
abstract class PdfAnnotationEntity extends Equatable {
  final String id;
  final int pageNumber;
  final AnnotationType type;
  final DateTime createdAt;

  const PdfAnnotationEntity({
    required this.id,
    required this.pageNumber,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, pageNumber, type, createdAt];
}

/// Types d'annotations supportées
enum AnnotationType {
  text,
  image,
  signature,
  underline,
  strikethrough,
}

/// Annotation texte
class TextAnnotation extends PdfAnnotationEntity {
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final String fontColor;
  final String fontFamily;

  const TextAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.text,
    required this.x,
    required this.y,
    this.fontSize = 12.0,
    this.fontColor = '#000000',
    this.fontFamily = 'Helvetica',
  }) : super(
    type: AnnotationType.text,
  );

  @override
  List<Object?> get props => [...super.props, text, x, y, fontSize, fontColor, fontFamily];

  TextAnnotation copyWith({
    String? id,
    int? pageNumber,
    DateTime? createdAt,
    String? text,
    double? x,
    double? y,
    double? fontSize,
    String? fontColor,
    String? fontFamily,
  }) {
    return TextAnnotation(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

/// Annotation image
class ImageAnnotation extends PdfAnnotationEntity {
  final String imagePath;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;

  const ImageAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.imagePath,
    required this.x,
    required this.y,
    this.width = 100.0,
    this.height = 100.0,
    this.rotation = 0.0,
  }) : super(
    type: AnnotationType.image,
  );

  @override
  List<Object?> get props => [...super.props, imagePath, x, y, width, height, rotation];

  ImageAnnotation copyWith({
    String? id,
    int? pageNumber,
    DateTime? createdAt,
    String? imagePath,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
  }) {
    return ImageAnnotation(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// Annotation signature
class SignatureAnnotation extends PdfAnnotationEntity {
  final String signaturePath;
  final double x;
  final double y;
  final double width;
  final double height;

  const SignatureAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.signaturePath,
    required this.x,
    required this.y,
    this.width = 150.0,
    this.height = 75.0,
  }) : super(
    type: AnnotationType.signature,
  );

  @override
  List<Object?> get props => [...super.props, signaturePath, x, y, width, height];

  SignatureAnnotation copyWith({
    String? id,
    int? pageNumber,
    DateTime? createdAt,
    String? signaturePath,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return SignatureAnnotation(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      signaturePath: signaturePath ?? this.signaturePath,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
