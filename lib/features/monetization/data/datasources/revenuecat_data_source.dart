import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RevenueCatDataSource {
  Future<void> initialize({String? appUserId});
  Future<List<SubscriptionPackageEntity>> getOfferings();
  Future<bool> purchasePackage(String packageId);
  Future<bool> restorePurchases();
  Future<bool> isUserPro();
  Future<void> setMockPro(bool isPro);
}

class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  static const String entitlementId = 'removebg_free_pro';
  static const String fallbackEntitlementId = 'pro_access';
  static const String _mockProKey = 'rc_mock_pro_enabled';

  final SharedPreferences sharedPreferences;
  bool _isConfigured = false;
  List<rc.Package> _cachedRcPackages = [];

  RevenueCatDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> initialize({String? appUserId}) async {
    try {
      final apiKey = Platform.isAndroid
          ? EnvConfig.instance.revenueCatAndroidKey
          : EnvConfig.instance.revenueCatIosKey;

      if (apiKey.isEmpty || apiKey.contains('sample_key')) {
        debugPrint('[RevenueCat] Placeholder key detected. Test sandbox mode active.');
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

    return _getDefaultStudioPackages();
  }

  @override
  Future<bool> purchasePackage(String packageId) async {
    if (_isConfigured && _cachedRcPackages.isNotEmpty) {
      final targetPkg = _cachedRcPackages.where((p) => p.identifier == packageId).firstOrNull;
      if (targetPkg != null) {
        try {
          final customerInfo = await rc.Purchases.purchasePackage(targetPkg);
          final active = _hasActiveEntitlement(customerInfo);
          if (active) {
            await setMockPro(true);
            return true;
          }
          return false;
        } catch (e) {
          debugPrint('[RevenueCat] Purchase failed or cancelled: $e');
          return false;
        }
      }
    }
    // Sandbox / Test fallback simulator (allows instant testing on emulator)
    await setMockPro(true);
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    if (_isConfigured) {
      try {
        final customerInfo = await rc.Purchases.restorePurchases();
        final active = _hasActiveEntitlement(customerInfo);
        if (active) {
          await setMockPro(true);
          return true;
        }
      } catch (e) {
        debugPrint('[RevenueCat] Restore failed: $e');
      }
    }
    return sharedPreferences.getBool(_mockProKey) ?? false;
  }

  @override
  Future<bool> isUserPro() async {
    // Check local test mode first (enables immediate testing)
    final isMockPro = sharedPreferences.getBool(_mockProKey) ?? false;
    if (isMockPro) {
      return true;
    }

    if (_isConfigured) {
      try {
        final customerInfo = await rc.Purchases.getCustomerInfo();
        return _hasActiveEntitlement(customerInfo);
      } catch (_) {
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

  @override
  Future<void> setMockPro(bool isPro) async {
    await sharedPreferences.setBool(_mockProKey, isPro);
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
        id: 'pro_monthly',
        title: 'Monthly Pro Studio',
        description: 'Unlimited 4K HD cutouts, custom backdrops, and ad-free studio',
        priceString: '\$4.99/mo',
        price: 4.99,
        currencyCode: 'USD',
        packageType: PackageType.monthly,
        isBestValue: false,
        monthlyEquivalentPrice: null,
      ),
      SubscriptionPackageEntity(
        id: 'pro_annual',
        title: 'Annual Pro Studio',
        description: 'Save 50% with annual billing. Full studio access & priority AI',
        priceString: '\$29.99/yr',
        price: 29.99,
        currencyCode: 'USD',
        packageType: PackageType.annual,
        isBestValue: true,
        trialPeriod: '3-Day Free Trial',
        monthlyEquivalentPrice: '\$2.49/mo',
      ),
    ];
  }
}
