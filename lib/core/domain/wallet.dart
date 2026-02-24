enum WalletTransactionType {
  credit,
  debit,
  hold,
  release,
  withdrawal,
  fee,
}

class WalletBalance {
  const WalletBalance({
    required this.userId,
    required this.available,
    required this.inEscrow,
    required this.updatedAt,
  });

  final String userId;
  final double available;
  final double inEscrow;
  final DateTime updatedAt;

  WalletBalance copyWith({
    double? available,
    double? inEscrow,
  }) {
    return WalletBalance(
      userId: userId,
      available: available ?? this.available,
      inEscrow: inEscrow ?? this.inEscrow,
      updatedAt: DateTime.now(),
    );
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.reference,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final WalletTransactionType type;
  final double amount;
  final String reference;
  final DateTime createdAt;
}
