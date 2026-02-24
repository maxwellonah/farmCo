import 'dart:async';

import 'package:flutter/material.dart';

import '../features/admin/presentation/screens/admin_home_screen.dart';
import '../features/admin/presentation/screens/admin_login_screen.dart';
import '../features/agent/presentation/screens/agent_home_screen.dart';
import '../features/agent/presentation/screens/agent_login_screen.dart';
import '../features/agent/presentation/screens/agent_onboarding_screen.dart';
import '../features/buyer/presentation/screens/buyer_home_screen.dart';
import '../features/buyer/presentation/screens/buyer_onboarding_screen.dart';
import '../features/farmer/presentation/screens/farmer_home_screen.dart';
import '../features/farmer/presentation/screens/farmer_registration_screen.dart';
import '../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';

enum AppStage {
  splash,
  language,
  roleSelection,
  farmerRegistration,
  farmerHome,
  buyerOnboarding,
  buyerHome,
  agentLogin,
  agentOnboarding,
  agentHome,
  adminLogin,
  adminHome,
}

class RootFlow extends StatefulWidget {
  const RootFlow({super.key});

  @override
  State<RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<RootFlow> {
  AppStage _stage = AppStage.splash;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _stage = AppStage.language;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setStage(AppStage stage) {
    setState(() {
      _stage = stage;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case AppStage.splash:
        return const SplashScreen();
      case AppStage.language:
        return LanguageSelectionScreen(
          onContinue: () => _setStage(AppStage.roleSelection),
        );
      case AppStage.roleSelection:
        return RoleSelectionScreen(
          onFarmerSelected: () => _setStage(AppStage.farmerRegistration),
          onBuyerSelected: () => _setStage(AppStage.buyerOnboarding),
          onAgentSelected: () => _setStage(AppStage.agentLogin),
          onAdminSelected: () => _setStage(AppStage.adminLogin),
        );
      case AppStage.farmerRegistration:
        return FarmerRegistrationScreen(
          onBack: () => _setStage(AppStage.roleSelection),
          onComplete: () => _setStage(AppStage.farmerHome),
        );
      case AppStage.farmerHome:
        return FarmerHomeScreen(onLogout: () => _setStage(AppStage.roleSelection));
      case AppStage.buyerOnboarding:
        return BuyerOnboardingScreen(
          onBack: () => _setStage(AppStage.roleSelection),
          onComplete: () => _setStage(AppStage.buyerHome),
        );
      case AppStage.buyerHome:
        return BuyerHomeScreen(onLogout: () => _setStage(AppStage.roleSelection));
      case AppStage.agentLogin:
        return AgentLoginScreen(
          onBack: () => _setStage(AppStage.roleSelection),
          onLogin: () => _setStage(AppStage.agentOnboarding),
          onQuickEnter: () => _setStage(AppStage.agentHome),
        );
      case AppStage.agentOnboarding:
        return AgentOnboardingScreen(
          onBack: () => _setStage(AppStage.agentLogin),
          onComplete: () => _setStage(AppStage.agentHome),
        );
      case AppStage.agentHome:
        return AgentHomeScreen(onLogout: () => _setStage(AppStage.roleSelection));
      case AppStage.adminLogin:
        return AdminLoginScreen(
          onBack: () => _setStage(AppStage.roleSelection),
          onLogin: () => _setStage(AppStage.adminHome),
        );
      case AppStage.adminHome:
        return AdminHomeScreen(onLogout: () => _setStage(AppStage.roleSelection));
    }
  }
}
