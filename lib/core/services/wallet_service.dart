import '../domain/domain.dart';

abstract class WalletService {
  Stream<WalletBalance> watchBalance(String userId);

  Stream<List<WalletTransaction>> watchTransactions(String userId);

  Future<void> credit({
    required String userId,
    required double amount,
    required String reference,
  });

  Future<void> debit({
    required String userId,
    required double amount,
    required String reference,
  });

  Future<void> holdInEscrow({
    required String userId,
    required double amount,
    required String reference,
  });

  Future<void> releaseFromEscrow({
    required String userId,
    required double amount,
    required String reference,
  });
}
