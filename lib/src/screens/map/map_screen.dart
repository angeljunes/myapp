import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/alert.dart';
import '../../services/alerts_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final AlertsService _alertsService = AlertsService();

  List<AlertModel> _alerts = [];
  bool _loadingAlerts = true;
  bool _locating = false;
  LatLng _mapCenter = const LatLng(-12.0464, -77.0428); // Lima por defecto
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
    _getCurrentLocation();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _loadingAlerts = true;
      _error = null;
    });
    try {
      final alerts = await _alertsService.fetchAlerts();
      setState(() {
        _alerts = alerts;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loadingAlerts = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Activa el GPS para usar tu ubicación.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permite el acceso a la ubicación para centrar el mapa.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Los permisos de ubicación están denegados permanentemente. Ve a ajustes para habilitarlos.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _mapCenter = point;
      });
      _mapController.move(point, 15);
    } catch (e) {
      setState(() {
        _error = 'No se pudo obtener tu ubicación: $e';
      });
    } finally {
      setState(() => _locating = false);
    }
  }

  List<Marker> get _markers {
    return _alerts
        .map(
          (alert) => Marker(
            width: 40,
            height: 40,
            point: alert.position,
            child: Tooltip(
              message:
                  '${alert.title}\nPrioridad: ${alert.priority}\nEstado: ${alert.status}',
              child: GestureDetector(
                onTap: () => _showAlertDetails(alert),
                child: Icon(
                  Icons.location_on,
                  color: _priorityColor(alert.priority),
                  size: 36,
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return Colors.red;
      case 'MEDIA':
        return Colors.amber;
      case 'BAJA':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  void _showAlertDetails(AlertModel alert) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(alert.description),
            const SizedBox(height: 12),
            Text('Prioridad: ${alert.priority}'),
            Text('Estado: ${alert.status}'),
            if (alert.address != null) ...[
              const SizedBox(height: 12),
              Text('Dirección: ${alert.address}'),
            ],
          ],
        ),
      ),
    );
  }

  void _onEmergencyPressed() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Botón de emergencia'),
        content: const Text(
            'Aquí podrás enviar una alerta automática basada en tu ubicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Alertas'),
        actions: [
          IconButton(
            onPressed: _fetchAlerts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar alertas',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13,
              onTap: (_, point) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Ubicación seleccionada'),
                    content: Text(
                        'Lat: ${point.latitude.toStringAsFixed(5)}\nLng: ${point.longitude.toStringAsFixed(5)}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.rcas.mobile',
              ),
              if (_markers.isNotEmpty)
                MarkerLayer(
                  markers: _markers,
                  rotate: false,
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _loadingAlerts
                                ? 'Cargando alertas...'
                                : 'Alertas registradas: ${_alerts.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_locating)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Usar mi ubicación',
                        ),
                      ],
                    ),
                    if (_error != null)...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'emergency',
                  onPressed: _onEmergencyPressed,
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('EMERGENCIA'),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'alerts',
                  onPressed: () async {
                    if (_alerts.isEmpty) return;
                    final selected = await showModalBottomSheet<AlertModel>(
                      context: context,
                      builder: (_) => Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _alerts.length,
                          itemBuilder: (_, index) {
                            final alert = _alerts[index];
                            return ListTile(
                              title: Text(alert.title),
                              subtitle: Text(alert.address ?? alert.description),
                              trailing: Icon(Icons.circle,
                                  color: _priorityColor(alert.priority), size: 12),
                              onTap: () => Navigator.of(context).pop(alert),
                            );
                          },
                        ),
                      ),
                    );
                    if (selected != null) {
                      _mapController.move(selected.position, 16);
                      _showAlertDetails(selected);
                    }
                  },
                  child: const Icon(Icons.list_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
