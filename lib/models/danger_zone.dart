class DangerZone {
  final String? description;  // Make nullable
  final double latitude;
  final double longitude;

  const DangerZone({
    this.description,
    required this.latitude,
    required this.longitude,
  });

  // Add factory constructor to create from JSON
  factory DangerZone.fromJson(Map<String, dynamic> json) {
    return DangerZone(
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}