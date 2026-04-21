import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recentCities = [];

  final List<String> _popularCities = [
    'Tokyo', 'London', 'New York', 'Paris', 'Dubai',
    'Singapore', 'Sydney', 'Jakarta', 'Seoul', 'Mumbai',
    'Los Angeles', 'Berlin', 'Toronto', 'Bangkok', 'Cairo',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentCities();
  }

  Future<void> _loadRecentCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentCities = prefs.getStringList('recent_cities') ?? [];
    });
  }

  Future<void> _saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [city, ..._recentCities.where((c) => c != city)]
        .take(5)
        .toList();
    await prefs.setStringList('recent_cities', updated);
  }

  void _selectCity(String city) async {
    await _saveCity(city);
    if (mounted) Navigator.pop(context, city);
  }

  void _submit() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) _selectCity(city);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose City',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Enter city name...',
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.white.withOpacity(0.5)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: Color(0xFF4FC3F7)),
                  onPressed: _submit,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                      color: Color(0xFF4FC3F7), width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (_recentCities.isNotEmpty) ...[
                  _sectionTitle('Recent Searches'),
                  ..._recentCities.map((city) => _cityTile(
                        city,
                        icon: Icons.history_rounded,
                        iconColor: Colors.orange.shade300,
                      )),
                  const SizedBox(height: 16),
                ],
                _sectionTitle('Popular Cities'),
                ..._popularCities.map((city) => _cityTile(
                      city,
                      icon: Icons.location_city_rounded,
                      iconColor: Colors.blue.shade300,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _cityTile(String city,
      {required IconData icon, required Color iconColor}) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        city,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.white.withOpacity(0.3)),
      onTap: () => _selectCity(city),
    );
  }
}