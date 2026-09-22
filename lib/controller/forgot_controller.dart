import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();

  final isLoading = false.obs;

  // ============================================================
  // SEND RESET EMAIL
  // ============================================================

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage(
        'Please enter your email address',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      showMessage(
        'Please enter a valid email address',
      );
      return;
    }

    try {
      isLoading.value = true;

      await _auth.sendPasswordResetEmail(
        email: email,
      );

      showMessage(
        'Password reset link has been sent to your email.',
        isSuccess: true,
      );

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      Get.back();
    } on FirebaseAuthException catch (e) {
      showMessage(
        firebaseErrorMessage(e.code),
      );
    } catch (e) {
      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FIREBASE ERROR
  // ============================================================

  String firebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'too-many-requests':
        return 'Too many requests. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return 'Unable to send reset email. Please try again.';
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message, {
    bool isSuccess = false,
  }) {
    Get.snackbar(
      isSuccess ? 'Success' : 'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      backgroundColor: isSuccess
          ? const Color(0xFF2196F3)
          : const Color(0xFF172534),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}