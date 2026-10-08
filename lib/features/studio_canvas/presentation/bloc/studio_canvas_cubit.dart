import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/core/services/haptic_service.dart';

enum BackdropMode { transparent, solid, gradient, blur, customPhoto }

class StudioCanvasState extends Equatable {
  final BackdropMode mode;
  final Color solidColor;
  final LinearGradient gradient;
  final File? customPhotoFile;
  final double blurSigma;
  final bool isCompareActive;

  const StudioCanvasState({
    this.mode = BackdropMode.transparent,
    this.solidColor = Colors.white,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.customPhotoFile,
    this.blurSigma = 18.0,
    this.isCompareActive = true,
  });

  StudioCanvasState copyWith({
    BackdropMode? mode,
    Color? solidColor,
    LinearGradient? gradient,
    File? customPhotoFile,
    double? blurSigma,
    bool? isCompareActive,
  }) {
    return StudioCanvasState(
      mode: mode ?? this.mode,
      solidColor: solidColor ?? this.solidColor,
      gradient: gradient ?? this.gradient,
      customPhotoFile: customPhotoFile ?? this.customPhotoFile,
      blurSigma: blurSigma ?? this.blurSigma,
      isCompareActive: isCompareActive ?? this.isCompareActive,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        solidColor,
        gradient,
        customPhotoFile,
        blurSigma,
        isCompareActive,
      ];
}

class StudioCanvasCubit extends Cubit<StudioCanvasState> {
  StudioCanvasCubit() : super(const StudioCanvasState());

  void setTransparentMode() {
    HapticService.selection();
    emit(state.copyWith(mode: BackdropMode.transparent));
  }

  void setSolidColor(Color color) {
    HapticService.selection();
    emit(state.copyWith(mode: BackdropMode.solid, solidColor: color));
  }

  void setGradient(LinearGradient gradient) {
    HapticService.selection();
    emit(state.copyWith(mode: BackdropMode.gradient, gradient: gradient));
  }

  void setBlurMode([double sigma = 18.0]) {
    HapticService.selection();
    emit(state.copyWith(mode: BackdropMode.blur, blurSigma: sigma));
  }

  void setCustomPhoto(File file) {
    HapticService.selection();
    emit(state.copyWith(mode: BackdropMode.customPhoto, customPhotoFile: file));
  }

  void toggleCompare() {
    HapticService.light();
    emit(state.copyWith(isCompareActive: !state.isCompareActive));
  }
}
