import 'package:flutter/material.dart';
import 'package:get_my_location/get_my_location.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Location Example')),
        body: const LocationGetter(
          showRefreshButton: true,
          refreshButtonPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }
}
