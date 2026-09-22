import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalchat/controller/signup_controller.dart';

class SignupView extends StatefulWidget {
  SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final SignupController controller = Get.put(SignupController());

  // ============================================================
  // FORM KEY
  // ============================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // ============================================================
  // VALIDATE + SIGN UP
  // ============================================================

  void _submitSignup() {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    controller.createAccount();
  }

  // ============================================================
  // DISPOSE FOCUS NODES
  // ============================================================

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),

      body: SafeArea(
        child: Column(
          children: [

            // =========================================================
            // SIGNUP HEADER
            // =========================================================

            SizedBox(
              height: Get.height * .20,

              child: Stack(
                clipBehavior: Clip.none,

                children: [

                  // ===================================================
                  // HEADER BACKGROUND
                  // ===================================================

                  Container(
                    width: double.infinity,
                    height: Get.height * .20,

                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFD9F0FF),
                          Color(0xFFEAF7FF),
                        ],
                      ),
                    ),
                  ),

                  // ===================================================
                  // YELLOW CIRCLE
                  // ===================================================

                  Positioned(
                    right: -Get.width * .085,
                    bottom: -Get.height * .086,

                    child: Container(
                      width: Get.width * .53,
                      height: Get.height * .21,

                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD34E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // ===================================================
                  // DOCTOR IMAGE
                  // ===================================================

                  Positioned(
                    bottom: -Get.height * .0025,
                    right: 0,

                    child: SizedBox(
                      width: Get.width * .467,
                      height: Get.height * .265,

                      child: Image.asset(
                        'assets/doctor.png',

                        fit: BoxFit.contain,

                        alignment: Alignment.bottomCenter,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Column(
                            mainAxisAlignment:
                                MainAxisAlignment.end,

                            children: [

                              Container(
                                width: Get.width * .192,
                                height: Get.width * .192,

                                decoration:
                                    const BoxDecoration(
                                  color: Color(0xFFD4B49D),
                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  Icons.person,
                                  size: Get.width * .139,
                                  color: Colors.white,
                                ),
                              ),

                              Container(
                                width: Get.width * .333,
                                height: Get.height * .154,

                                decoration:
                                    const BoxDecoration(
                                  color: Color(0xFFE9F4FF),

                                  borderRadius:
                                      BorderRadius.only(
                                    topLeft:
                                        Radius.circular(45),
                                    topRight:
                                        Radius.circular(45),
                                  ),
                                ),

                                child: Icon(
                                  Icons.medical_services_outlined,
                                  size: Get.width * .147,
                                  color:
                                      const Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // ===================================================
                  // CREATE ACCOUNT TITLE
                  // ===================================================

                  Positioned(
                    left: Get.width * .053,
                    top: Get.height * .074,
                    right: Get.width * .373,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Create Account',

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .053,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: Get.height * .011,
                        ),

                        Text(
                          'Sign up to book appointments and consult with the best doctors.',

                          style: TextStyle(
                            color:
                                const Color(0xFF647587),

                            fontSize:
                                Get.width * .0267,

                            fontWeight:
                                FontWeight.w500,

                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================================================
            // WHITE FORM AREA
            // =========================================================
            //
            // IMPORTANT:
            // Expanded automatically takes ALL remaining screen space.
            // No fixed height is used here.
            //
            // =========================================================

            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(Get.width * .067),

                    topRight:
                        Radius.circular(Get.width * .067),
                  ),
                ),

                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding: EdgeInsets.fromLTRB(
                    Get.width * .053,
                    Get.height * .040,
                    Get.width * .053,
                    Get.height * .040,
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // =================================================
                        // FULL NAME
                        // =================================================

                        Text(
                          'Full Name',

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .037,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        SizedBox(
                          height: Get.height * .012,
                        ),

                        SizedBox(
                          width: double.infinity,

                          child: TextFormField(
                            controller:
                                controller.nameController,

                            focusNode:
                                _nameFocus,

                            textInputAction:
                                TextInputAction.next,

                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(
                                _emailFocus,
                              );
                            },

                            style: TextStyle(
                              color:
                                  const Color(0xFF172534),

                              fontSize:
                                  Get.width * .037,
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }

                              if (value.trim().length < 2) {
                                return 'Please enter a valid name';
                              }

                              return null;
                            },

                            decoration:
                                InputDecoration(
                              hintText:
                                  'Enter your full name',

                              hintStyle:
                                  TextStyle(
                                color:
                                    const Color(0xFF9AA6B2),

                                fontSize:
                                    Get.width * .037,
                              ),

                              prefixIcon: Icon(
                                Icons.person_outline,

                                color:
                                    const Color(0xFF667584),

                                size:
                                    Get.width * .056,
                              ),

                              contentPadding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    Get.width * .032,

                                vertical: 0,
                              ),

                              filled: true,

                              fillColor:
                                  Colors.white,

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xFFDDE3E9),
                                ),
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xFF2196F3),

                                  width: 1.3,
                                ),
                              ),

                              errorBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color: Colors.red,

                                  width: 1.3,
                                ),
                              ),

                              focusedErrorBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color: Colors.red,

                                  width: 1.3,
                                ),
                              ),

                              errorStyle: TextStyle(
                                color: Colors.red,

                                fontSize:
                                    Get.width * .027,
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // EMAIL SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .020,
                        ),

                        // =================================================
                        // EMAIL LABEL
                        // =================================================

                        Text(
                          'Email Address',

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .037,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        SizedBox(
                          height: Get.height * .012,
                        ),

                        // =================================================
                        // EMAIL FIELD
                        // =================================================

                        SizedBox(
                          width: double.infinity,

                          child: TextFormField(
                            controller:
                                controller.emailController,

                            focusNode:
                                _emailFocus,

                            keyboardType:
                                TextInputType.emailAddress,

                            textInputAction:
                                TextInputAction.next,

                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(
                                _phoneFocus,
                              );
                            },

                            style: TextStyle(
                              color:
                                  const Color(0xFF172534),

                              fontSize:
                                  Get.width * .037,
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email address';
                              }

                              if (!GetUtils.isEmail(
                                  value.trim())) {
                                return 'Please enter a valid email address';
                              }

                              return null;
                            },

                            decoration:
                                InputDecoration(
                              hintText:
                                  'Enter your email',

                              hintStyle:
                                  TextStyle(
                                color:
                                    const Color(0xFF9AA6B2),

                                fontSize:
                                    Get.width * .037,
                              ),

                              prefixIcon: Icon(
                                Icons.email_outlined,

                                color:
                                    const Color(0xFF667584),

                                size:
                                    Get.width * .056,
                              ),

                              contentPadding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    Get.width * .032,

                                vertical: 0,
                              ),

                              filled: true,

                              fillColor:
                                  Colors.white,

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xFFDDE3E9),
                                ),
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xFF2196F3),

                                  width: 1.3,
                                ),
                              ),

                              errorBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color: Colors.red,

                                  width: 1.3,
                                ),
                              ),

                              focusedErrorBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color: Colors.red,

                                  width: 1.3,
                                ),
                              ),

                              errorStyle: TextStyle(
                                color: Colors.red,

                                fontSize:
                                    Get.width * .027,
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // PHONE SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .020,
                        ),

                        // =================================================
                        // PHONE LABEL
                        // =================================================

                        Text(
                          'Phone Number',

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .037,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        SizedBox(
                          height: Get.height * .012,
                        ),

                        // =================================================
                        // PHONE FIELD
                        // =================================================

                        SizedBox(
                          width: double.infinity,

                          child: TextFormField(
                            controller:
                                controller.phoneController,

                            focusNode:
                                _phoneFocus,

                            keyboardType:
                                TextInputType.phone,

                            textInputAction:
                                TextInputAction.next,

                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(
                                _passwordFocus,
                              );
                            },

                            style: TextStyle(
                              color:
                                  const Color(0xFF172534),

                              fontSize:
                                  Get.width * .037,
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }

                              if (value.trim().length < 7) {
                                return 'Please enter a valid phone number';
                              }

                              return null;
                            },

                            decoration:
                                InputDecoration(
                              hintText:
                                  'Enter your phone number',

                              hintStyle:
                                  TextStyle(
                                color:
                                    const Color(0xFF9AA6B2),

                                fontSize:
                                    Get.width * .037,
                              ),

                              prefixIcon: Icon(
                                Icons.phone_outlined,

                                color:
                                    const Color(0xFF667584),

                                size:
                                    Get.width * .056,
                              ),

                              contentPadding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    Get.width * .032,

                                vertical: 0,
                              ),

                              filled: true,

                              fillColor:
                                  Colors.white,

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xFFDDE3E9),
                                ),
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xFF2196F3),

                                  width: 1.3,
                                ),
                              ),

                              errorBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color: Colors.red,

                                  width: 1.3,
                                ),
                              ),

                              focusedErrorBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  Get.width * .037,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color: Colors.red,

                                  width: 1.3,
                                ),
                              ),

                              errorStyle: TextStyle(
                                color: Colors.red,

                                fontSize:
                                    Get.width * .027,
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // PASSWORD SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .020,
                        ),

                        // =================================================
                        // PASSWORD LABEL
                        // =================================================

                        Text(
                          'Password',

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .037,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        SizedBox(
                          height: Get.height * .012,
                        ),

                        // =================================================
                        // PASSWORD FIELD
                        // =================================================

                        Obx(
                          () => SizedBox(
                            width: double.infinity,

                            child: TextFormField(
                              controller:
                                  controller.passwordController,

                              focusNode:
                                  _passwordFocus,

                              obscureText:
                                  controller
                                      .obscurePassword
                                      .value,

                              textInputAction:
                                  TextInputAction.next,

                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(
                                  _confirmPasswordFocus,
                                );
                              },

                              style: TextStyle(
                                color:
                                    const Color(0xFF172534),

                                fontSize:
                                    Get.width * .037,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please create a password';
                                }

                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }

                                return null;
                              },

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Create a password',

                                hintStyle:
                                    TextStyle(
                                  color:
                                      const Color(0xFF9AA6B2),

                                  fontSize:
                                      Get.width * .037,
                                ),

                                prefixIcon: Icon(
                                  Icons.lock_outline,

                                  color:
                                      const Color(0xFF667584),

                                  size:
                                      Get.width * .056,
                                ),

                                suffixIcon:
                                    IconButton(
                                  splashRadius:
                                      Get.width * .053,

                                  onPressed:
                                      controller
                                          .togglePassword,

                                  icon: Icon(
                                    controller
                                            .obscurePassword
                                            .value
                                        ? Icons
                                            .visibility_off_outlined
                                        : Icons
                                            .visibility_outlined,

                                    color:
                                        const Color(
                                      0xFF647587,
                                    ),

                                    size:
                                        Get.width * .053,
                                  ),
                                ),

                                contentPadding:
                                    EdgeInsets.symmetric(
                                  horizontal:
                                      Get.width * .032,

                                  vertical: 0,
                                ),

                                filled: true,

                                fillColor:
                                    Colors.white,

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFDDE3E9),
                                  ),
                                ),

                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFF2196F3),

                                    width: 1.3,
                                  ),
                                ),

                                errorBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color: Colors.red,

                                    width: 1.3,
                                  ),
                                ),

                                focusedErrorBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color: Colors.red,

                                    width: 1.3,
                                  ),
                                ),

                                errorStyle: TextStyle(
                                  color: Colors.red,

                                  fontSize:
                                      Get.width * .027,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // CONFIRM PASSWORD SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .020,
                        ),

                        // =================================================
                        // CONFIRM PASSWORD LABEL
                        // =================================================

                        Text(
                          'Confirm Password',

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .037,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        SizedBox(
                          height: Get.height * .012,
                        ),

                        // =================================================
                        // CONFIRM PASSWORD FIELD
                        // =================================================

                        Obx(
                          () => SizedBox(
                            width: double.infinity,

                            child: TextFormField(
                              controller:
                                  controller
                                      .confirmPasswordController,

                              focusNode:
                                  _confirmPasswordFocus,

                              obscureText:
                                  controller
                                      .obscureConfirmPassword
                                      .value,

                              textInputAction:
                                  TextInputAction.done,

                              onFieldSubmitted: (_) {
                                _submitSignup();
                              },

                              style: TextStyle(
                                color:
                                    const Color(0xFF172534),

                                fontSize:
                                    Get.width * .037,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please confirm your password';
                                }

                                if (value !=
                                    controller
                                        .passwordController
                                        .text) {
                                  return 'Passwords do not match';
                                }

                                return null;
                              },

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Confirm your password',

                                hintStyle:
                                    TextStyle(
                                  color:
                                      const Color(0xFF9AA6B2),

                                  fontSize:
                                      Get.width * .037,
                                ),

                                prefixIcon: Icon(
                                  Icons.lock_outline,

                                  color:
                                      const Color(0xFF667584),

                                  size:
                                      Get.width * .056,
                                ),

                                suffixIcon:
                                    IconButton(
                                  splashRadius:
                                      Get.width * .053,

                                  onPressed:
                                      controller
                                          .toggleConfirmPassword,

                                  icon: Icon(
                                    controller
                                            .obscureConfirmPassword
                                            .value
                                        ? Icons
                                            .visibility_off_outlined
                                        : Icons
                                            .visibility_outlined,

                                    color:
                                        const Color(
                                      0xFF647587,
                                    ),

                                    size:
                                        Get.width * .053,
                                  ),
                                ),

                                contentPadding:
                                    EdgeInsets.symmetric(
                                  horizontal:
                                      Get.width * .032,

                                  vertical: 0,
                                ),

                                filled: true,

                                fillColor:
                                    Colors.white,

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFDDE3E9),
                                  ),
                                ),

                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFF2196F3),

                                    width: 1.3,
                                  ),
                                ),

                                errorBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color: Colors.red,

                                    width: 1.3,
                                  ),
                                ),

                                focusedErrorBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color: Colors.red,

                                    width: 1.3,
                                  ),
                                ),

                                errorStyle: TextStyle(
                                  color: Colors.red,

                                  fontSize:
                                      Get.width * .027,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // TERMS SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .015,
                        ),

                        // =================================================
                        // TERMS
                        // =================================================

                        Obx(
                          () => Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,

                            children: [

                              SizedBox(
                                width: Get.width * .059,
                                height: Get.width * .059,

                                child: Checkbox(
                                  value: controller
                                      .agreeToTerms
                                      .value,

                                  onChanged:
                                      controller
                                          .toggleTerms,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      Get.width * .011,
                                    ),
                                  ),

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(0xFFD0D7DE),
                                  ),

                                  activeColor:
                                      const Color(
                                    0xFF2196F3,
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: Get.width * .027,
                              ),

                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,

                                  children: [

                                    Text(
                                      'I agree to the ',

                                      style: TextStyle(
                                        color:
                                            const Color(
                                          0xFF647587,
                                        ),

                                        fontSize:
                                            Get.width * .026,
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {},

                                      child: Text(
                                        'Terms of Service',

                                        style: TextStyle(
                                          color:
                                              const Color(
                                            0xFF2196F3,
                                          ),

                                          fontSize:
                                              Get.width * .026,

                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      ' and ',

                                      style: TextStyle(
                                        color:
                                            const Color(
                                          0xFF647587,
                                        ),

                                        fontSize:
                                            Get.width * .026,
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {},

                                      child: Text(
                                        'Privacy Policy',

                                        style: TextStyle(
                                          color:
                                              const Color(
                                            0xFF2196F3,
                                          ),

                                          fontSize:
                                              Get.width * .026,

                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =================================================
                        // SIGNUP BUTTON SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .013,
                        ),

                        // =================================================
                        // SIGNUP BUTTON
                        // =================================================

                        Obx(
                          () => SizedBox(
                            width: double.infinity,

                            height:
                                Get.height * .0516,

                            child:
                                ElevatedButton(
                              onPressed:
                                  controller
                                          .isLoading
                                          .value
                                      ? null
                                      : _submitSignup,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF2196F3,
                                ),

                                disabledBackgroundColor:
                                    const Color(
                                  0xFF90CAF9,
                                ),

                                foregroundColor:
                                    Colors.white,

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    Get.width * .037,
                                  ),
                                ),
                              ),

                              child:
                                  controller
                                          .isLoading
                                          .value
                                      ? SizedBox(
                                          width:
                                              Get.width *
                                                  .059,

                                          height:
                                              Get.width *
                                                  .059,

                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                Get.width *
                                                    .0067,

                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Sign Up',

                                          style:
                                              TextStyle(
                                            fontSize:
                                                Get.width *
                                                    .04,

                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),
                            ),
                          ),
                        ),

                        // =================================================
                        // OR SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .019,
                        ),

                        // =================================================
                        // OR CONTINUE WITH
                        // =================================================

                        Row(
                          children: [

                            const Expanded(
                              child: Divider(
                                color:
                                    Color(0xFFDDE3E9),

                                thickness: 1,
                              ),
                            ),

                            Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    Get.width * .045,
                              ),

                              child: Text(
                                'or continue with',

                                style: TextStyle(
                                  color:
                                      const Color(
                                    0xFF647587,
                                  ),

                                  fontSize:
                                      Get.width * .0293,
                                ),
                              ),
                            ),

                            const Expanded(
                              child: Divider(
                                color:
                                    Color(0xFFDDE3E9),

                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        // =================================================
                        // SOCIAL SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .0146,
                        ),

                        // =================================================
                        // SOCIAL BUTTONS
                        // =================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            // =============================================
                            // GOOGLE
                            // =============================================

                            SizedBox(
                              width:
                                  Get.width * .147,

                              height:
                                  Get.width * .147,

                              child:
                                  OutlinedButton(
                                onPressed:
                                    controller
                                        .googleSignup,

                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  padding:
                                      EdgeInsets.zero,

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFDDE3E9,
                                    ),
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      Get.width * .037,
                                    ),
                                  ),
                                ),

                                child: Text(
                                  'G',

                                  style: TextStyle(
                                    fontSize:
                                        Get.width *
                                            .061,

                                    fontWeight:
                                        FontWeight.w700,

                                    color:
                                        const Color(
                                      0xFF4285F4,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // =============================================
                            // SPACE
                            // =============================================

                            SizedBox(
                              width:
                                  Get.width * .085,
                            ),

                            // =============================================
                            // APPLE
                            // =============================================

                            SizedBox(
                              width:
                                  Get.width * .147,

                              height:
                                  Get.width * .147,

                              child:
                                  OutlinedButton(
                                onPressed:
                                    controller
                                        .appleSignup,

                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  padding:
                                      EdgeInsets.zero,

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFDDE3E9,
                                    ),
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      Get.width * .037,
                                    ),
                                  ),
                                ),

                                child: Icon(
                                  Icons.apple,

                                  size:
                                      Get.width * .077,

                                  color:
                                      Colors.black,
                                ),
                              ),
                            ),

                            // =============================================
                            // SPACE
                            // =============================================

                            SizedBox(
                              width:
                                  Get.width * .085,
                            ),

                            // =============================================
                            // FACEBOOK
                            // =============================================

                            SizedBox(
                              width:
                                  Get.width * .147,

                              height:
                                  Get.width * .147,

                              child:
                                  OutlinedButton(
                                onPressed:
                                    controller
                                        .facebookSignup,

                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  padding:
                                      EdgeInsets.zero,

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFDDE3E9,
                                    ),
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      Get.width * .037,
                                    ),
                                  ),
                                ),

                                child: Container(
                                  width:
                                      Get.width * .072,

                                  height:
                                      Get.width * .072,

                                  decoration:
                                      const BoxDecoration(
                                    color:
                                        Color(
                                      0xFF1877F2,
                                    ),

                                    shape:
                                        BoxShape.circle,
                                  ),

                                  alignment:
                                      Alignment.center,

                                  child: Text(
                                    'f',

                                    style: TextStyle(
                                      color:
                                          Colors.white,

                                      fontSize:
                                          Get.width *
                                              .069,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // =================================================
                        // LOGIN SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .021,
                        ),

                        // =================================================
                        // LOGIN
                        // =================================================

                        Center(
                          child: Wrap(
                            alignment:
                                WrapAlignment.center,

                            children: [

                              Text(
                                'Already have an account? ',

                                style: TextStyle(
                                  color:
                                      const Color(
                                    0xFF647587,
                                  ),

                                  fontSize:
                                      Get.width * .032,
                                ),
                              ),

                              GestureDetector(
                                onTap:
                                    controller.goToLogin,

                                child: Text(
                                  'Login',

                                  style: TextStyle(
                                    color:
                                        const Color(
                                      0xFF2196F3,
                                    ),

                                    fontSize:
                                        Get.width * .032,

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =================================================
                        // BOTTOM SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .025,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}