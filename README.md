# Get My Location 🌍

[![pub package](https://img.shields.io/pub/v/get_my_location.svg)](https://pub.dev/packages/get_my_location)

A Flutter widget that **fetches and displays the user's current location** with
address lookup, loading and error states, and a refresh button.

## ✨ Features
- 📍 Get latitude/longitude with accuracy
- 🏠 Reverse geocoding for address lookup
- ⏳ Built‑in loading and error UI
- 🔄 One‑tap refresh button

## 🚀 Installation

```yaml
dependencies:
  get_my_location: ^2.0.3
```

## 🧩 Basic usage

```dart
import 'package:flutter/material.dart';
import 'package:get_my_location/get_my_location.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Get My Location')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: LocationGetter(),
          ),
        ),
      ),
    );
  }
}