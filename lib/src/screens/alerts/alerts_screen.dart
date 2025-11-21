import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/map_provider.dart';
import '../../widgets/alert_tile.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'TODAS';
  final List<String> _filters = ['TODAS', 'ALTA', 'MEDIA', 'BAJA'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  List<AlertModel> _getFilteredAlerts(List<AlertModel> alerts) {
    if (_selectedFilter == 'TODAS') {
      return alerts;
    }
    return alerts.where((alert) => alert.priority == _selectedFilter).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return Colors.red;
      case 'MEDIA':
        return Colors.orange;
      case 'BAJA':
        return Colors.green;
      default:
        return Colors.grey;
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
                    color: _getPriorityColor(alert.priority),
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
                      // Navigate to map tab and show this alert
                      context.read<MapProvider>().moveToLocation(
                        LatLng(alert.latitude, alert.longitude),
                        zoom: 18.0,
                      );
                      // You might want to switch to map tab here
                    },
                    icon: const Icon(Icons.map),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, child) {
          final filteredAlerts = _getFilteredAlerts(alertProvider.alerts);

          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrar por prioridad:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedFilter = filter);
                                }
                              },
                              selectedColor: filter == 'TODAS' 
                                  ? Colors.blue[100] 
                                  : _getPriorityColor(filter).withOpacity(0.2),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          alertProvider.alerts.length.toString(),
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Alta',
                          alertProvider.alerts
                              .where((a) => a.priority == 'ALTA')
                              .length
                              .toString(),
                          Colors.red,
                        ),
                        _buildStatItem(
                          'Media',
                          alertProvider.alerts
                              .where((a) => a.priority == 'MEDIA')
                              .length
                              .toString(),
                          Colors.orange,
                        ),
                        _buildStatItem(
                          'Baja',
                          alertProvider.alerts
                              .where((a) => a.priority == 'BAJA')
                              .length
                              .toString(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Alerts list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: alertProvider.loadAlerts,
                  child: alertProvider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : alertProvider.error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error al cargar alertas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    alertProvider.error!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: alertProvider.loadAlerts,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            )
                          : filteredAlerts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.list_alt,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _selectedFilter == 'TODAS'
                                            ? 'No hay alertas registradas'
                                            : 'No hay alertas de prioridad $_selectedFilter',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Las alertas aparecerán aquí cuando se registren',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredAlerts.length,
                                  itemBuilder: (context, index) {
                                    final alert = filteredAlerts[index];
                                    return AlertTile(
                                      alert: alert,
                                      onTap: () => _showAlertDetails(alert),
                                    );
                                  },
                                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}