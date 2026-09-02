import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../framework/data/status_enum.dart';
import '../../framework/providers/provider/country_provider.dart';
import '../../framework/repository/model/country_model/country_model.dart';

class CountryListScreen extends ConsumerStatefulWidget {
  const CountryListScreen({super.key});

  @override
  ConsumerState<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends ConsumerState<CountryListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(countryProvider).fetchCountries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CountryModel> _filtered(List<CountryModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _onRefresh() async {
    await ref.read(countryProvider).fetchCountries(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(countryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          if (notifier.countries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${notifier.countries.length}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          Expanded(child: _buildBody(notifier)),
        ],
      ),
    );
  }

  Widget _buildBody(CountryNotifier notifier) {
    if (notifier.status == StatusEnum.loading) {
      return _buildShimmer();
    }

    if (notifier.status == StatusEnum.error) {
      return _buildError(notifier.errorMessage ?? 'Failed to load countries');
    }

    final filtered = _filtered(notifier.countries);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.public_off_rounded,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No countries found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24, top: 4),
        itemCount: filtered.length,
        itemBuilder: (context, i) =>
            _CountryTile(country: filtered[i], query: _searchQuery),
      ),
    );
  }

  Widget _buildShimmer() {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A3C)
        : const Color(0xFFE0E0E0);

    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(radius: 22, backgroundColor: base),
        title: Container(height: 14, width: 120, color: base),
        subtitle: Container(
            height: 11, width: 60, color: base, margin: const EdgeInsets.only(top: 6)),
        trailing: Container(height: 20, width: 30, color: base),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .error
                    .withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text('Failed to load countries',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Country tile ─────────────────────────────────────────────────────────────

class _CountryTile extends StatelessWidget {
  final CountryModel country;
  final String query;

  const _CountryTile({required this.country, required this.query});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _FlagAvatar(name: country.name),
        title: _HighlightText(
          text: country.name,
          query: query,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: country.createdAt != null
            ? Text(
                _formatDate(country.createdAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              )
            : null,
        trailing: country.id != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${country.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Country name → ISO 3166-1 alpha-2 code lookup (top-level const) ─────────
const _kCountryCodes = <String, String>{
  'aruba': 'AW', 'singapore': 'SG', 'suriname': 'SR', 'benin': 'BJ',
  'philippines': 'PH', 'papua new guinea': 'PG',
  'christmas island': 'CX', 'virgin islands, british': 'VG',
  'russian federation': 'RU', 'somalia': 'SO', 'azerbaijan': 'AZ',
  'turkmenistan': 'TM', 'mongolia': 'MN', 'united kingdom': 'GB',
  'uzbekistan': 'UZ', 'uganda': 'UG', 'ecuador': 'EC',
  'czech republic': 'CZ', 'czechia': 'CZ', 'south africa': 'ZA',
  'norfolk island': 'NF', 'pitcairn islands': 'PN', 'lesotho': 'LS',
  'sweden': 'SE', 'gambia': 'GM', 'oman': 'OM', 'seychelles': 'SC',
  'norway': 'NO', 'thailand': 'TH', 'congo': 'CG', 'india': 'IN',
  'palestine': 'PS', 'belgium': 'BE', 'rwanda': 'RW', 'georgia': 'GE',
  'colombia': 'CO', 'germany': 'DE', 'tunisia': 'TN',
  'puerto rico': 'PR', 'italy': 'IT', 'kuwait': 'KW', 'egypt': 'EG',
  'mali': 'ML', 'mauritania': 'MR', 'pakistan': 'PK',
  'zimbabwe': 'ZW', 'saint barthelemy': 'BL', 'liberia': 'LR',
  'haiti': 'HT',
  'south georgia and the south sandwich islands': 'GS',
  'algeria': 'DZ', 'bosnia and herzegovina': 'BA',
  'united arab emirates': 'AE', 'austria': 'AT',
  'united states': 'US', 'canada': 'CA', 'australia': 'AU',
  'france': 'FR', 'spain': 'ES', 'china': 'CN', 'japan': 'JP',
  'brazil': 'BR', 'mexico': 'MX', 'argentina': 'AR',
  'nigeria': 'NG', 'kenya': 'KE', 'ghana': 'GH', 'ethiopia': 'ET',
  'iran': 'IR', 'iraq': 'IQ', 'saudi arabia': 'SA',
  'turkey': 'TR', 'ukraine': 'UA', 'poland': 'PL',
  'netherlands': 'NL', 'portugal': 'PT', 'greece': 'GR',
  'new zealand': 'NZ', 'indonesia': 'ID', 'malaysia': 'MY',
  'bangladesh': 'BD', 'sri lanka': 'LK', 'nepal': 'NP',
  'myanmar': 'MM', 'vietnam': 'VN', 'cambodia': 'KH',
};

const _kAvatarColors = <Color>[
  Color(0xFF1565C0), Color(0xFF00695C), Color(0xFF6A1B9A),
  Color(0xFFBF360C), Color(0xFF00838F), Color(0xFF283593),
  Color(0xFF558B2F), Color(0xFFAD1457), Color(0xFF4527A0),
  Color(0xFF00600F),
];

// ── Flag avatar — uses emoji flag, no network required ───────────────────────

class _FlagAvatar extends StatelessWidget {
  final String name;

  const _FlagAvatar({required this.name});

  String? _emojiFlag() {
    final code = _kCountryCodes[name.trim().toLowerCase()];
    if (code == null) return null;
    // Regional indicator A starts at 0x1F1E6; uppercase A is 0x41
    const offset = 0x1F1E6 - 0x41;
    return code.runes.map((r) => String.fromCharCode(r + offset)).join();
  }

  Color _bgColor() {
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % _kAvatarColors.length : 0;
    return _kAvatarColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _emojiFlag();
    final color = _bgColor();

    if (emoji != null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

// ── Highlight matching text ──────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;

  const _HighlightText(
      {required this.text, required this.query, required this.style});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase());
    if (idx == -1) return Text(text, style: style);

    return RichText(
      text: TextSpan(style: style, children: [
        TextSpan(text: text.substring(0, idx)),
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: style.copyWith(
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(text: text.substring(idx + query.length)),
      ]),
    );
  }
}
