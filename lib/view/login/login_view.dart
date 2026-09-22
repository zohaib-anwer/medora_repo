import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalchat/controller/login_controller.dart';
import 'package:medicalchat/view/singup/singup_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.put(LoginController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),

      body: SafeArea(
        child: Column(
          children: [

            // =========================================================
            // LOGIN HEADER
            // =========================================================

            SizedBox(
              height: Get.height * .22,

              child: Stack(
                clipBehavior: Clip.none,

                children: [

                  // ===================================================
                  // HEADER BACKGROUND
                  // ===================================================

                  Container(
                    width: double.infinity,
                    height: Get.height * .22,

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
                  // LOGIN TITLE
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
                          'Welcome Back',

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
                          'Login to your account to continue finding the best doctors.',

                          style: TextStyle(
                            color:
                                const Color(0xFF647587),

                            fontSize:
                                Get.width * .0267,

                            fontWeight:
                                FontWeight.w500,
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
                    Get.height * .035,
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

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

                            style: TextStyle(
                              color:
                                  const Color(0xFF172534),

                              fontSize:
                                  Get.width * .037,
                            ),

                            onFieldSubmitted: (_) {
                              _passwordFocus.requestFocus();
                            },

                            validator: (value) {
                              final email =
                                  value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Please enter your email address';
                              }

                              if (!GetUtils.isEmail(email)) {
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
                                    const Color(
                                  0xFF9AA6B2,
                                ),

                                fontSize:
                                    Get.width * .037,
                              ),

                              prefixIcon:
                                  Icon(
                                Icons.email_outlined,

                                color:
                                    const Color(
                                  0xFF667584,
                                ),

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
                            ),
                          ),
                        ),

                        // =================================================
                        // PASSWORD SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .025,
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
                          () => TextFormField(
                            controller:
                                controller.passwordController,

                            focusNode:
                                _passwordFocus,

                            obscureText:
                                controller
                                    .obscurePassword
                                    .value,

                            textInputAction:
                                TextInputAction.done,

                            style: TextStyle(
                              color:
                                  const Color(0xFF172534),

                              fontSize:
                                  Get.width * .037,
                            ),

                            onFieldSubmitted: (_) {
                              if (_formKey
                                  .currentState!
                                  .validate()) {
                                controller.login();
                              }
                            },

                            validator: (value) {
                              final password =
                                  value ?? '';

                              if (password.isEmpty) {
                                return 'Please enter your password';
                              }

                              if (password.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },

                            decoration:
                                InputDecoration(
                              hintText:
                                  'Enter your password',

                              hintStyle:
                                  TextStyle(
                                color:
                                    const Color(
                                  0xFF9AA6B2,
                                ),

                                fontSize:
                                    Get.width * .037,
                              ),

                              prefixIcon:
                                  Icon(
                                Icons.lock_outline,

                                color:
                                    const Color(
                                  0xFF667584,
                                ),

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
                            ),
                          ),
                        ),

                        // =================================================
                        // FORGOT PASSWORD SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .015,
                        ),

                        // =================================================
                        // FORGOT PASSWORD
                        // =================================================

                        Align(
                          alignment:
                              Alignment.centerRight,

                          child: GestureDetector(
                            onTap:
                                controller.forgotPassword,

                            child: Text(
                              'Forgot Password?',

                              style: TextStyle(
                                color:
                                    const Color(
                                  0xFF2196F3,
                                ),

                                fontSize:
                                    Get.width * .0347,

                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // LOGIN BUTTON SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .037,
                        ),

                        // =================================================
                        // LOGIN BUTTON
                        // =================================================

                        Obx(
                          () => SizedBox(
                            width: double.infinity,

                            height:
                                Get.height * .0616,

                            child:
                                ElevatedButton(
                              onPressed:
                                  controller
                                          .isLoading
                                          .value
                                      ? null
                                      : () {
                                          if (_formKey
                                              .currentState!
                                              .validate()) {
                                            controller.login();
                                          }
                                        },

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
                                    Get.width * .04,
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
                                                  .061,

                                          height:
                                              Get.width *
                                                  .061,

                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2.5,

                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Login',

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
                        // DIVIDER SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .045,
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
                        // SOCIAL BUTTON SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .0246,
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
                                        .googleLogin,

                                style:
                                    OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  padding:
                                      EdgeInsets.zero,

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(0xFFDDE3E9),
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
                                        .appleLogin,

                                style:
                                    OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  padding:
                                      EdgeInsets.zero,

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(0xFFDDE3E9),
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
                                        .facebookLogin,

                                style:
                                    OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  padding:
                                      EdgeInsets.zero,

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(0xFFDDE3E9),
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
                                        Color(0xFF1877F2),

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
                        // SIGN UP SPACE
                        // =================================================

                        SizedBox(
                          height: Get.height * .031,
                        ),

                        // =================================================
                        // SIGN UP
                        // =================================================

                        Center(
                          child: Wrap(
                            alignment:
                                WrapAlignment.center,

                            children: [

                              Text(
                                "Don't have an account? ",

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
                                onTap: () {
                                  Get.to(
                                    () => SignupView(),

                                    transition:
                                        Transition.rightToLeft,

                                    duration:
                                        const Duration(
                                      milliseconds: 300,
                                    ),
                                  );
                                },

                                child: Text(
                                  'Sign Up',

                                  style: TextStyle(
                                    color:
                                        const Color(
                                      0xFF2196F3,
                                    ),

                                    fontSize:
                                        Get.width * .032,

                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
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