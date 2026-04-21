class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final int visibility;
  final int pressure;
  final String description;
  final String mainCondition;
  final String icon;
  final DateTime sunrise;
  final DateTime sunset;
  final int cloudiness;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.visibility,
    required this.pressure,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.cloudiness,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDegree: json['wind']['deg'] ?? 0,
      visibility: json['visibility'] ?? 0,
      pressure: json['main']['pressure'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunset'] as int) * 1000),
      cloudiness: json['clouds']['all'] ?? 0,
    );
  }

  WeatherCondition get condition {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return WeatherCondition.clear;
      case 'clouds':
        return cloudiness > 70
            ? WeatherCondition.overcast
            : WeatherCondition.cloudy;
      case 'rain':
      case 'drizzle':
        return WeatherCondition.rain;
      case 'thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'snow':
        return WeatherCondition.snow;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return WeatherCondition.foggy;
      default:
        return WeatherCondition.clear;
    }
  }

  String get windDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((windDegree + 22.5) / 45).floor() % 8];
  }

  String get visibilityKm => '${(visibility / 1000).toStringAsFixed(1)} km';
}

enum WeatherCondition {
  clear,
  cloudy,
  overcast,
  rain,
  thunderstorm,
  snow,
  foggy,
}