import '../../domain/domain.dart';
import '../wallet_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';
import 'polling_stream.dart';

class ApiWalletService implements WalletService {
  ApiWalletService(this._client, {required this.pollInterval});

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<void> credit({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    await _client.post(
      '/wallets/$userId/credit',
      body: <String, dynamic>{'amount': amount, 'reference': reference},
    );
  }

  @override
  Future<void> debit({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    await _client.post(
      '/wallets/$userId/debit',
      body: <String, dynamic>{'amount': amount, 'reference': reference},
    );
  }

  @override
  Future<void> holdInEscrow({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    await _client.post(
      '/wallets/$userId/hold',
      body: <String, dynamic>{'amount': amount, 'reference': reference},
    );
  }

  @override
  Future<void> releaseFromEscrow({
    required String userId,
    required double amount,
    required String reference,
  }) async {
    await _client.post(
      '/wallets/$userId/release',
      body: <String, dynamic>{'amount': amount, 'reference': reference},
    );
  }

  @override
  Stream<WalletBalance> watchBalance(String userId) {
    return pollingStream<WalletBalance>(
      () async {
        final dynamic response = await _client.get('/wallets/$userId/balance');
        return _balanceFromJson(response as Map<String, dynamic>);
      },
      interval: pollInterval,
    );
  }

  @override
  Stream<List<WalletTransaction>> watchTransactions(String userId) {
    return pollingStream<List<WalletTransaction>>(
      () async {
        final dynamic response = await _client.get('/wallets/$userId/transactions');
        final List<dynamic> list = response is List ? response : <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(_transactionFromJson)
            .toList();
      },
      interval: pollInterval,
    );
  }

  WalletBalance _balanceFromJson(Map<String, dynamic> json) {
    return WalletBalance(
      userId: json['userId']?.toString() ?? '',
      available: parseDouble(json['available']),
      inEscrow: parseDouble(json['inEscrow']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  WalletTransaction _transactionFromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: enumByNameOr<WalletTransactionType>(
        WalletTransactionType.values,
        json['type']?.toString(),
        WalletTransactionType.credit,
      ),
      amount: parseDouble(json['amount']),
      reference: json['reference']?.toString() ?? '',
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
