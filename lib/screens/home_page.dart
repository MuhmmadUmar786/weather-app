import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mvvm_statemanagement/screens/weekly_weather_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mvvm_statemanagement/widgets/home_small_widget.dart';

import '../constants/my_app_theme.dart';
import '../providers/weather_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMM').format(now);
    // Example Output: Saturday, 30 Aug
  }


  String _location = "";
  String _lat = "";
  String _log = "";

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation().whenComplete((){
    //   fetchCurrentWeather();
    //   fetchWeather();
    //
    // });
  }

  var apiKey = '2818bfcb96eb17113b745270011e7b5c';
  List<Map<String, dynamic>> nextHours = [];

  Future<void> fetchWeather() async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$_lat&lon=$_log&appid=$apiKey&units=metric";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data.toString());

      DateTime now = DateTime.now();
      List<Map<String, dynamic>> hours = [];

      // Loop through forecast items
      for (var item in data['list']) {
        DateTime time =
        DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

        // Only take forecasts that are in the future
        if (time.isAfter(now)) {
          hours.add({
            "time": time,
            "temp": item['main']['temp'],
            "feels_like": item['main']['feels_like'],
            "wind_speed": item['wind']['speed'],
            "description": item['weather'][0]['description'],
            "icon": item['weather'][0]['icon'],
          });
        }
      }

      // Limit to next 5 entries
      hours = hours.take(5).toList();

      setState(() {
        nextHours = hours;
      });
    } else {
      print("Failed to load weather: ${response.body}");
    }
  }


  double temperature=0.0;
  double? feelsLike;
  double? windSpeed;
  // double? uvIndex;
  String description='';
  String? icon='01d';

  Future<void> fetchCurrentWeather() async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_log&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);


      setState(() {
        temperature = data['main']['temp'];
        feelsLike = data['main']['feels_like'];
        windSpeed = data["wind"]["speed"];
        // uvIndex = data['current']['uvi'];
        // pressure = data['current']['pressure'];
        description = data['weather'][0]['description'];
        icon = data['weather'][0]['icon'];
      });
      print(temperature.toString()+" "+feelsLike.toString());
    } else {
      print("Failed to fetch weather: ${response.body}");
    }
  }



  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _location = "Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _location = "Location permissions are permanently denied");
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
        setState(() {
          _location = "${placemark.locality}, ${placemark.country}";
          _lat=position.latitude.toString();
          _log=position.longitude.toString();
        });
      }
    } catch (e) {
      setState(() => _location = "Error: $e");
    }
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }




  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);

    var h=MediaQuery.of(context).size.height;
    var w=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Image.asset('assets/map.png',height: 10,width: 10,fit: BoxFit.cover,),
        ),

        title:    Text(
          getGreetingMessage(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search))
        ],
      ),

      body:
      provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          :
      RefreshIndicator(
        onRefresh: () async {
          await provider.fetchAllWeather();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0,vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.location,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20,),
              if (provider.currentWeather != null)
              Container(
                height: h*0.52,
                width: w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    SizedBox(height: 30,),

                    Image.network("https://openweathermap.org/img/wn/${provider.currentWeather!.icon}@2x.png",fit: BoxFit.cover,
                      height: 50,width: 50,),
                    SizedBox(height: 10,),

                    Text(
                      toTitleCase(provider.currentWeather!.description),
                      style: TextStyle(fontSize: 24,color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 5,),

                    Text(
                      getFormattedDate(),
                      style: TextStyle(fontSize: 12,color: Colors.grey[300], fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 30,),

                    Text(
                      '${provider.currentWeather!.temp.toInt()}°',
                      style: TextStyle(fontSize: 60,color: Colors.white, fontWeight: FontWeight.bold),
                    ),

                    Expanded(child: Container()),



                    Container(
                      width: w,
                      height: 1,
                      color: Colors.white,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HomeSmallWidget(image: 'assets/wind.png', title: 'WIND', value: '${provider.currentWeather!.speed} km/j'),
                        Container(
                          height: 65,
                          width: 1,
                          color: Colors.white,
                        ),

                        HomeSmallWidget(image: 'assets/feel.png', title: 'FEEL LIKE', value: '${provider.currentWeather!.feelsLike.toInt()}°'),

                      ],
                    ),
                    Container(
                      width: w,
                      height: 1,
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HomeSmallWidget(image: 'assets/uv.png', title: 'INDEX UV', value: '2'),



                        Container(
                          height: 65,
                          width: 1,
                          color: Colors.white,
                        ),
                        HomeSmallWidget(image: 'assets/pressure.png', title: 'PRESSURE', value: '1012 mbar'),

                      ],
                    ),
                    SizedBox(height: 0,)
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Text(
                    'Today',
                    style: TextStyle(fontSize: 17,color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Container()),
                  InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeeklyWeatherPage(
                          // location: _location,lat: _lat,lon: _log,
                        )),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Next 7 Days',
                          style: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined,size: 15,)
                      ],
                    ),
                  )

                ],
              ),
              SizedBox(height: 10,),


              Container(
                height: 115,
                width: w,
                child: provider.hours.isEmpty
                    ?

                SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 115,
                            width: w * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )

                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.hours.length,
                  itemBuilder: (context, index) {
                    final hour = provider.hours[index];
                    return  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 115,
                        width: w*0.16,
                        decoration: BoxDecoration(
                          // color: primaryColor,
                          border: Border.all(
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("${DateFormat('hh:mm a').format(hour.time)}",
                            style: TextStyle(color: Colors.black,fontSize: 12),
                            ),

                        Image.network(
                          "https://openweathermap.org/img/wn/${hour.icon}@2x.png",
                          width: 50,
                          height: 50,
                        ),

                            Text("${hour.temp.toInt()}°C",
                              style: TextStyle(color: Colors.black,fontSize: 12),

                            ),

                          ],
                        ),
                      ),
                    );

                  },
                ),
              )

            ],
          ),
        ),
      ),

    );
  }
}


