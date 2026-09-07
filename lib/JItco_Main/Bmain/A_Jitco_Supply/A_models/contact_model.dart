// lib/models/contact_model.dart
class ContactModel {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final bool isPrimary;
  final String? outletId;
  final String? outletName;
  final String? companyId;

  ContactModel({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    this.isPrimary = false,
    this.outletId,
    this.outletName,
    this.companyId,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    print('Parsing contact from JSON:');
    print('Keys available: ${json.keys.join(', ')}');

    // Handle phone_number which might be int or string
    final phoneNumber = json['phone_number'];
    final phone = phoneNumber != null
        ? phoneNumber
              .toString() // Convert int to string
        : json['phone']?.toString() ??
              json['mobile']?.toString() ??
              json['contact_number']?.toString() ??
              '';

    // Extract outlet ID - check multiple possible formats
    String? parsedOutletId;

    // Check in order of priority
    if (json['outlet'] is String) {
      // If outlet is directly a string ID
      parsedOutletId = json['outlet'];
    } else if (json['outlet'] is Map && json['outlet']?['_id'] != null) {
      // If outlet is an object with _id
      parsedOutletId = json['outlet']?['_id']?.toString();
    } else if (json['outlet'] is Map && json['outlet']?['id'] != null) {
      // If outlet is an object with id
      parsedOutletId = json['outlet']?['id']?.toString();
    } else if (json['outlet_id'] != null) {
      // Fallback to outlet_id
      parsedOutletId = json['outlet_id']?.toString();
    }

    return ContactModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['full_name'] ?? json['name'] ?? '',
      phone: phone,
      email: json['email'] ?? '',
      profileImage: json['profile_image'] ?? json['image'],
      isPrimary:
          json['isPrimary'] == true ||
          json['is_primary'] == true ||
          json['primary'] == true,
      outletId: parsedOutletId,
      outletName: json['outlet'] is Map
          ? (json['outlet'] as Map)['name']
          : null,
      companyId: json['company'] ?? '',
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     if (id != null) '_id': id,
  //     'full_name': name,
  //     'phone_number': phone,
  //     'email': email,
  //     'profile_image': profileImage,
  //     'isPrimary': isPrimary,
  //     'outlet': outletId, //CHANGED: 'outlet_id' to 'outlet'
  //     'company': companyId,
  //   };
  // }

  Map<String, dynamic> toJson({bool forUpdate = false}) {
    print('📤 === ContactModel.toJson() ===');
    print('   For Update: $forUpdate');
    print('   ID: $id');
    print('   Name: $name');
    print('   Phone: $phone');
    print('   Email: $email');
    print('   Outlet ID: $outletId');
    print('   isPrimary (type: ${isPrimary.runtimeType}): $isPrimary');

    final Map<String, dynamic> json = {
      'full_name': name,
      'phone_number': phone,
      'email': email,
      'outlet': outletId ?? '', // String
      'isPrimary': isPrimary, // This is bool, which is fine for dynamic
    };

    // Add _id only for updates
    if (forUpdate && id != null && id!.isNotEmpty) {
      json['_id'] = id!;
      print(' Added _id for update: ${id!}');
    }

    // Add optional fields only if they exist
    if (profileImage != null && profileImage!.isNotEmpty) {
      json['profile_image'] = profileImage!;
    }

    if (companyId != null && companyId!.isNotEmpty) {
      json['company'] = companyId!;
    }

    print('Final JSON: $json');
    print('   Types:');
    json.forEach((key, value) {
      print('     $key: $value (${value.runtimeType})');
    });
    print('==============================');
    return json;
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profileImage,
    bool? isPrimary,
    String? outletId,
    String? outletName,
    String? companyId,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      isPrimary: isPrimary ?? this.isPrimary,
      outletId: outletId ?? this.outletId,
      outletName: outletName ?? this.outletName,
      companyId: companyId ?? this.companyId,
    );
  }
}
