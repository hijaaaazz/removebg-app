import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';

abstract class RevenueCatDataSource {
  Future<void> initialize({String? appUserId});
  Future<void> logIn(String appUserId);
  Future<void> logOut();
  Future<List<SubscriptionPackageEntity>> getOfferings();
  Future<bool> purchasePackage(String packageId);
  Future<bool> restorePurchases();
  Future<bool> isUserPro();
}

class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  static const String entitlementId = 'removebg_free_pro';
  static const String fallbackEntitlementId = 'pro_access';

  bool _isConfigured = false;
  List<rc.Package> _cachedRcPackages = [];

  RevenueCatDataSourceImpl();

  @override
  Future<void> initialize({String? appUserId}) async {
    try {
      final apiKey = Platform.isAndroid
          ? EnvConfig.instance.revenueCatAndroidKey
          : EnvConfig.instance.revenueCatIosKey;

      if (apiKey.isEmpty || apiKey.contains('sample_key')) {
        debugPrint('[RevenueCat] No valid API key configured.');
        _isConfigured = false;
        return;
      }

      final configuration = rc.PurchasesConfiguration(apiKey);
      if (appUserId != null && appUserId.isNotEmpty) {
        configuration.appUserID = appUserId;
      }
      await rc.Purchases.configure(configuration);
      _isConfigured = true;
      debugPrint('[RevenueCat] SDK successfully initialized with backend.');
    } catch (e) {
      debugPrint('[RevenueCat] Initialization error: $e');
      _isConfigured = false;
    }
  }

  @override
  Future<void> logIn(String appUserId) async {
    if (_isConfigured) {
      try {
        await rc.Purchases.logIn(appUserId);
        debugPrint('[RevenueCat] Logged in with appUserId: $appUserId');
      } catch (e) {
        debugPrint('[RevenueCat] LogIn error: $e');
      }
    }
  }

  @override
  Future<void> logOut() async {
    if (_isConfigured) {
      try {
        await rc.Purchases.logOut();
        debugPrint('[RevenueCat] Logged out user.');
      } catch (e) {
        debugPrint('[RevenueCat] LogOut error: $e');
      }
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
              trialPeriod: pType == PackageType.annual ? '3-Day Free Trial' : null,
              monthlyEquivalentPrice: monthlyEquiv,
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('[RevenueCat] Fetch offerings error: $e');
      }
    }

    // No local mock catalog: strictly return empty if remote store has no products
    return const [];
  }

  @override
  Future<bool> purchasePackage(String packageId) async {
    if (_isConfigured && _cachedRcPackages.isNotEmpty) {
      final targetPkg = _cachedRcPackages.where((p) => p.identifier == packageId).firstOrNull;
      if (targetPkg != null) {
        try {
          final customerInfo = await rc.Purchases.purchasePackage(targetPkg);
          return _hasActiveEntitlement(customerInfo);
        } catch (e) {
          debugPrint('[RevenueCat] Purchase failed or cancelled: $e');
          return false;
        }
      }
    }
    return false;
  }

  @override
  Future<bool> restorePurchases() async {
    if (_isConfigured) {
      try {
        final customerInfo = await rc.Purchases.restorePurchases();
        return _hasActiveEntitlement(customerInfo);
      } catch (e) {
        debugPrint('[RevenueCat] Restore failed: $e');
        return false;
      }
    }
    return false;
  }

  @override
  Future<bool> isUserPro() async {
    if (_isConfigured) {
      try {
        final customerInfo = await rc.Purchases.getCustomerInfo();
        return _hasActiveEntitlement(customerInfo);
      } catch (e) {
        debugPrint('[RevenueCat] Error checking CustomerInfo: $e');
        return false;
      }
    }
    return false;
  }

  bool _hasActiveEntitlement(rc.CustomerInfo customerInfo) {
    return (customerInfo.entitlements.all[entitlementId]?.isActive ?? false) ||
        (customerInfo.entitlements.all[fallbackEntitlementId]?.isActive ?? false) ||
        customerInfo.entitlements.active.isNotEmpty;
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
}
