import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/doctor_detail_controller.dart';

class DoctorDetailView extends StatefulWidget {
  DoctorDetailView({
    super.key,
    required this.doctor,
  }) {
    Get.put(
      DoctorDetailController(
        doctor: doctor,
      ),
      tag: _tag,
    );
  }

  final Map<String, dynamic> doctor;

  String get _tag =>
      doctor['id']?.toString() ??
      doctor['doctorId']?.toString() ??
      UniqueKey().toString();

  @override
  State<DoctorDetailView> createState() =>
      _DoctorDetailViewState();
}

class _DoctorDetailViewState
    extends State<DoctorDetailView> {
  // =========================================================
  // DESCRIPTION STATE
  // =========================================================

  bool _isDescriptionExpanded = false;

  DoctorDetailController get controller =>
      Get.find<DoctorDetailController>(
        tag: widget._tag,
      );

  // =========================================================
  // COLORS
  // =========================================================

  static const Color blue =
      Color(0xFF2196F3);

  static const Color darkText =
      Color(0xFF172534);

  static const Color greyText =
      Color(0xFF647587);

  static const Color background =
      Color(0xFFF3F7FF);

  static const Color borderColor =
      Color(0xFFDDE3E9);

  static const Color lightBlue =
      Color(0xFFD9F0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _header(),
                    _content(),
                  ],
                ),
              ),
            ),

            _appointmentButton(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header() {
    return SizedBox(
      height: Get.height * .27,

      child: Stack(
        clipBehavior: Clip.none,

        children: [
          Container(
            width: double.infinity,

            height: Get.height * .27,

            decoration:
                const BoxDecoration(
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

          // ---------------------------------------------------
          // BACK BUTTON
          // ---------------------------------------------------

          Positioned(
            left: Get.width * .020,

            top: Get.height * .01,

            child: IconButton(
              onPressed: controller.goBack,

              icon: Icon(
                Icons.arrow_back,
                color: darkText,
                size: Get.width * .065,
              ),
            ),
          ),

          // ---------------------------------------------------
          // DOCTOR INFO
          // ---------------------------------------------------

          Positioned(
            left: Get.width * .053,

            top: Get.height * .085,

            child: Obx(
              () {
                final doctor =
                    controller.doctor;

                final String name =
                    doctor['name']
                            ?.toString() ??
                        '';

                final String specialist =
                    doctor['specialist']
                            ?.toString() ??
                        '';

                final String rating =
                    doctor['rating']
                            ?.toString() ??
                        '';

                final String price =
                    doctor['price']
                            ?.toString() ??
                        '';

                return SizedBox(
                  width: Get.width * .55,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        name,

                        maxLines: 2,

                        overflow:
                            TextOverflow.ellipsis,

                        style: TextStyle(
                          color: darkText,
                          fontSize:
                              Get.width * .045,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .008,
                      ),

                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              specialist,

                              maxLines: 2,

                              overflow:
                                  TextOverflow.ellipsis,

                              style: TextStyle(
                                color: greyText,
                                fontSize:
                                    Get.width * .03,
                              ),
                            ),
                          ),

                          SizedBox(
                            width:
                                Get.width * .015,
                          ),

                          if (rating.isNotEmpty)
                            Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color:
                                      Color(
                                    0xFFFFC107,
                                  ),
                                  size: 17,
                                ),

                                Text(
                                  ' $rating',

                                  style:
                                      TextStyle(
                                    color:
                                        darkText,
                                    fontSize:
                                        Get.width *
                                            .027,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      SizedBox(
                        height:
                            Get.height * .027,
                      ),

                      if (price.isNotEmpty)
                        Container(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                Get.width * .025,
                            vertical:
                                Get.height * .010,
                          ),

                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
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

                            borderRadius:
                                BorderRadius.circular(
                              Get.width * .025,
                            ),

                            border:
                                Border.all(
                              color: darkText,
                            ),
                          ),

                          child: Text(
                            '\$$price',

                            style: TextStyle(
                              color: darkText,
                              fontSize:
                                  Get.width * .030,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ---------------------------------------------------
          // YELLOW CIRCLE
          // ---------------------------------------------------

          Positioned(
            right: -Get.width * .05,

            bottom: -Get.height * .11,

            child: Container(
              width: Get.width * .47,

              height: Get.width * .47,

              decoration:
                  const BoxDecoration(
                color: Color(0xFFFFD34E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ---------------------------------------------------
          // DOCTOR IMAGE
          // ---------------------------------------------------

          Positioned(
            right: -Get.width * .01,

            bottom: -Get.height * .003,

            child: Obx(
              () => SizedBox(
                width: Get.width * .47,

                height: Get.height * .235,

                child: _doctorImage(
                  controller
                          .doctor['imageUrl']
                          ?.toString() ??
                      '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================

  Widget _content() {
    return Obx(
      () {
        final doctor =
            controller.doctor;

        final String patients =
            doctor['patients']
                    ?.toString() ??
                '';

        final String experience =
            doctor['experience']
                    ?.toString() ??
                '';

        final String description =
            doctor['description']
                    ?.toString() ??
                '';

    final String practice =
    doctor['practice']?.toString().trim() ?? '';
        return Container(
          width: double.infinity,

          padding:
              EdgeInsets.fromLTRB(
            Get.width * .053,
            Get.height * .030,
            Get.width * .053,
            Get.height * .120,
          ),

          decoration:
              BoxDecoration(
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

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =================================================
              // STATS
              // =================================================

              if (patients.isNotEmpty ||
                  experience.isNotEmpty)
                Row(
                  children: [
                    if (patients.isNotEmpty)
                      Expanded(
                        child: _statCard(
                          Icons.people,
                          patients,
                          'Patients',
                        ),
                      ),

                    if (patients.isNotEmpty &&
                        experience.isNotEmpty)
                      SizedBox(
                        width:
                            Get.width * .025,
                      ),

                    if (experience.isNotEmpty)
                      Expanded(
                        child: _statCard(
                          Icons.work_outline,
                          experience,
                          'Experience',
                        ),
                      ),
                  ],
                ),

              // =================================================
              // DESCRIPTION
              // =================================================
if (description.isNotEmpty) ...[
  SizedBox(
    height: Get.height * .030,
  ),

  _sectionTitle(
    'Description',
  ),

  SizedBox(
    height: Get.height * .012,
  ),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AnimatedCrossFade(
      duration: const Duration(
        milliseconds: 200,
      ),
      crossFadeState:
          _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,

      firstChild: Text(
        description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: greyText,
          fontSize: Get.width * .027,
          height: 1.5,
        ),
      ),

      secondChild: Text(
        description,
        style: TextStyle(
          color: greyText,
          fontSize: Get.width * .027,
          height: 1.5,
        ),
      ),
    ),

    SizedBox(
      height: Get.height * .006,
    ),

    GestureDetector(
      onTap: () {
        setState(() {
          _isDescriptionExpanded =
              !_isDescriptionExpanded;
        });
      },

      child: Text(
        _isDescriptionExpanded
            ? 'See less'
            : 'See all',

        style: TextStyle(
          color: blue,
          fontSize: Get.width * .027,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ],
),
],

              // =================================================
              // FULL WEEK SCHEDULE
              // =================================================

              SizedBox(
                height:
                    Get.height * .032,
              ),

              _sectionTitle(
                'Online Schedule',
              ),

              SizedBox(
                height:
                    Get.height * .015,
              ),

              _weeklySchedule(),

              // =================================================
              // PRACTICE
              // =================================================

              if (practice.isNotEmpty) ...[
                SizedBox(
                  height:
                      Get.height * .032,
                ),

                _sectionTitle(
                  'Place of practice',
                ),

                SizedBox(
                  height:
                      Get.height * .010,
                ),

                Text(
                  practice,

                  style: TextStyle(
                    color: greyText,
                    fontSize:
                        Get.width * .027,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // FULL WEEK SCHEDULE
  // =========================================================

Widget _weeklySchedule() {
  return Obx(
    () {
      final int selectedIndex =
          controller.selectedDay.value;

      return ListView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: controller.days.length,
        itemBuilder: (context, index) {
          final String day =
              controller.days[index];

          final dynamic schedule =
              controller.getDaySchedule(day);

          final String scheduleText =
              controller.formatSchedule(schedule);

          final bool selected =
              selectedIndex == index;

          final bool available =
              scheduleText != 'Not available' &&
                  scheduleText != 'Unavailable';

          return GestureDetector(
            behavior:
                HitTestBehavior.opaque,

            onTap: () {
              controller.selectDay(index);
            },

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),

              margin: EdgeInsets.only(
                bottom: Get.height * .012,
              ),

              padding:
                  EdgeInsets.symmetric(
                horizontal:
                    Get.width * .035,
                vertical:
                    Get.height * .015,
              ),

              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEAF7FF)
                    : const Color(0xFFF8FAFC),

                borderRadius:
                    BorderRadius.circular(
                  Get.width * .025,
                ),

                border: Border.all(
                  color: selected
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFDDE3E9),
                ),
              ),

              child: Row(
                children: [
                  // ==================================================
                  // DAY CIRCLE
                  // ==================================================

                  Container(
                    width: Get.width * .100,
                    height: Get.width * .100,

                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2196F3)
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Text(
                        day.substring(0, 3),
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF172534),
                          fontSize:
                              Get.width * .023,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: Get.width * .030,
                  ),

                  // ==================================================
                  // DAY + TIME
                  // ==================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            color:
                                const Color(0xFF172534),
                            fontSize:
                                Get.width * .028,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        SizedBox(
                          height:
                              Get.height * .004,
                        ),

                        Text(
                          scheduleText,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                const Color(0xFF647587),
                            fontSize:
                                Get.width * .023,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // ICON
                  // ==================================================

                  Icon(
                    available
                        ? Icons.schedule_outlined
                        : Icons.event_busy_outlined,

                    color: available
                        ? const Color(0xFF2196F3)
                        : const Color(0xFF647587),

                    size:
                        Get.width * .055,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,

      style: TextStyle(
        color: darkText,
        fontSize:
            Get.width * .035,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard(
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      height:
          Get.height * .075,

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF8FAFC,
        ),

        borderRadius:
            BorderRadius.circular(
          Get.width * .025,
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: blue,
            size:
                Get.width * .055,
          ),

          SizedBox(
            width:
                Get.width * .018,
          ),

          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                value,

                style: TextStyle(
                  color: blue,
                  fontSize:
                      Get.width * .029,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              Text(
                label,

                style: TextStyle(
                  color: greyText,
                  fontSize:
                      Get.width * .021,
                ),
              ),
            ],
          ),
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
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.person,
          color:
              Color(0xFF7FAED0),
          size: 80,
        ),
      );
    }

    return Image.network(
      imageUrl,

      fit:
          BoxFit.contain,

      alignment:
          Alignment.bottomCenter,

      errorBuilder:
          (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.person,
            color:
                Color(0xFF7FAED0),
            size: 80,
          ),
        );
      },
    );
  }

  // =========================================================
  // APPOINTMENT BUTTON
  // =========================================================

  Widget _appointmentButton() {
    return Container(
      color: Colors.white,

      padding:
          EdgeInsets.fromLTRB(
        Get.width * .053,
        Get.height * .012,
        Get.width * .053,
        Get.height * .018,
      ),

      child: SizedBox(
        width: double.infinity,

        height:
            Get.height * .058,

        child: ElevatedButton(
          onPressed:
              controller.makeAppointment,

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
                Get.width * .037,
              ),
            ),
          ),

          child: Text(
            'Make Appointment',

            style: TextStyle(
              fontSize:
                  Get.width * .032,

              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}