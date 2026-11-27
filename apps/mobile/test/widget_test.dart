import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:imovia_mobile/app/providers.dart';
import 'package:imovia_mobile/features/home/data/home_repository.dart';
import 'package:imovia_mobile/features/home/presentation/home_page.dart';

void main() {
  testWidgets('home renders recent API listings on the light design surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            _FakeHomeRepository([_property]),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trouvez votre bien\nidéal au Bénin'), findsOneWidget);
    expect(find.text('Villa de démonstration'), findsOneWidget);
    expect(find.textContaining('FCFA'), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
    expect(find.text('Annonces récentes'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(overlay.value.statusBarIconBrightness, Brightness.dark);
    final layoutException = tester.takeException();
    expect(layoutException, isNull, reason: '$layoutException');
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets(
    'home passes search text and category filters to the next page action',
    (tester) async {
      String? searched;
      String? category;
      String? operation;
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeRepositoryProvider.overrideWithValue(
              _FakeHomeRepository(const []),
            ),
          ],
          child: MaterialApp(
            home: HomePage(
              onSearch: (query) => searched = query,
              onCategory: (value, kind) {
                category = value;
                operation = kind;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), ' Cotonou ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(searched, 'Cotonou');
      await tester.tap(find.text('Terrains'));
      expect(category, 'LAND');
      expect(operation, isNull);
      expect(find.text('Aucune annonce pour le moment'), findsOneWidget);
      expect(tester.takeException(), isNull);
      addTearDown(tester.view.resetPhysicalSize);
    },
  );
}

const _property = HomeProperty(
  id: 'property-1',
  slug: 'villa-demo',
  title: 'Villa de démonstration',
  category: 'VILLA',
  operationType: 'RENT',
  price: '250000',
  currency: 'XOF',
  locationName: 'Cotonou, Fidjrossè',
  coverMediaId: null,
);

class _FakeHomeRepository implements HomeRepository {
  const _FakeHomeRepository(this.properties);
  final List<HomeProperty> properties;

  @override
  Future<List<HomeProperty>> loadRecent() async => properties;

  @override
  Future<String> loadMediaUrl(PropertyMediaRef media) async =>
      'https://example.com/photo.jpg';
}
