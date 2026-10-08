import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';
import 'package:removeit_app/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:removeit_app/features/monetization/domain/usecases/check_pro_status_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/get_offerings_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/purchase_package_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/restore_purchases_usecase.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_event.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_state.dart';

class MockMonetizationRepository implements MonetizationRepository {
  Either<Failure, List<SubscriptionPackageEntity>>? offeringsResult;
  Either<Failure, bool>? purchaseResult;
  Either<Failure, bool>? restoreResult;
  Either<Failure, bool>? proStatusResult;

  @override
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getOfferings() async {
    return offeringsResult ??
        const Right([
          SubscriptionPackageEntity(
            id: 'pro_annual',
            title: 'Annual Pro',
            description: 'Full studio access',
            priceString: '\$29.99/year',
            price: 29.99,
            currencyCode: 'USD',
            packageType: PackageType.annual,
            isBestValue: true,
          ),
          SubscriptionPackageEntity(
            id: 'pro_monthly',
            title: 'Monthly Pro',
            description: 'Monthly studio access',
            priceString: '\$4.99/month',
            price: 4.99,
            currencyCode: 'USD',
            packageType: PackageType.monthly,
            isBestValue: false,
          ),
        ]);
  }

  @override
  Future<Either<Failure, bool>> purchasePackage(String packageId) async {
    return purchaseResult ?? const Right(true);
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    return restoreResult ?? const Right(true);
  }

  @override
  Future<Either<Failure, bool>> checkProStatus() async {
    return proStatusResult ?? const Right(false);
  }
}

void main() {
  late MockMonetizationRepository repository;
  late GetOfferingsUseCase getOfferingsUseCase;
  late PurchasePackageUseCase purchasePackageUseCase;
  late RestorePurchasesUseCase restorePurchasesUseCase;
  late CheckProStatusUseCase checkProStatusUseCase;
  late MonetizationBloc bloc;

  setUp(() {
    repository = MockMonetizationRepository();
    getOfferingsUseCase = GetOfferingsUseCase(repository);
    purchasePackageUseCase = PurchasePackageUseCase(repository);
    restorePurchasesUseCase = RestorePurchasesUseCase(repository);
    checkProStatusUseCase = CheckProStatusUseCase(repository);

    bloc = MonetizationBloc(
      getOfferingsUseCase: getOfferingsUseCase,
      purchasePackageUseCase: purchasePackageUseCase,
      restorePurchasesUseCase: restorePurchasesUseCase,
      checkProStatusUseCase: checkProStatusUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is MonetizationInitialState', () {
    expect(bloc.state, equals(const MonetizationInitialState()));
  });

  test('emits [MonetizationLoadingState, MonetizationLoadedState] when offerings load successfully', () async {
    const testPackages = [
      SubscriptionPackageEntity(
        id: 'pro_annual',
        title: 'Annual Pro',
        description: 'Full studio access',
        priceString: '\$29.99/year',
        price: 29.99,
        currencyCode: 'USD',
        packageType: PackageType.annual,
        isBestValue: true,
      ),
      SubscriptionPackageEntity(
        id: 'pro_monthly',
        title: 'Monthly Pro',
        description: 'Monthly studio access',
        priceString: '\$4.99/month',
        price: 4.99,
        currencyCode: 'USD',
        packageType: PackageType.monthly,
        isBestValue: false,
      ),
    ];

    final expectedStates = [
      const MonetizationLoadingState(),
      const MonetizationLoadedState(
        packages: testPackages,
        selectedPackageId: 'pro_annual',
        isPro: false,
      ),
    ];

    final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const LoadOfferingsEvent());
    await expectation;
  });

  test('updates selectedPackageId when SelectPackageEvent is added', () async {
    bloc.add(const LoadOfferingsEvent());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      bloc.stream,
      emits(predicate<MonetizationState>((state) {
        return state is MonetizationLoadedState && state.selectedPackageId == 'pro_monthly';
      })),
    );

    bloc.add(const SelectPackageEvent('pro_monthly'));
  });

  test('restores purchases successfully', () async {
    repository.restoreResult = const Right(true);

    final expectedStates = [
      const MonetizationLoadingState(),
      const MonetizationSuccessState(
        message: 'Purchases successfully restored!',
        isPro: true,
      ),
    ];

    final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const RestorePurchasesEvent());
    await expectation;
  });
}
