class LoginRequest {
  final String phoneNumber;

  LoginRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber};
  }
}

class VerifyOtpRequest {
  final String phoneNumber;
  final String otp;

  VerifyOtpRequest({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber, 'otp': otp};
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? userId;
  final String? refreshToken;
  final Map<String, dynamic>? data;
  final bool isNewUser;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.userId,
    this.refreshToken,
    this.data,
    required this.isNewUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // print('Parsing AuthResponse JSON: $json');

    // Extract token from data.token
    String? token;
    String? userId;
    bool isNewUser = false; //default

    if (json['data'] != null) {
      final data = json['data'];
      token = data['token']?.toString();

      if (data['customer'] != null) {
        userId = data['customer']['_id']?.toString();
      }
    }

    // print('Extracted token: $token');
    // print('Extracted userId: $userId');

    return AuthResponse(
      success: (json['status'] == 'success'),
      message: json['message'] ?? 'Success', // Provide default message
      token: token,
      userId: userId,
      refreshToken: json['refresh_token'],
      data: json['data'],
      isNewUser: isNewUser,
    );
  }
}

class OtpResponse {
  final bool success;
  final String message;
  final String? verificationId;
  final String? otp;
  final bool isNewUser;

  OtpResponse({
    required this.success,
    required this.message,
    this.verificationId,
    this.otp,
    required this.isNewUser,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: (json['status'] == 'success') || (json['success'] == true),
      message: json['message'] ?? '',
      verificationId: json['verification_id'],
      otp: json['otp'],
      isNewUser: json['isNewUser'] ?? false,
    );
  }
}
