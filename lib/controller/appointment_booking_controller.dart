import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/bottom_nav/bottom_nav_bar.dart';

// ============================================================
// SLOT ALREADY BOOKED EXCEPTION
// ============================================================

class SlotAlreadyBookedException implements Exception {}

// ============================================================
// APPOINTMENT BOOKING CONTROLLER
// ============================================================

class AppointmentBookingController extends GetxController {
  AppointmentBookingController({
    required Map<String, dynamic> doctor,
  }) {
    this.doctor.value = Map<String, dynamic>.from(doctor);
  }

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // DOCTOR
  // ============================================================

  final RxMap<String, dynamic> doctor =
      <String, dynamic>{}.obs;

  // ============================================================
  // APPOINTMENT DATA
  // ============================================================

  final Rxn<DateTime> selectedDate =
      Rxn<DateTime>();

  final RxString selectedTime =
      ''.obs;

  final RxBool isLoading =
      false.obs;

  final RxBool isLoadingSlots =
      false.obs;

  final RxList<String> availableTimeSlots =
      <String>[].obs;

  // Already booked slots
  final RxSet<String> bookedTimeSlots =
      <String>{}.obs;

  // ============================================================
  // WEEK DAYS
  // ============================================================

  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ============================================================
  // DOCTOR ID
  // ============================================================

  String get doctorId {
    return doctor['id']?.toString() ??
        doctor['doctorId']?.toString() ??
        '';
  }

  // ============================================================
  // DOCTOR NAME
  // ============================================================

  String get doctorName {
    return doctor['name']?.toString() ??
        'Doctor';
  }

  // ============================================================
  // SPECIALIST
  // ============================================================

  String get specialist {
    return doctor['specialist']?.toString() ??
        doctor['category']?.toString() ??
        '';
  }

  // ============================================================
  // DOCTOR IMAGE
  // ============================================================

  String get doctorImage {
    return doctor['imageUrl']?.toString() ??
        '';
  }

  // ============================================================
  // FORMATTED DATE
  // ============================================================

  String get formattedDate {
    if (selectedDate.value == null) {
      return 'Select appointment date';
    }

    final DateTime date =
        selectedDate.value!;

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ============================================================
  // GET DAY SCHEDULE
  // ============================================================

  Map<String, dynamic>? getDaySchedule(
    String day,
  ) {
    final dynamic schedule =
        doctor['schedule'];

    if (schedule is! Map) {
      return null;
    }

    dynamic daySchedule;

    // Full day name
    daySchedule = schedule[day];

    // Lowercase
    daySchedule ??=
        schedule[day.toLowerCase()];

    // Short day
    final String shortDay =
        day.substring(0, 3);

    daySchedule ??=
        schedule[shortDay];

    // Short lowercase
    daySchedule ??=
        schedule[shortDay.toLowerCase()];

    if (daySchedule is Map) {
      return Map<String, dynamic>.from(
        daySchedule,
      );
    }

    return null;
  }

  // ============================================================
  // IS DAY AVAILABLE
  // ============================================================

  bool isDayAvailable(
    String day,
  ) {
    final Map<String, dynamic>?
        schedule =
        getDaySchedule(day);

    if (schedule == null) {
      return false;
    }

    final dynamic enabledValue =
        schedule['enabled'] ??
            schedule['available'] ??
            schedule['isAvailable'];

    final bool enabled =
        _parseBool(enabledValue);

    if (!enabled) {
      return false;
    }

    final String start =
        schedule['startTime']?.toString() ??
            schedule['start']?.toString() ??
            schedule['from']?.toString() ??
            '';

    final String end =
        schedule['endTime']?.toString() ??
            schedule['end']?.toString() ??
            schedule['to']?.toString() ??
            '';

    if (start.isEmpty ||
        end.isEmpty) {
      return false;
    }

    final TimeOfDay? startTime =
        _parseTime(start);

    final TimeOfDay? endTime =
        _parseTime(end);

    if (startTime == null ||
        endTime == null) {
      return false;
    }

    final int startMinutes =
        startTime.hour * 60 +
            startTime.minute;

    final int endMinutes =
        endTime.hour * 60 +
            endTime.minute;

    return startMinutes <
        endMinutes;
  }

  // ============================================================
  // CHECK DATE AVAILABLE
  // ============================================================

  bool isDateAvailable(
    DateTime date,
  ) {
    final String day =
        weekdays[date.weekday - 1];

    return isDayAvailable(day);
  }

  // ============================================================
  // GET SELECTED WEEKDAY
  // ============================================================

  String getSelectedWeekday() {
    if (selectedDate.value == null) {
      return '';
    }

    return weekdays[
        selectedDate.value!.weekday - 1];
  }

  // ============================================================
  // PICK APPOINTMENT DATE
  // ============================================================

  Future<void> pickAppointmentDate(
    BuildContext context,
  ) async {
    final DateTime now =
        DateTime.now();

    final DateTime today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    DateTime initialDate =
        selectedDate.value ?? today;

    // ----------------------------------------------------------
    // FIND FIRST AVAILABLE DATE
    // ----------------------------------------------------------

    if (!isDateAvailable(initialDate)) {
      final DateTime? firstAvailable =
          _findFirstAvailableDate(today);

      if (firstAvailable != null) {
        initialDate =
            firstAvailable;
      } else {
        _showMessage(
          'No Availability',
          'This doctor has no available schedule in the next year.',
        );
        return;
      }
    }

    // ----------------------------------------------------------
    // DATE PICKER
    // ----------------------------------------------------------

    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(
        today.year + 1,
        today.month,
        today.day,
      ),

      selectableDayPredicate:
          (DateTime date) {
        return isDateAvailable(date);
      },

      helpText:
          'SELECT APPOINTMENT DATE',

      cancelText: 'CANCEL',

      confirmText: 'SELECT',

      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Theme(
          data: Theme.of(context)
              .copyWith(
            colorScheme:
                const ColorScheme.light(
              primary:
                  Color(0xFF2196F3),
              onPrimary:
                  Colors.white,
              surface:
                  Colors.white,
              onSurface:
                  Color(0xFF172534),
            ),
            dialogTheme:
                const DialogThemeData(
              backgroundColor:
                  Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    // ----------------------------------------------------------
    // USER CANCELLED
    // ----------------------------------------------------------

    if (picked == null) {
      return;
    }

    // ----------------------------------------------------------
    // SAFETY CHECK
    // ----------------------------------------------------------

    if (!isDateAvailable(picked)) {
      _showMessage(
        'Date Not Available',
        'The doctor is not available on this day.',
      );
      return;
    }

    // ----------------------------------------------------------
    // SAVE DATE
    // ----------------------------------------------------------

    selectedDate.value =
        DateTime(
      picked.year,
      picked.month,
      picked.day,
    );

    // Reset selected time
    selectedTime.value = '';

    // ----------------------------------------------------------
    // LOAD TIME SLOTS
    // ----------------------------------------------------------

    await loadAvailableTimeSlots();
  }

  // ============================================================
  // FIND FIRST AVAILABLE DATE
  // ============================================================

  DateTime? _findFirstAvailableDate(
    DateTime from,
  ) {
    DateTime date =
        DateTime(
      from.year,
      from.month,
      from.day,
    );

    final DateTime maxDate =
        DateTime(
      from.year + 1,
      from.month,
      from.day,
    );

    while (!date.isAfter(maxDate)) {
      if (isDateAvailable(date)) {
        return date;
      }

      date = date.add(
        const Duration(days: 1),
      );
    }

    return null;
  }

  // ============================================================
  // LOAD AVAILABLE TIME SLOTS
  // ============================================================

  Future<void> loadAvailableTimeSlots() async {
    availableTimeSlots.clear();
    bookedTimeSlots.clear();

    final DateTime? date =
        selectedDate.value;

    if (date == null) {
      return;
    }

    isLoadingSlots.value = true;

    try {
      final String weekday =
          getSelectedWeekday();

      final Map<String, dynamic>?
          schedule =
          getDaySchedule(weekday);

      if (schedule == null) {
        return;
      }

      // --------------------------------------------------------
      // ENABLED
      // --------------------------------------------------------

      final bool enabled =
          _parseBool(
        schedule['enabled'] ??
            schedule['available'] ??
            schedule['isAvailable'],
      );

      if (!enabled) {
        return;
      }

      // --------------------------------------------------------
      // START TIME
      // --------------------------------------------------------

      final String start =
          schedule['startTime']
                  ?.toString() ??
              schedule['start']
                  ?.toString() ??
              schedule['from']
                  ?.toString() ??
              '';

      // --------------------------------------------------------
      // END TIME
      // --------------------------------------------------------

      final String end =
          schedule['endTime']
                  ?.toString() ??
              schedule['end']
                  ?.toString() ??
              schedule['to']
                  ?.toString() ??
              '';

      if (start.isEmpty ||
          end.isEmpty) {
        return;
      }

      // --------------------------------------------------------
      // PARSE TIME
      // --------------------------------------------------------

      final TimeOfDay? startTime =
          _parseTime(start);

      final TimeOfDay? endTime =
          _parseTime(end);

      if (startTime == null ||
          endTime == null) {
        return;
      }

      int startMinutes =
          startTime.hour * 60 +
              startTime.minute;

      final int endMinutes =
          endTime.hour * 60 +
              endTime.minute;

      if (startMinutes >=
          endMinutes) {
        return;
      }

      // --------------------------------------------------------
      // CREATE 30 MINUTE SLOTS
      // --------------------------------------------------------

      while (startMinutes <
          endMinutes) {
        final int slotEnd =
            startMinutes + 30;

        if (slotEnd >
            endMinutes) {
          break;
        }

        final String slot =
            _formatMinutes(
          startMinutes,
        );

        availableTimeSlots.add(
          slot,
        );

        startMinutes += 30;
      }

      // --------------------------------------------------------
      // LOAD BOOKED SLOTS
      // --------------------------------------------------------

      await _loadBookedSlots();
    } catch (e) {
      debugPrint(
        'LOAD AVAILABLE SLOTS ERROR: $e',
      );

      _showMessage(
        'Error',
        'Unable to load available time slots.',
      );
    } finally {
      isLoadingSlots.value =
          false;
    }
  }

  // ============================================================
  // LOAD BOOKED SLOTS
  // ============================================================

  Future<void> _loadBookedSlots() async {
    if (selectedDate.value == null ||
        doctorId.isEmpty) {
      return;
    }

    bookedTimeSlots.clear();

    try {
      /*
       * We check appointmentSlots using the
       * deterministic slot ID.
       *
       * Example:
       *
       * doctor123_20260915_10_00_AM
       *
       * If this document exists, that slot
       * is already reserved.
       */

      for (final String slot
          in availableTimeSlots) {
        final String slotId =
            _createSlotId(
          doctorId,
          selectedDate.value!,
          slot,
        );

        final DocumentSnapshot<
                Map<String, dynamic>>
            snapshot =
            await _firestore
                .collection(
                  'appointmentSlots',
                )
                .doc(slotId)
                .get();

        if (!snapshot.exists) {
          continue;
        }

        final Map<String, dynamic>?
            data =
            snapshot.data();

        final String status =
            data?['status']
                    ?.toString()
                    .toLowerCase() ??
                '';

        // Cancelled/rejected slots
        // can be booked again.
        final bool reusable =
            status == 'cancelled' ||
                status == 'canceled' ||
                status == 'rejected';

        if (!reusable) {
          bookedTimeSlots.add(
            slot,
          );
        }
      }
    } catch (e) {
      debugPrint(
        'LOAD BOOKED SLOTS ERROR: $e',
      );
    }
  }

  // ============================================================
  // CHECK IF SLOT BOOKED
  // ============================================================

  bool isSlotBooked(
    String slot,
  ) {
    return bookedTimeSlots
        .contains(slot);
  }

  // ============================================================
  // PARSE BOOLEAN
  // ============================================================

  bool _parseBool(
    dynamic value,
  ) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value
              .trim()
              .toLowerCase() ==
          'true';
    }

    if (value is num) {
      return value != 0;
    }

    return false;
  }

  // ============================================================
  // PARSE TIME
  // ============================================================

  TimeOfDay? _parseTime(
    String value,
  ) {
    String time =
        value.trim().toUpperCase();

    if (time.isEmpty) {
      return null;
    }

    try {
      // --------------------------------------------------------
      // AM / PM FORMAT
      // --------------------------------------------------------

      if (time.contains('AM') ||
          time.contains('PM')) {
        final bool isPM =
            time.contains('PM');

        time = time
            .replaceAll('AM', '')
            .replaceAll('PM', '')
            .trim();

        final List<String> parts =
            time.split(':');

        if (parts.length != 2) {
          return null;
        }

        int hour =
            int.parse(
          parts[0].trim(),
        );

        final int minute =
            int.parse(
          parts[1].trim(),
        );

        if (hour < 1 ||
            hour > 12) {
          return null;
        }

        if (minute < 0 ||
            minute > 59) {
          return null;
        }

        if (hour == 12) {
          hour = 0;
        }

        if (isPM) {
          hour += 12;
        }

        return TimeOfDay(
          hour: hour,
          minute: minute,
        );
      }

      // --------------------------------------------------------
      // 24 HOUR FORMAT
      // --------------------------------------------------------

      final List<String> parts =
          time.split(':');

      if (parts.length != 2) {
        return null;
      }

      final int hour =
          int.parse(
        parts[0].trim(),
      );

      final int minute =
          int.parse(
        parts[1].trim(),
      );

      if (hour < 0 ||
          hour > 23) {
        return null;
      }

      if (minute < 0 ||
          minute > 59) {
        return null;
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // FORMAT MINUTES
  // ============================================================

  String _formatMinutes(
    int totalMinutes,
  ) {
    int hour =
        totalMinutes ~/ 60;

    final int minute =
        totalMinutes % 60;

    final String period =
        hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final String minuteText =
        minute.toString().padLeft(
          2,
          '0',
        );

    return '$hour:$minuteText $period';
  }

  // ============================================================
  // CREATE UNIQUE SLOT ID
  // ============================================================

  String _createSlotId(
    String doctorId,
    DateTime date,
    String time,
  ) {
    final String datePart =
        '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';

    final String normalizedTime =
        time
            .trim()
            .toUpperCase()
            .replaceAll(' ', '_')
            .replaceAll(':', '_');

    return '${doctorId}_${datePart}_$normalizedTime';
  }

  // ============================================================
  // SAVE APPOINTMENT
  // ============================================================

  Future<void> saveAppointment() async {
    final User? user =
        _auth.currentUser;

    // ----------------------------------------------------------
    // LOGIN
    // ----------------------------------------------------------

    if (user == null) {
      _showMessage(
        'Login Required',
        'Please login before booking an appointment.',
      );
      return;
    }

    // ----------------------------------------------------------
    // DATE
    // ----------------------------------------------------------

    final DateTime? selected =
        selectedDate.value;

    if (selected == null) {
      _showMessage(
        'Select Date',
        'Please select an appointment date.',
      );
      return;
    }

    // ----------------------------------------------------------
    // DATE AVAILABILITY
    // ----------------------------------------------------------

    if (!isDateAvailable(selected)) {
      _showMessage(
        'Date Not Available',
        'The doctor is not available on this date.',
      );
      return;
    }

    // ----------------------------------------------------------
    // TIME
    // ----------------------------------------------------------

    final String time =
        selectedTime.value.trim();

    if (time.isEmpty) {
      _showMessage(
        'Select Time',
        'Please select an appointment time.',
      );
      return;
    }

    // ----------------------------------------------------------
    // DOCTOR
    // ----------------------------------------------------------

    if (doctorId.isEmpty) {
      _showMessage(
        'Error',
        'Doctor information is missing.',
      );
      return;
    }

    // ----------------------------------------------------------
    // PREVENT DOUBLE TAP
    // ----------------------------------------------------------

    if (isLoading.value) {
      return;
    }

    // ----------------------------------------------------------
    // LOCAL CHECK
    // ----------------------------------------------------------

    if (isSlotBooked(time)) {
      _showMessage(
        'Time Not Available',
        'This appointment slot has already been booked.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final DateTime appointmentDate =
          DateTime(
        selected.year,
        selected.month,
        selected.day,
      );

      // ========================================================
      // UNIQUE SLOT ID
      // ========================================================

      final String slotId =
          _createSlotId(
        doctorId,
        appointmentDate,
        time,
      );

      // ========================================================
      // FIRESTORE REFERENCES
      // ========================================================

      final DocumentReference<
              Map<String, dynamic>>
          slotRef =
          _firestore
              .collection(
                'appointmentSlots',
              )
              .doc(slotId);

      final DocumentReference<
              Map<String, dynamic>>
          appointmentRef =
          _firestore
              .collection(
                'appointments',
              )
              .doc();

      // ========================================================
      // ATOMIC FIRESTORE TRANSACTION
      // ========================================================

      await _firestore.runTransaction(
        (transaction) async {
          // ----------------------------------------------------
          // READ SLOT
          // ----------------------------------------------------

          final DocumentSnapshot<
                  Map<String, dynamic>>
              slotSnapshot =
              await transaction.get(
            slotRef,
          );

          // ----------------------------------------------------
          // SLOT EXISTS
          // ----------------------------------------------------

          if (slotSnapshot.exists) {
            final Map<String, dynamic>?
                slotData =
                slotSnapshot.data();

            final String status =
                slotData?['status']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            final bool reusable =
                status == 'cancelled' ||
                    status == 'canceled' ||
                    status == 'rejected';

            if (!reusable) {
              throw SlotAlreadyBookedException();
            }
          }

          // ----------------------------------------------------
          // CREATE SLOT RESERVATION
          // ----------------------------------------------------

          transaction.set(
            slotRef,
            {
              'doctorId': doctorId,
              'doctorName': doctorName,
              'userId': user.uid,
              'appointmentId':
                  appointmentRef.id,
              'date': Timestamp.fromDate(
                appointmentDate,
              ),
              'time': time,
              'status': 'pending',
              'createdAt':
                  FieldValue.serverTimestamp(),
            },
          );

          // ----------------------------------------------------
          // CREATE APPOINTMENT
          // ----------------------------------------------------

          transaction.set(
            appointmentRef,
            {
              'userId': user.uid,

              'doctorId': doctorId,

              'doctor': doctorName,

              'doctorName': doctorName,

              'specialist':
                  specialist,

              'doctorSpecialist':
                  specialist,

              'doctorImage':
                  doctorImage,

              'date':
                  Timestamp.fromDate(
                appointmentDate,
              ),

              'appointmentDate':
                  Timestamp.fromDate(
                appointmentDate,
              ),

              'time': time,

              'appointmentTime':
                  time,

              'status': 'pending',

              'slotId': slotId,

              'createdAt':
                  FieldValue.serverTimestamp(),
            },
          );
        },
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      bookedTimeSlots.add(time);

      selectedTime.value = '';

      // --------------------------------------------------------
      // TOP SUCCESS MESSAGE
      // --------------------------------------------------------

      Get.snackbar(
        'Appointment Booked',
        'Your appointment request has been submitted successfully.',
        snackPosition:
            SnackPosition.TOP,
        margin:
            const EdgeInsets.all(15),
        borderRadius: 14,
        backgroundColor:
            const Color(0xFF2196F3),
        colorText: Colors.white,
        duration:
            const Duration(
          seconds: 3,
        ),
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: 28,
        ),
        shouldIconPulse: false,
        isDismissible: true,
        dismissDirection:
            DismissDirection.horizontal,
      );

      // ========================================================
      // GO HOME
      // ========================================================

      await Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
      );

      Get.offAll(
        () => BottomNavBar(),
        transition:
            Transition.rightToLeft,
        duration:
            const Duration(
          milliseconds: 300,
        ),
      );
    }

    // ==========================================================
    // SLOT ALREADY BOOKED
    // ==========================================================

    on SlotAlreadyBookedException {
      bookedTimeSlots.add(time);

      selectedTime.value = '';

      _showMessage(
        'Time Not Available',
        'Sorry, this time slot has already been booked by another patient.',
      );
    }

    // ==========================================================
    // FIREBASE ERROR
    // ==========================================================

    on FirebaseException catch (e) {
      debugPrint(
        'APPOINTMENT FIREBASE ERROR: $e',
      );

      _showMessage(
        'Booking Failed',
        e.message ??
            'Something went wrong while booking the appointment.',
      );
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e) {
      debugPrint(
        'APPOINTMENT BOOKING ERROR: $e',
      );

      _showMessage(
        'Booking Failed',
        'Something went wrong. Please try again.',
      );
    }

    // ==========================================================
    // STOP LOADING
    // ==========================================================

    finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String title,
    String message,
  ) {
    Get.snackbar(
      title,
      message,
      snackPosition:
          SnackPosition.TOP,
      margin:
          const EdgeInsets.all(15),
      borderRadius: 14,
      backgroundColor:
          const Color(0xFF172534),
      colorText: Colors.white,
      duration:
          const Duration(seconds: 3),
    );
  }
}