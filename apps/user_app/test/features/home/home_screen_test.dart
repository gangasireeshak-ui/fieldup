import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldup_user_app/features/home/presentation/home_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: child),
    );

void main() {
  group('HomeScreen top bar', () {
    testWidgets('renders FieldUp logo text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('FieldUp'), findsOneWidget);
    });

    testWidgets('renders user name in identity row', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Pravir S.'), findsOneWidget);
    });

    testWidgets('renders location in context strip', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('JP Nagar, Bangalore'), findsOneWidget);
    });

    testWidgets('renders live player count', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('142 players active'), findsOneWidget);
    });
  });

  group('_GamesRow card', () {
    testWidgets('renders game title Downtown 5v5', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Downtown 5v5', skipOffstage: false), findsOneWidget);
    });

    testWidgets('renders game time', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Tonight, 8 PM', skipOffstage: false), findsOneWidget);
    });
  });

  group('_VenuesRow card', () {
    testWidgets('renders venue name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Feather Touch Arena', skipOffstage: false), findsOneWidget);
    });

    testWidgets('renders Book button for venue', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Book →', skipOffstage: false), findsWidgets);
    });
  });

  group('_TrainersRow card', () {
    testWidgets('renders trainer name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Suresh Phogat', skipOffstage: false), findsOneWidget);
    });

    testWidgets('renders Book button for trainer', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Book →', skipOffstage: false), findsWidgets);
    });
  });
}
