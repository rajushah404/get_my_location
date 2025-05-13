import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// A widget that fetches and displays the device's current location.
///
/// Features:
/// - Automatic permission handling
/// - Customizable loading/error states
/// - Configurable location accuracy
///
/// Example:
/// ```dart
/// LocationGetter(
///   builder: (context, position, isLoading, error) {
///     if (isLoading) return CircularProgressIndicator();
///     if (error != null) return Text('Error: $error');
///     return Text('Lat: ${position?.latitude}');
///   },
/// )
/// ```
class LocationGetter extends StatefulWidget {
  /// Custom builder for the widget.
  final Widget Function(
    BuildContext context,
    Position? position,
    bool isLoading,
    String? error,
  )?
  builder;

  /// Widget to show while loading.
  final Widget? loadingWidget;

  /// Widget to show on error.
  final Widget? errorWidget;

  /// Location settings (accuracy, distance filter).
  final LocationSettings locationSettings;

  /// Whether to fetch location automatically when the widget initializes.
  final bool autoFetchOnInit;

  /// Creates a [LocationGetter] widget.
  const LocationGetter({
    super.key,
    this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    ),
    this.autoFetchOnInit = true,
  });

  @override
  State<LocationGetter> createState() => _LocationGetterState();
}

class _LocationGetterState extends State<LocationGetter> {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.autoFetchOnInit) _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied.');
        }
      }

      // Fetch current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: widget.locationSettings,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _currentPosition, _isLoading, _error);
    }

    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorWidget ?? Center(child: Text('Error: $_error'));
    }

    if (_currentPosition == null) {
      return const Center(child: Text('No location data available.'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _getCurrentLocation,
          child: const Text('Refresh Location'),
        ),
      ],
    );
  }
}
