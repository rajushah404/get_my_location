import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_my_location/src/models/location_data.dart';

class LocationGetter extends StatefulWidget {
  /// Custom builder for the widget.
  final Widget Function(
    BuildContext context,
    Position? position,
    bool isLoading,
    String? error,
    LocationData? location,
  )? builder;
  final ValueChanged<LocationData>? onLocationFetched;
  final bool showRefreshButton; // New parameter
  final Widget? refreshButton; // Customizable button
  final EdgeInsetsGeometry? refreshButtonPadding; // Button positioning

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
    this.onLocationFetched,
    this.showRefreshButton = true,
    this.refreshButton,
    this.refreshButtonPadding,
  });

  @override
  State<LocationGetter> createState() => _LocationGetterState();
}

class _LocationGetterState extends State<LocationGetter> {
  LocationData? _currentLocation;
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: widget.locationSettings,
      );

      // Add this line to update the position
      setState(() => _currentPosition = position);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      String address = [
        place.street,
        place.locality,
        place.postalCode,
        place.country
      ].where((part) => part?.isNotEmpty ?? false).join(', ');

      var locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
      );

      setState(() => _currentLocation = locationData);
      widget.onLocationFetched?.call(locationData);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(
          context, _currentPosition, _isLoading, _error, _currentLocation);
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
      children: [
        if (_currentLocation != null) ...[
          Text('Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}'),
          Text('Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}'),
          if (_currentLocation!.address != null)
            Text('Address: ${_currentLocation!.address}'),
          Text('Accuracy: ${_currentLocation!.accuracy?.toStringAsFixed(2)}m'),
          Text('Time: ${_currentLocation!.timestamp.toLocal()}'),
        ],

        // Conditional Refresh Button
        if (widget.showRefreshButton)
          Padding(
            padding: widget.refreshButtonPadding ?? EdgeInsets.zero,
            child: widget.refreshButton ??
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: const Text('Refresh Location'),
                ),
          ),
      ],
    );
  }
}
