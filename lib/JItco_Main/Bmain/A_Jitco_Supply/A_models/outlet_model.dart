// // lib/models/outlet_model.dart
// class OutletModel {
//   final String? id;
//   final String name;
//   final String address;
//   final String state;
//   final String city;
//   final String pinCode;
//   final DateTime? registrationDate;
//   final String? msmeNumber;
//   final String? fssaiNumber;
//   final String? gstNumber;

//   OutletModel({
//     this.id,
//     required this.name,
//     required this.address,
//     required this.state,
//     required this.city,
//     required this.pinCode,
//     this.registrationDate,
//     this.msmeNumber,
//     this.fssaiNumber,
//     this.gstNumber,
//   }) {
//     // Validate required fields
//     // assert(name.isNotEmpty, 'Outlet name is required');
//     // assert(address.isNotEmpty, 'Address is required');
//     // assert(state.isNotEmpty, 'State is required');
//     // assert(city.isNotEmpty, 'City is required');
//     // assert(pinCode.isNotEmpty, 'PinCode is required');
//   }

//   // factory OutletModel.fromJson(Map<String, dynamic> json) {
//   //   print('📋 Parsing outlet JSON:');
//   //   print('   Full JSON: $json');
//   //   // Debug: Print all keys to see what's available
//   //   print('   Available keys: ${json.keys.join(', ')}');
//   //   return OutletModel(
//   //     id: json['_id']?.toString(),
//   //     name: json['name']?.toString() ?? '',
//   //     address: json['address']?.toString() ?? '',
//   //     // State might be an object with _id and name properties
//   //     state: json['state'] is Map
//   //         ? (json['state']['name']?.toString() ?? '')
//   //         : (json['state']?.toString() ?? ''),
//   //     city: json['city']?['name'].toString() ?? '',
//   //     // API returns 'pin_code' not 'pinCode'
//   //     pinCode: json['pin_code']?.toString() ?? '',
//   //     registrationDate: json['registrationDate'] != null
//   //         ? DateTime.tryParse(json['registrationDate'])
//   //         : null,
//   //     // API returns 'msme_number' not 'msmeNumber'
//   //     msmeNumber: json['msme_number']?.toString(),
//   //     // API returns 'fssai_number' not 'fssaiNumber'
//   //     fssaiNumber: json['fssai_number']?.toString(),
//   //     // API returns 'gst' not 'gstNumber'
//   //     gstNumber: json['gst']?.toString(),
//   //   );
//   // }

//   // factory OutletModel.fromJson(Map<String, dynamic> json) {
//   //   print('Parsing outlet JSON:');
//   //   try {
//   //     // Debug: Print all JSON keys and values
//   //     print('JSON Keys: ${json.keys.join(', ')}');
//   //     // Extract state - handle both object and string formats
//   //     String stateValue = '';
//   //     if (json['state'] is Map) {
//   //       // State is an object like {_id: 13, name: 'Haryana'}
//   //       final stateMap = json['state'] as Map;
//   //       stateValue =
//   //           stateMap['name']?.toString() ??
//   //           stateMap['_id']?.toString() ??
//   //           'Not specified';
//   //       print('   State object: ${json['state']}');
//   //       print('   Extracted state: $stateValue');
//   //     } else if (json['state'] != null) {
//   //       // State is a string or number
//   //       stateValue = json['state']?.toString() ?? 'Not specified';
//   //     }
//   //     // Extract city - handle both object and string formats
//   //     String cityValue = '';
//   //     if (json['city'] is Map) {
//   //       // City is an object like {_id: 16, name: 'Amudalavalasa'}
//   //       final cityMap = json['city'] as Map;
//   //       cityValue =
//   //           cityMap['name']?.toString() ??
//   //           cityMap['_id']?.toString() ??
//   //           'Not specified';
//   //       print('City object: ${json['city']}');
//   //       print('Extracted city: $cityValue');
//   //     } else if (json['city'] != null) {
//   //       // City is a string
//   //       cityValue = json['city']?.toString() ?? 'Not specified';
//   //     }
//   //     return OutletModel(
//   //       id: json['_id']?.toString(),
//   //       name: json['name']?.toString() ?? 'Unnamed Outlet',
//   //       address: json['address']?.toString() ?? 'No address',
//   //       state: stateValue,
//   //       city: cityValue,
//   //       pinCode:
//   //           json['pin_code']?.toString() ?? json['pinCode']?.toString() ?? '',
//   //       registrationDate: json['registrationDate'] != null
//   //           ? DateTime.tryParse(json['registrationDate'])
//   //           : null,
//   //       msmeNumber:
//   //           json['msme_number']?.toString() ?? json['msmeNumber']?.toString(),
//   //       fssaiNumber:
//   //           json['fssai_number']?.toString() ?? json['fssaiNumber']?.toString(),
//   //       gstNumber: json['gst']?.toString() ?? json['gstNumber']?.toString(),
//   //     );
//   //   } catch (e) {
//   //     print('ERROR in OutletModel.fromJson: $e');
//   //     print('Problematic JSON: $json');
//   //     // Return a default outlet instead of throwing
//   //     return OutletModel(
//   //       id: json['_id']?.toString() ?? 'unknown',
//   //       name: json['name']?.toString() ?? 'Error parsing outlet',
//   //       address: 'Error parsing address',
//   //       state: 'Unknown',
//   //       city: 'Unknown',
//   //       pinCode: '',
//   //     );
//   //   }
//   // }

//   //Id used in that edit
//   // factory OutletModel.fromJson(Map<String, dynamic> json) {
//   //   print('Parsing outlet JSON:');
//   //   try {
//   //     // Debug: Print all JSON keys and values
//   //     print('JSON Keys: ${json.keys.join(', ')}');
//   //     // Extract state ID - handle both object and string formats
//   //     String stateId = '';
//   //     if (json['state'] is Map) {
//   //       // State is an object like {_id: 13, name: 'Haryana'}
//   //       final stateMap = json['state'] as Map;
//   //       stateId = stateMap['_id']?.toString() ?? '';
//   //       print('   State object: ${json['state']}');
//   //       print('   Extracted state ID: $stateId');
//   //     } else if (json['state'] != null) {
//   //       // State is a string ID
//   //       stateId = json['state']?.toString() ?? '';
//   //     }
//   //     // Extract city ID - handle both object and string formats
//   //     String cityId = '';
//   //     if (json['city'] is Map) {
//   //       // City is an object like {_id: 16, name: 'Amudalavalasa'}
//   //       final cityMap = json['city'] as Map;
//   //       cityId = cityMap['_id']?.toString() ?? '';
//   //       print('City object: ${json['city']}');
//   //       print('Extracted city ID: $cityId');
//   //     } else if (json['city'] != null) {
//   //       // City is a string ID
//   //       cityId = json['city']?.toString() ?? '';
//   //     }
//   //     return OutletModel(
//   //       id: json['_id']?.toString(),
//   //       name: json['name']?.toString() ?? 'Unnamed Outlet',
//   //       address: json['address']?.toString() ?? 'No address',
//   //       state: stateId, // ✅ Store the ID, not the name
//   //       city: cityId, // ✅ Store the ID, not the name
//   //       pinCode:
//   //           json['pin_code']?.toString() ?? json['pinCode']?.toString() ?? '',
//   //       registrationDate: json['registrationDate'] != null
//   //           ? DateTime.tryParse(json['registrationDate'])
//   //           : null,
//   //       msmeNumber:
//   //           json['msme_number']?.toString() ?? json['msmeNumber']?.toString(),
//   //       fssaiNumber:
//   //           json['fssai_number']?.toString() ?? json['fssaiNumber']?.toString(),
//   //       gstNumber: json['gst']?.toString() ?? json['gstNumber']?.toString(),
//   //     );
//   //   } catch (e) {
//   //     print('ERROR in OutletModel.fromJson: $e');
//   //     print('Problematic JSON: $json');
//   //     // Return a default outlet instead of throwing
//   //     return OutletModel(
//   //       id: json['_id']?.toString() ?? 'unknown',
//   //       name: json['name']?.toString() ?? 'Error parsing outlet',
//   //       address: 'Error parsing address',
//   //       state: '',
//   //       city: '',
//   //       pinCode: '',
//   //     );
//   //   }
//   // }

//   //without Id used in that edit
//   // In outlet_model.dart, update your fromJson factory method
//   factory OutletModel.fromJson(Map<String, dynamic> json) {
//     print('Parsing outlet JSON:');

//     try {
//       // Debug: Print all JSON keys and values
//       print('JSON Keys: ${json.keys.join(', ')}');

//       // Extract state - store BOTH id and name
//       String stateId = '';
//       String stateName = '';
//       if (json['state'] is Map) {
//         // State is an object like {_id: 13, name: 'Haryana'}
//         final stateMap = json['state'] as Map;
//         stateId = stateMap['_id']?.toString() ?? '';
//         stateName = stateMap['name']?.toString() ?? '';
//         print('   State object: ${json['state']}');
//         print('   Extracted state ID: $stateId, Name: $stateName');
//       } else if (json['state'] != null) {
//         // State is a string ID
//         stateId = json['state']?.toString() ?? '';
//         stateName = ''; // No name available
//       }

//       // Extract city - store BOTH id and name
//       String cityId = '';
//       String cityName = '';
//       if (json['city'] is Map) {
//         // City is an object like {_id: 16, name: 'Amudalavalasa'}
//         final cityMap = json['city'] as Map;
//         cityId = cityMap['_id']?.toString() ?? '';
//         cityName = cityMap['name']?.toString() ?? '';
//         print('City object: ${json['city']}');
//         print('Extracted city ID: $cityId, Name: $cityName');
//       } else if (json['city'] != null) {
//         // City is a string ID
//         cityId = json['city']?.toString() ?? '';
//         cityName = ''; // No name available
//       }

//       return OutletModel(
//         id: json['_id']?.toString(),
//         name: json['name']?.toString() ?? 'Unnamed Outlet',
//         address: json['address']?.toString() ?? 'No address',
//         state: stateName.isEmpty
//             ? stateId
//             : stateName, // ✅ Use name if available, otherwise ID
//         city: cityName.isEmpty
//             ? cityId
//             : cityName, // ✅ Use name if available, otherwise ID
//         pinCode:
//             json['pin_code']?.toString() ?? json['pinCode']?.toString() ?? '',
//         registrationDate: json['registrationDate'] != null
//             ? DateTime.tryParse(json['registrationDate'])
//             : null,
//         msmeNumber:
//             json['msme_number']?.toString() ?? json['msmeNumber']?.toString(),
//         fssaiNumber:
//             json['fssai_number']?.toString() ?? json['fssaiNumber']?.toString(),
//         gstNumber: json['gst']?.toString() ?? json['gstNumber']?.toString(),
//       );
//     } catch (e) {
//       print('ERROR in OutletModel.fromJson: $e');
//       print('Problematic JSON: $json');
//       return OutletModel(
//         id: json['_id']?.toString() ?? 'unknown',
//         name: json['name']?.toString() ?? 'Error parsing outlet',
//         address: 'Error parsing address',
//         state: 'Unknown',
//         city: 'Unknown',
//         pinCode: '',
//       );
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {
//       if (id != null && id!.isNotEmpty) '_id': id,
//       'name': name,
//       'address': address,
//       'city': city,
//       'pin_code': pinCode,
//     };
//     // Handle state - check if it needs to be sent as ID or name
//     if (state.isNotEmpty) {
//       // Check if state looks like an ID (numeric or short string)
//       if (state.length <= 3 || int.tryParse(state) != null) {
//         data['state'] = {'_id': state}; // Send as ID
//       } else {
//         data['state'] = {'name': state}; // Send as name
//       }
//     }
//     if (registrationDate != null) {
//       data['registrationDate'] = registrationDate!.toIso8601String();
//     }
//     if (msmeNumber != null && msmeNumber!.isNotEmpty) {
//       data['msme_number'] = msmeNumber;
//     }
//     if (fssaiNumber != null && fssaiNumber!.isNotEmpty) {
//       data['fssai_number'] = fssaiNumber;
//     }
//     if (gstNumber != null && gstNumber!.isNotEmpty) {
//       data['gst'] = gstNumber;
//     }
//     print('Converted outlet to JSON:');
//     print(data);
//     return data;
//   }
// }

// lib/models/outlet_model.dart
class OutletModel {
  final String? id;
  final String name;
  final String address;
  final String? stateName; // For display
  final String? cityName; // For display
  final String stateId; // For editing
  final String cityId; // For editing
  final String? cityWarehouse;
  final String pinCode;
  final DateTime? registrationDate;
  final String? msmeNumber;
  final String? fssaiNumber;
  final String? gstNumber;

  OutletModel({
    this.id,
    required this.name,
    required this.address,
    this.stateName,
    this.cityName,
    required this.stateId,
    required this.cityId,
    this.cityWarehouse,
    required this.pinCode,
    this.registrationDate,
    this.msmeNumber,
    this.fssaiNumber,
    this.gstNumber,
  }) {
    // Validation is relaxed since backend might return partial data.
  }

  // Extract both ID and name from JSON
  factory OutletModel.fromJson(Map<String, dynamic> json) {
    print('Parsing outlet JSON:');

    try {
      // Extract state - handle both object and string formats
      String stateId = '';
      String stateName = '';
      if (json['state'] is Map) {
        // State is an object like {_id: 13, name: 'Haryana'}
        final stateMap = json['state'] as Map;
        stateId = stateMap['_id']?.toString() ?? '';
        stateName = stateMap['name']?.toString() ?? '';
        print('   State: ID=$stateId, Name=$stateName');
      } else if (json['state'] != null) {
        // State is a string ID
        stateId = json['state']?.toString() ?? '';
        stateName = ''; // No name available
      }

      // Extract city - handle both object and string formats
      String cityId = '';
      String cityName = '';
      String cityWarehouse = '';
      if (json['city'] is Map) {
        // City is an object like {_id: 1196, name: 'Bawani Khera'}
        final cityMap = json['city'] as Map;
        cityId = cityMap['_id']?.toString() ?? '';
        cityName = cityMap['name']?.toString() ?? '';
        cityWarehouse = cityMap['name']?[0]?.toString() ?? '';
        print('   City: ID=$cityId, Name=$cityName');
      } else if (json['city'] != null) {
        // City is a string ID
        cityId = json['city']?.toString() ?? '';
        cityName = ''; // No name available
      }

      return OutletModel(
        id: json['_id']?.toString(),
        name: json['name']?.toString() ?? 'Unnamed Outlet',
        address: json['address']?.toString() ?? 'No address',
        stateName: stateName,
        cityName: cityName,
        stateId: stateId,
        cityId: cityId,
        cityWarehouse: cityWarehouse,
        pinCode:
            json['pin_code']?.toString() ?? json['pinCode']?.toString() ?? '',
        registrationDate: json['registrationDate'] != null
            ? DateTime.tryParse(json['registrationDate'])
            : null,
        msmeNumber:
            json['msme_number']?.toString() ?? json['msmeNumber']?.toString(),
        fssaiNumber:
            json['fssai_number']?.toString() ?? json['fssaiNumber']?.toString(),
        gstNumber: json['gst']?.toString() ?? json['gstNumber']?.toString(),
      );
    } catch (e) {
      print('ERROR in OutletModel.fromJson: $e');
      print('Problematic JSON: $json');
      return OutletModel(
        id: json['_id']?.toString() ?? 'unknown',
        name: json['name']?.toString() ?? 'Error parsing outlet',
        address: 'Error parsing address',
        stateName: 'Unknown',
        cityName: 'Unknown',
        stateId: '',
        cityId: '',
        cityWarehouse: 'Unknown',
        pinCode: '',
      );
    }
  }

  //Send IDs for API calls
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      if (id != null && id!.isNotEmpty) '_id': id,
      'name': name,
      'address': address,
      'city': {'_id': cityId}, // Send city ID
      'pin_code': pinCode,
    };

    // Send state ID
    if (stateId.isNotEmpty) {
      data['state'] = {'_id': stateId};
    }

    if (registrationDate != null) {
      data['registrationDate'] = registrationDate!.toIso8601String();
    }
    if (msmeNumber != null && msmeNumber!.isNotEmpty) {
      data['msme_number'] = msmeNumber;
    }
    if (fssaiNumber != null && fssaiNumber!.isNotEmpty) {
      data['fssai_number'] = fssaiNumber;
    }
    if (gstNumber != null && gstNumber!.isNotEmpty) {
      data['gst'] = gstNumber;
    }

    print('Converted outlet to JSON:');
    print('State ID: $stateId, City ID: $cityId');
    print('Data: $data');
    return data;
  }
}
