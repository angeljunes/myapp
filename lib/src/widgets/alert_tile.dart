import 'package:flutter/material.dart';

import '../models/alert.dart';

class AlertTile extends StatelessWidget {
  const AlertTile({
    super.key,
    required this.alert,
    this.onTap,
  });

  final AlertModel alert;
  final VoidCallback? onTap;

  Color get _priorityColor {
    switch (alert.priority.toUpperCase()) {
      case 'ALTA':
        return Colors.redAccent;
      case 'MEDIA':
        return Colors.amber;
      case 'BAJA':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _priorityColor,
          child: Text(
            alert.priority.characters.first,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(alert.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description),
            const SizedBox(height: 4),
            Text(
              alert.address ??
                  'Lat: ${alert.position.latitude.toStringAsFixed(3)}, Lng: ${alert.position.longitude.toStringAsFixed(3)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text('Estado: ${alert.status}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
