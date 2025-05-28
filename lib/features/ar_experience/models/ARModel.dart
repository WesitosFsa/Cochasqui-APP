class ARModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String key; // clave que viene de la BDD

  ARModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.key,
  });

  String get imagePath => "assets/images/$key.jpg";
  String get gltfPath => "assets/models/$key.gltf";
}
