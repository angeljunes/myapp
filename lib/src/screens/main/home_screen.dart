import 'package:flutter/material.dart';

import '../../screens/map/map_screen.dart';
import '../../screens/alerts/alerts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio RCAS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monitoreo ciudadano',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Verifica el estado general de alertas y accede rápidamente a las herramientas.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: _SummaryCard(label: 'Alertas activas', value: '—', icon: Icons.warning_amber_rounded)),
              SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Alertas resueltas', value: '—', icon: Icons.verified_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _SummaryCard(label: 'Pendientes', value: '—', icon: Icons.pending_actions)),
              SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Última sincronización', value: 'Ahora', icon: Icons.sync)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Accesos rápidos',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            title: 'Ver mapa',
            subtitle: 'Ubica alertas cercanas y usa tu ubicación',
            icon: Icons.map,
            color: Colors.blueAccent,
            onTap: () => _open(context, const MapScreen()),
          ),
          _QuickActionTile(
            title: 'Listado de alertas',
            subtitle: 'Filtra por prioridad o estado',
            icon: Icons.list_alt,
            color: Colors.deepOrange,
            onTap: () => _open(context, const AlertsScreen()),
          ),
          _QuickActionTile(
            title: 'Registrar alerta',
            subtitle: 'Reporta una situación inmediata',
            icon: Icons.add_alert,
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aquí se abrirá el formulario de registro.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
