import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalchat/controller/emailverification_controller.dart';

class EmailVerificationView extends StatelessWidget {
  EmailVerificationView({super.key});

  final EmailVerificationController controller =
      Get.put(
    EmailVerificationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F7FF),

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
                  // BLUE HEADER
                  // ===================================================

                  Container(
                    width: double.infinity,

                    height:
                        Get.height * .28,

                    decoration:
                        const BoxDecoration(
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,

                        colors: [
                          Color(
                            0xFFD9F0FF,
                          ),
                          Color(
                            0xFFEAF7FF,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===================================================
                  // YELLOW CIRCLE
                  // ===================================================

                  Positioned(
                    right:
                        -Get.width * .085,

                    bottom:
                        -Get.height * .09,

                    child: Container(
                      width:
                          Get.width * .53,

                      height:
                          Get.height * .21,

                      decoration:
                          const BoxDecoration(
                        color:
                            Color(
                          0xFFFFD34E,
                        ),

                        shape:
                            BoxShape.circle,
                      ),
                    ),
                  ),

                  // ===================================================
                  // TITLE
                  // ===================================================

                  Positioned(
                    left:
                        Get.width * .053,

                    top:
                        Get.height * .075,

                    right:
                        Get.width * .25,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Verify Your Email',

                          style:
                              TextStyle(
                            color:
                                const Color(
                              0xFF172534,
                            ),

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
                          'One more step to secure your account.',

                          style:
                              TextStyle(
                            color:
                                const Color(
                              0xFF647587,
                            ),

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
            // WHITE BODY
            // =========================================================

            Expanded(
              child: Container(
                width: double.infinity,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

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

                child:
                    SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      EdgeInsets.fromLTRB(
                    Get.width * .053,

                    Get.height * .045,

                    Get.width * .053,

                    Get.height * .045,
                  ),

                  child: Column(
                    children: [

                      // ===================================================
                      // EMAIL ICON
                      // ===================================================

                      Container(
                        width:
                            Get.width * .22,

                        height:
                            Get.width * .22,

                        decoration:
                            const BoxDecoration(
                          color:
                              Color(
                            0xFFEAF7FF,
                          ),

                          shape:
                              BoxShape.circle,
                        ),

                        child: Icon(
                          Icons
                              .mark_email_read_outlined,

                          color:
                              const Color(
                            0xFF2196F3,
                          ),

                          size:
                              Get.width * .12,
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .035,
                      ),

                      // ===================================================
                      // TITLE
                      // ===================================================

                      Text(
                        'Check your inbox',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color:
                              const Color(
                            0xFF172534,
                          ),

                          fontSize:
                              Get.width * .05,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .015,
                      ),

                      // ===================================================
                      // DESCRIPTION
                      // ===================================================

                      Text(
                        'We sent a verification link to:',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color:
                              const Color(
                            0xFF647587,
                          ),

                          fontSize:
                              Get.width * .034,
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .01,
                      ),

                      // ===================================================
                      // EMAIL
                      //
                      // IMPORTANT:
                      // NO Obx HERE
                      // ===================================================

                      Text(
                        controller.email,

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
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

                      SizedBox(
                        height:
                            Get.height * .025,
                      ),

                      // ===================================================
                      // INFO
                      // ===================================================

                      Text(
                        'Please open the email and tap the verification link. After verifying your email, return here and press the button below.',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color:
                              const Color(
                            0xFF647587,
                          ),

                          fontSize:
                              Get.width * .032,

                          height: 1.5,
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .035,
                      ),

                      // ===================================================
                      // VERIFIED BUTTON
                      // ===================================================

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
                                        .checkVerification,

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
                                    BorderRadius
                                        .circular(
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

                                          strokeWidth:
                                              2.5,
                                        ),
                                      )
                                    : Text(
                                        'I Have Verified My Email',

                                        style:
                                            TextStyle(
                                          fontSize:
                                              Get.width *
                                                  .037,

                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .025,
                      ),

                      // ===================================================
                      // RESEND
                      // ===================================================

                      Obx(
                        () => GestureDetector(
                          onTap:
                              controller
                                      .isSending
                                      .value
                                  ? null
                                  : controller
                                      .resendVerificationEmail,

                          child: Text(
                            controller
                                    .isSending
                                    .value
                                ? 'Sending...'
                                : 'Resend Verification Email',

                            style:
                                TextStyle(
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

                      SizedBox(
                        height:
                            Get.height * .03,
                      ),

                      // ===================================================
                      // USE ANOTHER ACCOUNT
                      // ===================================================

                      GestureDetector(
                        onTap:
                            controller.logout,

                        child: Text(
                          'Use another account',

                          style:
                              TextStyle(
                            color:
                                const Color(
                              0xFF647587,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}