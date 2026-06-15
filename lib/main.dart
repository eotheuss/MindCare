
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:mindcare/screens/screens.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  await messaging.requestPermission(alert: true, badge: true, sound: true);

  runApp(const MindCareApp());
}

enum AppScreen {
  welcome,
  role,
  login,
  patientHome,
  patientDiary,
  patientReport,
  appointment,
  appointmentConfirm
}

enum UserRole { patient, professional }

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindCare Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.pink,
          brightness: Brightness.light,
        ),
      ),
      home: const MindCareFlow(),
    );
  }
}

class MindCareFlow extends StatefulWidget {
  const MindCareFlow({super.key});

  @override
  State<MindCareFlow> createState() => _MindCareFlowState();
}

class _MindCareFlowState extends State<MindCareFlow> {
  AppScreen screen = AppScreen.welcome;
  UserRole role = UserRole.patient;
  int patientTab = 0;
  int professionalTab = 0;

  void go(AppScreen next) {
    setState(() => screen = next);
  }

  void chooseRole(UserRole selectedRole) {
    setState(() {
      role = selectedRole;
      screen = AppScreen.login;
    });
  }

  void enterApp() {
    setState(() {
      if (role == UserRole.patient) {
        patientTab = 0;
        screen = AppScreen.patientHome;
      }
    });
  }

  void patientNav(int index) {
    setState(() {
      patientTab = index;
      screen = switch (index) {
        0 => AppScreen.patientHome,
        1 => AppScreen.patientDiary,
        _ => AppScreen.patientReport,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (screen) {
      AppScreen.welcome => WelcomeScreen(onStart: () => go(AppScreen.role)),
      AppScreen.role => RoleScreen(onRoleSelected: chooseRole),
      AppScreen.login => LoginScreen(
        role: role,
        onBack: () => go(AppScreen.role),
        onLogin: enterApp,
      ),
      AppScreen.patientHome => PatientHomeScreen(
        email: 'Maria Silva',
        onDiary: () => patientNav(1),
        onSchedule: () => go(AppScreen.appointment),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.patientDiary => PatientDiaryScreen(
        email: 'Maria Silva',
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.patientReport => PatientReportScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
        email: 'Maria Silva',
      ),
      AppScreen.appointment => AppointmentScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onConfirm: () => go(AppScreen.appointmentConfirm),
        onNav: patientNav,
        email: 'Maria Silva',
      ),
      AppScreen.appointmentConfirm => AppointmentConfirmScreen(
        onBack: () => go(AppScreen.appointment),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
        email: 'Maria Silva',
        selectedDate: DateTime.now(),
        professional: null,
        type: '',
      )
    
    };

    return page;
  }
}

class AppColors {
  static const background = Color(0xFFDFF6FF);
  static const patientHeader = Color(0xFF63BDF4);
  static const professionalHeader = Color(0xFFBE78E5);
  static const pink = Color(0xFFE93D9B);
  static const purple = Color(0xFF8257E5);
  static const blue = Color(0xFF168DDA);
  static const navy = Color(0xFF070B3F);
  static const green = Color(0xFF20C663);
  static const red = Color(0xFFFF5B63);
  static const card = Color(0xFFFFFFFF);
  static const muted = Color(0xFF667085);
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.child, this.bottomNavigationBar, super.key});

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: bottomNavigationBar,
              ),
            ),
    );
  }
}

