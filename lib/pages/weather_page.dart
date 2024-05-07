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

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();


    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }

    catch (e){
      print(e);
    }
  }

 String getWeatherAnimation(String? mainCondition) {
  if (mainCondition == null) return 'assets/loading.json';
  String timeOfDay = _dayOrNight(DateTime.now().millisecondsSinceEpoch ~/ 1000);

  // Simplify the switch statement by removing redundant cases
  switch (mainCondition.toLowerCase()) {
    case 'clear':
      return timeOfDay == "Day" ? 'assets/sun.json' : 'assets/night.json';
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'fog':
      // For these conditions, the same animation is used for day and night
      return 'assets/fog.json';
    case 'clouds':
      return timeOfDay == "Day" ? 'assets/cloud.json' : 'assets/cloud.json';
    case 'rain':
    case 'drizzle':
    case 'shower rain':
      return timeOfDay == "Day" ? 'assets/rain.json' : 'assets/rain.json';
    case 'thunderstorm':
      // Thunderstorm animation is the same for day and night
      return 'assets/thunder.json';
    case'snow':
      return timeOfDay == "Day" ? 'assets/snow.json' : 'assets/snow_night.json';
    default:
      return 'assets/loading.json';
  }
}

String _convertDegreesToCardinal(String degrees) {
  final deg = int.tryParse(degrees) ?? 0;
  // Use a more efficient way to determine the cardinal direction
  const directions = ["North", "Northeast", "East", "Southeast", "South", "Southwest", "West", "Northwest"];
  int index = ((deg + 22.5) % 360) ~/ 45;
  return directions[index];
}

String _formatTime(int timeStamp) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  // Use DateFormat if available or keep as is for simplicity
  return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
}

String _dayOrNight(int timeStamp) {
  final hour = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000).hour;
  return (hour >= 6 && hour < 18) ? "Day" : "Night";
}

String displaySunriseOrSunset() {
  String timeOfDay = _dayOrNight(DateTime.now().millisecondsSinceEpoch ~/ 1000);
  // Ensure null safety with null-aware operators
  String formattedSunrise = _weather?.sunrise != null ? _formatTime(_weather!.sunrise) : "N/A";
  String formattedSunset = _weather?.sunset != null ? _formatTime(_weather!.sunset) : "N/A";

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
    backgroundColor: Colors.blueGrey[900], // Using a deep blue-grey for a sleek look
    body: SafeArea(
      child: SingleChildScrollView( // Allows the content to be scrollable
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start
            children: [
              const SizedBox(height: 20),
              Text(
                _weather?.cityName ?? "City not found", // Default value if cityName is null
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              Text(
                "Condition: "+ _weather!.mainCondition ?? "Condition loading...", // Default value if mainCondition is null
                style: const TextStyle(
                    fontSize: 20, // Increased font size
                    color: Colors.white70
                ),
              ),
              const SizedBox(height: 20),
              Center( // Centers the Lottie animation
                child: Lottie.asset(
                  getWeatherAnimation(_weather?.mainCondition),
                  width: 300,
                  height: 300,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '${_weather?.temperature?.round() ?? "N/A"}°C', // Default value if temperature is null
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Feels like: ${_weather?.feelsLike?.round() ?? "N/A"}°C", // Default value if feelsLike is null
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Humidity: ${_weather?.humidity ?? "N/A"}%", // Default value if humidity is null
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              Text(
                "Wind: ${_weather?.windSpeed ?? "N/A"} km/h - ${_weather?.windDirection != null ? _convertDegreesToCardinal(_weather!.windDirection!) : "Direction unknown"}", // Default message if windDirection is null
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