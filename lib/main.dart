import 'package:flutter/material.dart';
import 'package:graduation_project11/features/customer/home/presentation/screen/home_screen.dart';
import 'package:graduation_project11/features/customer/recycling/presentation/screens/order_status_screen.dart';
import 'package:graduation_project11/features/customer/recycling/presentation/screens/rewarding_screen.dart';
import 'package:graduation_project11/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project11/core/routes/pages.dart';
import 'package:graduation_project11/core/themes/app__theme.dart';
import 'package:graduation_project11/core/providers/auth_provider.dart';
import 'package:graduation_project11/features/delivery%20boy/home/presentation/screen/DeliveryHomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project11/core/utils/shared_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? resumeEmail = prefs.getString(
    SharedKeys.orderStatusResumeEmail,
  );
  final bool shouldResumeToRewarding =
      prefs.getBool(SharedKeys.shouldResumeToRewardingScreen) ?? false;

  Widget initialScreenWidget;

  if (shouldResumeToRewarding && authProvider.isLoggedIn) {
    final totalPoints = prefs.getInt(SharedKeys.rewardingScreenTotalPoints);
    final assignmentId = prefs.getInt(SharedKeys.rewardingScreenAssignmentId);

    if (totalPoints != null) {
      initialScreenWidget = RewardingScreen(
        totalPoints: totalPoints,
        assignmentId: assignmentId,
      );
      await prefs.setBool(SharedKeys.shouldResumeToRewardingScreen, false);
      print("main.dart: Resuming to RewardingScreen.");
    } else {
      await prefs.setBool(SharedKeys.shouldResumeToRewardingScreen, false);
      print("main.dart: RewardingScreen resume data missing. Clearing flag.");
      initialScreenWidget = const AuthWrapper(); // Fallback
    }
  } else if (resumeEmail != null &&
      resumeEmail.isNotEmpty &&
      authProvider.isLoggedIn && // Check current auth state
      authProvider.userType == 'regular_user' &&
      authProvider.email == resumeEmail) {
    // If resume conditions are met (user is logged in as the same regular user)
    initialScreenWidget = OrderStatusScreen(userEmail: resumeEmail);
    print("main.dart: Resuming to OrderStatusScreen.");
  } else {
    if (resumeEmail != null && resumeEmail.isNotEmpty) {
      await prefs.remove(SharedKeys.orderStatusResumeEmail);
      print("main.dart: Cleared stale orderStatusResumeEmail for $resumeEmail");
    }
    if (shouldResumeToRewarding) {
      // If shouldResumeToRewarding was true but authProvider was not logged in, clear the flag.
      await prefs.setBool(SharedKeys.shouldResumeToRewardingScreen, false);
      print(
        "main.dart: Cleared shouldResumeToRewardingScreen because user is not logged in.",
      );
    }
    initialScreenWidget = const AuthWrapper();
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authProvider)],
      child: MyApp(initialScreen: initialScreenWidget),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: initialScreen,
        onGenerateRoute: AppRoute.generate,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.email == null && !authProvider.isLoggedIn) {
          return const SplashScreen();
        }

        if (!authProvider.isLoggedIn) {
          return const SplashScreen();
        }

        if (authProvider.userType == 'delivery_boy') {
          return DeliveryHomeScreen(email: authProvider.email!);
        } else if (authProvider.userType == 'regular_user') {
          return const HomeScreen();
        }

        print(
          'AuthWrapper: Fallback. UserType: ${authProvider.userType}, LoggedIn: ${authProvider.isLoggedIn}. Defaulting to SplashScreen.',
        );
        return const SplashScreen();
      },
    );
  }
}
