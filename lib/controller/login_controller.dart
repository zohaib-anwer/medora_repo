import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/email_verificatin/email_verification_view.dart';
import 'package:medicalchat/view/forgot/forgot_view.dart';
import 'package:medicalchat/view/bottom_nav/bottom_nav_bar.dart';

class LoginController extends GetxController {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // ============================================================
  // GETX VARIABLES
  // ============================================================

  final obscurePassword = true.obs;
  final isLoading = false.obs;

  // ============================================================
  // VALIDATION VARIABLES
  // ============================================================

  final emailError = RxnString();
  final passwordError = RxnString();

  // ============================================================
  // TOGGLE PASSWORD
  // ============================================================

  void togglePassword() {
    obscurePassword.value =
        !obscurePassword.value;
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool validateEmail() {
    final email =
        emailController.text.trim();

    if (email.isEmpty) {
      emailError.value =
          'Please enter your email address';
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      emailError.value =
          'Please enter a valid email address';
      return false;
    }

    emailError.value = null;
    return true;
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  bool validatePassword() {
    final password =
        passwordController.text;

    if (password.isEmpty) {
      passwordError.value =
          'Please enter your password';
      return false;
    }

    if (password.length < 6) {
      passwordError.value =
          'Password must be at least 6 characters';
      return false;
    }

    passwordError.value = null;
    return true;
  }

  // ============================================================
  // EMAIL CHANGED
  // ============================================================

  void onEmailChanged(String value) {
    if (emailError.value != null) {
      validateEmail();
    }
  }

  // ============================================================
  // PASSWORD CHANGED
  // ============================================================

  void onPasswordChanged(String value) {
    if (passwordError.value != null) {
      validatePassword();
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final emailValid =
        validateEmail();

    final passwordValid =
        validatePassword();

    if (!emailValid) {
      emailFocusNode.requestFocus();
      return;
    }

    if (!passwordValid) {
      passwordFocusNode.requestFocus();
      return;
    }

    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    try {
      isLoading.value = true;

      // ==========================================================
      // FIREBASE LOGIN
      // ==========================================================

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user =
          userCredential.user;

      if (user == null) {
        showMessage(
          'Unable to login. Please try again.',
        );
        return;
      }

      // ==========================================================
      // RELOAD USER
      // ==========================================================

      await user.reload();

      user = _auth.currentUser;

      if (user == null) {
        showMessage(
          'Unable to get your account information.',
        );
        return;
      }

      // ==========================================================
      // CHECK EMAIL VERIFICATION
      // ==========================================================

      if (!user.emailVerified) {
        showMessage(
          'Please verify your email address first.',
        );

        Get.to(
          () => EmailVerificationView(),
          transition:
              Transition.rightToLeft,
          duration:
              const Duration(
            milliseconds: 300,
          ),
        );

        return;
      }

      // ==========================================================
      // GET USER ROLE FROM FIRESTORE
      // ==========================================================

      final DocumentSnapshot<Map<String, dynamic>>
          userDocument =
          await _firestore
              .collection('paitent')
              .doc(user.uid)
              .get();

      if (!userDocument.exists) {
        showMessage(
          'Unable to load your account profile.',
        );

        await _auth.signOut();
        return;
      }

      final Map<String, dynamic>? data =
          userDocument.data();

      final String role =
    data?['role']
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';

debugPrint('LOGIN UID => ${user.uid}');
debugPrint('LOGIN PROFILE => $data');
debugPrint('LOGIN ROLE => "$role"');

switch (role) {
  case 'patient':
    Get.offAll(
      () => const BottomNavBar(),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    break;

  case 'doctor':
    Get.offAllNamed('/doctorDashboard');
    break;

  case 'admin':
    Get.offAllNamed('/adminDashboard');
    break;

  default:
    showMessage(
      'Your account role is not configured correctly.',
    );

    debugPrint(
      'UNKNOWN LOGIN ROLE => "$role"',
    );
    break;
}

    } on FirebaseAuthException catch (e) {
      showMessage(
        firebaseErrorMessage(e.code),
      );
    } on FirebaseException catch (e) {
      showMessage(
        'Database error: ${e.message ?? 'Please try again.'}',
      );
    } catch (e) {
      debugPrint(
        'LOGIN ERROR: $e',
      );

      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void forgotPassword() {
    Get.to(
      () => ForgotView(),
      transition:
          Transition.rightToLeft,
      duration:
          const Duration(
        milliseconds: 300,
      ),
    );
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> googleLogin() async {
    showMessage(
      'Google Sign-In setup is required for this platform.',
    );
  }

  // ============================================================
  // APPLE LOGIN
  // ============================================================

  Future<void> appleLogin() async {
    showMessage(
      'Apple Sign-In setup is required for this platform.',
    );
  }

  // ============================================================
  // FACEBOOK LOGIN
  // ============================================================

  Future<void> facebookLogin() async {
    showMessage(
      'Facebook Sign-In setup is required for this platform.',
    );
  }

  // ============================================================
  // FIREBASE ERROR MESSAGES
  // ============================================================

  String firebaseErrorMessage(
    String code,
  ) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return 'Login failed. Please try again.';
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void showMessage(
    String message, {
    bool isSuccess = false,
  }) {
    Get.snackbar(
      isSuccess
          ? 'Success'
          : 'Error',
      message,
      snackPosition:
          SnackPosition.TOP,
      margin:
          const EdgeInsets.all(15),
      borderRadius: 12,
      backgroundColor:
          isSuccess
              ? const Color(0xFF2196F3)
              : const Color(0xFF172534),
      colorText:
          Colors.white,
      duration:
          const Duration(
        seconds: 2,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.onClose();
  }
}