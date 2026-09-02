import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/employees/domain/entities/country.dart';
import '../../features/employees/presentation/bloc/country_cubit.dart';
import '../../injection_container.dart';

class CountryListScreen extends StatelessWidget {
  const CountryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CountryCubit>(
      create: (_) => sl<CountryCubit>()..fetchCountries(),
      child: const _CountryListView(),
    );
  }
}

class _CountryListView extends StatefulWidget {
  const _CountryListView();

  @override
  State<_CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<_CountryListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Country> _filtered(List<Country> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search countries...',
                hintStyle: const TextStyle(
                    color: Colors.white60),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color:
                          Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Colors.white, width: 1.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CountryCubit, CountryState>(
        builder: (context, state) {
          if (state is CountryLoading) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (_, __) => _shimmerTile(context),
            );
          }

          if (state is CountryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.6)),
                  const SizedBox(height: 16),
                  Text('Failed to load countries',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(state.message,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton.icon(
                      onPressed: () => context
                          .read<CountryCubit>()
                          .fetchCountries(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is CountryLoaded) {
            final filtered = _filtered(state.countries);
            if (filtered.isEmpty) {
              return const Center(
                  child: Text('No countries found'));
            }
            return RefreshIndicator(
              onRefresh: () => context
                  .read<CountryCubit>()
                  .fetchCountries(forceRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: filtered.length,
                itemBuilder: (_, i) =>
                    _CountryTile(country: filtered[i], query: _searchQuery),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _shimmerTile(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A3C)
        : const Color(0xFFE0E0E0);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(22))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 14,
                      width: 120,
                      color: base),
                  const SizedBox(height: 8),
                  Container(
                      height: 11,
                      width: 80,
                      color: base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final Country country;
  final String query;
  const _CountryTile({required this.country, required this.query});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flag = _flagEmoji(country.name);
    final color = _avatarColor(country.name);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightText(text: country.name, query: query),
                  if (country.id != null)
                    Text(
                      '#${country.id}',
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.45)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _flagEmoji(String name) {
    final code = _kCountryCodes[name.trim().toLowerCase()];
    if (code == null || code.length != 2) {
      return name.isNotEmpty ? name[0].toUpperCase() : '?';
    }
    return code
        .toUpperCase()
        .split('')
        .map((c) =>
            String.fromCharCode(c.codeUnitAt(0) - 65 + 0x1F1E6))
        .join();
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF00ACC1),
      Color(0xFF388E3C),
      Color(0xFFF57C00),
      Color(0xFF6A1B9A),
    ];
    return colors[name.length % colors.length];
  }

  static const _kCountryCodes = {
    'india': 'in',
    'united states': 'us',
    'united kingdom': 'gb',
    'australia': 'au',
    'canada': 'ca',
    'germany': 'de',
    'france': 'fr',
    'japan': 'jp',
    'china': 'cn',
    'brazil': 'br',
    'south africa': 'za',
    'new zealand': 'nz',
    'singapore': 'sg',
    'malaysia': 'my',
    'uae': 'ae',
    'united arab emirates': 'ae',
    'italy': 'it',
    'spain': 'es',
    'russia': 'ru',
    'mexico': 'mx',
  };
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600));
    }
    final lower = text.toLowerCase();
    final qi = lower.indexOf(query.toLowerCase());
    if (qi < 0) {
      return Text(text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600));
    }
    return RichText(
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: text.substring(0, qi)),
          TextSpan(
            text: text.substring(qi, qi + query.length),
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12)),
          ),
          TextSpan(text: text.substring(qi + query.length)),
        ],
      ),
    );
  }
}
