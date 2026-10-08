import 'package:equatable/equatable.dart';

abstract class MonetizationEvent extends Equatable {
  const MonetizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadOfferingsEvent extends MonetizationEvent {
  const LoadOfferingsEvent();
}

class SelectPackageEvent extends MonetizationEvent {
  final String packageId;

  const SelectPackageEvent(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

class PurchaseSelectedPackageEvent extends MonetizationEvent {
  final String packageId;

  const PurchaseSelectedPackageEvent(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

class RestorePurchasesEvent extends MonetizationEvent {
  const RestorePurchasesEvent();
}

class CheckProStatusEvent extends MonetizationEvent {
  const CheckProStatusEvent();
}
