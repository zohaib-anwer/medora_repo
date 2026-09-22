import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/consult_controller.dart';

class ConsultView extends StatelessWidget {
  ConsultView({super.key});

  final ConsultController controller =
      Get.put(ConsultController());

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
      backgroundColor: background,

      body: SafeArea(
        child: RefreshIndicator(
          color: blue,
          backgroundColor: Colors.white,
          onRefresh: controller.refreshDoctors,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            padding: EdgeInsets.fromLTRB(
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
                  'Consult',
                  style: TextStyle(
                    color: darkText,
                    fontSize: Get.width * .053,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: Get.height * .007,
                ),

                Text(
                  'Find the right doctor for you',
                  style: TextStyle(
                    color: greyText,
                    fontSize: Get.width * .028,
                  ),
                ),

                // =================================================
                // SPECIALISTS
                // =================================================

                SizedBox(
                  height: Get.height * .030,
                ),

                Text(
                  'Specialists',
                  style: TextStyle(
                    color: darkText,
                    fontSize: Get.width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height: Get.height * .017,
                ),

                // =================================================
                // CATEGORY LIST
                // =================================================

                SizedBox(
                  height: Get.height * .050,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.categories.length,

                    itemBuilder: (context, index) {
                      return _categoryItem(index);
                    },
                  ),
                ),

                // =================================================
                // AVAILABLE DOCTORS
                // =================================================

                SizedBox(
                  height: Get.height * .035,
                ),

                Text(
                  'Available Doctors',
                  style: TextStyle(
                    color: darkText,
                    fontSize: Get.width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height: Get.height * .018,
                ),

                // =================================================
                // DOCTORS
                // =================================================

                Obx(
                  () {
                    // =============================================
                    // LOADING
                    // =============================================

                    if (controller.isLoading.value) {
                      return _loadingWidget();
                    }

                    // =============================================
                    // ERROR
                    // =============================================

                    if (controller
                        .errorMessage
                        .value
                        .isNotEmpty) {
                      return _errorWidget();
                    }

                    // =============================================
                    // FILTERED DOCTORS
                    // =============================================

                    final List<Map<String, dynamic>>
                        filteredDoctors =
                        controller.filteredDoctors;

                    // =============================================
                    // EMPTY
                    // =============================================

                    if (filteredDoctors.isEmpty) {
                      return _emptyDoctorsWidget();
                    }

                    // =============================================
                    // DOCTOR LIST
                    // =============================================

                    return ListView.builder(
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          filteredDoctors.length,

                      itemBuilder:
                          (context, index) {
                        final Map<String, dynamic>
                            doctor =
                            filteredDoctors[index];

                        return _doctorCard(doctor);
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
  // CATEGORY ITEM
  // =========================================================

  Widget _categoryItem(int index) {
    return Obx(
      () {
        final bool selected =
            controller.selectedCategory.value == index;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,

          onTap: () {
            controller.selectCategory(index);
          },

          child: Container(
            margin: EdgeInsets.only(
              right: Get.width * .020,
            ),

            padding: EdgeInsets.symmetric(
              horizontal: Get.width * .035,
            ),

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: selected
                  ? blue
                  : Colors.white,

              borderRadius:
                  BorderRadius.circular(
                Get.width * .025,
              ),

              border: Border.all(
                color: selected
                    ? blue
                    : borderColor,
              ),
            ),

            child: Text(
              controller.categories[index],

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : greyText,

                fontSize: Get.width * .024,

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
  // DOCTOR CARD
  // =========================================================

  Widget _doctorCard(
    Map<String, dynamic> doctor,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // =======================================================
      // CARD TAP = DOCTOR DETAIL
      // =======================================================

      onTap: () {
        controller.openDoctor(doctor);
      },

      child: Container(
        width: double.infinity,

        margin: EdgeInsets.only(
          bottom: Get.height * .018,
        ),

        padding: EdgeInsets.all(
          Get.width * .030,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            Get.width * .037,
          ),

          border: Border.all(
            color: borderColor,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            // =================================================
            // IMAGE
            // =================================================

            _doctorImage(doctor),

            SizedBox(
              width: Get.width * .030,
            ),

            // =================================================
            // INFORMATION
            // =================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // =============================================
                  // NAME
                  // =============================================

                  Text(
                    _stringValue(
                      doctor['name'],
                      fallback: 'Doctor',
                    ),

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: TextStyle(
                      color: darkText,
                      fontSize: Get.width * .032,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(
                    height: Get.height * .005,
                  ),

                  // =============================================
                  // SPECIALIST
                  // =============================================

                  Text(
                    _stringValue(
                      doctor['specialist'],
                      fallback:
                          'General Specialist',
                    ),

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: TextStyle(
                      color: greyText,
                      fontSize: Get.width * .024,
                    ),
                  ),

                  SizedBox(
                    height: Get.height * .010,
                  ),

                  // =============================================
                  // RATING + EXPERIENCE
                  // =============================================

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 15,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        _stringValue(
                          doctor['rating'],
                          fallback: '0',
                        ),

                        style: TextStyle(
                          color: darkText,
                          fontSize: Get.width * .022,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      SizedBox(
                        width: Get.width * .025,
                      ),

                      Flexible(
                        child: Text(
                          _stringValue(
                            doctor['experience'],
                            fallback:
                                'Experience not added',
                          ),

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(
                            color: greyText,
                            fontSize:
                                Get.width * .020,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: Get.height * .006,
                  ),

                  // =============================================
                  // PRICE
                  // =============================================

                  if (_hasValue(doctor['price']))
                    Text(
                      'Rs. ${doctor['price']}',

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        color: blue,
                        fontSize: Get.width * .022,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(
              width: Get.width * .015,
            ),

            // =================================================
            // CHAT BUTTON
            // =================================================

            GestureDetector(
              behavior:
                  HitTestBehavior.opaque,

              onTap: () {
                controller.openChat(doctor);
              },

              child: Container(
                width: Get.width * .090,
                height: Get.width * .090,

                decoration: BoxDecoration(
                  color: lightBlue,

                  borderRadius:
                      BorderRadius.circular(
                    Get.width * .025,
                  ),

                  border: Border.all(
                    color: borderColor,
                  ),
                ),

                child: Icon(
                  Icons.chat_outlined,
                  color: blue,
                  size: Get.width * .050,
                ),
              ),
            ),

            SizedBox(
              width: Get.width * .018,
            ),

            // =================================================
            // ARROW
            // =================================================

            Icon(
              Icons.arrow_forward_ios,

              color:
                  const Color(0xFFB7C1C9),

              size: Get.width * .035,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DOCTOR IMAGE
  // =========================================================

  Widget _doctorImage(
    Map<String, dynamic> doctor,
  ) {
    final String imageUrl =
        _stringValue(doctor['imageUrl']);

    return Container(
      width: Get.width * .18,
      height: Get.width * .18,

      decoration: BoxDecoration(
        color: lightBlue,

        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),

        child: imageUrl.isEmpty
            ? _defaultDoctorIcon()
            : Image.network(
                imageUrl,

                width: double.infinity,
                height: double.infinity,

                fit: BoxFit.cover,

                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Center(
                    child: SizedBox(
                      width: Get.width * .045,
                      height: Get.width * .045,

                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: blue,
                      ),
                    ),
                  );
                },

                errorBuilder: (
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
      child: Icon(
        Icons.person,

        color:
            const Color(0xFF7FAED0),

        size: Get.width * .090,
      ),
    );
  }

  // =========================================================
  // LOADING WIDGET
  // =========================================================

  Widget _loadingWidget() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        vertical: Get.height * .060,
      ),

      child: const Center(
        child: CircularProgressIndicator(
          color: blue,
        ),
      ),
    );
  }

  // =========================================================
  // ERROR WIDGET
  // =========================================================

  Widget _errorWidget() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(
        Get.width * .050,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .035,
        ),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons.error_outline,

            color:
                const Color(0xFFE53935),

            size: Get.width * .080,
          ),

          SizedBox(
            height: Get.height * .012,
          ),

          Text(
            controller.errorMessage.value,

            textAlign: TextAlign.center,

            style: TextStyle(
              color: greyText,
              fontSize: Get.width * .027,
            ),
          ),

          SizedBox(
            height: Get.height * .015,
          ),

          ElevatedButton(
            onPressed: controller.retry,

            style:
                ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),

            child: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY DOCTORS
  // =========================================================

  Widget _emptyDoctorsWidget() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(
        Get.width * .050,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .035,
        ),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: Get.width * .16,
            height: Get.width * .16,

            decoration:
                const BoxDecoration(
              color: lightBlue,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.person_search_outlined,
              color: blue,
              size: Get.width * .075,
            ),
          ),

          SizedBox(
            height: Get.height * .015,
          ),

          Text(
            'No doctors available',

            style: TextStyle(
              color: darkText,
              fontSize: Get.width * .032,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(
            height: Get.height * .007,
          ),

          Text(
            'No doctor has been added for this specialist yet.',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: greyText,
              fontSize: Get.width * .025,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SAFE STRING
  // =========================================================

  String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final String text =
        value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  // =========================================================
  // HAS VALUE
  // =========================================================

  bool _hasValue(dynamic value) {
    if (value == null) {
      return false;
    }

    return value
        .toString()
        .trim()
        .isNotEmpty;
  }
}