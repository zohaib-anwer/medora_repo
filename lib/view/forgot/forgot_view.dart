import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalchat/controller/forgot_controller.dart';

class ForgotView extends StatelessWidget {
  ForgotView({super.key});

  final ForgotController controller =
      Get.put(ForgotController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),

      body: SafeArea(
        child: Column(
          children: [

            // =========================================================
            // HEADER
            // =========================================================

            SizedBox(
              height: Get.height * .28,

              child: Stack(
                clipBehavior: Clip.none,

                children: [

                  // ===================================================
                  // HEADER BACKGROUND
                  // ===================================================

                  Container(
                    width: double.infinity,
                    height: Get.height * .28,

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
                    bottom: -Get.height * .09,

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
                                  Icons
                                      .medical_services_outlined,
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
                  // FORGOT PASSWORD TITLE
                  // ===================================================

                  Positioned(
                    left: Get.width * .053,
                    top: Get.height * .075,
                    right: Get.width * .25,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Forgot Password?',

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
                          height:
                              Get.height * .011,
                        ),

                        Text(
                          'Enter your email and we will send you a password reset link.',

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
            // WHITE FORM
            // =========================================================
            //
            // Expanded automatically takes ALL remaining screen space.
            // This removes the empty space below the white container.
            // =========================================================

            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.only(
                    topLeft:
                        Radius.circular(
                      Get.width * .067,
                    ),

                    topRight:
                        Radius.circular(
                      Get.width * .067,
                    ),
                  ),
                ),

                padding:
                    EdgeInsets.symmetric(
                  horizontal:
                      Get.width * .053,

                  vertical:
                      Get.height * .045,
                ),

                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

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
                        height:
                            Get.height * .012,
                      ),

                      // =================================================
                      // EMAIL FIELD
                      // =================================================

                      SizedBox(
                        height:
                            Get.height * .0616,

                        child: TextField(
                          controller:
                              controller.emailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          style: TextStyle(
                            color:
                                const Color(0xFF172534),

                            fontSize:
                                Get.width * .037,
                          ),

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

                            filled: true,

                            fillColor:
                                Colors.white,

                            contentPadding:
                                EdgeInsets.symmetric(
                              horizontal:
                                  Get.width * .032,
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                Get.width * .037,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Color(
                                  0xFFDDE3E9,
                                ),
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
                                    Color(
                                  0xFF2196F3,
                                ),

                                width: 1.3,
                              ),
                            ),

                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                Get.width * .037,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // =================================================
                      // BUTTON SPACE
                      // =================================================

                      SizedBox(
                        height:
                            Get.height * .035,
                      ),

                      // =================================================
                      // SEND RESET BUTTON
                      // =================================================

                      Obx(
                        () => SizedBox(
                          width:
                              double.infinity,

                          height:
                              Get.height * .0616,

                          child:
                              ElevatedButton(
                            onPressed:
                                controller
                                        .isLoading
                                        .value
                                    ? null
                                    : controller
                                        .sendResetEmail,

                            style:
                                ElevatedButton
                                    .styleFrom(
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
                                                .059,

                                        height:
                                            Get.width *
                                                .059,

                                        child:
                                            const CircularProgressIndicator(
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Send Reset Link',

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
                      // BACK SPACE
                      // =================================================

                      SizedBox(
                        height:
                            Get.height * .035,
                      ),

                      // =================================================
                      // BACK TO LOGIN
                      // =================================================

                      Center(
                        child: GestureDetector(
                          onTap:
                              Get.back,

                          child: Text(
                            'Back to Login',

                            style: TextStyle(
                              color:
                                  const Color(
                                0xFF2196F3,
                              ),

                              fontSize:
                                  Get.width * .034,

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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