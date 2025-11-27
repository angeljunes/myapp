// Test básico para la aplicación RCAS
//
// Para realizar interacciones con widgets en el test, usa WidgetTester
// de flutter_test package. Por ejemplo, puedes enviar gestos de tap y scroll.
// También puedes usar WidgetTester para encontrar widgets hijos en el árbol,
// leer texto, y verificar que los valores de las propiedades sean correctos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rcas_app/main.dart';

void main() {
  testWidgets('RCAS App smoke test', (WidgetTester tester) async {
    // Construir nuestra app y disparar un frame.
    await tester.pumpWidget(const RCASApp());

    // Verificar que la app se inicializa correctamente
    // Debe mostrar la pantalla de login o loading inicialmente
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Esperar a que termine la inicialización
    await tester.pumpAndSettle();
    
    // Verificar que aparece la pantalla de login
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Ingrese sus datos'), findsOneWidget);
    
    // Verificar que existen los campos de login
    expect(find.byType(TextFormField), findsAtLeast(2)); // Email/usuario y contraseña
    
    // Verificar que existe el botón de login
    expect(find.text('CONTINUAR'), findsOneWidget);
    
    // Verificar que existe el botón de crear cuenta
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const RCASApp());
    await tester.pumpAndSettle();
    
    // Intentar hacer login sin datos
    await tester.tap(find.text('CONTINUAR'));
    await tester.pump();
    
    // Verificar que aparecen mensajes de validación
    expect(find.text('Ingrese su correo o usuario'), findsOneWidget);
    expect(find.text('Ingrese su contraseña'), findsOneWidget);
  });

  testWidgets('Navigation to register screen test', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const RCASApp());
    await tester.pumpAndSettle();
    
    // Tap en el botón de crear cuenta
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    
    // Verificar que navega a la pantalla de registro
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Complete sus datos para registrarse'), findsOneWidget);
    
    // Verificar que existen los campos de registro
    expect(find.byType(TextFormField), findsAtLeast(5)); // Nombre, email, usuario, zona, contraseñas
  });
}
