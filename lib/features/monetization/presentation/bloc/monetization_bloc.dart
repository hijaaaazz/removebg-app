import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/features/monetization/domain/usecases/check_pro_status_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/get_offerings_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/purchase_package_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/restore_purchases_usecase.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_event.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_state.dart';

class MonetizationBloc extends Bloc<MonetizationEvent, MonetizationState> {
  final GetOfferingsUseCase getOfferingsUseCase;
  final PurchasePackageUseCase purchasePackageUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final CheckProStatusUseCase checkProStatusUseCase;

  MonetizationBloc({
    required this.getOfferingsUseCase,
    required this.purchasePackageUseCase,
    required this.restorePurchasesUseCase,
    required this.checkProStatusUseCase,
  }) : super(const MonetizationInitialState()) {
    on<LoadOfferingsEvent>(_onLoadOfferings);
    on<SelectPackageEvent>(_onSelectPackage);
    on<PurchaseSelectedPackageEvent>(_onPurchaseSelectedPackage);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<CheckProStatusEvent>(_onCheckProStatus);
  }

  Future<void> _onLoadOfferings(
    LoadOfferingsEvent event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(const MonetizationLoadingState());

    final offeringsResult = await getOfferingsUseCase();
    final proStatusResult = await checkProStatusUseCase();

    final isPro = proStatusResult.getOrElse((_) => false);

    offeringsResult.fold(
      (failure) => emit(MonetizationErrorState(message: failure.message)),
      (packages) {
        final bestValuePkg = packages.where((p) => p.isBestValue).firstOrNull;
        final defaultSelectedId = bestValuePkg?.id ?? (packages.isNotEmpty ? packages.first.id : '');

        emit(MonetizationLoadedState(
          packages: packages,
          selectedPackageId: defaultSelectedId,
          isPro: isPro,
        ));
      },
    );
  }

  void _onSelectPackage(
    SelectPackageEvent event,
    Emitter<MonetizationState> emit,
  ) {
    if (state is MonetizationLoadedState) {
      final current = state as MonetizationLoadedState;
      emit(MonetizationLoadedState(
        packages: current.packages,
        selectedPackageId: event.packageId,
        isPro: current.isPro,
      ));
    }
  }

  Future<void> _onPurchaseSelectedPackage(
    PurchaseSelectedPackageEvent event,
    Emitter<MonetizationState> emit,
  ) async {
    if (state is MonetizationLoadedState) {
      final current = state as MonetizationLoadedState;
      emit(MonetizationPurchasingState(
        packages: current.packages,
        selectedPackageId: event.packageId,
      ));

      final result = await purchasePackageUseCase(event.packageId);

      result.fold(
        (failure) => emit(MonetizationErrorState(
          message: failure.message,
          packages: current.packages,
          selectedPackageId: event.packageId,
        )),
        (success) {
          if (success) {
            emit(const MonetizationSuccessState(
              message: '🎉 Welcome to RemoveIt Pro!',
              isPro: true,
            ));
          } else {
            emit(MonetizationErrorState(
              message: 'Purchase was cancelled or incomplete.',
              packages: current.packages,
              selectedPackageId: event.packageId,
            ));
          }
        },
      );
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<MonetizationState> emit,
  ) async {
    final prevPackages = (state is MonetizationLoadedState)
        ? (state as MonetizationLoadedState).packages
        : null;
    final prevSelectedId = (state is MonetizationLoadedState)
        ? (state as MonetizationLoadedState).selectedPackageId
        : null;

    emit(const MonetizationLoadingState());

    final result = await restorePurchasesUseCase();

    result.fold(
      (failure) => emit(MonetizationErrorState(
        message: failure.message,
        packages: prevPackages,
        selectedPackageId: prevSelectedId,
      )),
      (success) {
        if (success) {
          emit(const MonetizationSuccessState(
            message: 'Purchases successfully restored!',
            isPro: true,
          ));
        } else {
          emit(MonetizationErrorState(
            message: 'No active Pro subscription found to restore.',
            packages: prevPackages,
            selectedPackageId: prevSelectedId,
          ));
        }
      },
    );
  }

  Future<void> _onCheckProStatus(
    CheckProStatusEvent event,
    Emitter<MonetizationState> emit,
  ) async {
    final result = await checkProStatusUseCase();
    result.fold(
      (_) {},
      (isPro) {
        if (state is MonetizationLoadedState) {
          final current = state as MonetizationLoadedState;
          emit(MonetizationLoadedState(
            packages: current.packages,
            selectedPackageId: current.selectedPackageId,
            isPro: isPro,
          ));
        }
      },
    );
  }
}
