import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../model/weather_model.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('eab1ef22f11762c08e85a07da56ca4e0');
  Weather? _weather;

  Future<void> _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      if (mounted) {
        setState(() {
          _weather = weather;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/loading.json';
    String timeOfDay = _dayOrNight(DateTime.now().millisecondsSinceEpoch ~/ 1000);

    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return timeOfDay == "Day" ? 'assets/sun.json' : 'assets/night.json';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/fog.json';
      case 'clouds':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'snow':
        return timeOfDay == "Day" ? 'assets/snow.json' : 'assets/snow_night.json';
      default:
        return 'assets/loading.json';
    }
  }

  String _convertDegreesToCardinal(String? degrees) {
    final deg = int.tryParse(degrees ?? '0') ?? 0;
    const directions = ["North", "Northeast", "East", "Southeast", "South", "Southwest", "West", "Northwest"];
    int index = ((deg + 22.5) % 360) ~/ 45;
    return directions[index];
  }

  String _formatTime(int? timeStamp) {
    if (timeStamp == null) return "N/A";
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String _dayOrNight(int timeStamp) {
    final hour = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000).hour;
    return (hour >= 6 && hour < 18) ? "Day" : "Night";
  }

  String displaySunriseOrSunset() {
    String timeOfDay = _dayOrNight(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    String formattedSunrise = _formatTime(_weather?.sunrise);
    String formattedSunset = _formatTime(_weather?.sunset);

    return timeOfDay == "Night" ? "Sunrise: $formattedSunrise" : "Sunset: $formattedSunset";
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  _weather?.cityName ?? "City not found",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
                Text(
                  "Condition: ${_weather?.mainCondition ?? "Condition loading..."}",
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Lottie.asset(
                    getWeatherAnimation(_weather?.mainCondition),
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${_weather?.temperature.round() ?? "N/A"}°C',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Feels like: ${_weather?.feelsLike.round() ?? "N/A"}°C",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Humidity: ${_weather?.humidity ?? "N/A"}%",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "Wind: ${_weather?.windSpeed ?? "N/A"} km/h - ${_weather?.windDirection != null ? _convertDegreesToCardinal(_weather!.windDirection) : "Direction unknown"}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  displaySunriseOrSunset(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}