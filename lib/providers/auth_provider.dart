import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> login(String cedula, String password) async {
    // Aquí iría la lógica de autenticación con el backend
    // Por ahora, simulamos un login exitoso
    await Future.delayed(const Duration(seconds: 1));

    _isAuthenticated = true;
    _userId = cedula;
    _userName = 'Mario Sosa';
    _userEmail = 'mandressosa@unicesar.edu.co';

    notifyListeners();
  }

  Future<void> register(
    String name,
    String cedula,
    String email,
    String password,
  ) async {
    // Aquí iría la lógica de registro con el backend
    // Por ahora, simulamos un registro exitoso
    await Future.delayed(const Duration(seconds: 1));

    _isAuthenticated = true;
    _userId = cedula;
    _userName = name;
    _userEmail = email;

    notifyListeners();
  }

  Future<void> logout() async {
    // Aquí iría la lógica de cierre de sesión
    await Future.delayed(const Duration(milliseconds: 500));

    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _userEmail = null;

    notifyListeners();
  }

  Future<void> resetPassword(String cedula, String email) async {
    // Aquí iría la lógica de restablecimiento de contraseña
    await Future.delayed(const Duration(seconds: 1));

    // Simulamos el envío de un correo de restablecimiento
    return;
  }
}
