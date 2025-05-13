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
    return LocationGetter(
      onLocationFetched: (location) {
        print('Location: ${location.address}');
      },
      onError: (error) {
        print('Error: $error');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Basic Example')),
        body: const Center(
          child: Text('Check console for location updates'),
        ),
      ),
    );
  }
}
