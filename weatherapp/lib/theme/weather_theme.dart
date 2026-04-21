import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color cardColor;
  final List<Color> gradientColors;
  final String emoji;
  final String backgroundDescription;
  final bool isDark;

  const WeatherTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.cardColor,
    required this.gradientColors,
    required this.emoji,
    required this.backgroundDescription,
    required this.isDark,
  });

  static WeatherTheme forCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return WeatherTheme(
          primaryColor: const Color(0xFFFF9800),
          secondaryColor: const Color(0xFFFFCC02),
          textColor: const Color(0xFF1A1A2E),
          cardColor: Colors.white.withOpacity(0.25),
          gradientColors: const [
            Color(0xFF87CEEB),
            Color(0xFF4FC3F7),
            Color(0xFF0288D1),
          ],
          emoji: '☀️',
          backgroundDescription: 'clear',
          isDark: false,
        );

      case WeatherCondition.cloudy:
        return WeatherTheme(
          primaryColor: const Color(0xFF78909C),
          secondaryColor: const Color(0xFFB0BEC5),
          textColor: const Color(0xFF1A1A2E),
          cardColor: Colors.white.withOpacity(0.3),
          gradientColors: const [
            Color(0xFFB0BEC5),
            Color(0xFF78909C),
            Color(0xFF546E7A),
          ],
          emoji: '⛅',
          backgroundDescription: 'cloudy',
          isDark: false,
        );

      case WeatherCondition.overcast:
        return WeatherTheme(
          primaryColor: const Color(0xFF546E7A),
          secondaryColor: const Color(0xFF607D8B),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.15),
          gradientColors: const [
            Color(0xFF546E7A),
            Color(0xFF37474F),
            Color(0xFF263238),
          ],
          emoji: '☁️',
          backgroundDescription: 'overcast',
          isDark: true,
        );

      case WeatherCondition.rain:
        return WeatherTheme(
          primaryColor: const Color(0xFF42A5F5),
          secondaryColor: const Color(0xFF1E88E5),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.15),
          gradientColors: const [
            Color(0xFF37474F),
            Color(0xFF455A64),
            Color(0xFF1565C0),
          ],
          emoji: '🌧️',
          backgroundDescription: 'rainy',
          isDark: true,
        );

      case WeatherCondition.thunderstorm:
        return WeatherTheme(
          primaryColor: const Color(0xFFAB47BC),
          secondaryColor: const Color(0xFFFFEB3B),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.12),
          gradientColors: const [
            Color(0xFF1A0533),
            Color(0xFF2C1654),
            Color(0xFF1A237E),
          ],
          emoji: '⛈️',
          backgroundDescription: 'stormy',
          isDark: true,
        );

      case WeatherCondition.snow:
        return WeatherTheme(
          primaryColor: const Color(0xFF90CAF9),
          secondaryColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1A237E),
          cardColor: Colors.white.withOpacity(0.35),
          gradientColors: const [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
            Color(0xFF90CAF9),
          ],
          emoji: '❄️',
          backgroundDescription: 'snowy',
          isDark: false,
        );

      case WeatherCondition.foggy:
        return WeatherTheme(
          primaryColor: const Color(0xFF90A4AE),
          secondaryColor: const Color(0xFFB0BEC5),
          textColor: const Color(0xFF263238),
          cardColor: Colors.white.withOpacity(0.25),
          gradientColors: const [
            Color(0xFFCFD8DC),
            Color(0xFFB0BEC5),
            Color(0xFF90A4AE),
          ],
          emoji: '🌫️',
          backgroundDescription: 'foggy',
          isDark: false,
        );
    }
  }
}