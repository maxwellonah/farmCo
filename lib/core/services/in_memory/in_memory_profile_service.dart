import '../../domain/domain.dart';
import '../profile_service.dart';

class InMemoryProfileService implements ProfileService {
  final Map<String, FarmerProfile> _farmers = <String, FarmerProfile>{};
  final Map<String, BuyerProfile> _buyers = <String, BuyerProfile>{};
  final Map<String, AgentProfile> _agents = <String, AgentProfile>{};

  @override
  Future<AgentProfile?> getAgentProfile(String userId) async => _agents[userId];

  @override
  Future<BuyerProfile?> getBuyerProfile(String userId) async => _buyers[userId];

  @override
  Future<FarmerProfile?> getFarmerProfile(String userId) async => _farmers[userId];

  @override
  Future<void> saveAgentProfile(AgentProfile profile) async {
    _agents[profile.userId] = profile;
  }

  @override
  Future<void> saveBuyerProfile(BuyerProfile profile) async {
    _buyers[profile.userId] = profile;
  }

  @override
  Future<void> saveFarmerProfile(FarmerProfile profile) async {
    _farmers[profile.userId] = profile;
  }

  @override
  Future<List<AgentProfile>> listAgents() async =>
      _agents.values.toList()
        ..sort((AgentProfile a, AgentProfile b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<BuyerProfile>> listBuyers() async =>
      _buyers.values.toList()
        ..sort((BuyerProfile a, BuyerProfile b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<FarmerProfile>> listFarmers() async =>
      _farmers.values.toList()
        ..sort((FarmerProfile a, FarmerProfile b) => b.createdAt.compareTo(a.createdAt));
}
