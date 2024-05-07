class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final String humidity;
  final double feelsLike;
  final double windSpeed;
  final String windDirection;
  final int timeStamp;
  final int sunrise;
  final int sunset;
  final int pressure;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.windDirection,
    required this.timeStamp,
    required this.sunrise,
    required this.sunset,
    required this.pressure,

  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      humidity: json['main']['humidity'].toString(),
      feelsLike: json['main']['feels_like'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      windDirection: json['wind']['deg'].toString(),
      timeStamp: json['dt'].toInt(),
      sunrise: json['sys']['sunrise'].toInt(),
      sunset: json['sys']['sunset'].toInt(),
      pressure: json['main']['pressure'].toInt(),

    );
  }
}