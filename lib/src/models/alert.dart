import 'package:latlong2/latlong.dart';

class AlertModel {
  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.position,
    this.address,
  });

  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final LatLng position;
  final String? address;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble() ??
        (json['latitud'] as num?)?.toDouble() ??
        0;
    final lng = (json['longitude'] as num?)?.toDouble() ??
        (json['longitud'] as num?)?.toDouble() ??
        0;
    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Alerta',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'MEDIA',
      status: json['status'] ?? 'PENDIENTE',
      position: LatLng(lat, lng),
      address: json['address'] ?? json['direccion'],
    );
  }
}
