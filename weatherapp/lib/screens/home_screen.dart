import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../theme/weather_theme.dart';
import '../widgets/weather_illustration.dart';
import '../widgets/weather_detail_card.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherData? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadDefaultWeather();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultWeather() async {
    await _fetchWeatherByCity('Jakarta');
  }

  Future<void> _fetchWeatherByCity(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _weatherService.getWeatherByCity(city);
      setState(() {
        _weather = data;
        _isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      final data = await _weatherService.getWeatherByCoords(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _weather = data;
        _isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _openSearch() async {
    final city = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (city != null && city.isNotEmpty) {
      _fetchWeatherByCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _weather != null
        ? WeatherTheme.forCondition(_weather!.condition)
        : WeatherTheme.forCondition(WeatherCondition.clear);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(theme),
              Expanded(
                child: _isLoading
                    ? _buildLoader(theme)
                    : _errorMessage != null
                        ? _buildError(theme)
                        : _buildContent(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(WeatherTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('EEE, MMM d').format(DateTime.now()),
            style: TextStyle(
              color: theme.textColor.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            children: [
              _iconButton(
                icon: Icons.my_location_rounded,
                theme: theme,
                onTap: _fetchWeatherByLocation,
                tooltip: 'Use my location',
              ),
              const SizedBox(width: 8),
              _iconButton(
                icon: Icons.search_rounded,
                theme: theme,
                onTap: _openSearch,
                tooltip: 'Search city',
              ),
              const SizedBox(width: 8),
              _iconButton(
                icon: Icons.settings_rounded,
                theme: theme,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                tooltip: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required WeatherTheme theme,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.textColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildLoader(WeatherTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.textColor),
          const SizedBox(height: 16),
          Text(
            'Fetching weather...',
            style: TextStyle(color: theme.textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(WeatherTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: theme.textColor.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDefaultWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.cardColor,
                foregroundColor: theme.textColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(WeatherTheme theme) {
    if (_weather == null) return const SizedBox();
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildCityName(theme),
            const SizedBox(height: 4),
            WeatherIllustration(
              condition: _weather!.condition,
              theme: theme,
            ),
            _buildTemperature(theme),
            const SizedBox(height: 4),
            _buildDescription(theme),
            const SizedBox(height: 20),
            _buildHiLo(theme),
            const SizedBox(height: 24),
            _buildDetailsGrid(theme),
            const SizedBox(height: 24),
            _buildSunriseSunset(theme),
            const SizedBox(height: 32),
            _buildSearchBar(theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCityName(WeatherTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on_rounded,
            color: theme.textColor.withOpacity(0.8), size: 16),
        const SizedBox(width: 4),
        Text(
          '${_weather!.cityName}, ${_weather!.country}',
          style: TextStyle(
            color: theme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTemperature(WeatherTheme theme) {
    return Center(
      child: Text(
        '${_weather!.temperature.round()}°',
        style: TextStyle(
          color: theme.textColor,
          fontSize: 88,
          fontWeight: FontWeight.w200,
          height: 1.0,
          letterSpacing: -4,
        ),
      ),
    );
  }

  Widget _buildDescription(WeatherTheme theme) {
    return Column(
      children: [
        Text(
          _weather!.description.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textColor.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Feels like ${_weather!.feelsLike.round()}°C',
          style: TextStyle(
            color: theme.textColor.withOpacity(0.65),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildHiLo(WeatherTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _hiLoChip('H: ${_weather!.tempMax.round()}°', theme),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 1,
          height: 16,
          color: theme.textColor.withOpacity(0.3),
        ),
        _hiLoChip('L: ${_weather!.tempMin.round()}°', theme),
      ],
    );
  }

  Widget _hiLoChip(String text, WeatherTheme theme) {
    return Text(
      text,
      style: TextStyle(
        color: theme.textColor.withOpacity(0.75),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDetailsGrid(WeatherTheme theme) {
    final details = [
      {'icon': '💧', 'label': 'Humidity', 'value': '${_weather!.humidity}%'},
      {
        'icon': '🌬️',
        'label': 'Wind',
        'value': '${_weather!.windSpeed.toStringAsFixed(1)} m/s ${_weather!.windDirection}'
      },
      {'icon': '👁️', 'label': 'Visibility', 'value': _weather!.visibilityKm},
      {'icon': '🌡️', 'label': 'Pressure', 'value': '${_weather!.pressure} hPa'},
      {'icon': '☁️', 'label': 'Cloudiness', 'value': '${_weather!.cloudiness}%'},
      {
        'icon': '🌡️',
        'label': 'Feels Like',
        'value': '${_weather!.feelsLike.round()}°C'
      },
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: details
          .map((d) => WeatherDetailCard(
                icon: d['icon']!,
                label: d['label']!,
                value: d['value']!,
                theme: theme,
              ))
          .toList(),
    );
  }

  Widget _buildSunriseSunset(WeatherTheme theme) {
    final fmt = DateFormat('h:mm a');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('🌅', style: TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  fmt.format(_weather!.sunrise),
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Sunrise',
                  style: TextStyle(
                    color: theme.textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: theme.textColor.withOpacity(0.2)),
          Expanded(
            child: Column(
              children: [
                const Text('🌇', style: TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  fmt.format(_weather!.sunset),
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Sunset',
                  style: TextStyle(
                    color: theme.textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WeatherTheme theme) {
    return GestureDetector(
      onTap: _openSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.textColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                color: theme.textColor.withOpacity(0.6)),
            const SizedBox(width: 12),
            Text(
              'Search for another city...',
              style: TextStyle(
                color: theme.textColor.withOpacity(0.5),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}