class AlertModel {
  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.address,
    this.userId,
    this.username,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final double latitude;
  final double longitude;
  final String? address;
  final String? userId;
  final String? username;
  final DateTime? createdAt;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble() ??
        (json['latitud'] as num?)?.toDouble() ??
        0.0;
    final lng = (json['longitude'] as num?)?.toDouble() ??
        (json['longitud'] as num?)?.toDouble() ??
        0.0;
    
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {
        // If parsing fails, leave as null
      }
    }

    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['titulo'] ?? 'Alerta',
      description: json['description'] ?? json['descripcion'] ?? '',
      priority: json['priority'] ?? json['prioridad'] ?? 'MEDIA',
      status: json['status'] ?? json['estado'] ?? 'PENDIENTE',
      latitude: lat,
      longitude: lng,
      address: json['address'] ?? json['direccion'],
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      username: json['username'] ?? json['usuario'],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'userId': userId,
      'username': username,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'AlertModel(id: $id, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
