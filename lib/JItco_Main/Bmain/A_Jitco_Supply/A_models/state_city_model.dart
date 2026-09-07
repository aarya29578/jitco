class StateModel {
  final int id;
  final String name;
  final List<int> cities;

  StateModel({required this.id, required this.name, required this.cities});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['_id'],
      name: json['name'],
      cities: List<int>.from(json['cities']),
    );
  }
}

class CityModel {
  final int id;
  final String name;

  CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['_id'], name: json['name']);
  }
}
