import 'dart:async';

import '../../domain/domain.dart';
import '../wallet_service.dart';
import 'id_generator.dart';

class InMemoryWalletService implements WalletService {
  final Map<String, WalletBalance> _balances = <String, WalletBalance>{};
  final Map<String, List<WalletTransaction>> _transactions =
      <String, List<WalletTransaction>>{};
  final Map<String, StreamController<WalletBalance>> _balanceControllers =
      <String, StreamController<WalletBalance>>{};
  final Map<String, StreamController<List<WalletTransaction>>>
      _transactionControllers = <String, StreamController<List<WalletTransaction>>>{};

  @override
  Future<void> credit({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    final WalletBalance current = _ensureWallet(userId);
    _balances[userId] = current.copyWith(available: current.available + amount);
    _addTransaction(
      userId: userId,
      type: WalletTransactionType.credit,
      amount: amount,
      reference: reference,
    );
    _emit(userId);
  }

  @override
  Future<void> debit({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    final WalletBalance current = _ensureWallet(userId);
    _balances[userId] = current.copyWith(available: current.available - amount);
    _addTransaction(
      userId: userId,
      type: WalletTransactionType.debit,
      amount: amount,
      reference: reference,
    );
    _emit(userId);
  }

  @override
  Future<void> holdInEscrow({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    final WalletBalance current = _ensureWallet(userId);
    _balances[userId] = current.copyWith(
      available: current.available - amount,
      inEscrow: current.inEscrow + amount,
    );
    _addTransaction(
      userId: userId,
      type: WalletTransactionType.hold,
      amount: amount,
      reference: reference,
    );
    _emit(userId);
  }

  @override
  Future<void> releaseFromEscrow({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    final WalletBalance current = _ensureWallet(userId);
    _balances[userId] = current.copyWith(
      available: current.available + amount,
      inEscrow: current.inEscrow - amount,
    );
    _addTransaction(
      userId: userId,
      type: WalletTransactionType.release,
      amount: amount,
      reference: reference,
    );
    _emit(userId);
  }

  @override
  Stream<WalletBalance> watchBalance(String userId) {
    final StreamController<WalletBalance> controller =
        _balanceControllers.putIfAbsent(
      userId,
      () => StreamController<WalletBalance>.broadcast(),
    );
    controller.add(_ensureWallet(userId));
    return controller.stream;
  }

  @override
  Stream<List<WalletTransaction>> watchTransactions(String userId) {
    final StreamController<List<WalletTransaction>> controller =
        _transactionControllers.putIfAbsent(
      userId,
      () => StreamController<List<WalletTransaction>>.broadcast(),
    );
    controller.add(List<WalletTransaction>.unmodifiable(_transactions[userId] ?? <WalletTransaction>[]));
    return controller.stream;
  }

  WalletBalance _ensureWallet(String userId) {
    return _balances.putIfAbsent(
      userId,
      () => WalletBalance(
        userId: userId,
        available: 0,
        inEscrow: 0,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _addTransaction({
    required String userId,
    required WalletTransactionType type,
    required double amount,
    required String reference,
  }) {
    final List<WalletTransaction> list =
        _transactions.putIfAbsent(userId, () => <WalletTransaction>[]);
    list.insert(
      0,
      WalletTransaction(
        id: generateId('txn'),
        userId: userId,
        type: type,
        amount: amount,
        reference: reference,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _emit(String userId) {
    final StreamController<WalletBalance>? balanceController =
        _balanceControllers[userId];
    if (balanceController != null && !balanceController.isClosed) {
      balanceController.add(_ensureWallet(userId));
    }

    final StreamController<List<WalletTransaction>>? txController =
        _transactionControllers[userId];
    if (txController != null && !txController.isClosed) {
      txController.add(List<WalletTransaction>.unmodifiable(
        _transactions[userId] ?? <WalletTransaction>[],
      ));
    }
  }

  Future<void> dispose() async {
    for (final StreamController<WalletBalance> controller
        in _balanceControllers.values) {
      await controller.close();
    }
    for (final StreamController<List<WalletTransaction>> controller
        in _transactionControllers.values) {
      await controller.close();
    }
  }
}
