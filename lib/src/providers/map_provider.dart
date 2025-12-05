import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapProvider extends ChangeNotifier {
  MapProvider() {
    _init();
  }

  MapController? _mapController;
  LatLng _currentPosition = const LatLng(-12.0464, -77.0428); // Lima por defecto
  bool _locationLoading = false;
  bool _locationPermissionGranted = false;
  String? _locationError;

  MapController? get mapController => _mapController;
  LatLng get currentPosition => _currentPosition;
  bool get locationLoading => _locationLoading;
  bool get locationPermissionGranted => _locationPermissionGranted;
  String? get locationError => _locationError;

  Future<void> _init() async {
    // No pedir permisos automáticamente
    // El mapa se mostrará con ubicación predeterminada (Lima)
    // Los permisos solo se pedirán cuando el usuario presione "Mi ubicación" o "Emergencia"
    _mapController = MapController();
  }

  void setMapController(MapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Servicios de ubicación deshabilitados. El mapa funcionará con ubicación predeterminada.';
        _locationPermissionGranted = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Permisos denegados. Puedes usar el mapa pero no tu ubicación actual.';
          _locationPermissionGranted = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Para usar tu ubicación, habilita los permisos en Configuración > Aplicaciones > Permisos';
        _locationPermissionGranted = false;
        notifyListeners();
        return;
      }

      _locationPermissionGranted = true;
      _locationError = null;
      notifyListeners();
    } catch (e) {
      _locationError = 'El mapa funcionará sin tu ubicación actual';
      _locationPermissionGranted = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      await _checkLocationPermission();
      if (!_locationPermissionGranted) return;
    }

    _locationLoading = true;
    _locationError = null;
    notifyListeners();

    try {
      // Intentar obtener la última ubicación conocida primero para mostrar algo rápido
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _currentPosition = LatLng(lastKnown.latitude, lastKnown.longitude);
        if (_mapController != null) {
          _mapController!.move(_currentPosition, 15.0);
        }
        notifyListeners();
      }

      // Obtener la ubicación actual con la mejor precisión posible
      // IMPORTANTE: No usar forceAndroidLocationManager ya que reduce precisión
      // bestForNavigation proporciona la máxima precisión disponible
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 30), // Aumentado para mejor fix GPS
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
      
      // Mostrar información de precisión en consola para debugging
      print('📍 Ubicación obtenida:');
      print('   Lat: ${position.latitude}, Lng: ${position.longitude}');
      print('   Precisión: ${position.accuracy.toStringAsFixed(1)}m');
      print('   Altitud: ${position.altitude.toStringAsFixed(1)}m');
      print('   Velocidad: ${position.speed.toStringAsFixed(1)}m/s');
      
      // Move map to current location if controller is available
      if (_mapController != null) {
        _mapController!.move(_currentPosition, 18.0); // Zoom más cercano para mejor precisión
      }
      
      // Mostrar advertencia si la precisión es baja
      if (position.accuracy > 50) {
        _locationError = 'Precisión baja (±${position.accuracy.toStringAsFixed(0)}m). Intenta moverte a un área abierta.';
      } else if (position.accuracy > 20) {
        _locationError = 'Precisión moderada (±${position.accuracy.toStringAsFixed(0)}m).';
      }
    } catch (e) {
      // Si falla getCurrentPosition, ya mostramos lastKnown si existía.
      // Si no, mostramos el error.
      if (_currentPosition.latitude == -12.0464 && _currentPosition.longitude == -77.0428) {
        _locationError = 'No se pudo obtener ubicación GPS. Verifica que:\n• El GPS esté activado\n• Estés en un área abierta\n• La app tenga permisos de ubicación';
      } else {
        _locationError = 'Usando última ubicación conocida. Para mayor precisión, muévete a un área abierta.';
      }
      print('❌ Error obteniendo ubicación: $e');
    } finally {
      _locationLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveToLocation(LatLng location, {double zoom = 15.0}) async {
    if (_mapController != null) {
      _mapController!.move(location, zoom);
    }
  }

  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
