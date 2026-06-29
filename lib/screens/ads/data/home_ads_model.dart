class HomeAdModel {
  final int id;
  final String title;
  final String description;
  final bool showOnHome;
  final List<String> images;

  HomeAdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.showOnHome,
    required this.images,
  });

  factory HomeAdModel.fromJson(Map<String, dynamic> json) {
    return HomeAdModel(
      id: json["id"],

      title: json["title"] ?? '',

      description: json["description"] ?? '',

      showOnHome: json["show_on_home"] ?? false,

      images: (json["images"] as List)
          .map(
            (e) => e["image"].toString(),
      )
          .toList(),
    );
  }
}