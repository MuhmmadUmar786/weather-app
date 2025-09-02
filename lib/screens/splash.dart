import 'package:flutter/material.dart';
import 'package:mvvm_statemanagement/screens/home_page.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {


  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final weatherProvider =
    Provider.of<WeatherProvider>(context, listen: false);

    try {
      await weatherProvider.fetchAllWeather(); // ✅ Load all data here
      await Future.delayed(const Duration(seconds: 2)); // just for splash effect
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  HomePage()),
      );
    } catch (e) {
      print("❌ Error loading weather: $e");
      // Optionally show an error screen or retry
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/weather.png',height: 200,width: 200,),
      ),
    );
  }
}
