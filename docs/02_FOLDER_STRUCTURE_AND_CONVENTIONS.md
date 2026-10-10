# 02. Folder Structure & Coding Conventions

## 1. Complete Directory Tree

Below is the production-grade folder structure for the **RemoveIt** Flutter mobile app. Every file and folder adheres to strict single-responsibility principles:

```
lib/
├── app.dart                                # Root MaterialApp.router setup
├── main.dart                               # Entry point, environment bootstrap
├── injection_container.dart                # Dependency Injection (get_it setup)
│
├── core/                                   # Shared code across all features
│   ├── constants/                          # Global constants
│   │   ├── api_endpoints.dart              # Backend API URLs & routes
│   │   ├── app_constants.dart              # Timeout durations, image dimension limits
│   │   └── storage_keys.dart               # Secure storage & preferences keys
│   │
│   ├── database/                           # Drift SQLite local database
│   │   ├── app_database.dart               # Drift database schema & DAOs
│   │   ├── tables/                         # Table definitions (jobs, cache, assets)
│   │   └── connection/                     # Platform-specific native connection
│   │
│   ├── error/                              # Error & exception abstractions
│   │   ├── exceptions.dart                 # Raw exceptions thrown by data sources
│   │   ├── failures.dart                   # Domain failure types (Either<Failure, T>)
│   │   └── error_handler.dart              # Centralized Dio / UI error mapping
│   │
│   ├── network/                            # HTTP & Connectivity
│   │   ├── api_client.dart                 # Dio client singleton wrapper
│   │   ├── auth_interceptor.dart           # Bearer token & queued silent refresh logic
│   │   ├── logging_interceptor.dart        # Structured request/response logging
│   │   ├── retry_interceptor.dart          # Exponential backoff for network drops
│   │   └── network_info.dart               # Connectivity status checker
│   │
│   ├── router/                             # GoRouter navigation & deep linking
│   │   ├── app_router.dart                 # GoRouter instance & route definitions
│   │   ├── route_names.dart                # Constant route path & name strings
│   │   └── route_guards.dart               # Auth & onboarding route guards
│   │
│   ├── services/                           # Hardware & OS services
│   │   ├── haptic_service.dart             # Tactile feedback triggers
│   │   ├── image_picker_service.dart       # Camera / Gallery media picker
│   │   ├── gallery_saver_service.dart      # Saving output PNG to Camera Roll
│   │   └── share_service.dart              # Native OS share sheet integration
│   │
│   ├── theme/                              # Studio Design System & UI tokens
│   │   ├── app_colors.dart                 # Obsidian, Cosmic Violet, Neon Cyan palette
│   │   ├── app_typography.dart             # Google Fonts (Outfit & Inter) styles
│   │   ├── app_spacing.dart                # Spacing & padding constants (4, 8, 12, 16, 24, 32)
│   │   ├── app_shadows.dart                # Glassmorphism & neon glow box shadows
│   │   ├── studio_theme_extension.dart     # Custom theme extension for Studio tokens
│   │   └── app_theme.dart                  # Dark & Light ThemeData configurations
│   │
│   ├── utils/                              # Helper functions & extensions
│   │   ├── context_extensions.dart         # context.colors, context.textTheme, context.l10n
│   │   ├── image_preprocessor.dart         # Isolate-based image downscaling & EXIF stripper
│   │   └── date_time_formatter.dart        # Human-readable & ISO date formatting
│   │
│   └── widgets/                            # Centralized Common Component Library
│       ├── buttons/                        # GlowButton, StudioIconButton, GlassButton
│       ├── canvas/                         # ZoomableCanvas, SplitComparisonSlider
│       ├── feedback/                       # StudioToast, LoadingOverlay, ShimmerBox
│       ├── layout/                         # StudioScaffold, StudioAppBar, StudioGlassCard
│       └── monetization/                   # AdBannerContainer, QuotaPillBadge, ProCrownBadge
│
└── features/                               # Business features (Feature-First architecture)
    │
    ├── authentication/                     # Guest mode, Google Sign-In, Apple Sign-In
    │   ├── domain/
    │   │   ├── entities/                   # UserEntity, AuthTokensEntity
    │   │   ├── repositories/               # AuthRepository interface
    │   │   └── usecases/                   # SignInWithGoogleUseCase, RefreshTokenUseCase
    │   ├── data/
    │   │   ├── models/                     # UserModel, AuthTokensModel
    │   │   ├── datasources/                # AuthRemoteDataSource, AuthLocalDataSource
    │   │   └── repositories/               # AuthRepositoryImpl
    │   └── presentation/
    │       ├── bloc/                       # AuthBloc, AuthEvent, AuthState
    │       ├── screens/                    # LoginModalSheet, AccountProfileScreen
    │       └── widgets/                    # GoogleSignInButton, AppleSignInButton
    │
    ├── image_processing/                   # Upload, AI segmentation, polling, claim
    │   ├── domain/
    │   │   ├── entities/                   # JobEntity, ImageDimensionsEntity
    │   │   ├── repositories/               # JobRepository interface
    │   │   └── usecases/                   # UploadImageUseCase, PollJobStatusUseCase, ClaimJobUseCase
    │   ├── data/
    │   │   ├── models/                     # JobModel, ImageDimensionsModel
    │   │   ├── datasources/                # JobRemoteDataSource
    │   │   └── repositories/               # JobRepositoryImpl
    │   └── presentation/
    │       ├── bloc/                       # JobProcessingBloc, JobProcessingEvent, JobProcessingState
    │       ├── screens/                    # HomeScreen (Upload Hero), ProcessingLoadingScreen
    │       └── widgets/                    # ImageDropZone, ProcessingProgressIndicator
    │
    ├── studio_canvas/                      # Interactive editor, comparison, backdrops
    │   ├── domain/
    │   │   ├── entities/                   # CanvasStateEntity, BackdropPresetEntity
    │   │   └── usecases/                   # ApplyBackdropUseCase, RenderCompositeUseCase
    │   └── presentation/
    │       ├── bloc/                       # StudioCanvasCubit, StudioCanvasState
    │       ├── screens/                    # StudioCanvasScreen, ExportPreviewScreen
    │       └── widgets/                    # SplitWipeSlider, BackdropSelectorBar, ColorPalettePicker
    │
    ├── quota/                              # Daily limit, bonus ads tracking, timer
    │   ├── domain/
    │   │   ├── entities/                   # UserQuotaEntity
    │   │   ├── repositories/               # QuotaRepository interface
    │   │   └── usecases/                   # GetUserQuotaUseCase
    │   ├── data/
    │   │   ├── models/                     # UserQuotaModel
    │   │   ├── datasources/                # QuotaRemoteDataSource
    │   │   └── repositories/               # QuotaRepositoryImpl
    │   └── presentation/
    │       ├── bloc/                       # QuotaBloc, QuotaEvent, QuotaState
    │       └── widgets/                    # QuotaCounterCard, ResetCountdownTimer
    │
    ├── monetization/                       # AdMob SSV, RevenueCat Paywall, Subscriptions
    │   ├── domain/
    │   │   ├── entities/                   # AdConfigEntity, SubscriptionTierEntity
    │   │   ├── repositories/               # MonetizationRepository interface
    │   │   └── usecases/                   # StartRewardedAdSessionUseCase, PurchaseProTierUseCase
    │   ├── data/
    │   │   ├── models/                     # AdConfigModel, RewardedSessionModel
    │   │   ├── datasources/                # AdMobDataSource, RevenueCatDataSource
    │   │   └── repositories/               # MonetizationRepositoryImpl
    │   └── presentation/
    │       ├── bloc/                       # MonetizationBloc, MonetizationEvent, MonetizationState
    │       ├── screens/                    # ProPaywallScreen, WatchAdBonusModal
    │       └── widgets/                    # ProFeatureComparisonTable, PlanSelectorCard
    │
    ├── history/                            # Saved cutouts, local SQLite sync, bulk delete
    │   ├── domain/
    │   │   ├── entities/                   # HistoryItemEntity
    │   │   ├── repositories/               # HistoryRepository interface
    │   │   └── usecases/                   # GetHistoryUseCase, DeleteHistoryItemUseCase
    │   ├── data/
    │   │   ├── models/                     # HistoryItemModel
    │   │   ├── datasources/                # HistoryLocalDataSource (Drift), HistoryRemoteDataSource
    │   │   └── repositories/               # HistoryRepositoryImpl
    │   └── presentation/
    │       ├── bloc/                       # HistoryBloc, HistoryEvent, HistoryState
    │       ├── screens/                    # HistoryScreen, HistoryDetailScreen
    │       └── widgets/                    # HistoryGridTile, BulkSelectionActionBar
    │
    └── settings/                           # Theme toggle, App info, Clear Cache, Legal
        └── presentation/
            ├── screens/                    # SettingsScreen, AboutAppScreen, PrivacyPolicyScreen
            └── widgets/                    # SettingsTile, ThemeToggleSwitch, StorageClearTile
```

---

## 2. Naming Conventions

Consistency across files, classes, and variables guarantees that any engineer can locate functionality instantly:

### 2.1 File Naming (snake_case with explicit suffixes)
| Component Type | Suffix | Example |
| :--- | :--- | :--- |
| **Domain Entity** | `_entity.dart` | `job_entity.dart`, `user_quota_entity.dart` |
| **Repository Interface** | `_repository.dart` | `job_repository.dart` |
| **Repository Implementation** | `_repository_impl.dart` | `job_repository_impl.dart` |
| **Use Case** | `_usecase.dart` | `upload_image_usecase.dart`, `claim_job_usecase.dart` |
| **Data Model (DTO)** | `_model.dart` | `job_model.dart`, `user_quota_model.dart` |
| **Data Source** | `_remote_data_source.dart` | `job_remote_data_source.dart` |
| **BLoC / Cubit** | `_bloc.dart` / `_cubit.dart` | `job_processing_bloc.dart`, `studio_canvas_cubit.dart` |
| **BLoC Event / State** | `_event.dart` / `_state.dart` | `job_processing_event.dart`, `job_processing_state.dart` |
| **Route Screen** | `_screen.dart` | `studio_canvas_screen.dart`, `home_screen.dart` |
| **Shared Widget** | `_widget.dart` | `glow_button.dart`, `comparison_slider.dart` |

### 2.2 Class & Variable Naming
- **Classes**: `PascalCase` matching file name (`UploadImageUseCase`, `JobProcessingBloc`).
- **Variables & Functions**: `camelCase` (`uploadImage`, `isQuotaExhausted`, `onSendProgress`).
- **Constants**: `lowerCamelCase` or `SCREAMING_SNAKE_CASE` for environment primitives (`apiBaseUrl`, `kDefaultConnectTimeout`).

---

## 3. Barrel Exports & Layer Encapsulation

1. **Feature Public API**: Each feature may expose a root barrel export file (e.g. `lib/features/image_processing/image_processing.dart`) exporting only the components needed externally:
   - Root BLoCs (`JobProcessingBloc`, `JobProcessingState`)
   - Entry point screens (`HomeScreen`, `ProcessingLoadingScreen`)
   - Domain entities required by other features (`JobEntity`)
2. **Never export internal data sources or models** in public barrel files. Keep the Data layer strictly encapsulated.

---

## 4. Immutability & Code Standards

- **Value Equality with `Equatable`**: All Entities, Events, States, and DTOs must extend `Equatable` and implement `List<Object?> get props`.
- **`const` Constructors Everywhere**: Use `const` constructors for all immutable classes and stateless widgets to minimize unnecessary Flutter element rebuilds.
- **Strict Typing**: Never use `dynamic`. Explicitly type all collection literals and generic parameters (`Map<String, dynamic>`, `List<JobEntity>`).

---

## 5. File Size Limits & Modular Widget Decomposition (< 300 Lines Rule)

Professional production codebases reject monolithic multi-hundred-line "god files". RemoveIt enforces a strict architectural rule:

### 5.1 The 300-Line Maximum Ceiling
- **Hard Rule**: No individual Dart source file (`*.dart`) may exceed **300 lines of code**.
- **Screens as Lean Orchestrators**: Screen files (`*_screen.dart`) must act solely as thin coordinators—binding BLoC providers, listening to high-level states, orchestrating lifecycle, and mounting layout sections.
- **Sub-Widget Extraction**: Any distinct visual block, card, modal sheet, or complex layout section must be extracted into its own focused widget under `features/<feature>/presentation/widgets/`.
- **Custom Painters & Clippers**: Custom painting algorithms (`CustomPainter`) and clipping geometries (`CustomClipper`) must reside in dedicated, testable widget files rather than being appended at the end of screen files.

### 5.2 Verification Checklist
| File Category | Target Line Count | Max Ceiling | Prohibited Patterns |
| :--- | :--- | :--- | :--- |
| **Screens** (`*_screen.dart`) | 80 – 200 lines | 300 lines | Inlining custom painters, sheets, complex cards |
| **Feature Widgets** (`*_widget.dart`, `*_card.dart`) | 60 – 180 lines | 250 lines | Embedding multiple unrelated components |
| **BLoCs / Cubits** (`*_bloc.dart`) | 80 – 200 lines | 300 lines | Inlining raw HTTP or DB calls |
| **Data Sources / Repositories** | 80 – 220 lines | 300 lines | Multi-entity CRUD conglomerations |

