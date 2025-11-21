import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/country.dart';
import '../../models/city.dart';
import '../../providers/location_provider.dart';

class CountryCitySelectorScreen extends StatefulWidget {
  const CountryCitySelectorScreen({super.key});

  @override
  State<CountryCitySelectorScreen> createState() => _CountryCitySelectorScreenState();
}

class _CountryCitySelectorScreenState extends State<CountryCitySelectorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadCountries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Seleccione su país y ciudad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta información nos ayuda a personalizar las alertas según su ubicación.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Country selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.public, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'País',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (locationProvider.loadingCountries)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        if (locationProvider.loadingCountries)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Cargando países...'),
                            ),
                          )
                        else if (locationProvider.countries.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                const Text('No se pudieron cargar los países'),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: locationProvider.loadCountries,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<Country>(
                            value: locationProvider.selectedCountry,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Seleccione un país',
                            ),
                            items: locationProvider.countries.map((country) {
                              return DropdownMenuItem(
                                value: country,
                                child: Text('${country.name} (${country.code})'),
                              );
                            }).toList(),
                            onChanged: (country) {
                              if (country != null) {
                                locationProvider.selectCountry(country);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // City selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_city, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'Ciudad',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (locationProvider.loadingCities)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        if (locationProvider.selectedCountry == null)
                          const Text(
                            'Primero seleccione un país',
                            style: TextStyle(color: Colors.grey),
                          )
                        else if (locationProvider.loadingCities)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Cargando ciudades...'),
                            ),
                          )
                        else if (locationProvider.cities.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                const Text('No se encontraron ciudades'),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (locationProvider.selectedCountry != null) {
                                      locationProvider.loadCitiesByCountry(
                                        locationProvider.selectedCountry!.id,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<City>(
                            value: locationProvider.selectedCity,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Seleccione una ciudad',
                            ),
                            items: locationProvider.cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city.name),
                              );
                            }).toList(),
                            onChanged: (city) {
                              if (city != null) {
                                locationProvider.selectCity(city);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Error display
                if (locationProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          locationProvider.clearSelection();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: locationProvider.selectedCountry != null &&
                                locationProvider.selectedCity != null
                            ? () {
                                Navigator.of(context).pop({
                                  'country': locationProvider.selectedCountry,
                                  'city': locationProvider.selectedCity,
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
