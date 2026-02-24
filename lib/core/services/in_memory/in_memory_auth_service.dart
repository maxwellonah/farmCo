import 'dart:async';

import '../../domain/domain.dart';
import '../auth_service.dart';
import 'id_generator.dart';

class InMemoryAuthService implements AuthService {
  final StreamController<UserSession?> _controller =
      StreamController<UserSession?>.broadcast();

  UserSession? _currentSession;

  @override
  UserSession? get currentSession => _currentSession;

  @override
  Stream<UserSession?> authStateChanges() => _controller.stream;

  @override
  Future<UserSession> signInWithPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required UserRole role,
    required String displayName,
  }) async {
    final UserSession session = UserSession(
      userId: generateId('user'),
      role: role,
      displayName: displayName,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );
    _currentSession = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<UserSession> signInWithCredentials({
    required String username,
    required String password,
    required UserRole role,
    required String displayName,
  }) async {
    final UserSession session = UserSession(
      userId: generateId('user'),
      role: role,
      displayName: displayName,
      phoneNumber: username,
      createdAt: DateTime.now(),
    );
    _currentSession = session;
    _controller.add(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
    _controller.add(null);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
