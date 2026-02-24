import 'dart:async';

import '../../domain/domain.dart';
import '../auth_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';

class ApiAuthService implements AuthService {
  ApiAuthService(this._client);

  final ApiClient _client;
  final StreamController<UserSession?> _controller =
      StreamController<UserSession?>.broadcast();

  UserSession? _currentSession;

  @override
  UserSession? get currentSession => _currentSession;

  @override
  Stream<UserSession?> authStateChanges() => _controller.stream;

  @override
  Future<UserSession> signInWithCredentials({
    required String username,
    required String password,
    required UserRole role,
    required String displayName,
  }) async {
    final dynamic response = await _client.post(
      '/auth/credentials/sign-in',
      body: <String, Object?>{
        'username': username,
        'password': password,
        'role': role.name,
        'displayName': displayName,
      },
    );
    final UserSession session = _sessionFromJson(response as Map<String, dynamic>);
    _currentSession = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<UserSession> signInWithPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required UserRole role,
    required String displayName,
  }) async {
    final dynamic response = await _client.post(
      '/auth/phone-otp/sign-in',
      body: <String, Object?>{
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        'role': role.name,
        'displayName': displayName,
      },
    );
    final UserSession session = _sessionFromJson(response as Map<String, dynamic>);
    _currentSession = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    await _client.post('/auth/sign-out');
    _currentSession = null;
    _controller.add(null);
  }

  UserSession _sessionFromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId']?.toString() ?? '',
      role: enumByNameOr<UserRole>(
        UserRole.values,
        json['role']?.toString(),
        UserRole.farmer,
      ),
      displayName: json['displayName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
