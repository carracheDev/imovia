import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/imovia_colors.dart';
import '../data/search_repository.dart';

class LocationPickerSheet extends ConsumerStatefulWidget {
  const LocationPickerSheet({
    super.key,
    this.title = 'Choisir une localisation',
    this.allowAnySelection = true,
  });

  final String title;
  final bool allowAnySelection;

  @override
  ConsumerState<LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  final _controller = TextEditingController();
  final List<SearchLocation?> _parents = [null];
  Timer? _debounce;
  Future<List<SearchLocation>>? _browseFuture;
  Future<List<SearchLocation>>? _searchFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _browseFuture = ref.read(searchRepositoryProvider).loadLocations();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    setState(() {
      _query = query;
      _searchFuture = null;
    });
    if (query.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || _query != query) return;
      setState(() {
        _searchFuture = ref
            .read(searchRepositoryProvider)
            .searchLocations(query);
      });
    });
  }

  void _openChildren(SearchLocation location) {
    setState(() {
      _parents.add(location);
      _browseFuture = ref
          .read(searchRepositoryProvider)
          .loadLocations(parentId: location.id);
    });
  }

  void _exploreSearchResult(SearchLocation location) {
    _controller.clear();
    setState(() {
      _query = '';
      _searchFuture = null;
      _parents
        ..clear()
        ..add(null)
        ..add(location);
      _browseFuture = ref
          .read(searchRepositoryProvider)
          .loadLocations(parentId: location.id);
    });
  }

  void _goBack() {
    if (_query.isNotEmpty) {
      _controller.clear();
      _onQueryChanged('');
      return;
    }
    if (_parents.length == 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _parents.removeLast();
      _browseFuture = ref
          .read(searchRepositoryProvider)
          .loadLocations(parentId: _parents.last?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _parents.last;
    final searching = _query.isNotEmpty;
    return FractionallySizedBox(
      heightFactor: .86,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: ImoviaColors.page,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 18, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: Icon(
                      _query.isNotEmpty || _parents.length > 1
                          ? Icons.arrow_back_rounded
                          : Icons.close_rounded,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      current?.name ?? widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Ville, commune ou quartier',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            _onQueryChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: ImoviaColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: searching
                  ? _buildSearchResults()
                  : _buildBrowseList(current),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final future = _searchFuture;
    if (future == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<List<SearchLocation>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Recherche indisponible. Réessaie.'));
        }
        final locations = snapshot.data ?? const <SearchLocation>[];
        if (locations.isEmpty) {
          return const Center(child: Text('Aucune localité trouvée.'));
        }
        return _locationList(locations, searchResults: true);
      },
    );
  }

  Widget _buildBrowseList(SearchLocation? current) =>
      FutureBuilder<List<SearchLocation>>(
        future: _browseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossible de charger les localités.'),
            );
          }
          final locations = snapshot.data ?? const <SearchLocation>[];
          if (locations.isEmpty) {
            return const Center(child: Text('Aucune localité disponible.'));
          }
          return _locationList(
            locations,
            searchResults: false,
            current: current,
          );
        },
      );

  Widget _locationList(
    List<SearchLocation> locations, {
    required bool searchResults,
    SearchLocation? current,
  }) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
    itemCount: locations.length,
    separatorBuilder: (_, _) => const SizedBox(height: 6),
    itemBuilder: (context, index) {
      final location = locations[index];
      final selectable =
          widget.allowAnySelection ||
          location.level == 'ARRONDISSEMENT' ||
          location.level == 'NEIGHBORHOOD';
      final subtitle = searchResults
          ? (location.path ?? _locationLevelLabel(location.level))
          : _locationLevelLabel(location.level);
      final canBrowseChildren =
          !widget.allowAnySelection && location.level != 'NEIGHBORHOOD';
      final canSelect =
          widget.allowAnySelection ||
          location.level == 'ARRONDISSEMENT' ||
          location.level == 'NEIGHBORHOOD';
      final trailing = widget.allowAnySelection
          ? const Icon(
              Icons.north_west_rounded,
              color: ImoviaColors.brandAccent,
            )
          : location.level == 'ARRONDISSEMENT'
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Choisir cet arrondissement',
                  onPressed: () => Navigator.of(context).pop(location),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  color: ImoviaColors.brandAccent,
                ),
                IconButton(
                  tooltip: 'Voir les quartiers',
                  onPressed: () => searchResults
                      ? _exploreSearchResult(location)
                      : _openChildren(location),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            )
          : canBrowseChildren
          ? IconButton(
              tooltip: 'Explorer ${location.name}',
              onPressed: () => searchResults
                  ? _exploreSearchResult(location)
                  : _openChildren(location),
              icon: const Icon(Icons.chevron_right_rounded),
            )
          : canSelect
          ? const Icon(Icons.check_circle_outline_rounded)
          : null;
      return Material(
        color: ImoviaColors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          title: Text(location.name),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing,
          onTap: () {
            if (searchResults && !selectable) {
              _exploreSearchResult(location);
            } else if (selectable) {
              Navigator.of(context).pop(location);
            } else {
              _openChildren(location);
            }
          },
          onLongPress: searchResults ? null : () => _openChildren(location),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    },
  );
}

String _locationLevelLabel(String level) => switch (level) {
  'DEPARTMENT' => 'Département',
  'COMMUNE' => 'Commune',
  'ARRONDISSEMENT' => 'Arrondissement',
  'NEIGHBORHOOD' => 'Quartier',
  _ => 'Localisation',
};
