import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:imovia_mobile/app/providers.dart';
import 'package:imovia_mobile/features/search/data/search_repository.dart';
import 'package:imovia_mobile/features/search/domain/search_criteria.dart';
import 'package:imovia_mobile/features/search/presentation/search_page.dart';

void main() {
  testWidgets(
    'combines search, operation and budget before previewing API count',
    (tester) async {
      final repository = _FakeSearchRepository(resultCount: 7);
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [searchRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: SearchPage(initialCriteria: SearchCriteria(query: 'Cotonou')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Appartement');
      await tester.tap(find.text('À louer'));
      await tester.enterText(fields.at(1), '50000');
      await tester.enterText(fields.at(2), '300000');
      await tester.tap(find.text('Afficher les résultats'));
      await tester.pumpAndSettle();

      expect(repository.lastCriteria?.query, 'Appartement');
      expect(repository.lastCriteria?.operationType, 'RENT');
      expect(repository.lastCriteria?.priceMin, '50000');
      expect(repository.lastCriteria?.priceMax, '300000');
      expect(
        find.text('7 annonces correspondent à vos critères.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      addTearDown(tester.view.resetPhysicalSize);
    },
  );

  testWidgets('rejects an inverted budget without calling the API', (
    tester,
  ) async {
    final repository = _FakeSearchRepository(resultCount: 0);
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [searchRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '500000');
    await tester.enterText(fields.at(2), '100000');
    await tester.tap(find.text('Afficher les résultats'));
    await tester.pumpAndSettle();

    expect(repository.countCalls, 0);
    expect(
      find.text('Le budget minimum doit être inférieur au budget maximum.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    addTearDown(tester.view.resetPhysicalSize);
  });
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({required this.resultCount});

  final int resultCount;
  SearchCriteria? lastCriteria;
  int countCalls = 0;

  @override
  Future<int> countResults(SearchCriteria criteria) async {
    countCalls++;
    lastCriteria = criteria;
    return resultCount;
  }

  @override
  Future<List<SearchLocation>> loadLocations({String? parentId}) async =>
      const [];

  @override
  Future<SearchResultsPage> loadResults(
    SearchCriteria criteria, {
    required int page,
    int pageSize = 10,
  }) async =>
      SearchResultsPage(items: const [], total: 0, page: page, totalPages: 0);
}
