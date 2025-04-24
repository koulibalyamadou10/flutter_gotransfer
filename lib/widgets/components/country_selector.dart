import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CountrySelector extends StatefulWidget {
  final ValueChanged<String> onCountrySelected;
  final String? initialValue;

  const CountrySelector({
    Key? key,
    required this.onCountrySelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _CountrySelectorState createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  final List<Map<String, String>> _countries = [
    {'name': 'Canada', 'code': 'CA', 'dial_code': '+1', 'flag': '🇨🇦'},
    {'name': 'France', 'code': 'FR', 'dial_code': '+33', 'flag': '🇫🇷'},
    {'name': 'Guinée', 'code': 'GN', 'dial_code': '+224', 'flag': '🇬🇳'},
    {'name': 'États-Unis', 'code': 'US', 'dial_code': '+1', 'flag': '🇺🇸'},
    {'name': 'Côte d\'Ivoire', 'code': 'CI', 'dial_code': '+225', 'flag': '🇨🇮'},
    {'name': 'Sénégal', 'code': 'SN', 'dial_code': '+221', 'flag': '🇸🇳'},
  ];

  late List<Map<String, String>> _filteredCountries;
  late String _selectedCountry;

  @override
  void initState() {
    super.initState();
    _filteredCountries = _countries;
    _selectedCountry = widget.initialValue ?? _countries.first['name']!;
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = _countries
          .where((country) =>
      country['name']!.toLowerCase().contains(query.toLowerCase()) ||
          country['dial_code']!.contains(query))
          .toList();
    });
  }

  void _showCountryPicker(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un pays...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterCountries,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return ListTile(
                      leading: Text(country['flag']!, style: TextStyle(fontSize: 24)),
                      title: Text(country['name']!),
                      subtitle: Text(country['dial_code']!),
                      trailing: _selectedCountry == country['name']
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCountry = country['name']!;
                          widget.onCountrySelected(country['code']!);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      searchController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCountry = _countries.firstWhere(
          (country) => country['name'] == _selectedCountry,
      orElse: () => _countries.first,
    );

    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(selectedCountry['flag']!, style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text(selectedCountry['name']!),
              ],
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}