import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_my_location/src/models/location_data.dart';

class LocationGetter extends StatefulWidget {
  /// The child widget that will have access to location data
  final Widget child;

  /// Whether to fetch location automatically when the widget initializes
  final bool autoFetch;

  /// Location settings (accuracy, distance filter)
  final LocationSettings locationSettings;

  /// Callback when location is successfully fetched
  final ValueChanged<LocationData>? onLocationFetched;

  /// Callback when location fetching fails
  final ValueChanged<String>? onError;

  /// Callback when location fetching starts
  final VoidCallback? onLoading;

  const LocationGetter({
    super.key,
    required this.child,
    this.autoFetch = true,
    this.locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    ),
    this.onLocationFetched,
    this.onError,
    this.onLoading,
  });

  @override
  State<LocationGetter> createState() => LocationGetterState();

  /// Static method to access the LocationGetterState from descendant widgets
  static LocationGetterState? of(BuildContext context) {
    return context.findAncestorStateOfType<LocationGetterState>();
  }
}

class LocationGetterState extends State<LocationGetter> {
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;

  /// Get the current location
  Future<void> getLocation() async {
    widget.onLoading?.call();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: widget.locationSettings,
      );

      // Get address
      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country
          ].where((part) => part?.isNotEmpty ?? false).join(', ');
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      // Create location data
      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
      );

      // Update state and callbacks
      setState(() => _currentLocation = locationData);
      widget.onLocationFetched?.call(locationData);
    } catch (e) {
      final error = e.toString();
      setState(() => _error = error);
      widget.onError?.call(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoFetch) getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Public getters for the current state
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
}
