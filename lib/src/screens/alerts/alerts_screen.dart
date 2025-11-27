import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/alert.dart';
import '../../providers/auth_provider.dart';
import '../../services/alerts_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertsService _alertsService = AlertsService();

  List<AlertModel> _alerts = [];
  List<AlertModel> _filteredAlerts = [];
  bool _loading = true;
  String? _priorityFilter;
  String? _statusFilter;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Obtener el usuario actual del AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Usar el endpoint filtrado por rol
      final alerts = await _alertsService.fetchAlertsByUser(user.id);
      setState(() {
        _alerts = alerts;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    final filtered = _alerts.where((alert) {
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
    _applyFilters();
  }

  void _onSelectStatus(String? status) {
    setState(() {
      _statusFilter = status;
    });
    _applyFilters();
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas registradas'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadAlerts,
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
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredAlerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: const [
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aquí puedes abrir el formulario para registrar una alerta.'),
            ),
          );
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Registrar alerta'),
      ),
    );
  }
}
