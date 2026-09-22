import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/home/home_view.dart';
import 'package:medicalchat/view/bottom_nav/bottom_nav_bar.dart';

class EmailVerificationController
    extends GetxController {
  // =========================================================
  // FIREBASE
  // =========================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // LOADING
  // =========================================================

  final RxBool isLoading =
      false.obs;

  final RxBool isSending =
      false.obs;

  // =========================================================
  // USER EMAIL
  // =========================================================

  String get email {
    return _auth.currentUser?.email ?? '';
  }

  // =========================================================
  // CHECK VERIFICATION
  // =========================================================

  Future<void> checkVerification() async {
    try {
      isLoading.value = true;

      User? user =
          _auth.currentUser;

      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      // =======================================================
      // RELOAD
      // =======================================================

      await user.reload();

      user = _auth.currentUser;

      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      // =======================================================
      // CHECK EMAIL
      // =======================================================

      if (!user.emailVerified) {
        showMessage(
          'Email Not Verified',
          'Please verify your email first.',
        );
        return;
      }

      // =======================================================
      // GET ROLE
      // =======================================================

      final DocumentSnapshot<
              Map<String, dynamic>>
          userDocument =
          await _firestore
             .collection('paitent')
              .doc(user.uid)
              .get();

      if (!userDocument.exists) {
        showMessage(
          'Account Error',
          'Unable to load your account profile.',
        );
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

debugPrint('VERIFICATION UID => ${user.uid}');
debugPrint('VERIFICATION PROFILE => $data');
debugPrint('VERIFICATION ROLE => "$role"');

      // =======================================================
      // ROLE NAVIGATION
      // =======================================================

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
      'Account Error',
      'Your account role is not configured correctly.',
    );

    debugPrint(
      'UNKNOWN VERIFICATION ROLE => "$role"',
    );

    await _auth.signOut();

    Get.offAllNamed('/login');
    break;
}
    } catch (e) {
      showMessage(
        'Error',
        'Unable to check email verification.',
      );

      debugPrint(
        'Check verification error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // RESEND VERIFICATION EMAIL
  // =========================================================

  Future<void> resendVerificationEmail() async {
    try {
      isSending.value = true;

      final User? user =
          _auth.currentUser;

      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      if (user.emailVerified) {
        showMessage(
          'Already Verified',
          'Your email is already verified.',
        );
        return;
      }

      await user.sendEmailVerification();

      showMessage(
        'Email Sent',
        'Verification email has been sent again.',
      );
    } on FirebaseAuthException catch (e) {
      String message =
          'Unable to send verification email.';

      if (e.code ==
          'too-many-requests') {
        message =
            'Too many requests. Please try again later.';
      }

      showMessage(
        'Error',
        message,
      );

      debugPrint(
        'Resend verification error: ${e.code}',
      );
    } catch (e) {
      showMessage(
        'Error',
        'Unable to send verification email.',
      );

      debugPrint(
        'Resend verification error: $e',
      );
    } finally {
      isSending.value = false;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    try {
      await _auth.signOut();

      Get.offAllNamed(
        '/login',
      );
    } catch (e) {
      debugPrint(
        'Logout error: $e',
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(
    String title,
    String message,
  ) {
    Get.snackbar(
      title,
      message,
      snackPosition:
          SnackPosition.BOTTOM,
      margin:
          const EdgeInsets.all(16),
      backgroundColor:
          Colors.white,
      colorText:
          const Color(0xFF172534),
      duration:
          const Duration(
        seconds: 3,
      ),
    );
  }
}