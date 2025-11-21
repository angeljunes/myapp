class City {
  const City({
    required this.id,
    required this.name,
    required this.countryId,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String countryId;
  final double? latitude;
  final double? longitude;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['nombre'] ?? '',
      countryId: json['countryId']?.toString() ?? json['country_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? (json['latitud'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble() ?? (json['longitud'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryId': countryId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
