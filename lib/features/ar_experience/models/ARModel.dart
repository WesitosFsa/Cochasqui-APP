class ARModel {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String gltfPath;
  final String category;

  ARModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.gltfPath,
    required this.category,
  });

  factory ARModel.fromMap(Map<String, dynamic> data) {
    return ARModel(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      imagePath: data['imagePath'],
      gltfPath: data['gltfPath'],
      category: data['category'],
    );
  }
}
