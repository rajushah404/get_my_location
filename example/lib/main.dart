import 'package:flutter/material.dart';
import 'package:get_my_location/src/location_getter.dart';

void main() => runApp(const MyApp());

/// Demo app for [get_your_location] package.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get My Location Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LocationDemoScreen(),
    );
  }
}

class LocationDemoScreen extends StatelessWidget {
  const LocationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get My Location')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: LocationGetter(),
      ),
    );
  }
}
