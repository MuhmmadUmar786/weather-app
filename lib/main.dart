import 'package:flutter/material.dart';
import 'package:mvvm_statemanagement/constants/my_app_theme.dart';
import 'package:mvvm_statemanagement/providers/weather_provider.dart';
import 'package:mvvm_statemanagement/screens/splash.dart';
import 'package:provider/provider.dart';


void main() {
  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      // theme: MyAppTheme.lightTheme,
      home:  Splash(),
    );
  }
}

