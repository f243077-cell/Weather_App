import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secret.dart';

class WeatherService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeather(String cityName) async {
    final res = await http.get(
      Uri.parse('$_baseUrl?q=$cityName&APPID=$APIKEY'),
    );
    final data = jsonDecode(res.body);
    if (data['cod'] != 200) throw Exception(data['message']);
    return {
      'city': data['name'],
      'temp': data['main']['temp'],
      'feelsLike': data['main']['feels_like'],
      'condition': data['weather'][0]['main'],
      'humidity': data['main']['humidity'].toDouble(),
      'windSpeed': data['wind']['speed'],
      'pressure': data['main']['pressure'].toDouble(),
      'sunrise': data['sys']['sunrise'],
      'sunset': data['sys']['sunset'],
    };
  }

  IconData getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.cloud;
    }
  }
}
