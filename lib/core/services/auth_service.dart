import '../domain/domain.dart';

abstract class AuthService {
  Stream<UserSession?> authStateChanges();

  UserSession? get currentSession;

  Future<UserSession> signInWithPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required UserRole role,
    required String displayName,
  });

  Future<UserSession> signInWithCredentials({
    required String username,
    required String password,
    required UserRole role,
    required String displayName,
  });

  Future<void> signOut();
}
