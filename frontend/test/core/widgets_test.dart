import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_badge.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';
import 'package:rgwin_crm/core/widgets/app_error_state.dart';

void main() {
  group('Design System Widget Tests', () {
    testWidgets('AppButton renders label and triggers callback', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Save Visit',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Visit'), findsOneWidget);
      await tester.tap(find.text('Save Visit'));
      expect(tapped, isTrue);
    });

    testWidgets('AppBadge renders variant text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'Sample (10 Units)',
              variant: AppBadgeVariant.sample,
            ),
          ),
        ),
      );

      expect(find.text('Sample (10 Units)'), findsOneWidget);
    });

    testWidgets('AppEmptyState displays title and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.people_outline,
              title: 'No Doctors Found',
              description:
                  'Add your first doctor to begin tracking relationships.',
            ),
          ),
        ),
      );

      expect(find.text('No Doctors Found'), findsOneWidget);
      expect(
        find.text('Add your first doctor to begin tracking relationships.'),
        findsOneWidget,
      );
    });

    testWidgets('AppErrorState displays message and retry action', (
      tester,
    ) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState(
              message: 'Failed to connect to backend server.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to connect to backend server.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });
  });
}
