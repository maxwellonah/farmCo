import 'user_role.dart';

class UserSession {
  const UserSession({
    required this.userId,
    required this.role,
    required this.displayName,
    required this.phoneNumber,
    required this.createdAt,
  });

  final String userId;
  final UserRole role;
  final String displayName;
  final String phoneNumber;
  final DateTime createdAt;
}
