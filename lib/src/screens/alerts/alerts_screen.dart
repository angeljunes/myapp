import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/alerts_service.dart';
import '../../widgets/create_alert_dialog.dart';
import '../../providers/map_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<AlertModel> _filteredAlerts = [];
  String? _priorityFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  Future<void> _loadAlerts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      return;
    }

    // Usar el endpoint filtrado por rol
    await alertProvider.loadAlertsByUser(user.id);
  }

  void _applyFilters(List<AlertModel> alerts) {
    final filtered = alerts.where((alert) {
      final matchesPriority = _priorityFilter == null
          ? true
          : alert.priority.toUpperCase() == _priorityFilter;
      final matchesStatus = _statusFilter == null
          ? true
          : alert.status.toUpperCase() == _statusFilter;
      return matchesPriority && matchesStatus;
    }).toList();

    setState(() {
      _filteredAlerts = filtered;
    });
  }

  void _onSelectPriority(String? priority) {
    setState(() {
      _priorityFilter = priority;
    });
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    _applyFilters(alertProvider.alerts);
  }

  void _onSelectStatus(String? status) {
    setState(() {
      _statusFilter = status;
    });
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    _applyFilters(alertProvider.alerts);
  }

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
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

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por prioridad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: _priorityFilter == null,
              onSelected: (_) => _onSelectPriority(null),
            ),
            FilterChip(
              label: const Text('Alta'),
              selected: _priorityFilter == 'ALTA',
              onSelected: (_) => _onSelectPriority('ALTA'),
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            FilterChip(
              label: const Text('Media'),
              selected: _priorityFilter == 'MEDIA',
              onSelected: (_) => _onSelectPriority('MEDIA'),
              backgroundColor: Colors.amber.withOpacity(0.1),
            ),
            FilterChip(
              label: const Text('Baja'),
              selected: _priorityFilter == 'BAJA',
              onSelected: (_) => _onSelectPriority('BAJA'),
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Filtrar por estado',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Todos'),
              selected: _statusFilter == null,
              onSelected: (_) => _onSelectStatus(null),
            ),
            FilterChip(
              label: const Text('Pendiente'),
              selected: _statusFilter == 'PENDIENTE',
              onSelected: (_) => _onSelectStatus('PENDIENTE'),
            ),
            FilterChip(
              label: const Text('Verificada'),
              selected: _statusFilter == 'VERIFICADA',
              onSelected: (_) => _onSelectStatus('VERIFICADA'),
            ),
            FilterChip(
              label: const Text('Resuelta'),
              selected: _statusFilter == 'RESUELTA',
              onSelected: (_) => _onSelectStatus('RESUELTA'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _priorityColor(alert.priority),
          child: Text(alert.priority[0]),
        ),
        title: Text(alert.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description),
            const SizedBox(height: 4),
            Text(
              alert.address ?? 'Lat: ${alert.latitude.toStringAsFixed(3)}, '
                  'Lng: ${alert.longitude.toStringAsFixed(3)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text('Estado: ${alert.status}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAlertDetails(alert),
      ),
    );
  }

  void _showAlertDetails(AlertModel alert) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.role == 'ADMIN';
    
    // Debug: Verificar rol del usuario
    print('DEBUG: Usuario role = ${authProvider.currentUser?.role}');
    print('DEBUG: isAdmin = $isAdmin');

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(alert.description),
            const SizedBox(height: 12),
            Text('Prioridad: ${alert.priority}'),
            Text('Estado: ${alert.status}'),
            if (alert.address != null) ...[
              const SizedBox(height: 8),
              Text('Dirección: ${alert.address}'),
            ],
            const SizedBox(height: 12),
            Text(
              'Coordenadas: ${alert.latitude.toStringAsFixed(5)}, '
              '${alert.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            // Admin actions
            if (isAdmin) ...[
              const Divider(height: 24),
              const Text(
                'Acciones de Administrador',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditAlertDialog(alert);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteAlert(alert);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditAlertDialog(AlertModel alert) {
    final statusController = TextEditingController(text: alert.status);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Actualizar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Alerta: ${alert.title}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: alert.status,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'PENDIENTE', child: Text('Pendiente')),
                DropdownMenuItem(value: 'VERIFICADA', child: Text('Verificada')),
                DropdownMenuItem(value: 'RESUELTA', child: Text('Resuelta')),
              ],
              onChanged: (value) {
                if (value != null) {
                  statusController.text = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final alertProvider = Provider.of<AlertProvider>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final userId = authProvider.currentUser?.id ?? '';
              
              final success = await alertProvider.updateAlert(
                alert.id,
                userId,
                {'status': statusController.text},
              );
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Alerta actualizada correctamente'
                          : 'Error al actualizar: ${alertProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  _loadAlerts();
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAlert(AlertModel alert) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar la alerta "${alert.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final alertProvider = Provider.of<AlertProvider>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final userId = authProvider.currentUser?.id ?? '';
              
              final success = await alertProvider.deleteAlert(alert.id, userId);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Alerta eliminada correctamente'
                          : 'Error al eliminar: ${alertProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  _loadAlerts();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }



  Future<void> _registerAlert() async {
    // Mostrar indicador de carga
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Obteniendo tu ubicación...'),
          ],
        ),
        duration: Duration(seconds: 20), // Duración larga mientras carga
      ),
    );

    try {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      
      // Intentar obtener ubicación actual
      await mapProvider.getCurrentLocation();
      
      // Ocultar SnackBar de carga
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (mapProvider.locationError != null && !mapProvider.locationPermissionGranted) {
        // Si hay error de permisos, mostrar diálogo explicativo
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Ubicación necesaria'),
              content: Text(mapProvider.locationError ?? 'Se requiere permiso de ubicación para registrar una alerta.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Intentar de nuevo
                    _registerAlert();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Mostrar diálogo de creación con la ubicación obtenida
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => CreateAlertDialog(
            latitude: mapProvider.currentPosition.latitude,
            longitude: mapProvider.currentPosition.longitude,
          ),
        ).then((_) {
          // Recargar alertas al cerrar el diálogo (por si se creó una)
          _loadAlerts();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, alertProvider, child) {
        // Apply filters whenever alerts change
        if (_filteredAlerts.isEmpty || _priorityFilter != null || _statusFilter != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _applyFilters(alertProvider.alerts);
          });
        } else {
          _filteredAlerts = alertProvider.alerts;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alertas registradas'),
            actions: [
              IconButton(
                onPressed: alertProvider.loading ? null : _loadAlerts,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadAlerts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterSection(),
                const SizedBox(height: 16),
                if (alertProvider.error != null)
                  Text(
                    alertProvider.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                if (alertProvider.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_filteredAlerts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 40, color: Colors.black38),
                        SizedBox(height: 8),
                        Text('No hay alertas que coincidan con los filtros.'),
                      ],
                    ),
                  )
                else
                  ..._filteredAlerts.map(_buildAlertItem),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _registerAlert,
            icon: const Icon(Icons.add_alert),
            label: const Text('Registrar alerta'),
          ),
        );
      },
    );
  }
}
