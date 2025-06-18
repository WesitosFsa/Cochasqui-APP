class UserProfile {
  final String id;
  final String? nombre;
  final String? apellido;

  UserProfile({
    required this.id,
    this.nombre,
    this.apellido,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nombre: json['nombre'],
      apellido: json['apellido'],
    );
  }

  String get fullName {
    if (nombre != null && apellido != null) {
      return '$nombre $apellido';
    } else if (nombre != null) {
      return nombre!;
    } else if (apellido != null) {
      return apellido!;
    }
    return 'Usuario Desconocido';
  }
}

class UserFeedback {
  final String id;
  final UserProfile? user;
  final String mensaje;
  final DateTime createdAt;
  bool leido;

  UserFeedback({
    required this.id,
    this.user, 
    required this.mensaje,
    required this.createdAt,
    required this.leido,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      user: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      mensaje: json['mensaje'],
      createdAt: DateTime.parse(json['created_at']),
      leido: json['leido'] ?? false,
    );
  }
}
