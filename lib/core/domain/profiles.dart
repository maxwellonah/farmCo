class FarmerProfile {
  const FarmerProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.farmerId,
    required this.farmName,
    required this.location,
    required this.primaryCrops,
    required this.createdAt,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String farmerId;
  final String farmName;
  final String location;
  final List<String> primaryCrops;
  final DateTime createdAt;
}

class BuyerProfile {
  const BuyerProfile({
    required this.userId,
    required this.companyName,
    required this.businessType,
    required this.contactPhone,
    required this.regions,
    required this.preferredCrops,
    required this.createdAt,
  });

  final String userId;
  final String companyName;
  final String businessType;
  final String contactPhone;
  final List<String> regions;
  final List<String> preferredCrops;
  final DateTime createdAt;
}

class AgentProfile {
  const AgentProfile({
    required this.userId,
    required this.fullName,
    required this.agentId,
    required this.coverageArea,
    required this.vehicleType,
    required this.rating,
    required this.createdAt,
  });

  final String userId;
  final String fullName;
  final String agentId;
  final List<String> coverageArea;
  final String vehicleType;
  final double rating;
  final DateTime createdAt;
}
