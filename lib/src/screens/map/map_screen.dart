import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

import '../../models/alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/map_provider.dart';
import '../../widgets/create_alert_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
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

  void _updateMarkers(List<AlertModel> alerts) {
    _markers = alerts.map((alert) {
      return Marker(
        markerId: MarkerId(alert.id),
        position: LatLng(alert.latitude, alert.longitude),
        infoWindow: InfoWindow(
          title: alert.title,
          snippet: '${alert.priority} - ${alert.status}',
          onTap: () => _showAlertDetails(alert),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(alert.priority),
        ),
      );
    }).toSet();
  }

  double _getMarkerHue(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return BitmapDescriptor.hueRed;
      case 'MEDIA':
        return BitmapDescriptor.hueOrange;
      case 'BAJA':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _showAlertDetails(AlertModel alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _priorityColor(alert.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alert.priority,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(alert.username ?? 'Usuario desconocido'),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  alert.createdAt != null
                      ? '${alert.createdAt!.day}/${alert.createdAt!.month}/${alert.createdAt!.year}'
                      : 'Fecha desconocida',
                ),
              ],
            ),
            if (alert.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(alert.address!)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<MapProvider>().moveToLocation(
                        LatLng(alert.latitude, alert.longitude),
                        zoom: 18.0,
                      );
                    },
                    icon: const Icon(Icons.zoom_in),
                    label: const Text('Ver en mapa'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTap(LatLng location) {
    _showCreateAlertDialog(location);
  }

  void _showCreateAlertDialog(LatLng location) {
    showDialog(
      context: context,
      builder: (_) => CreateAlertDialog(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
  }

  void _onEmergencyPressed() async {
    final mapProvider = context.read<MapProvider>();
    
    // Intentar obtener ubicación actual
    if (!mapProvider.locationPermissionGranted) {
      await mapProvider.getCurrentLocation();
    }
    
    // Si no hay permisos, usar la posición actual del mapa (centro visible)
    final location = mapProvider.currentPosition;
    
    // Get address from coordinates
    String? address;
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      // Address lookup failed, continue without address
    }

    if (mounted) {
      final alertProvider = context.read<AlertProvider>();
      
      // Obtener el usuario actual para incluir su ID
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;
      
      final success = await alertProvider.createAlert(
        title: 'EMERGENCIA',
        description: 'Alerta de emergencia creada desde el mapa',
        latitude: location.latitude,
        longitude: location.longitude,
        priority: 'ALTA',
        address: address,
        userId: userId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta de emergencia creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear alerta: ${alertProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AlertProvider, MapProvider>(
        builder: (context, alertProvider, mapProvider, child) {
          _updateMarkers(alertProvider.alerts);

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapProvider.setMapController(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: mapProvider.currentPosition,
                  zoom: 13.0,
                ),
                markers: _markers,
                onTap: _onMapTap,
                myLocationEnabled: mapProvider.locationPermissionGranted,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              
              // Top info card
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
                                alertProvider.loading
                                    ? 'Cargando alertas...'
                                    : 'Alertas: ${alertProvider.alerts.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (mapProvider.locationLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            IconButton(
                              onPressed: mapProvider.getCurrentLocation,
                              icon: const Icon(Icons.my_location),
                              tooltip: 'Mi ubicación',
                            ),
                            IconButton(
                              onPressed: alertProvider.loadAlerts,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Actualizar alertas',
                            ),
                          ],
                        ),
                        if (alertProvider.error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            alertProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        if (mapProvider.locationError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            mapProvider.locationError!,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Floating action buttons
              Positioned(
                bottom: 24,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'emergency',
                      onPressed: _onEmergencyPressed,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: const Text('EMERGENCIA'),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'alerts',
                      onPressed: () async {
                        if (alertProvider.alerts.isEmpty) return;
                        
                        final selected = await showModalBottomSheet<AlertModel>(
                          context: context,
                          builder: (_) => Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.7,
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Lista de Alertas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: alertProvider.alerts.length,
                                    itemBuilder: (_, index) {
                                      final alert = alertProvider.alerts[index];
                                      return ListTile(
                                        leading: Icon(
                                          Icons.circle,
                                          color: _priorityColor(alert.priority),
                                          size: 12,
                                        ),
                                        title: Text(alert.title),
                                        subtitle: Text(
                                          alert.address ?? alert.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Text(alert.priority),
                                        onTap: () => Navigator.of(context).pop(alert),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        
                        if (selected != null) {
                          mapProvider.moveToLocation(
                            LatLng(selected.latitude, selected.longitude),
                            zoom: 16.0,
                          );
                          _showAlertDetails(selected);
                        }
                      },
                      child: const Icon(Icons.list_alt),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
