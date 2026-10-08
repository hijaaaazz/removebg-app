import 'package:equatable/equatable.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';

abstract class MonetizationState extends Equatable {
  const MonetizationState();

  @override
  List<Object?> get props => [];
}

class MonetizationInitialState extends MonetizationState {
  const MonetizationInitialState();
}

class MonetizationLoadingState extends MonetizationState {
  const MonetizationLoadingState();
}

class MonetizationLoadedState extends MonetizationState {
  final List<SubscriptionPackageEntity> packages;
  final String selectedPackageId;
  final bool isPro;

  const MonetizationLoadedState({
    required this.packages,
    required this.selectedPackageId,
    required this.isPro,
  });

  SubscriptionPackageEntity? get selectedPackage =>
      packages.where((p) => p.id == selectedPackageId).firstOrNull;

  @override
  List<Object?> get props => [packages, selectedPackageId, isPro];
}

class MonetizationPurchasingState extends MonetizationState {
  final List<SubscriptionPackageEntity> packages;
  final String selectedPackageId;

  const MonetizationPurchasingState({
    required this.packages,
    required this.selectedPackageId,
  });

  @override
  List<Object?> get props => [packages, selectedPackageId];
}

class MonetizationSuccessState extends MonetizationState {
  final String message;
  final bool isPro;

  const MonetizationSuccessState({
    required this.message,
    required this.isPro,
  });

  @override
  List<Object?> get props => [message, isPro];
}

class MonetizationErrorState extends MonetizationState {
  final String message;
  final List<SubscriptionPackageEntity>? packages;
  final String? selectedPackageId;

  const MonetizationErrorState({
    required this.message,
    this.packages,
    this.selectedPackageId,
  });

  @override
  List<Object?> get props => [message, packages, selectedPackageId];
}
