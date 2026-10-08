import 'package:equatable/equatable.dart';

class HistoryItemEntity extends Equatable {
  final String id;
  final String? originalLocalPath;
  final String previewRemoteUrl;
  final String? cleanRemoteUrl;
  final int width;
  final int height;
  final DateTime createdAt;
  final bool isPro;
  final bool isSynced;

  const HistoryItemEntity({
    required this.id,
    this.originalLocalPath,
    required this.previewRemoteUrl,
    this.cleanRemoteUrl,
    required this.width,
    required this.height,
    required this.createdAt,
    this.isPro = false,
    this.isSynced = false,
  });

  String get effectiveImageUrl => cleanRemoteUrl ?? previewRemoteUrl;

  @override
  List<Object?> get props => [
        id,
        originalLocalPath,
        previewRemoteUrl,
        cleanRemoteUrl,
        width,
        height,
        createdAt,
        isPro,
        isSynced,
      ];
}
