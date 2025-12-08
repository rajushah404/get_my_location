import 'package:flutter/material.dart';
import 'package:get_my_location/src/location_getter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LocationGetterExample());
  }
}

class LocationGetterExample extends StatelessWidget {
  const LocationGetterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get My Location Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: LocationGetter(
            onLocationFetched: (location) {
              debugPrint('Location fetched: $location');
            },
            onError: (error) {
              debugPrint('Location error: $error');
            },
          ),
        ),
      ),
    );
  }
}
