import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalchat/controller/appointment_booking_controller.dart';

class AppointmentBookingView extends StatelessWidget {
  AppointmentBookingView({
    super.key,
    required this.doctor,
  });

  final Map<String, dynamic> doctor;

  late final AppointmentBookingController controller =
      Get.put(
        AppointmentBookingController(doctor: doctor),
        tag: doctor['id']?.toString() ??
            doctor['doctorId']?.toString() ??
            doctor['name']?.toString(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7FF),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF172534),
            size: 20,
          ),
        ),

        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Color(0xFF172534),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.05,
              vertical: Get.height * 0.015,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --------------------------------------------------
                // DOCTOR CARD
                // --------------------------------------------------

                _doctorCard(),

                SizedBox(height: Get.height * 0.025),

                // --------------------------------------------------
                // SELECT DATE
                // --------------------------------------------------

                const Text(
                  'Select Date',
                  style: TextStyle(
                    color: Color(0xFF172534),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: Get.height * 0.012),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await controller.pickAppointmentDate(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.045,
                      vertical: Get.height * 0.02,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE3E9),
                      ),
                    ),

                    child: Row(
                      children: [

                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF2196F3),
                            size: 25,
                          ),
                        ),

                        SizedBox(width: Get.width * 0.035),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              const Text(
                                'Appointment Date',
                                style: TextStyle(
                                  color: Color(0xFF647587),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                controller.formattedDate,
                                style: const TextStyle(
                                  color: Color(0xFF172534),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF647587),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: Get.height * 0.025),

                // --------------------------------------------------
                // SELECT TIME
                // --------------------------------------------------

                const Text(
                  'Select Time',
                  style: TextStyle(
                    color: Color(0xFF172534),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: Get.height * 0.012),

                if (controller.selectedDate.value == null)

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE3E9),
                      ),
                    ),

                    child: const Row(
                      children: [

                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF647587),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Please select an appointment date first.',
                            style: TextStyle(
                              color: Color(0xFF647587),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                else if (controller.availableTimeSlots.isEmpty)

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE3E9),
                      ),
                    ),

                    child: const Row(
                      children: [

                        Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF647587),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'No available time slots for this date.',
                            style: TextStyle(
                              color: Color(0xFF647587),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                else

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.availableTimeSlots.map(
                      (time) {
                        final bool selected =
                            controller.selectedTime.value == time;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedTime.value = time;
                          },

                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),

                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF2196F3)
                                  : Colors.white,

                              borderRadius:
                                  BorderRadius.circular(12),

                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFFDDE3E9),
                              ),
                            ),

                            child: Text(
                              time,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF172534),

                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),

                SizedBox(height: Get.height * 0.035),

                // --------------------------------------------------
                // APPOINTMENT SUMMARY
                // --------------------------------------------------

                if (controller.selectedDate.value != null &&
                    controller.selectedTime.value.isNotEmpty)

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD9F0FF),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          'Appointment Summary',
                          style: TextStyle(
                            color: Color(0xFF172534),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [

                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF2196F3),
                              size: 19,
                            ),

                            const SizedBox(width: 10),

                            Text(
                              controller.formattedDate,
                              style: const TextStyle(
                                color: Color(0xFF172534),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            const Icon(
                              Icons.access_time_outlined,
                              color: Color(0xFF2196F3),
                              size: 19,
                            ),

                            const SizedBox(width: 10),

                            Text(
                              controller.selectedTime.value,
                              style: const TextStyle(
                                color: Color(0xFF172534),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: Get.height * 0.035),

                // --------------------------------------------------
                // BOOK BUTTON
                // --------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            controller.saveAppointment();
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2196F3),

                      disabledBackgroundColor:
                          const Color(0xFF90CAF9),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    child: controller.isLoading.value

                        ? const SizedBox(
                            width: 23,
                            height: 23,

                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )

                        : const Text(
                            'Confirm Appointment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: Get.height * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // DOCTOR CARD
  // ==============================================================

  Widget _doctorCard() {
    final String name =
        doctor['name']?.toString() ?? 'Doctor';

    final String specialist =
        doctor['specialist']?.toString() ??
            doctor['category']?.toString() ??
            'Medical Specialist';

    final String imageUrl =
        doctor['imageUrl']?.toString() ?? '';

    final String rating =
        doctor['rating']?.toString() ?? '0.0';

    final String experience =
        doctor['experience']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Get.width * 0.04),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDDE3E9),
        ),
      ),

      child: Row(
        children: [

          // Doctor image
          Container(
            width: 72,
            height: 72,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD34E),
            ),

            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    )

                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),

          SizedBox(width: Get.width * 0.035),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF172534),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  specialist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF647587),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD34E),
                      size: 17,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      rating,
                      style: const TextStyle(
                        color: Color(0xFF172534),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Icon(
                      Icons.work_outline,
                      color: Color(0xFF647587),
                      size: 16,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '$experience years',
                      style: const TextStyle(
                        color: Color(0xFF647587),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}