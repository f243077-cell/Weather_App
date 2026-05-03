import 'package:flutter/material.dart';
import 'package:weather_app/Additional_Info_item.dart';
import 'package:weather_app/HourlyForecastItem.dart';
import 'package:weather_app/Weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _cityController = TextEditingController();

  Map<String, dynamic>? mainWeather;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> cityWeatherList = [];

  @override
  void initState() {
    super.initState();
    _loadMainWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadMainWeather() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await _service.fetchWeather('London');
      setState(() {
        mainWeather = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addCity(String cityName) async {
    final name = cityName.trim();
    if (name.isEmpty) return;
    if (cityWeatherList.any(
      (c) => c['city'].toString().toLowerCase() == name.toLowerCase(),
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name is already added')));
      return;
    }
    try {
      final data = await _service.fetchWeather(name);
      setState(() => cityWeatherList.add(data));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('City not found: $name')));
    }
  }

  void _swapWithMain(int index) {
    setState(() {
      final tapped = cityWeatherList[index];
      cityWeatherList[index] = mainWeather!;
      mainWeather = tapped;
    });
  }

  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add City'),
        content: TextField(
          controller: _cityController,
          decoration: const InputDecoration(hintText: 'Enter city name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _cityController.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addCity(_cityController.text);
              _cityController.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Kelvin to Celsius
  String _toCelsius(double kelvin) =>
      '${(kelvin - 273.15).toStringAsFixed(1)}°C';

  // Unix timestamp to time string
  String _formatTime(int unixTimestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  // Sunrise/sunset progress (0.0 to 1.0)
  double _sunProgress(int sunrise, int sunset) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    if (now <= sunrise) return 0.0;
    if (now >= sunset) return 1.0;
    return (now - sunrise) / (sunset - sunrise);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null)
      return Scaffold(body: Center(child: Text('Error: $error')));

    final sunrise = mainWeather!['sunrise'] as int;
    final sunset = mainWeather!['sunset'] as int;
    final progress = _sunProgress(sunrise, sunset);

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d0d1a),
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadMainWeather,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1a2a4a),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // City name with dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4a9eff),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mainWeather!['city'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Temperature
                  Text(
                    _toCelsius(mainWeather!['temp'] as double),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                    ),
                  ),

                  // Feels like
                  Text(
                    'Feels like ${_toCelsius(mainWeather!['feelsLike'] as double)}',
                    style: const TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  // Condition pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _service.getWeatherIcon(mainWeather!['condition']),
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mainWeather!['condition'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Other cities ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Other Cities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddCityDialog,
                  icon: const Icon(
                    Icons.add,
                    size: 14,
                    color: Color(0xFF4a9eff),
                  ),
                  label: const Text(
                    'Add City',
                    style: TextStyle(color: Color(0xFF4a9eff), fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4a9eff).withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Color(0xFF4a9eff),
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── City cards using HourlyForecastItem ────────────────
            cityWeatherList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Tap "Add City" to get started',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cityWeatherList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final city = cityWeatherList[index];
                        return GestureDetector(
                          onTap: () => _swapWithMain(index),
                          onLongPress: () {
                            setState(() => cityWeatherList.removeAt(index));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${city['city']} removed'),
                              ),
                            );
                          },
                          child: HourlyForecastItem(
                            time: city['city'],
                            temperature: _toCelsius(city['temp'] as double),
                            icon: _service.getWeatherIcon(city['condition']),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 20),
            // ── Additional info ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value:
                        '${(mainWeather!['humidity'] as double).toStringAsFixed(0)}%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value:
                        '${(mainWeather!['windSpeed'] as double).toStringAsFixed(1)} m/s',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AdditionalInfoItem(
                    icon: Icons.speed,
                    label: 'Pressure',
                    value:
                        '${(mainWeather!['pressure'] as double).toStringAsFixed(0)} hPa',
                  ),
                ),
              ],
            ),

            // ── Sunrise & Sunset ───────────────────────────────────
            const Text(
              'Sunrise & Sunset',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a2a4a),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sunrise
                      Column(
                        children: [
                          const Icon(
                            Icons.wb_twilight,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sunrise',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(sunrise),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Progress bar
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.wb_sunny,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(height: 6),
                              Stack(
                                children: [
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.orange, Colors.amber],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sunset
                      Column(
                        children: [
                          const Icon(
                            Icons.nights_stay,
                            color: Colors.blueAccent,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sunset',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(sunset),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
