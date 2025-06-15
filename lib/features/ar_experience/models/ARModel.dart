class ARModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String key;
  final String riddle;
  final String answer;
  final bool unlocked;

  ARModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.key,
    required this.riddle,
    required this.answer,
    this.unlocked = false,
  });
  factory ARModel.fromJson(Map<String, dynamic> json) {
    return ARModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      category: json['category'],
      key: json['key'],
      riddle: json['riddle'],
      answer: json['answer'],
    );
  }

  String get imagePath => "assets/AR/images/$key.jpg";
  String get gltfPath => "assets/AR/models/$key.gltf";

  ARModel copyWith({bool? unlocked}) {
    return ARModel(
      id: id,
      name: name,
      description: description,
      category: category,
      key: key,
      riddle: riddle,
      answer: answer,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
