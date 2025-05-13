class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;
  final String? error;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasError => error != null;
  bool get hasAddress => address != null;

  @override
  String toString() {
    return 'LocationData(latitude: $latitude, longitude: $longitude, '
        'accuracy: $accuracy, address: $address, error: $error)';
  }
}
