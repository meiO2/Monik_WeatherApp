import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // API key is loaded from .env file — never hardcode it here
  String get _apiKey {
    final key = dotenv.env['OPENWEATHER_API_KEY'];
    if (key == null || key.isEmpty || key == 'your_api_key_here') {
      throw Exception(
          'OpenWeather API key not found. Please add it to your .env file.');
    }
    return key;
  }

  /// Fetch weather by city name
  Future<WeatherData> getWeatherByCity(String city) async {
    final url = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric',
    );

    final response = await http.get(url);
    return _handleResponse(response);
  }

  /// Fetch weather by geographic coordinates
  Future<WeatherData> getWeatherByCoords(
      double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );

    final response = await http.get(url);
    return _handleResponse(response);
  }

  WeatherData _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your .env file.');
    } else if (response.statusCode == 404) {
      throw Exception('City not found. Please check the city name.');
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch weather data.');
    }
  }
}