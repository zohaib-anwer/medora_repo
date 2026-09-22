import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/email_verificatin/email_verification_view.dart';

class SignupController extends GetxController {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final nameFocusNode =
      FocusNode();

  final emailFocusNode =
      FocusNode();

  final phoneFocusNode =
      FocusNode();

  final passwordFocusNode =
      FocusNode();

  final confirmPasswordFocusNode =
      FocusNode();

  // ============================================================
  // GETX VARIABLES
  // ============================================================

  final obscurePassword =
      true.obs;

  final obscureConfirmPassword =
      true.obs;

  final agreeToTerms =
      false.obs;

  final isLoading =
      false.obs;

  // ============================================================
  // VALIDATION ERRORS
  // ============================================================

  final nameError =
      RxnString();

  final emailError =
      RxnString();

  final phoneError =
      RxnString();

  final passwordError =
      RxnString();

  final confirmPasswordError =
      RxnString();

  // ============================================================
  // TOGGLE PASSWORD
  // ============================================================

  void togglePassword() {
    obscurePassword.value =
        !obscurePassword.value;
  }

  // ============================================================
  // TOGGLE CONFIRM PASSWORD
  // ============================================================

  void toggleConfirmPassword() {
    obscureConfirmPassword.value =
        !obscureConfirmPassword.value;
  }

  // ============================================================
  // TERMS
  // ============================================================

  void toggleTerms(
    bool? value,
  ) {
    agreeToTerms.value =
        value ?? false;
  }

  // ============================================================
  // NAME VALIDATION
  // ============================================================

  bool validateName() {
    final name =
        nameController.text.trim();

    if (name.isEmpty) {
      nameError.value =
          'Please enter your full name';
      return false;
    }

    nameError.value = null;
    return true;
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
  // PHONE VALIDATION
  // ============================================================

  bool validatePhone() {
    final phone =
        phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value =
          'Please enter your phone number';
      return false;
    }

    if (phone.length < 7) {
      phoneError.value =
          'Please enter a valid phone number';
      return false;
    }

    phoneError.value = null;
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
          'Please create a password';
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
  // CONFIRM PASSWORD VALIDATION
  // ============================================================

  bool validateConfirmPassword() {
    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      confirmPasswordError.value =
          'Please confirm your password';
      return false;
    }

    if (password != confirmPassword) {
      confirmPasswordError.value =
          'Passwords do not match';
      return false;
    }

    confirmPasswordError.value = null;
    return true;
  }

  // ============================================================
  // FIELD CHANGE METHODS
  // ============================================================

  void onNameChanged(
    String value,
  ) {
    if (nameError.value != null) {
      validateName();
    }
  }

  void onEmailChanged(
    String value,
  ) {
    if (emailError.value != null) {
      validateEmail();
    }
  }

  void onPhoneChanged(
    String value,
  ) {
    if (phoneError.value != null) {
      validatePhone();
    }
  }

  void onPasswordChanged(
    String value,
  ) {
    if (passwordError.value != null) {
      validatePassword();
    }

    if (confirmPasswordController
        .text
        .isNotEmpty) {
      validateConfirmPassword();
    }
  }

  void onConfirmPasswordChanged(
    String value,
  ) {
    if (confirmPasswordError.value != null) {
      validateConfirmPassword();
    }
  }

  // ============================================================
  // AUTOMATIC NEXT FIELD
  // ============================================================

  void nameSubmitted() {
    if (validateName()) {
      emailFocusNode.requestFocus();
    }
  }

  void emailSubmitted() {
    if (validateEmail()) {
      phoneFocusNode.requestFocus();
    }
  }

  void phoneSubmitted() {
    if (validatePhone()) {
      passwordFocusNode.requestFocus();
    }
  }

  void passwordSubmitted() {
    if (validatePassword()) {
      confirmPasswordFocusNode.requestFocus();
    }
  }

  void confirmPasswordSubmitted() {
    validateConfirmPassword();

    if (confirmPasswordError.value ==
        null) {
      createAccount();
    }
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> createAccount() async {
    FocusManager.instance.primaryFocus
        ?.unfocus();

    // ==========================================================
    // VALIDATE
    // ==========================================================

    final nameValid =
        validateName();

    final emailValid =
        validateEmail();

    final phoneValid =
        validatePhone();

    final passwordValid =
        validatePassword();

    final confirmPasswordValid =
        validateConfirmPassword();

    if (!nameValid) {
      nameFocusNode.requestFocus();
      return;
    }

    if (!emailValid) {
      emailFocusNode.requestFocus();
      return;
    }

    if (!phoneValid) {
      phoneFocusNode.requestFocus();
      return;
    }

    if (!passwordValid) {
      passwordFocusNode.requestFocus();
      return;
    }

    if (!confirmPasswordValid) {
      confirmPasswordFocusNode
          .requestFocus();
      return;
    }

    if (!agreeToTerms.value) {
      showMessage(
        'Please agree to the Terms of Service and Privacy Policy',
      );
      return;
    }

    // ==========================================================
    // VALUES
    // ==========================================================

    final String name =
        nameController.text.trim();

    final String email =
        emailController.text.trim();

    final String phone =
        phoneController.text.trim();

    final String password =
        passwordController.text;

    // ==========================================================
    // CREATE
    // ==========================================================

    try {
      isLoading.value = true;

      final UserCredential
          userCredential =
          await _auth
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        showMessage(
          'Account could not be created.',
        );
        return;
      }

      // ========================================================
      // DISPLAY NAME
      // ========================================================

      await user.updateDisplayName(
        name,
      );

      // ========================================================
      // SAVE USER
      // ========================================================

      await _firestore
         .collection('paitent')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': phone,

        // IMPORTANT
        'role': 'patient',

        'emailVerified': false,

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      // ========================================================
      // SEND VERIFICATION
      // ========================================================

      await user.sendEmailVerification();

      // ========================================================
      // SUCCESS
      // ========================================================

      showMessage(
        'Account created successfully. Verification email sent.',
        isSuccess: true,
      );

      // ========================================================
      // EMAIL VERIFICATION
      // ========================================================

      Get.off(
        () => EmailVerificationView(),
        transition:
            Transition.rightToLeft,
        duration:
            const Duration(
          milliseconds: 300,
        ),
      );
    } on FirebaseAuthException catch (e) {
      showMessage(
        firebaseErrorMessage(
          e.code,
        ),
      );
    } on FirebaseException catch (e) {
      showMessage(
        'Database error: ${e.message ?? 'Please try again.'}',
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

  String firebaseErrorMessage(
    String code,
  ) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'The email address is not valid.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return 'Account creation failed. Please try again.';
    }
  }

  // ============================================================
  // GOOGLE SIGNUP
  // ============================================================

  Future<void> googleSignup() async {
    // Google implementation below.
  }

  // ============================================================
  // APPLE SIGNUP
  // ============================================================

  Future<void> appleSignup() async {
    // Apple implementation below.
  }

  // ============================================================
  // FACEBOOK SIGNUP
  // ============================================================

  Future<void> facebookSignup() async {
    // Facebook implementation below.
  }

  // ============================================================
  // GO TO LOGIN
  // ============================================================

  void goToLogin() {
    Get.back();
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
          const Duration(seconds: 2),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.onClose();
  }
}