import '../domain/domain.dart';

abstract class ProfileService {
  Future<void> saveFarmerProfile(FarmerProfile profile);

  Future<void> saveBuyerProfile(BuyerProfile profile);

  Future<void> saveAgentProfile(AgentProfile profile);

  Future<FarmerProfile?> getFarmerProfile(String userId);

  Future<BuyerProfile?> getBuyerProfile(String userId);

  Future<AgentProfile?> getAgentProfile(String userId);
}
