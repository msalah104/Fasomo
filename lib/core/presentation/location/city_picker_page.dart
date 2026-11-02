import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/country_names.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// A searchable list of the bundled cities, offline. Pops with the picked
/// [City], or `null` when dismissed.
class CityPickerPage extends StatefulWidget {
  const new({this.selected, super.key});

  /// The city chosen now, marked in the list.
  final City? selected;

  /// Opens the picker as a full-screen dialog and returns the choice.
  static Future<City?> show(BuildContext context, {City? selected}) =>
      Navigator.of(context).push<City>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => CityPickerPage(selected: selected),
        ),
      );

  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setQuery(String query) => setState(() => _query = query);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final cities = CityCatalog.search(_query, languageCode: languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(localization.cityPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: localization.cityPickerSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: localization.cityPickerClearSearch,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          _setQuery('');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: cities.isEmpty
                ? _NoResults(query: _query)
                : ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) => _CityTile(
                      city: cities[index],
                      languageCode: languageCode,
                      isSelected: cities[index] == widget.selected,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const new({
    required this.city,
    required this.languageCode,
    required this.isSelected,
  });

  final City city;
  final String languageCode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final country = countryNames[city.countryCode]?.nameFor(languageCode);
    return ListTile(
      leading: ExcludeSemantics(
        child: Text(
          flagEmoji(city.countryCode),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      title: Text(city.nameFor(languageCode)),
      subtitle: Text(country ?? city.countryCode),
      selected: isSelected,
      trailing: isSelected
          ? const ExcludeSemantics(child: Icon(Icons.check))
          : null,
      onTap: () => Navigator.of(context).pop(city),
    );
  }
}

class _NoResults extends StatelessWidget {
  const new({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        AppLocalizations.of(context).cityPickerNoResults(query),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

/// The flag emoji of an ISO 3166-1 alpha-2 [countryCode], from its regional
/// indicator letters.
String flagEmoji(String countryCode) => String.fromCharCodes(
  countryCode.toUpperCase().codeUnits.map((unit) => unit - 0x41 + 0x1F1E6),
);
