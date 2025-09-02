import 'package:flutter/material.dart';
import 'package:mvvm_statemanagement/constants/my_app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart'; // for formatting date


class WeeklyWeatherPage extends StatefulWidget {
  // var location,lat,lon;
  // WeeklyWeatherPage({
  //   required this.location,
  //   required this.lat,
  //   required this.lon,
  //   super.key});

  @override
  State<WeeklyWeatherPage> createState() => _WeeklyWeatherPageState();
}

class _WeeklyWeatherPageState extends State<WeeklyWeatherPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // fetch7DayForecast(widget.lat,widget.lon);
  }


  var apiKey = '2818bfcb96eb17113b745270011e7b5c';
  Map<String, List<dynamic>> dailyData = {};

  Future<void> fetch7DayForecast(String lat, String lon) async {
    final apiKey = "2818bfcb96eb17113b745270011e7b5c";
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Group forecasts by date

      for (var item in data["list"]) {
        final date = DateTime.fromMillisecondsSinceEpoch(item["dt"] * 1000);
        final day = "${date.year}-${date.month}-${date.day}";

        dailyData.putIfAbsent(day, () => []);
        dailyData[day]!.add(item);
      }

      // Summarize each day (avg temp, wind, etc.)
      dailyData.forEach((day, forecasts) {
        double avgTemp = forecasts
            .map((f) => f["main"]["temp"] as num)
            .reduce((a, b) => a + b) /
            forecasts.length;

        double avgWind = forecasts
            .map((f) => f["wind"]["speed"] as num)
            .reduce((a, b) => a + b) /
            forecasts.length;

        print("📅 $day: temp=$avgTemp°C, wind=$avgWind m/s");
      });

      setState(() {
        dailyEntries= dailyData.entries.toList();;

      });
    } else {
      throw Exception("Failed to load forecast");
    }
  }

  List<MapEntry<String, List<dynamic>>> dailyEntries=[];
  String formatToDayMonth(String input) {
    // handles "2025-8-31" and "2025-08-31"
    final dt = DateFormat('y-M-d').parseStrict(input.trim());
    return DateFormat('d MMM').format(dt);      // -> "31 Aug"
  }

  String dayNameFrom(String input) {
    final dt = DateFormat('y-M-d').parseStrict(input.trim());
    return DateFormat('EEEE').format(dt);       // -> "Sunday"
  }

  @override
  Widget build(BuildContext context) {
    // final dailyEntries = dailyData.entries.toList();
    var h=MediaQuery.of(context).size.height;
    var w=MediaQuery.of(context).size.width;
    final provider = Provider.of<WeatherProvider>(context);

    return Scaffold(

      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,size: 17,)),
        title: Text(
          provider.location,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: Colors.white),
        ),
        centerTitle: true,
      ),
      body:ListView.builder(
        itemCount: provider.dailyForecast.length,
        itemBuilder: (context, index) {
          final day = provider.dailyForecast[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 10),
            child: Container(
              height: 50,
              width: w,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.network("https://openweathermap.org/img/wn/${day.icon}@2x.png"),
                  SizedBox(width: 25,),
                  Text("${dayNameFrom(day.date)}, ",
                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  Text("${formatToDayMonth(day.date)}",
                    style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey[400]),),

                  Expanded(child: Container()),
                  // SizedBox(width: 25,),
                  Text("${day.avgTemp.toStringAsFixed(0)}/",
                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  Text("${day.avgTemp.toStringAsFixed(1)}°",
                    style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey[400]),),
                ],
              ),
            ),
          );

          //   ListTile(
          //   leading: Image.network(
          //     "https://openweathermap.org/img/wn/${day.icon}@2x.png",
          //   ),
          //   title: Text("${day.date}"),
          //   subtitle: Text("Temp: ${day.avgTemp.toStringAsFixed(1)}°C"),
          //   trailing: Text("Wind: ${day.avgWind.toStringAsFixed(1)} m/s"),
          // );
        },
      )

      // ListView.builder(
      //   itemCount: provider.dailyForecast.length,
      //   itemBuilder: (context, index) {
      //     final entry = provider.dailyForecast[index];
      //
      //     final date = entry.date;
      //
      //
      //     final items = entry.value;
      //
      //     // Pick first item of the day (you can also calculate avg here)
      //     final item = items[0];
      //
      //     final temp = item["main"]["temp"];
      //     final feelsLike = item["main"]["feels_like"];
      //     final iconCode = item["weather"][0]["icon"];
      //     final iconUrl = "http://openweathermap.org/img/wn/$iconCode@2x.png";
      //
      //     return ;
      //
      //
      //   },
      // ),
    );
  }
}
