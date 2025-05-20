import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String email;
  final String? nombre;
  final String? apellido;
  final DateTime? fechaNacimiento;
  final String? genero;

  UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.apellido,
    this.fechaNacimiento,
    this.genero,
  });
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
