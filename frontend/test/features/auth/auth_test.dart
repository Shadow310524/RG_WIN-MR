import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/routing/app_router.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/features/auth/data/auth_repository.dart';
import 'package:rgwin_crm/features/auth/domain/models/user_model.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_state.dart';
import 'package:rgwin_crm/features/auth/presentation/login_screen.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? mockUser;
  bool shouldThrowLogin = false;
  String loginErrorMessage = "Invalid credentials";

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrowLogin) {
      throw Exception(loginErrorMessage);
    }
    final user = UserModel(
      id: "usr_mock_1",
      email: email,
      fullName: "Ravi Kumar",
      phone: "+91 9876543210",
      role: "MR",
      status: "ACTIVE",
    );
    mockUser = user;
    return user;
  }

  @override
  Future<UserModel?> restoreSession() async {
    return mockUser;
  }

  @override
  Future<void> logout() async {
    mockUser = null;
  }

  @override
  Future<String?> getAccessToken() async {
    return mockUser != null ? "mock_access_token" : null;
  }
}

void main() {
  group('Auth Unit & State Tests', () {
    test('Initial state is initial and not loading', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(authProvider);

      expect(state.status, AuthStatus.initial);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('login success sets authenticated status and user', () async {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(authProvider.notifier)
          .login(email: "mr.ravi@healix.com", password: "CorrectPassword123!");

      expect(success, true);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.isAuthenticated, true);
      expect(state.user?.email, "mr.ravi@healix.com");
      expect(state.user?.fullName, "Ravi Kumar");
      expect(state.errorMessage, isNull);
    });

    test(
      'login failure sets error message and unauthenticated status',
      () async {
        final mockRepo = MockAuthRepository()..shouldThrowLogin = true;
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        final success = await container
            .read(authProvider.notifier)
            .login(email: "mr.ravi@healix.com", password: "WrongPassword!");

        expect(success, false);
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.isAuthenticated, false);
        expect(state.errorMessage, contains("Invalid email or password"));
      },
    );

    test('session restoration restores user when credentials exist', () async {
      final mockRepo = MockAuthRepository()
        ..mockUser = const UserModel(
          id: "usr_mock_admin",
          email: "admin@healix.com",
          fullName: "System Admin",
          role: "ADMIN",
          status: "ACTIVE",
        );

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.isAuthenticated, true);
      expect(state.user?.role, "ADMIN");
    });

    test('logout clears user and reverts to unauthenticated', () async {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      // Login first
      await container
          .read(authProvider.notifier)
          .login(email: "mr.ravi@healix.com", password: "CorrectPassword123!");
      expect(container.read(authProvider).isAuthenticated, true);

      // Logout
      await container.read(authProvider.notifier).logout();
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authProvider).user, isNull);
    });
  });

  group('LoginScreen Widget Tests', () {
    Widget createLoginScreen({
      MockAuthRepository? repo,
      AuthController Function()? authControllerOverride,
    }) {
      final mockRepo = repo ?? MockAuthRepository();
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
          if (authControllerOverride != null)
            authProvider.overrideWith(authControllerOverride),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );
    }

    testWidgets('Renders Healix branding and form fields', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text("HEALIX CRM"), findsOneWidget);
      expect(find.text("Field Sales & Doctor Management"), findsOneWidget);
      expect(find.text("Sign in to your account"), findsOneWidget);
      expect(find.text("Work Email"), findsOneWidget);
      expect(find.text("Password"), findsOneWidget);
      expect(find.text("Sign In"), findsOneWidget);
    });

    testWidgets('Displays validation errors on empty submission', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Tap Sign In without filling form
      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      expect(find.text("Email is required"), findsOneWidget);
      expect(find.text("Password is required"), findsOneWidget);
    });

    testWidgets(
      'Displays validation error for malformed email and short password',
      (tester) async {
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(
          find.byType(TextFormField).at(0),
          "invalid-email",
        );
        // Enter short password
        await tester.enterText(find.byType(TextFormField).at(1), "123");

        await tester.tap(find.text("Sign In"));
        await tester.pumpAndSettle();

        expect(find.text("Please enter a valid email address"), findsOneWidget);
        expect(
          find.text("Password must be at least 6 characters"),
          findsOneWidget,
        );
      },
    );

    testWidgets('Displays error banner on failed login', (tester) async {
      final mockRepo = MockAuthRepository()..shouldThrowLogin = true;
      await tester.pumpWidget(createLoginScreen(repo: mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        "wrong@healix.com",
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        "WrongPassword123!",
      );

      await tester.tap(find.text("Sign In"));
      await tester.pumpAndSettle();

      expect(
        find.text("Invalid email or password. Please verify and try again."),
        findsOneWidget,
      );
    });

    testWidgets('Displays loading indicator while login is in flight', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_LoadingAuthController.new)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify button indicates loading
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.isLoading, true);
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Password visibility toggle toggles obscureText', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final passwordFormField = find.byType(TextFormField).at(1);
      final initialField = tester.widget<TextField>(
        find.descendant(
          of: passwordFormField,
          matching: find.byType(TextField),
        ),
      );
      expect(initialField.obscureText, true);

      // Tap show password icon (initially visibility_off_outlined)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      final visibleField = tester.widget<TextField>(
        find.descendant(
          of: passwordFormField,
          matching: find.byType(TextField),
        ),
      );
      expect(visibleField.obscureText, false);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('Navigation & Authentication Routing Tests', () {
    testWidgets('Unauthenticated user is redirected to /login', (tester) async {
      final mockRepo = MockAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
                theme: AppTheme.lightTheme,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verified redirect to Login screen
      expect(find.text("Sign in to your account"), findsOneWidget);
      expect(find.text("Sign In"), findsOneWidget);
    });

    testWidgets(
      'Authenticated user navigates to application shell and can logout',
      (tester) async {
        final mockRepo = MockAuthRepository()
          ..mockUser = const UserModel(
            id: "usr_admin",
            email: "admin@healix.com",
            fullName: "System Admin",
            role: "ADMIN",
            status: "ACTIVE",
          );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
            child: Consumer(
              builder: (context, ref, _) {
                // Trigger session restoration
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(authProvider.notifier).checkSession();
                });
                final router = ref.watch(routerProvider);
                return MaterialApp.router(
                  routerConfig: router,
                  theme: AppTheme.lightTheme,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Application shell is visible
        expect(find.text("Home"), findsWidgets);
        expect(find.text("Doctors"), findsWidgets);
        expect(find.text("ADMIN"), findsOneWidget);

        // Tap logout
        await tester.tap(find.byIcon(Icons.logout_rounded));
        await tester.pumpAndSettle();

        // Redirected to Login screen after logout
        expect(find.text("Sign in to your account"), findsOneWidget);
        expect(find.text("Sign In"), findsOneWidget);
      },
    );
  });
}

class _LoadingAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(isLoading: true);
  }
}
