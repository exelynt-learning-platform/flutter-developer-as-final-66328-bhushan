import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:employee_management_application_flutter_assessment/ui/helper/confirm_dialog.dart';

void main() {
  /// Helper: wraps [ConfirmDialog] in a minimal [MaterialApp] so that
  /// [Theme] lookups and [Navigator] work correctly.
  Widget buildDialog({
    String title = 'Delete Item',
    String message = 'Are you sure?',
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          confirmColor: confirmColor,
          icon: icon,
        ),
      ),
    );
  }

  // ── Content visibility ─────────────────────────────────────────────────────

  testWidgets('displays title and message', (tester) async {
    await tester.pumpWidget(buildDialog(
      title: 'Delete Item',
      message: 'This action cannot be undone.',
    ));

    expect(find.text('Delete Item'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
  });

  testWidgets('displays custom confirm and cancel labels', (tester) async {
    await tester.pumpWidget(buildDialog(
      confirmLabel: 'Yes, Remove',
      cancelLabel: 'No, Keep',
    ));

    expect(find.text('Yes, Remove'), findsOneWidget);
    expect(find.text('No, Keep'), findsOneWidget);
  });

  testWidgets('displays icon when provided', (tester) async {
    await tester.pumpWidget(buildDialog(icon: Icons.delete_forever_rounded));

    expect(find.byIcon(Icons.delete_forever_rounded), findsOneWidget);
  });

  testWidgets('does not display icon widget when icon is null', (tester) async {
    await tester.pumpWidget(buildDialog(icon: null));

    // Only the title text should appear — no icon row widget
    expect(find.byIcon(Icons.delete_forever_rounded), findsNothing);
  });

  // ── Confirm button ─────────────────────────────────────────────────────────

  testWidgets('tapping confirm button pops with true', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              dialogResult = await ConfirmDialog.show(
                ctx,
                title: 'Confirm',
                message: 'Are you sure?',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(dialogResult, isTrue);
  });

  // ── Cancel button ──────────────────────────────────────────────────────────

  testWidgets('tapping cancel button pops with false', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              dialogResult = await ConfirmDialog.show(
                ctx,
                title: 'Confirm',
                message: 'Are you sure?',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(dialogResult, isFalse);
  });

  // ── barrierDismissible = false ─────────────────────────────────────────────

  testWidgets('dialog stays open when tapping barrier (barrierDismissible: false)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () => ConfirmDialog.show(
              ctx,
              title: 'Confirm',
              message: 'Are you sure?',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Tap outside the dialog (barrier area)
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Dialog should still be present
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);
  });

  // ── static show() helper ──────────────────────────────────────────────────

  testWidgets('ConfirmDialog.show returns false when no result (safety check)',
      (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              result = await ConfirmDialog.show(
                ctx,
                title: 'Sign Out',
                message: 'Log out?',
                confirmLabel: 'Sign Out',
                confirmColor: Colors.orange,
                icon: Icons.logout_rounded,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Sign Out'), findsAtLeastNWidgets(1));
    expect(find.text('Log out?'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

    // Cancel it
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
