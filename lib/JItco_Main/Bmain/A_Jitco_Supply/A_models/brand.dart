// class Brand {
//   final String title;
//   final String image;
//   Brand({required this.title, required this.image});
// }

class BrandResponse {
  final String? status;
  final List<Brand>? data;

  BrandResponse({this.status, this.data});

  factory BrandResponse.fromJson(Map<String, dynamic> json) {
    return BrandResponse(
      status: json['status'],
      data: json['data'] != null
          ? List<Brand>.from(json['data'].map((x) => Brand.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data?.map((x) => x.toJson()).toList()};
  }
}

class Brand {
  final String? id;
  final String? name;
  final String? image;
  final bool? isActive;
  final bool? show;
  final String? slug;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  Brand({
    this.id,
    this.name,
    this.image,
    this.isActive,
    this.show,
    this.slug,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'],
      name: json['name'],
      image: json['image'], // nullable (some items missing image)
      isActive: json['isActive'],
      show: json['show'],
      slug: json['slug'],
      type: json['type'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'isActive': isActive,
      'show': show,
      'slug': slug,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}
