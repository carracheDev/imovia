import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:imovia_mobile/app/imovia_app.dart';
import 'package:imovia_mobile/app/providers.dart';
import 'package:imovia_mobile/features/home/data/home_repository.dart';
import 'package:imovia_mobile/features/properties/data/property_detail_repository.dart';
import 'package:imovia_mobile/features/search/data/search_repository.dart';
import 'package:imovia_mobile/features/search/domain/search_criteria.dart';

void main() {
  testWidgets('home category opens CH-02 with its initial operation filter', (
    tester,
  ) async {
    final searchRepository = _FakeSearchRepository();
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepository()),
          searchRepositoryProvider.overrideWithValue(searchRepository),
          propertyDetailRepositoryProvider.overrideWithValue(
            _FakePropertyDetailRepository(),
          ),
        ],
        child: const ImoviaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('À louer').first);
    await tester.pumpAndSettle();

    expect(find.text('Recherche avancée'), findsOneWidget);
    final rentChoice = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('À louer').last,
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(rentChoice.selected, isTrue);

    await tester.tap(find.text('Afficher les résultats'));
    await tester.pumpAndSettle();
    expect(
      find.text('2 annonces correspondent à vos critères.'),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voir 2 résultats'));
    await tester.pumpAndSettle();
    expect(find.text('Résultats'), findsOneWidget);
    expect(find.text('Villa de test'), findsOneWidget);
    expect(searchRepository.lastCriteria?.operationType, 'RENT');
    await tester.tap(find.text('Villa de test'));
    await tester.pumpAndSettle();
    expect(find.text('Description de test'), findsOneWidget);
    expect(find.text('Contacter l’annonceur'), findsOneWidget);
    await tester.ensureVisible(find.text('Contacter l’annonceur'));
    await tester.tap(find.text('Contacter l’annonceur'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continuer vers le contact'));
    await tester.tap(find.text('Continuer vers le contact'));
    await tester.pumpAndSettle();
    expect(find.text('Appeler  +22900000000'), findsOneWidget);
    expect(tester.takeException(), isNull);
    addTearDown(tester.view.resetPhysicalSize);
  });
}

class _FakePropertyDetailRepository implements PropertyDetailRepository {
  @override
  Future<PropertyDetail> load(String slug) async => const PropertyDetail(
    id: 'property-1',
    slug: 'villa-test',
    title: 'Villa de test',
    description: 'Description de test',
    category: 'VILLA',
    operationType: 'RENT',
    price: '250000',
    currency: 'XOF',
    locationName: 'Cotonou',
    ownerDisplayName: 'Annonceur test',
    details: {'bedrooms': 3},
    visitInstructions: null,
    media: [],
  );

  @override
  Future<PropertyContact> loadContact(String slug) async =>
      const PropertyContact(phone: '+22900000000');

  @override
  Future<String> loadMediaUrl(String slug, String mediaId) async => '';
}

class _FakeHomeRepository implements HomeRepository {
  @override
  Future<List<HomeProperty>> loadRecent() async => const [];

  @override
  Future<String> loadMediaUrl(PropertyMediaRef media) async => '';
}

class _FakeSearchRepository implements SearchRepository {
  SearchCriteria? lastCriteria;

  @override
  Future<int> countResults(SearchCriteria criteria) async {
    lastCriteria = criteria;
    return 2;
  }

  @override
  Future<SearchResultsPage> loadResults(
    SearchCriteria criteria, {
    required int page,
    int pageSize = 10,
  }) async => SearchResultsPage(
    items: const [
      HomeProperty(
        id: 'property-1',
        slug: 'villa-test',
        title: 'Villa de test',
        category: 'VILLA',
        operationType: 'RENT',
        price: '250000',
        currency: 'XOF',
        locationName: 'Cotonou',
        coverMediaId: null,
      ),
    ],
    total: 2,
    page: page,
    totalPages: 1,
  );

  @override
  Future<List<SearchLocation>> loadLocations({String? parentId}) async =>
      const [];

  @override
  Future<List<SearchLocation>> searchLocations(String query) async => const [];
}
