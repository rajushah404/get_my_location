class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude'],
      longitude: map['longitude'],
      accuracy: map['accuracy'],
      address: map['address'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
