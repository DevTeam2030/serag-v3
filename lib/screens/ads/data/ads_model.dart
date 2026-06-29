class AdModel {

  final int id;

  final String title;

  final String description;

  final bool showOnHome;

  final List<String> images;

  AdModel({

    required this.id,

    required this.title,

    required this.description,

    required this.showOnHome,

    required this.images,

  });

  factory AdModel.fromJson(
      Map<String,dynamic> json,
      ){

    return AdModel(

      id: json['id'],

      title: json['title'] ?? '',

      description: json['description'] ?? '',

      showOnHome:
      json['show_on_home'] ?? false,

      images:
      (json['images'] as List)

          .map(
            (e)=>e['image'].toString(),
      )

          .toList(),

    );

  }

}