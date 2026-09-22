import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/status_controller.dart';

class StatusView extends StatelessWidget {
  StatusView({super.key});

  final StatusController controller =
      Get.put(StatusController());

  // =========================================================
  // COLORS
  // =========================================================

  static const Color blue =
      Color(0xFF2196F3);

  static const Color darkText =
      Color(0xFF172534);

  static const Color greyText =
      Color(0xFF647587);

  static const Color borderColor =
      Color(0xFFDDE3E9);

  static const Color background =
      Color(0xFFF3F7FF);

  static const Color lightBlue =
      Color(0xFFEAF7FF);

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: RefreshIndicator(
          color: blue,
          backgroundColor: Colors.white,

          onRefresh:
              controller.refreshAppointments,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent:
                  BouncingScrollPhysics(),
            ),

            padding:
                EdgeInsets.fromLTRB(
              Get.width * .053,
              Get.height * .025,
              Get.width * .053,
              Get.height * .035,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =================================================
                // HEADER
                // =================================================

                Text(
                  'Status',
                  style: TextStyle(
                    color: darkText,
                    fontSize:
                        Get.width * .053,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .007,
                ),

                Text(
                  'Track your appointments',
                  style: TextStyle(
                    color: greyText,
                    fontSize:
                        Get.width * .028,
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .030,
                ),

                // =================================================
                // STATUS TABS
                // =================================================

                Obx(
                  () {
                    return SizedBox(
                      height:
                          Get.height * .050,

                      child:
                          ListView.builder(
                        scrollDirection:
                            Axis.horizontal,

                        physics:
                            const BouncingScrollPhysics(),

                        itemCount:
                            controller
                                .statusTabs
                                .length,

                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          return _statusTab(
                            index,
                          );
                        },
                      ),
                    );
                  },
                ),

                SizedBox(
                  height:
                      Get.height * .030,
                ),

                // =================================================
                // APPOINTMENTS
                // =================================================

                Obx(
                  () {
                    // =============================================
                    // LOADING
                    // =============================================

                    if (controller
                        .isLoading
                        .value) {
                      return _loadingWidget();
                    }

                    // =============================================
                    // ERROR
                    // =============================================

                    if (controller
                        .hasError
                        .value) {
                      return _errorWidget();
                    }

                    // =============================================
                    // DATA
                    // =============================================

                    final List<
                        Map<String, dynamic>>
                        appointmentList =
                        controller
                            .filteredAppointments
                            .toList();

                    // =============================================
                    // EMPTY
                    // =============================================

                    if (appointmentList.isEmpty) {
                      return _emptyAppointments();
                    }

                    // =============================================
                    // LIST
                    // =============================================

                    return ListView.builder(
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          appointmentList.length,

                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return _appointmentCard(
                          appointmentList[index],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STATUS TAB
  // =========================================================

  Widget _statusTab(
    int index,
  ) {
    return Obx(
      () {
        final bool selected =
            controller
                    .selectedStatus
                    .value ==
                index;

        return GestureDetector(
          behavior:
              HitTestBehavior.opaque,

          onTap: () {
            controller.selectStatus(
              index,
            );
          },

          child: Container(
            margin:
                EdgeInsets.only(
              right:
                  Get.width * .020,
            ),

            padding:
                EdgeInsets.symmetric(
              horizontal:
                  Get.width * .035,
            ),

            alignment:
                Alignment.center,

            decoration:
                BoxDecoration(
              color: selected
                  ? blue
                  : Colors.white,

              borderRadius:
                  BorderRadius.circular(
                Get.width * .025,
              ),

              border:
                  Border.all(
                color: selected
                    ? blue
                    : borderColor,
              ),
            ),

            child: Text(
              controller.statusTabs[index],

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : greyText,

                fontSize:
                    Get.width * .024,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // LOADING
  // =========================================================

  Widget _loadingWidget() {
    return SizedBox(
      height:
          Get.height * .300,

      child: const Center(
        child:
            CircularProgressIndicator(
          color: blue,
        ),
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _errorWidget() {
    return Container(
      width:
          double.infinity,

      padding:
          EdgeInsets.all(
        Get.width * .050,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .035,
        ),

        border:
            Border.all(
          color: borderColor,
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: Get.width * .085,
          ),

          SizedBox(
            height:
                Get.height * .012,
          ),

          Obx(
            () {
              final String message =
                  controller
                      .errorMessage
                      .value;

              return Text(
                message.isEmpty
                    ? 'Unable to load appointments.'
                    : message,

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: greyText,
                  fontSize:
                      Get.width * .027,
                ),
              );
            },
          ),

          SizedBox(
            height:
                Get.height * .018,
          ),

          ElevatedButton(
            onPressed:
                controller
                    .refreshAppointments,

            style:
                ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor:
                  Colors.white,
              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),

            child:
                const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _emptyAppointments() {
    return Container(
      width:
          double.infinity,

      padding:
          EdgeInsets.symmetric(
        horizontal:
            Get.width * .050,

        vertical:
            Get.height * .045,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .035,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child:
          Column(
        children: [
          Container(
            width:
                Get.width * .17,

            height:
                Get.width * .17,

            decoration:
                const BoxDecoration(
              color:
                  lightBlue,
              shape:
                  BoxShape.circle,
            ),

            child:
                Icon(
              Icons.calendar_today_outlined,
              color:
                  blue,
              size:
                  Get.width * .080,
            ),
          ),

          SizedBox(
            height:
                Get.height * .015,
          ),

          Text(
            'No appointments found',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color:
                  darkText,

              fontSize:
                  Get.width * .030,

              fontWeight:
                  FontWeight.w600,
            ),
          ),

          SizedBox(
            height:
                Get.height * .006,
          ),

          Text(
            'Your appointments will appear here.',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color:
                  greyText,

              fontSize:
                  Get.width * .024,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // APPOINTMENT CARD
  // =========================================================

  Widget _appointmentCard(
    Map<String, dynamic> appointment,
  ) {
    final String status =
        controller.getStatus(
      appointment,
    );

    final String normalizedStatus =
        controller.normalizeStatus(
      appointment['status'],
    );

    final String doctorName =
        controller.getDoctorName(
      appointment,
    );

    final String specialist =
        controller.getSpecialist(
      appointment,
    );

    final String doctorImage =
        controller.getDoctorImage(
      appointment,
    );

    final String date =
        controller.getDate(
      appointment,
    );

    final String time =
        controller.getTime(
      appointment,
    );

    final bool canCancel =
        normalizedStatus ==
                'upcoming' ||
            normalizedStatus ==
                'pending';

    return Container(
      width:
          double.infinity,

      margin:
          EdgeInsets.only(
        bottom:
            Get.height * .018,
      ),

      padding:
          EdgeInsets.all(
        Get.width * .035,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .037,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(
              0.025,
            ),

            blurRadius:
                8,

            offset:
                const Offset(
              0,
              3,
            ),
          ),
        ],
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =====================================================
          // DOCTOR INFO
          // =====================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [
              // =================================================
              // IMAGE
              // =================================================

              _doctorImage(
                doctorImage,
              ),

              SizedBox(
                width:
                    Get.width * .030,
              ),

              // =================================================
              // NAME
              // =================================================

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      doctorName,

                      maxLines:
                          1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          TextStyle(
                        color:
                            darkText,

                        fontSize:
                            Get.width *
                                .031,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    SizedBox(
                      height:
                          Get.height *
                              .005,
                    ),

                    Text(
                      specialist,

                      maxLines:
                          1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          TextStyle(
                        color:
                            greyText,

                        fontSize:
                            Get.width *
                                .023,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width:
                    Get.width * .015,
              ),

              // =================================================
              // STATUS
              // =================================================

              _statusBadge(
                status,
                normalizedStatus,
              ),
            ],
          ),

          SizedBox(
            height:
                Get.height * .020,
          ),

          Divider(
            color:
                borderColor,

            height:
                1,
          ),

          SizedBox(
            height:
                Get.height * .015,
          ),

          // =====================================================
          // DATE + TIME
          // =====================================================

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color:
                    blue,
                size:
                    16,
              ),

              const SizedBox(
                width:
                    7,
              ),

              Expanded(
                child:
                    Text(
                  date,

                  maxLines:
                      1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      TextStyle(
                    color:
                        greyText,

                    fontSize:
                        Get.width *
                            .022,
                  ),
                ),
              ),

              SizedBox(
                width:
                    Get.width * .020,
              ),

              const Icon(
                Icons.access_time,
                color:
                    blue,
                size:
                    16,
              ),

              const SizedBox(
                width:
                    7,
              ),

              Expanded(
                child:
                    Text(
                  time,

                  maxLines:
                      1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      TextStyle(
                    color:
                        greyText,

                    fontSize:
                        Get.width *
                            .022,
                  ),
                ),
              ),
            ],
          ),

          // =====================================================
          // CANCEL BUTTON
          // =====================================================

          if (canCancel) ...[
            SizedBox(
              height:
                  Get.height * .015,
            ),

            SizedBox(
              width:
                  double.infinity,

              height:
                  Get.height * .050,

              child:
                  OutlinedButton(
                onPressed:
                    () {
                  _showCancelDialog(
                    appointment,
                  );
                },

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      Colors.red,

                  side:
                      const BorderSide(
                    color:
                        Color(
                      0xFFFFCDD2,
                    ),
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                child:
                    Text(
                  'Cancel Appointment',

                  style:
                      TextStyle(
                    fontSize:
                        Get.width *
                            .024,

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // DOCTOR IMAGE
  // =========================================================

  Widget _doctorImage(
    String imageUrl,
  ) {
    return Container(
      width:
          Get.width * .15,

      height:
          Get.width * .15,

      decoration:
          BoxDecoration(
        color:
            lightBlue,

        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child:
          ClipRRect(
        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),

        child:
            imageUrl.isEmpty
                ? _defaultDoctorIcon()
                : Image.network(
                    imageUrl,

                    width:
                        double.infinity,

                    height:
                        double.infinity,

                    fit:
                        BoxFit.cover,

                    loadingBuilder:
                        (
                      context,
                      child,
                      progress,
                    ) {
                      if (progress ==
                          null) {
                        return child;
                      }

                      return Center(
                        child:
                            SizedBox(
                          width:
                              Get.width *
                                  .040,

                          height:
                              Get.width *
                                  .040,

                          child:
                              const CircularProgressIndicator(
                            strokeWidth:
                                2,

                            color:
                                blue,
                          ),
                        ),
                      );
                    },

                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _defaultDoctorIcon();
                    },
                  ),
      ),
    );
  }

  // =========================================================
  // DEFAULT DOCTOR ICON
  // =========================================================

  Widget _defaultDoctorIcon() {
    return Center(
      child:
          Icon(
        Icons.person_outline,

        color:
            const Color(
          0xFF7FAED0,
        ),

        size:
            Get.width * .070,
      ),
    );
  }

  // =========================================================
  // STATUS BADGE
  // =========================================================

  Widget _statusBadge(
    String status,
    String normalizedStatus,
  ) {
    Color backgroundColor =
        lightBlue;

    Color textColor =
        blue;

    IconData icon =
        Icons.schedule;

    if (normalizedStatus ==
        'upcoming') {
      backgroundColor =
          const Color(
        0xFFEAF7FF,
      );

      textColor =
          blue;

      icon =
          Icons.schedule;
    }

    else if (normalizedStatus ==
        'pending') {
      backgroundColor =
          const Color(
        0xFFFFF8E1,
      );

      textColor =
          const Color(
        0xFFF9A825,
      );

      icon =
          Icons.hourglass_empty;
    }

    else if (normalizedStatus ==
        'completed') {
      backgroundColor =
          const Color(
        0xFFE8F5E9,
      );

      textColor =
          Colors.green;

      icon =
          Icons.check_circle_outline;
    }

    else if (normalizedStatus ==
        'cancelled') {
      backgroundColor =
          const Color(
        0xFFFFEBEE,
      );

      textColor =
          const Color(
        0xFFE53935,
      );

      icon =
          Icons.cancel_outlined;
    }

    return Container(
      constraints:
          BoxConstraints(
        maxWidth:
            Get.width * .28,
      ),

      padding:
          EdgeInsets.symmetric(
        horizontal:
            Get.width * .020,

        vertical:
            Get.height * .006,
      ),

      decoration:
          BoxDecoration(
        color:
            backgroundColor,

        borderRadius:
            BorderRadius.circular(
          Get.width * .015,
        ),
      ),

      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            color:
                textColor,

            size:
                Get.width * .030,
          ),

          SizedBox(
            width:
                Get.width * .008,
          ),

          Flexible(
            child:
                Text(
              status,

              maxLines:
                  1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                color:
                    textColor,

                fontSize:
                    Get.width * .020,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CANCEL DIALOG
  // =========================================================

  void _showCancelDialog(
    Map<String, dynamic> appointment,
  ) {
    final String appointmentId =
        appointment['id']
                ?.toString()
                .trim() ??
            '';

    if (appointmentId.isEmpty) {
      Get.snackbar(
        'Error',
        'Appointment ID not found.',
        backgroundColor:
            Colors.red,
        colorText:
            Colors.white,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor:
            Colors.white,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),

        title:
            const Text(
          'Cancel Appointment',
        ),

        content:
            const Text(
          'Are you sure you want to cancel this appointment?',
        ),

        actions: [
          TextButton(
            onPressed:
                () {
              Get.back();
            },

            child:
                const Text(
              'No',

              style:
                  TextStyle(
                color:
                    greyText,
              ),
            ),
          ),

          ElevatedButton(
            onPressed:
                () async {
              Get.back();

              await controller
                  .cancelAppointment(
                appointmentId,
              );
            },

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,

              foregroundColor:
                  Colors.white,

              elevation:
                  0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),

            child:
                const Text(
              'Yes, Cancel',
            ),
          ),
        ],
      ),
    );
  }
}