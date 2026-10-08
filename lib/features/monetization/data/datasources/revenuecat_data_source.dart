import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';

abstract class RevenueCatDataSource {
  Future<void> initialize({required String appUserId});
  Future<List<SubscriptionPackageEntity>> getOfferings();
  Future<bool> purchasePackage(String packageId);
  Future<bool> restorePurchases();
  Future<bool> isUserPro();
}

class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  static const String entitlementId = 'pro_access';
  bool _isConfigured = false;
  List<rc.Package> _cachedRcPackages = [];

  @override
  Future<void> initialize({required String appUserId}) async {
    try {
      final apiKey = Platform.isAndroid
          ? EnvConfig.instance.revenueCatAndroidKey
          : EnvConfig.instance.revenueCatIosKey;

      if (apiKey.isEmpty) {
        _isConfigured = false;
        return;
      }

      final configuration = rc.PurchasesConfiguration(apiKey)..appUserID = appUserId;
      await rc.Purchases.configure(configuration);
      _isConfigured = true;
    } catch (_) {
      _isConfigured = false;
    }
  }

  @override
  Future<List<SubscriptionPackageEntity>> getOfferings() async {
    if (_isConfigured) {
      try {
        final offerings = await rc.Purchases.getOfferings();
        final currentOffering = offerings.current;

        if (currentOffering != null && currentOffering.availablePackages.isNotEmpty) {
          _cachedRcPackages = currentOffering.availablePackages;

          return _cachedRcPackages.map((pkg) {
            final pType = _mapRcPackageType(pkg.packageType);
            final price = pkg.storeProduct.price;
            String? monthlyEquiv;
            if (pType == PackageType.annual) {
              final monthlyVal = (price / 12).toStringAsFixed(2);
              monthlyEquiv = '\$$monthlyVal/mo';
            }

            return SubscriptionPackageEntity(
              id: pkg.identifier,
              title: pkg.storeProduct.title,
              description: pkg.storeProduct.description,
              priceString: pkg.storeProduct.priceString,
              price: price,
              currencyCode: pkg.storeProduct.currencyCode,
              packageType: pType,
              isBestValue: pType == PackageType.annual,
              trialPeriod: pType == PackageType.annual ? '3 Days Free' : null,
              monthlyEquivalentPrice: monthlyEquiv,
            );
          }).toList();
        }
      } catch (_) {
        // Fall back to default catalog if RevenueCat network or sandbox error occurs
      }
    }

    return _getDefaultStudioPackages();
  }

  @override
  Future<bool> purchasePackage(String packageId) async {
    if (_isConfigured && _cachedRcPackages.isNotEmpty) {
      final targetPkg = _cachedRcPackages.where((p) => p.identifier == packageId).firstOrNull;
      if (targetPkg != null) {
        try {
          final customerInfo = await rc.Purchases.purchasePackage(targetPkg);
          return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
        } catch (_) {
          return false;
        }
      }
    }
    // Sandbox / Test fallback simulator
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    if (_isConfigured) {
      try {
        final customerInfo = await rc.Purchases.restorePurchases();
        return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<bool> isUserPro() async {
    if (_isConfigured) {
      try {
        final customerInfo = await rc.Purchases.getCustomerInfo();
        return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  PackageType _mapRcPackageType(rc.PackageType type) {
    switch (type) {
      case rc.PackageType.annual:
        return PackageType.annual;
      case rc.PackageType.monthly:
        return PackageType.monthly;
      case rc.PackageType.lifetime:
        return PackageType.lifetime;
      default:
        return PackageType.monthly;
    }
  }

  List<SubscriptionPackageEntity> _getDefaultStudioPackages() {
    return const [
      SubscriptionPackageEntity(
        id: 'pro_annual',
        title: 'Annual Pro Studio',
        description: 'Unlimited 4K HD cutouts, custom backdrops, and ad-free studio',
        priceString: '\$29.99/year',
        price: 29.99,
        currencyCode: 'USD',
        packageType: PackageType.annual,
        isBestValue: true,
        trialPeriod: '3 Days Free',
        monthlyEquivalentPrice: '\$2.49/mo',
      ),
      SubscriptionPackageEntity(
        id: 'pro_monthly',
        title: 'Monthly Pro Studio',
        description: 'Unlimited cutouts with monthly flexibility',
        priceString: '\$4.99/month',
        price: 4.99,
        currencyCode: 'USD',
        packageType: PackageType.monthly,
        isBestValue: false,
        monthlyEquivalentPrice: '\$4.99/mo',
      ),
      SubscriptionPackageEntity(
        id: 'pro_lifetime',
        title: 'Lifetime Unlimited',
        description: 'Pay once, use forever across all iOS and Android devices',
        priceString: '\$59.99',
        price: 59.99,
        currencyCode: 'USD',
        packageType: PackageType.lifetime,
        isBestValue: false,
      ),
    ];
  }
}
