class CurrentWeather {
  final double temp;
  final double feelsLike;
  final String description;
  final String icon;
  final String speed;

  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.speed,
  });
}

class HourlyWeather {
  final DateTime time;
  final double temp;
  final String icon;
  final String feels_like;
  final String wind_speed;
  final String description;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.icon,
    required this.feels_like,
    required this.wind_speed,
    required this.description,
  });
}

class DailyWeather {
  final String date; // e.g. "2025-08-31"
  final double avgTemp;
  final double avgWind;
  final String icon;

  DailyWeather({
    required this.date,
    required this.avgTemp,
    required this.avgWind,
    required this.icon,
  });
}
