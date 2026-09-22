import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medicalchat/view/bottom_nav/bottom_nav_bar.dart';
import 'package:medicalchat/view/doctor_dashboard/doctor_dashboard_view.dart';
import 'package:medicalchat/view/email_verificatin/email_verification_view.dart';
import 'package:medicalchat/view/login/login_view.dart';

import 'firebase_options.dart';

import 'controller/push_notification/fcm_controller.dart';

import 'view/admin/admin_dashboard_view.dart';
import 'view/home/home_view.dart';

final box = GetStorage();

/// Firebase background notification handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'BACKGROUND NOTIFICATION => ${message.messageId}',
  );

  debugPrint(
    'TITLE => ${message.notification?.title}',
  );

  debugPrint(
    'BODY => ${message.notification?.body}',
  );

  debugPrint(
    'DATA => ${message.data}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase using gotourrd configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Initialize GetStorage
  await GetStorage.init();

  /// Register Firebase background notification handler
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  /// Start FCM controller
  Get.put(
    FcmController(),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Medical Chat',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
        ),
      ),

      builder: EasyLoading.init(),

      home: const AuthGate(),

      routes: {
        '/home': (context) => const BottomNavBar(),

        '/doctorDashboard': (context) =>
            const DoctorDashboardView(),

        '/adminDashboard': (context) =>
             AdminDashboardView(),
      },
    );
  }
}

///
/// AUTH GATE
///
/// Checks Firebase authentication state.
///
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        /// Firebase loading
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F7FF),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        /// User is not logged in
        if (!snapshot.hasData ||
            snapshot.data == null) {
          return LoginView();
        }

        final User user = snapshot.data!;

        /// Email verification check
        if (!user.emailVerified) {
          return EmailVerificationView();
        }

        /// User is logged in and verified
        return const RoleGate();
      },
    );
  }
}

///
/// ROLE GATE
///
/// Checks Firestore users/{uid}/role
///
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginView();
    }

    return FutureBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('paitent')
          .doc(user.uid)
          .get(),

      builder: (context, snapshot) {
        /// Loading
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F7FF),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        /// Error
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F7FF),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Something went wrong.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        /// Document does not exist
        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F7FF),
            body: Center(
              child: Text(
                'User profile not found.',
              ),
            ),
          );
        }

        final Map<String, dynamic>? data =
            snapshot.data!.data();

        final String role =
            data?['role']?.toString().toLowerCase() ?? '';

        /// USER
        if (role == 'patient'){
          return const BottomNavBar();
        }

        /// DOCTOR
        if (role == 'doctor') {
          return const DoctorDashboardView();
        }

        /// ADMIN
        if (role == 'admin') {
          return  AdminDashboardView();
        }

        /// Unknown role
        return Scaffold(
          backgroundColor: const Color(0xFFF3F7FF),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Unknown user role.\n\n'
                'Role: $role',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}