import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_my_location/src/models/location_data.dart';

/// A widget that fetches and **displays** the user's current location.
///
/// It handles permission checks, shows a loading state, renders any error that
/// occurs, and displays the resolved coordinates and address. A "Refresh"
/// button is also provided so the user can manually re‑fetch the location.
class LocationGetter extends StatefulWidget {
  /// Whether to fetch location automatically when the widget initializes.
  final bool autoFetch;

  /// Location settings (accuracy, distance filter).
  final LocationSettings locationSettings;

  /// Callback when location is successfully fetched.
  final ValueChanged<LocationData>? onLocationFetched;

  /// Callback when location fetching fails.
  final ValueChanged<String>? onError;

  /// Callback when location fetching starts.
  final VoidCallback? onLoading;

  const LocationGetter({
    super.key,
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
  State<LocationGetter> createState() => _LocationGetterState();
}

class _LocationGetterState extends State<LocationGetter> {
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;

  /// Get the current location and update the UI.
  Future<void> _getLocation() async {
    widget.onLoading?.call();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: widget.locationSettings,
      );

      // Get address (best‑effort, failures here don't break the whole flow)
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country,
          ].where((part) => part != null && part.isNotEmpty).join(', ');
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoFetch) {
      _isLoading = true;
      // Trigger the first fetch after the first frame so the initial build
      // can already show the loading indicator.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getLocation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoading) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const Center(child: Text('Fetching current location...')),
        ] else if (_error != null) ...[
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ] else if (_currentLocation != null) ...[
          Text(
            'Your location:',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${_currentLocation!.latitude.toStringAsFixed(6)}',
          ),
          Text(
            'Longitude: ${_currentLocation!.longitude.toStringAsFixed(6)}',
          ),
          if (_currentLocation!.accuracy != null)
            Text('Accuracy: ${_currentLocation!.accuracy!.toStringAsFixed(1)} m'),
          if (_currentLocation!.address != null) ...[
            const SizedBox(height: 8),
            Text(
              _currentLocation!.address!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ] else ...[
          const Text('Location not fetched yet.'),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _getLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Refresh location'),
          ),
        ),
      ],
    );
  }
}
