import '../../domain/domain.dart';
import '../profile_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';

class ApiProfileService implements ProfileService {
  ApiProfileService(this._client);

  final ApiClient _client;

  @override
  Future<AgentProfile?> getAgentProfile(String userId) async {
    final dynamic response = await _client.get('/profiles/agents/$userId');
    if (response == null) {
      return null;
    }
    return _agentFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BuyerProfile?> getBuyerProfile(String userId) async {
    final dynamic response = await _client.get('/profiles/buyers/$userId');
    if (response == null) {
      return null;
    }
    return _buyerFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<FarmerProfile?> getFarmerProfile(String userId) async {
    final dynamic response = await _client.get('/profiles/farmers/$userId');
    if (response == null) {
      return null;
    }
    return _farmerFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> saveAgentProfile(AgentProfile profile) async {
    await _client.put(
      '/profiles/agents/${profile.userId}',
      body: _agentToJson(profile),
    );
  }

  @override
  Future<void> saveBuyerProfile(BuyerProfile profile) async {
    await _client.put(
      '/profiles/buyers/${profile.userId}',
      body: _buyerToJson(profile),
    );
  }

  @override
  Future<void> saveFarmerProfile(FarmerProfile profile) async {
    await _client.put(
      '/profiles/farmers/${profile.userId}',
      body: _farmerToJson(profile),
    );
  }

  @override
  Future<List<AgentProfile>> listAgents() async {
    final dynamic response = await _client.get('/profiles/agents');
    final List<dynamic> data = response is List ? response : <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_agentFromJson)
        .toList();
  }

  @override
  Future<List<BuyerProfile>> listBuyers() async {
    final dynamic response = await _client.get('/profiles/buyers');
    final List<dynamic> data = response is List ? response : <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_buyerFromJson)
        .toList();
  }

  @override
  Future<List<FarmerProfile>> listFarmers() async {
    final dynamic response = await _client.get('/profiles/farmers');
    final List<dynamic> data = response is List ? response : <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_farmerFromJson)
        .toList();
  }

  FarmerProfile _farmerFromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      farmName: json['farmName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      primaryCrops: parseStringList(json['primaryCrops']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  BuyerProfile _buyerFromJson(Map<String, dynamic> json) {
    return BuyerProfile(
      userId: json['userId']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      regions: parseStringList(json['regions']),
      preferredCrops: parseStringList(json['preferredCrops']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  AgentProfile _agentFromJson(Map<String, dynamic> json) {
    return AgentProfile(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      agentId: json['agentId']?.toString() ?? '',
      coverageArea: parseStringList(json['coverageArea']),
      vehicleType: json['vehicleType']?.toString() ?? '',
      rating: parseDouble(json['rating'], fallback: 0),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> _farmerToJson(FarmerProfile profile) {
    return <String, dynamic>{
      'userId': profile.userId,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'phoneNumber': profile.phoneNumber,
      'farmerId': profile.farmerId,
      'farmName': profile.farmName,
      'location': profile.location,
      'primaryCrops': profile.primaryCrops,
      'createdAt': profile.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _buyerToJson(BuyerProfile profile) {
    return <String, dynamic>{
      'userId': profile.userId,
      'companyName': profile.companyName,
      'businessType': profile.businessType,
      'contactPhone': profile.contactPhone,
      'regions': profile.regions,
      'preferredCrops': profile.preferredCrops,
      'createdAt': profile.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _agentToJson(AgentProfile profile) {
    return <String, dynamic>{
      'userId': profile.userId,
      'fullName': profile.fullName,
      'agentId': profile.agentId,
      'coverageArea': profile.coverageArea,
      'vehicleType': profile.vehicleType,
      'rating': profile.rating,
      'createdAt': profile.createdAt.toIso8601String(),
    };
  }
}
