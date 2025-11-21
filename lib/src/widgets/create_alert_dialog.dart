import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

import '../providers/alert_provider.dart';

class CreateAlertDialog extends StatefulWidget {
  const CreateAlertDialog({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedPriority = 'MEDIA';
  String? _address;
  bool _loadingAddress = false;

  final List<String> _priorities = ['BAJA', 'MEDIA', 'ALTA'];

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates() async {
    setState(() => _loadingAddress = true);
    
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
              .replaceAll(RegExp(r'^,\s*|,\s*$'), '') // Remove leading/trailing commas
              .replaceAll(RegExp(r',\s*,'), ','); // Remove double commas
        });
      }
    } catch (e) {
      // Address lookup failed, continue without address
      setState(() => _address = null);
    } finally {
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) return;

    final alertProvider = context.read<AlertProvider>();
    
    final success = await alertProvider.createAlert(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: widget.latitude,
      longitude: widget.longitude,
      priority: _selectedPriority,
      address: _address,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta creada exitosamente'),
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Nueva Alerta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Ubicación:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${widget.latitude.toStringAsFixed(6)}\n'
                      'Lng: ${widget.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (_loadingAddress) ...[
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                          SizedBox(width: 4),
                          Text('Obteniendo dirección...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ] else if (_address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _address!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la alerta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Priority selector
              const Text(
                'Prioridad:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: _priorities.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          priority,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: _getPriorityColor(priority),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPriority = priority);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        Consumer<AlertProvider>(
          builder: (context, alertProvider, child) {
            return ElevatedButton(
              onPressed: alertProvider.creating ? null : _submitAlert,
              child: alertProvider.creating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear Alerta'),
            );
          },
        ),
      ],
    );
  }
}
