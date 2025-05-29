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

  String get imagePath => "assets/images/$key.jpg";
  String get gltfPath => "assets/models/$key.gltf";

  // Aquí te hace falta un método copyWith para poder cambiar unlocked sin perder datos:
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
