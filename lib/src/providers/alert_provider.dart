import 'package:flutter/material.dart';

import '../models/alert.dart';
import '../services/alerts_service.dart';

class AlertProvider extends ChangeNotifier {
  AlertProvider() {
    _init();
  }

  final AlertsService _alertsService = AlertsService();

  List<AlertModel> _alerts = [];
  bool _loading = false;
  bool _creating = false;
  String? _error;

  List<AlertModel> get alerts => _alerts;
  bool get loading => _loading;
  bool get creating => _creating;
  String? get error => _error;

  Future<void> _init() async {
    await loadAlerts();
  }

  Future<void> loadAlerts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _alerts = await _alertsService.fetchAlerts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createAlert({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    String priority = 'MEDIA',
    String? address,
  }) async {
    _creating = true;
    _error = null;
    notifyListeners();

    try {
      final newAlert = await _alertsService.createAlert(
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        priority: priority,
        address: address,
      );

      _alerts.insert(0, newAlert);
      _creating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _creating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAlert(String alertId, Map<String, dynamic> updates) async {
    try {
      final updatedAlert = await _alertsService.updateAlert(alertId, updates);
      
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        _alerts[index] = updatedAlert;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAlert(String alertId) async {
    try {
      await _alertsService.deleteAlert(alertId);
      
      _alerts.removeWhere((alert) => alert.id == alertId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _alertsService.dispose();
    super.dispose();
  }
}
