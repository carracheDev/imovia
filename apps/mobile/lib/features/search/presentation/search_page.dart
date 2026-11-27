import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../../core/ui/account_bottom_nav.dart';
import '../data/search_repository.dart';
import '../domain/search_criteria.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialCriteria = const SearchCriteria()});

  final SearchCriteria initialCriteria;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _queryController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late String? _operationType = widget.initialCriteria.operationType;
  late String? _category = widget.initialCriteria.category;
  SearchLocation? _location;
  Timer? _locationDebounce;
  Future<List<SearchLocation>>? _locationSuggestionsFuture;
  String? _locationSuggestionQuery;
  int? _resultCount;
  bool _isCounting = false;
  String? _formError;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: widget.initialCriteria.query ?? '',
    );
    _minPriceController = TextEditingController(
      text: widget.initialCriteria.priceMin ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialCriteria.priceMax ?? '',
    );
    final locationId = widget.initialCriteria.locationId;
    final locationName = widget.initialCriteria.locationName;
    if (locationId != null && locationName != null) {
      _location = SearchLocation(id: locationId, name: locationName, level: '');
    }
    _scheduleLocationSearch(widget.initialCriteria.query ?? '');
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationDebounce?.cancel();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  SearchCriteria get _criteria => SearchCriteria(
    query: _location != null || _queryController.text.trim().isEmpty
        ? null
        : _queryController.text.trim(),
    operationType: _operationType,
    category: _category,
    locationId: _location?.id,
    locationName: _location?.name,
    priceMin: _minPriceController.text.trim().isEmpty
        ? null
        : _minPriceController.text.trim(),
    priceMax: _maxPriceController.text.trim().isEmpty
        ? null
        : _maxPriceController.text.trim(),
  );

  void _scheduleLocationSearch(String value) {
    _locationDebounce?.cancel();
    final query = value.trim();
    _locationSuggestionQuery = null;
    _locationSuggestionsFuture = null;
    if (query.isEmpty) return;
    _locationDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || _queryController.text.trim() != query) return;
      setState(() {
        _locationSuggestionQuery = query;
        _locationSuggestionsFuture = ref
            .read(searchRepositoryProvider)
            .searchLocations(query);
      });
    });
  }

  void _onSearchQueryChanged(String value) {
    setState(() {
      _location = null;
      _resultCount = null;
      _scheduleLocationSearch(value);
    });
  }

  void _selectLocation(SearchLocation location) {
    _locationDebounce?.cancel();
    setState(() {
      _location = location;
      _queryController.text = location.name;
      _locationSuggestionQuery = null;
      _locationSuggestionsFuture = null;
      _resultCount = null;
      _apiError = null;
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildLocationSuggestions() {
    final query = _queryController.text.trim();
    if (_locationSuggestionQuery != query) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(child: Text('Recherche des villes et localités…')),
          ],
        ),
      );
    }
    return FutureBuilder<List<SearchLocation>>(
      future: _locationSuggestionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Text('Suggestions indisponibles. Réessaie.');
        }
        final locations = snapshot.data ?? const <SearchLocation>[];
        if (locations.isEmpty) {
          return const Text('Aucune ville ou localité trouvée.');
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: locations.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final location = locations[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(location.name),
                  subtitle: Text(
                    location.path ?? _locationLevelLabel(location.level),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _locationLevelLabel(location.level),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () => _selectLocation(location),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _countResults() async {
    FocusScope.of(context).unfocus();
    final minPrice = num.tryParse(_minPriceController.text.trim());
    final maxPrice = num.tryParse(_maxPriceController.text.trim());
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      setState(() {
        _formError = 'Le budget minimum doit être inférieur au budget maximum.';
        _resultCount = null;
      });
      return;
    }
    setState(() {
      _formError = null;
      _apiError = null;
    });

    if (_resultCount != null) {
      context.push<void>('/results', extra: _criteria);
      return;
    }

    setState(() => _isCounting = true);
    try {
      final count = await ref
          .read(searchRepositoryProvider)
          .countResults(_criteria);
      if (mounted) setState(() => _resultCount = count);
    } on ApiException {
      if (mounted) {
        setState(() => _apiError = 'Recherche indisponible. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _isCounting = false);
    }
  }

  void _clearFilters() {
    setState(() {
      _queryController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _operationType = null;
      _category = null;
      _location = null;
      _locationDebounce?.cancel();
      _locationSuggestionQuery = null;
      _locationSuggestionsFuture = null;
      _resultCount = null;
      _formError = null;
      _apiError = null;
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      leading: IconButton(
        onPressed: _goBack,
        tooltip: 'Retour',
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        'Recherche avancée',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        TextButton(onPressed: _clearFilters, child: const Text('Effacer')),
        const SizedBox(width: 8),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: [
        _SectionCard(
          title: 'Votre recherche',
          icon: Icons.search_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _queryController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Bien, ville ou quartier',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              if (_location != null) ...[
                const SizedBox(height: 10),
                _SelectedLocation(
                  location: _location!,
                  onClear: () {
                    _queryController.clear();
                    setState(() {
                      _location = null;
                      _resultCount = null;
                    });
                  },
                ),
              ] else if (_queryController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildLocationSuggestions(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Opération',
          icon: Icons.swap_horiz_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChoicePill(
                label: 'Tout',
                selected: _operationType == null,
                onTap: () => _setOperation(null),
              ),
              _ChoicePill(
                label: 'À vendre',
                selected: _operationType == 'SALE',
                onTap: () => _setOperation('SALE'),
              ),
              _ChoicePill(
                label: 'À louer',
                selected: _operationType == 'RENT',
                onTap: () => _setOperation('RENT'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Type de bien',
          icon: Icons.home_work_outlined,
          child: DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            decoration: const InputDecoration(
              hintText: 'Tous les types',
              prefixIcon: Icon(Icons.domain_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'ROOM', child: Text('Chambre simple')),
              DropdownMenuItem(
                value: 'ROOM_AND_LIVING',
                child: Text('Chambre-salon'),
              ),
              DropdownMenuItem(value: 'STUDIO', child: Text('Studio')),
              DropdownMenuItem(value: 'APARTMENT', child: Text('Appartement')),
              DropdownMenuItem(value: 'HOUSE', child: Text('Maison')),
              DropdownMenuItem(value: 'VILLA', child: Text('Villa')),
              DropdownMenuItem(value: 'LAND', child: Text('Terrain')),
              DropdownMenuItem(value: 'SHOP', child: Text('Boutique')),
              DropdownMenuItem(
                value: 'COMMERCIAL_SPACE',
                child: Text('Local commercial'),
              ),
              DropdownMenuItem(value: 'OFFICE', child: Text('Bureau')),
              DropdownMenuItem(value: 'WAREHOUSE', child: Text('Entrepôt')),
              DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
            ],
            onChanged: (value) => setState(() {
              _category = value;
              _resultCount = null;
            }),
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Budget (FCFA)',
          icon: Icons.account_balance_wallet_outlined,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() => _resultCount = null),
                  decoration: const InputDecoration(hintText: 'Minimum'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() => _resultCount = null),
                  decoration: const InputDecoration(hintText: 'Maximum'),
                ),
              ),
            ],
          ),
        ),
        if (_formError != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(message: _formError!, isError: true),
        ],
        if (_apiError != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(message: _apiError!, isError: true),
        ],
        if (_resultCount != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(
            message:
                '$_resultCount annonce${_resultCount == 1 ? '' : 's'} correspond${_resultCount == 1 ? '' : 'ent'} à vos critères.',
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _isCounting ? null : _countResults,
          icon: _isCounting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _resultCount == null
                      ? Icons.search_rounded
                      : Icons.arrow_forward_rounded,
                ),
          label: Text(
            _isCounting
                ? 'Recherche…'
                : _resultCount == null
                ? 'Afficher les résultats'
                : 'Voir $_resultCount résultat${_resultCount == 1 ? '' : 's'}',
          ),
        ),
      ],
    ),
    bottomNavigationBar: const AccountBottomNav(selected: 'Recherche'),
  );

  void _setOperation(String? value) => setState(() {
    _operationType = value;
    _resultCount = null;
  });
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ImoviaColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: ImoviaColors.brandAccent),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: ImoviaColors.brandAccentSoft,
    side: BorderSide(
      color: selected ? ImoviaColors.brandAccent : ImoviaColors.border,
    ),
    labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: selected ? ImoviaColors.brandAccent : ImoviaColors.ink,
    ),
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isError ? const Color(0xFFFCEBE9) : ImoviaColors.brandAccentSoft,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isError ? ImoviaColors.danger : ImoviaColors.brandAccent,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SelectedLocation extends StatelessWidget {
  const _SelectedLocation({required this.location, required this.onClear});

  final SearchLocation location;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: ImoviaColors.brandAccentSoft,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.place_rounded, color: ImoviaColors.brandAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (location.path != null)
                Text(
                  location.path!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClear,
          tooltip: 'Retirer la localisation',
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    ),
  );
}

String _locationLevelLabel(String level) => switch (level) {
  'DEPARTMENT' => 'Département',
  'COMMUNE' => 'Commune',
  'ARRONDISSEMENT' => 'Arrondissement',
  'NEIGHBORHOOD' => 'Quartier',
  _ => 'Localisation',
};
