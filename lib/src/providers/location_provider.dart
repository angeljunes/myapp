import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/city.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider() {
    _init();
  }

  final LocationService _locationService = LocationService();

  List<Country> _countries = [];
  List<City> _cities = [];
  Country? _selectedCountry;
  City? _selectedCity;
  bool _loadingCountries = false;
  bool _loadingCities = false;
  String? _error;

  List<Country> get countries => _countries;
  List<City> get cities => _cities;
  Country? get selectedCountry => _selectedCountry;
  City? get selectedCity => _selectedCity;
  bool get loadingCountries => _loadingCountries;
  bool get loadingCities => _loadingCities;
  String? get error => _error;

  Future<void> _init() async {
    await loadCountries();
  }

  Future<void> loadCountries() async {
    _loadingCountries = true;
    _error = null;
    notifyListeners();

    try {
      _countries = await _locationService.getCountries();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingCountries = false;
      notifyListeners();
    }
  }

  Future<void> loadCitiesByCountry(String countryId) async {
    _loadingCities = true;
    _error = null;
    _cities.clear();
    _selectedCity = null;
    notifyListeners();

    try {
      _cities = await _locationService.getCitiesByCountry(countryId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingCities = false;
      notifyListeners();
    }
  }

  void selectCountry(Country country) {
    if (_selectedCountry?.id != country.id) {
      _selectedCountry = country;
      _selectedCity = null;
      _cities.clear();
      notifyListeners();
      loadCitiesByCountry(country.id);
    }
  }

  void selectCity(City city) {
    _selectedCity = city;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCountry = null;
    _selectedCity = null;
    _cities.clear();
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
