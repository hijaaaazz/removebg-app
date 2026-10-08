import 'package:equatable/equatable.dart';

enum PackageType { monthly, annual, lifetime }

class SubscriptionPackageEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String priceString;
  final double price;
  final String currencyCode;
  final PackageType packageType;
  final bool isBestValue;
  final String? trialPeriod;
  final String? monthlyEquivalentPrice;

  const SubscriptionPackageEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    required this.packageType,
    this.isBestValue = false,
    this.trialPeriod,
    this.monthlyEquivalentPrice,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priceString,
        price,
        currencyCode,
        packageType,
        isBestValue,
        trialPeriod,
        monthlyEquivalentPrice,
      ];
}
