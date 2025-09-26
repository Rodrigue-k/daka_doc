import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entité représentant une signature numérique
class SignatureEntity extends Equatable {
  final String id;
  final String name;
  final List<Stroke> strokes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final SignatureSettings settings;

  const SignatureEntity({
    required this.id,
    required this.name,
    required this.strokes,
    required this.createdAt,
    required this.modifiedAt,
    required this.settings,
  });

  @override
  List<Object?> get props => [id, name, strokes, createdAt, modifiedAt, settings];

  SignatureEntity copyWith({
    String? id,
    String? name,
    List<Stroke>? strokes,
    DateTime? createdAt,
    DateTime? modifiedAt,
    SignatureSettings? settings,
  }) {
    return SignatureEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      strokes: strokes ?? this.strokes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      settings: settings ?? this.settings,
    );
  }

  /// Vérifie si la signature est vide
  bool get isEmpty => strokes.isEmpty;

  /// Obtient le nombre de traits
  int get strokeCount => strokes.length;
}

/// Représente un trait de signature
class Stroke extends Equatable {
  final List<Point> points;
  final StrokeSettings settings;

  const Stroke({
    required this.points,
    required this.settings,
  });

  @override
  List<Object?> get props => [points, settings];

  Stroke copyWith({
    List<Point>? points,
    StrokeSettings? settings,
  }) {
    return Stroke(
      points: points ?? this.points,
      settings: settings ?? this.settings,
    );
  }
}

/// Représente un point dans un trait
class Point extends Equatable {
  final double x;
  final double y;
  final DateTime timestamp;

  const Point({
    required this.x,
    required this.y,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [x, y, timestamp];
}

/// Paramètres de configuration d'une signature
class SignatureSettings extends Equatable {
  final double width;
  final double height;
  final Color backgroundColor;
  final bool transparentBackground;
  final StrokeSettings defaultStrokeSettings;

  const SignatureSettings({
    this.width = 400.0,
    this.height = 400.0, // Carré pour éviter la distorsion
    this.backgroundColor = Colors.white,
    this.transparentBackground = false,
    this.defaultStrokeSettings = const StrokeSettings(),
  });

  @override
  List<Object?> get props => [
    width,
    height,
    backgroundColor,
    transparentBackground,
    defaultStrokeSettings,
  ];

  SignatureSettings copyWith({
    double? width,
    double? height,
    Color? backgroundColor,
    bool? transparentBackground,
    StrokeSettings? defaultStrokeSettings,
  }) {
    return SignatureSettings(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      transparentBackground: transparentBackground ?? this.transparentBackground,
      defaultStrokeSettings: defaultStrokeSettings ?? this.defaultStrokeSettings,
    );
  }
}

/// Paramètres d'un trait
class StrokeSettings extends Equatable {
  final double width;
  final Color color;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;

  const StrokeSettings({
    this.width = 3.0,
    this.color = Colors.black,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
  });

  @override
  List<Object?> get props => [width, color, strokeCap, strokeJoin];

  StrokeSettings copyWith({
    double? width,
    Color? color,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
  }) {
    return StrokeSettings(
      width: width ?? this.width,
      color: color ?? this.color,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
    );
  }
}
