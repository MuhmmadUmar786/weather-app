import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/current_weather.dart';

class WeatherProvider with ChangeNotifier {
  CurrentWeather? currentWeather;
  List<HourlyWeather> hourlyForecast = [];
  List<DailyWeather> dailyForecast = [];

  String location = "";
  String? latitude;
  String? longitude;
  bool isLoading = false;
  var apiKey = ''; //get api key from https://api.openweathermap.org


  //get current location, latitude and longitude
  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          location = "Location permissions are denied";
          notifyListeners();

          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        location = "Location permissions are permanently denied";
        notifyListeners();

        return;
      }
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get city and country
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        location = "${placemark.locality}, ${placemark.country}";
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        notifyListeners();
      }
    } catch (e) {
      location = "Error: $e";
      notifyListeners();
    }
  }


  //fetch current temperature
  Future<void> fetchCurrentWeather() async {
    if (latitude == null || longitude == null) return;

    isLoading = true;
    notifyListeners();


    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      currentWeather = CurrentWeather(
        temp: data['main']['temp'],
        feelsLike: data['main']['feels_like'],
        description: data['weather'][0]['description'],
        icon: data['weather'][0]['icon'],
        speed: data["wind"]["speed"].toString(),
      );
    } else {
      print("Failed to fetch weather: ${response.body}");
    }

    isLoading = false;

    notifyListeners();
  }


//hourly weather like next 5-7 hours
  List<HourlyWeather> hours = [];

  Future<void> fetchHourlyWeather() async {
    if (latitude == null || longitude == null) return;

    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data.toString());

      DateTime now = DateTime.now();

      // Loop through forecast items
      for (var item in data['list']) {
        DateTime time =
        DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

        // Only take forecasts that are in the future
        if (time.isAfter(now)) {
          hours.add(
              HourlyWeather(
                time: time,
                temp: item['main']['temp'],
                feels_like: item['main']['feels_like'].toString(),
                wind_speed: item['wind']['speed'].toString(),
                description: item['weather'][0]['description'],
                icon: item['weather'][0]['icon'],
              )
            // "time": time,
            // "temp": item['main']['temp'],
            // "feels_like": item['main']['feels_like'],
            // "wind_speed": item['wind']['speed'],
            // "description": item['weather'][0]['description'],
            // "icon": item['weather'][0]['icon'],
          );
        }
      }
      // Limit to next 5 entries
      hours = hours.take(10).toList();
      // print("Hours data:${hours.length}");
      notifyListeners();

      // hourlyForecast = hours;
    } else {
      print("Failed to load weather: ${response.body}");
    }
    notifyListeners();
  }



  //weekly weather data

  Future<void> fetch7DayForecast() async {
    if (latitude == null || longitude == null) return;

    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      Map<String, List<dynamic>> dailyData = {};

      // Group forecasts by date
      for (var item in data["list"]) {
        final date = DateTime.fromMillisecondsSinceEpoch(item["dt"] * 1000);
        final day = "${date.year}-${date.month}-${date.day}";

        dailyData.putIfAbsent(day, () => []);
        dailyData[day]!.add(item);
      }

      // Convert grouped data into List<DailyWeather>
      dailyForecast = dailyData.entries.map((entry) {
        final forecasts = entry.value;

        double avgTemp = forecasts
            .map((f) => f["main"]["temp"] as num)
            .reduce((a, b) => a + b) /
            forecasts.length;

        double avgWind = forecasts
            .map((f) => f["wind"]["speed"] as num)
            .reduce((a, b) => a + b) /
            forecasts.length;

        // pick first icon of the day (you can improve by mode calculation)
        String icon = forecasts[0]["weather"][0]["icon"];

        return DailyWeather(
          date: entry.key,
          avgTemp: avgTemp,
          avgWind: avgWind,
          icon: icon,
        );
      }).toList();

      print("✅ Forecast parsed: ${dailyForecast.length} days");
    } else {
      print("Failed to load weather: ${response.body}");

      throw Exception("Failed to load forecast");
    }
    notifyListeners();

  }

  // 🚀 Fetch all together
  Future<void> fetchAllWeather() async {
    await _getCurrentLocation();
    await fetchCurrentWeather();
    await fetchHourlyWeather();
    await fetch7DayForecast();
  }

}
