import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/app.dart';
import 'package:rgwin_crm/features/auth/data/auth_repository.dart';
import 'package:rgwin_crm/features/auth/domain/models/user_model.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';

class MockAppAuthRepository implements AuthRepository {
  final UserModel? user;

  MockAppAuthRepository({this.user});

  @override
  Future<UserModel?> restoreSession() async => user;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return user ??
        UserModel(
          id: 'test_user',
          email: email,
          fullName: 'Test User',
          role: 'ADMIN',
          status: 'ACTIVE',
        );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getAccessToken() async => user != null ? 'test_token' : null;
}

void main() {
  testWidgets('RgWinApp boots unauthenticated and presents LoginScreen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAppAuthRepository()),
        ],
        child: const RgWinApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Healix branding and login prompt
    expect(find.text('HEALIX CRM'), findsOneWidget);
    expect(find.text('Field Sales & Doctor Management'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('RgWinApp boots authenticated and presents application shell', (
    tester,
  ) async {
    final mockUser = const UserModel(
      id: 'usr_admin',
      email: 'admin@healix.com',
      fullName: 'System Administrator',
      role: 'ADMIN',
      status: 'ACTIVE',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            MockAppAuthRepository(user: mockUser),
          ),
        ],
        child: const RgWinApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify application header and branding
    expect(find.text('Field Sales Overview'), findsOneWidget);

    // Verify navigation destinations (Home, Doctors, Visits, Sales, More)
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Doctors'), findsWidgets);
    expect(find.text('Visits'), findsWidgets);
    expect(find.text('Sales'), findsWidgets);
    expect(find.text('More'), findsWidgets);

    // Verify user role badge
    expect(find.text('ADMIN'), findsOneWidget);
  });
}
