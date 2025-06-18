class VisitedPin {
  final String id;
  final String userId;
  final int pinId;
  final DateTime visitedAt;

  VisitedPin({
    required this.id,
    required this.userId,
    required this.pinId,
    required this.visitedAt,
  });

  factory VisitedPin.fromJson(Map<String, dynamic> json) {
    return VisitedPin(
      id: json['id'],
      userId: json['user_id'],
      pinId: json['pin_id'],
      visitedAt: DateTime.parse(json['visited_at']),
    );
  }
}

class Pin {
  final int id;
  final String title;
  final String description;
  final String type;
  final double latitude;
  final double longitude;

  Pin({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
