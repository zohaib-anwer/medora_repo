import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/appointment/appointment_booking_view.dart';

class DoctorDetailController extends GetxController {
  DoctorDetailController({
    Map<String, dynamic>? doctor,
  }) {
    if (doctor != null) {
      this.doctor =
          Map<String, dynamic>.from(doctor).obs;
    }
  }

  // =========================================================
  // DOCTOR
  // =========================================================

  late RxMap<String, dynamic> doctor =
      <String, dynamic>{}.obs;

  // =========================================================
  // SELECTED DAY
  // =========================================================

  final RxInt selectedDay = 0.obs;

  // =========================================================
  // FULL WEEK
  // =========================================================

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // =========================================================
  // SELECT DAY
  // =========================================================

  void selectDay(int index) {
    if (index < 0 || index >= days.length) {
      return;
    }

    selectedDay.value = index;
  }

  // =========================================================
  // GET SCHEDULE
  // =========================================================

  dynamic getDaySchedule(String day) {
    final dynamic schedule = doctor['schedule'];

    if (schedule is! Map) {
      return null;
    }

    // Exact name
    if (schedule.containsKey(day)) {
      return schedule[day];
    }

    // Lowercase name
    final String lowerDay = day.toLowerCase();

    if (schedule.containsKey(lowerDay)) {
      return schedule[lowerDay];
    }

    // Short name
    final String shortDay = _shortDay(day);

    if (schedule.containsKey(shortDay)) {
      return schedule[shortDay];
    }

    final String lowerShortDay =
        shortDay.toLowerCase();

    if (schedule.containsKey(lowerShortDay)) {
      return schedule[lowerShortDay];
    }

    return null;
  }

  // =========================================================
  // SHORT DAY
  // =========================================================

  String _shortDay(String day) {
    switch (day) {
      case 'Monday':
        return 'Mon';

      case 'Tuesday':
        return 'Tue';

      case 'Wednesday':
        return 'Wed';

      case 'Thursday':
        return 'Thu';

      case 'Friday':
        return 'Fri';

      case 'Saturday':
        return 'Sat';

      case 'Sunday':
        return 'Sun';

      default:
        return day;
    }
  }

  // =========================================================
  // FORMAT SCHEDULE
  // =========================================================

  String formatSchedule(dynamic value) {
    if (value == null) {
      return 'Not available';
    }

    if (value is String) {
      final String text = value.trim();

      if (text.isEmpty) {
        return 'Not available';
      }

      return text;
    }

    if (value is bool) {
      return value
          ? 'Available'
          : 'Unavailable';
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'Not available';
      }

      return value
          .map((e) => e.toString())
          .join(' • ');
    }

    if (value is Map) {
      final bool enabled =
          value['enabled'] == true;

      final bool available =
          value['available'] == true ||
              value['isAvailable'] == true;

      final dynamic start =
          value['startTime'] ??
              value['from'] ??
              value['start'];

      final dynamic end =
          value['endTime'] ??
              value['to'] ??
              value['end'];

      final dynamic time =
          value['time'];

      final String? status =
          value['status']?.toString();

      if (!enabled &&
          value.containsKey('enabled')) {
        return 'Unavailable';
      }

      if (status != null &&
          status.trim().isNotEmpty) {
        if (start != null &&
            end != null) {
          return '$status • $start - $end';
        }

        return status;
      }

      if (start != null &&
          end != null) {
        return '$start - $end';
      }

      if (time != null) {
        final String timeText =
            time.toString().trim();

        if (timeText.isNotEmpty) {
          return timeText;
        }
      }

      if (enabled || available) {
        return 'Available';
      }

      if (value.isEmpty) {
        return 'Not available';
      }

      return value.entries
          .map(
            (entry) =>
                '${entry.key}: ${entry.value}',
          )
          .join(' • ');
    }

    return value.toString();
  }

  // =========================================================
  // PLACE OF PRACTICE
  // =========================================================

  String getPractice() {
    final List<String> fields = [
      'place',
      'practice',
      'placeOfPractice',
      'place_of_practice',
      'clinic',
      'clinicName',
      'hospital',
      'hospitalName',
      'location',
      'address',
    ];

    for (final field in fields) {
      final dynamic value =
          doctor[field];

      if (value != null) {
        final String text =
            value.toString().trim();

        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return '';
  }

  // =========================================================
  // MAKE APPOINTMENT
  // =========================================================

  void makeAppointment() {
    if (doctor.isEmpty) {
      Get.snackbar(
        'Error',
        'Doctor information is missing.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final Map<String, dynamic> doctorData =
        Map<String, dynamic>.from(
      doctor,
    );

    Get.to(
      () => AppointmentBookingView(
        doctor: doctorData,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  // =========================================================
  // BACK
  // =========================================================

  void goBack() {
    if (Get.isDialogOpen == true) {
      Get.back();
      return;
    }

    if (Get.isBottomSheetOpen == true) {
      Get.back();
      return;
    }

    Get.back();
  }
}