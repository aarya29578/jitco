class PostModel {
  String? status;
  List<Data>? data;

  PostModel({this.status, this.data});

  PostModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }
}

class Data {
  String? sId;
  String? name;
  String? image;

  Data({this.sId, this.name, this.image});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
  }
}