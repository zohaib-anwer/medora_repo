import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {
  // =========================================================
  // FIREBASE
  // =========================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================================================
  // STATUS TABS
  // =========================================================

  final RxList<String> statusTabs = <String>[
    'All',
    'Upcoming',
    'Pending',
    'Completed',
    'Cancelled',
  ].obs;

  final RxInt selectedStatus = 0.obs;

  // =========================================================
  // APPOINTMENTS
  // =========================================================

  final RxList<Map<String, dynamic>> appointments =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> filteredAppointments =
      <Map<String, dynamic>>[].obs;

  // =========================================================
  // STATES
  // =========================================================

  final RxBool isLoading = true.obs;

  final RxBool hasError = false.obs;

  final RxString errorMessage = ''.obs;

  // =========================================================
  // STREAMS
  // =========================================================

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _appointmentSubscription;

  StreamSubscription<User?>? _authSubscription;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    // Listen for Firebase login/logout.
    _authSubscription =
        _auth.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          _stopAppointmentListener();

          appointments.clear();
          filteredAppointments.clear();

          isLoading.value = false;
          hasError.value = false;
          errorMessage.value = '';
        } else {
          listenToAppointments();
        }
      },
    );

    // Also check immediately.
    final User? currentUser =
        _auth.currentUser;

    if (currentUser != null) {
      listenToAppointments();
    }
  }

  // =========================================================
  // LISTEN TO APPOINTMENTS
  // =========================================================

  void listenToAppointments() {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      appointments.clear();
      filteredAppointments.clear();

      isLoading.value = false;
      hasError.value = false;
      errorMessage.value = '';

      return;
    }

    // ---------------------------------------------------------
    // CANCEL OLD STREAM
    // ---------------------------------------------------------

    _appointmentSubscription?.cancel();

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    debugPrint(
      'STATUS: Loading appointments for user: ${user.uid}',
    );

    // =========================================================
    // FIRESTORE STREAM
    // =========================================================

    _appointmentSubscription = _firestore
        .collection('appointments')
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        debugPrint(
          'STATUS: Appointment documents found: '
          '${snapshot.docs.length}',
        );

        final List<Map<String, dynamic>>
            loadedAppointments = [];

        // -----------------------------------------------------
        // CONVERT FIRESTORE DOCUMENTS
        // -----------------------------------------------------

        for (final QueryDocumentSnapshot<
            Map<String, dynamic>> document
            in snapshot.docs) {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(
            document.data(),
          );

          // Always keep Firestore document ID.
          data['id'] = document.id;

          loadedAppointments.add(data);

          debugPrint(
            'STATUS APPOINTMENT: '
            'id=${document.id}, '
            'userId=${data['userId']}, '
            'doctor=${data['doctorName'] ?? data['doctor']}, '
            'status=${data['status']}, '
            'date=${data['date']}, '
            'time=${data['time']}',
          );
        }

        // -----------------------------------------------------
        // SORT
        // -----------------------------------------------------

        _sortAppointments(
          loadedAppointments,
        );

        // -----------------------------------------------------
        // UPDATE LIST
        // -----------------------------------------------------

        appointments.assignAll(
          loadedAppointments,
        );

        filterAppointments();

        isLoading.value = false;
        hasError.value = false;
        errorMessage.value = '';
      },
      onError: (Object error) {
        debugPrint(
          'STATUS APPOINTMENTS STREAM ERROR: $error',
        );

        isLoading.value = false;
        hasError.value = true;

        errorMessage.value =
            'Unable to load appointments. Please try again.';

        appointments.clear();
        filteredAppointments.clear();
      },
    );
  }

  // =========================================================
  // STOP APPOINTMENT STREAM
  // =========================================================

  void _stopAppointmentListener() {
    _appointmentSubscription?.cancel();

    _appointmentSubscription = null;
  }

  // =========================================================
  // SORT APPOINTMENTS
  // =========================================================

  void _sortAppointments(
    List<Map<String, dynamic>> list,
  ) {
    list.sort(
      (
        Map<String, dynamic> a,
        Map<String, dynamic> b,
      ) {
        final String statusA =
            normalizeStatus(
          a['status'],
        );

        final String statusB =
            normalizeStatus(
          b['status'],
        );

        final int priorityA =
            _statusPriority(
          statusA,
        );

        final int priorityB =
            _statusPriority(
          statusB,
        );

        if (priorityA != priorityB) {
          return priorityA.compareTo(
            priorityB,
          );
        }

        final DateTime? dateTimeA =
            _appointmentDateTime(a);

        final DateTime? dateTimeB =
            _appointmentDateTime(b);

        if (dateTimeA == null &&
            dateTimeB == null) {
          return 0;
        }

        if (dateTimeA == null) {
          return 1;
        }

        if (dateTimeB == null) {
          return -1;
        }

        return dateTimeA.compareTo(
          dateTimeB,
        );
      },
    );
  }

  // =========================================================
  // STATUS PRIORITY
  // =========================================================

  int _statusPriority(
    String status,
  ) {
    switch (status) {
      case 'upcoming':
        return 0;

      case 'pending':
        return 1;

      case 'completed':
        return 2;

      case 'cancelled':
        return 3;

      default:
        return 4;
    }
  }

  // =========================================================
  // FILTER
  // =========================================================

  void filterAppointments() {
    final int index =
        selectedStatus.value;

    // ---------------------------------------------------------
    // ALL
    // ---------------------------------------------------------

    if (index == 0) {
      filteredAppointments.assignAll(
        appointments,
      );

      return;
    }

    if (index < 0 ||
        index >= statusTabs.length) {
      filteredAppointments.assignAll(
        appointments,
      );

      return;
    }

    final String selected =
        statusTabs[index]
            .toLowerCase()
            .trim();

    final List<Map<String, dynamic>>
        result = appointments.where(
      (
        Map<String, dynamic> appointment,
      ) {
        final String status =
            normalizeStatus(
          appointment['status'],
        );

        return status == selected;
      },
    ).toList();

    filteredAppointments.assignAll(
      result,
    );
  }

  // =========================================================
  // SELECT STATUS
  // =========================================================

  void selectStatus(
    int index,
  ) {
    if (index < 0 ||
        index >= statusTabs.length) {
      return;
    }

    selectedStatus.value = index;

    filterAppointments();
  }

  // =========================================================
  // NORMALIZE STATUS
  // =========================================================

  String normalizeStatus(
    dynamic value,
  ) {
    String status =
        value?.toString().trim().toLowerCase() ??
            '';

    // Remove spaces / underscores / hyphens.
    status = status.replaceAll(
      RegExp(r'[\s_-]+'),
      '',
    );

    if (status.isEmpty) {
      return 'upcoming';
    }

    // ---------------------------------------------------------
    // UPCOMING
    // ---------------------------------------------------------

    if (status == 'upcoming' ||
        status == 'booked' ||
        status == 'approved' ||
        status == 'approve' ||
        status == 'confirm' ||
        status == 'confirmed' ||
        status == 'accepted' ||
        status == 'scheduled') {
      return 'upcoming';
    }

    // ---------------------------------------------------------
    // PENDING
    // ---------------------------------------------------------

    if (status == 'pending' ||
        status == 'waiting' ||
        status == 'requested' ||
        status == 'processing') {
      return 'pending';
    }

    // ---------------------------------------------------------
    // COMPLETED
    // ---------------------------------------------------------

    if (status == 'completed' ||
        status == 'complete' ||
        status == 'done' ||
        status == 'finished') {
      return 'completed';
    }

    // ---------------------------------------------------------
    // CANCELLED
    // ---------------------------------------------------------

    if (status == 'cancelled' ||
        status == 'canceled' ||
        status == 'cancel' ||
        status == 'rejected') {
      return 'cancelled';
    }

    return status;
  }

  // =========================================================
  // DISPLAY STATUS
  // =========================================================

  String getStatus(
    Map<String, dynamic> appointment,
  ) {
    final String status =
        normalizeStatus(
      appointment['status'],
    );

    switch (status) {
      case 'upcoming':
        return 'Upcoming';

      case 'pending':
        return 'Pending';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        if (status.isEmpty) {
          return 'Upcoming';
        }

        return _capitalize(status);
    }
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshAppointments() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      appointments.clear();
      filteredAppointments.clear();

      isLoading.value = false;
      hasError.value = false;
      errorMessage.value = '';

      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await _firestore
              .collection('appointments')
              .where(
                'userId',
                isEqualTo: user.uid,
              )
              .get();

      final List<Map<String, dynamic>>
          loadedAppointments = [];

      for (final QueryDocumentSnapshot<
          Map<String, dynamic>> document
          in snapshot.docs) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] = document.id;

        loadedAppointments.add(data);
      }

      _sortAppointments(
        loadedAppointments,
      );

      appointments.assignAll(
        loadedAppointments,
      );

      filterAppointments();

      isLoading.value = false;
      hasError.value = false;
    } catch (e) {
      debugPrint(
        'STATUS REFRESH ERROR: $e',
      );

      isLoading.value = false;
      hasError.value = true;

      errorMessage.value =
          'Unable to refresh appointments.';
    }
  }

  // =========================================================
  // DATE
  // =========================================================

  String getDate(
    Map<String, dynamic> appointment,
  ) {
    final DateTime? date =
        _getDateValue(
      appointment,
    );

    if (date != null) {
      return _formatDate(date);
    }

    // ---------------------------------------------------------
    // STRING FALLBACK
    // ---------------------------------------------------------

    final dynamic rawDate =
        appointment['date'];

    if (rawDate is String &&
        rawDate.trim().isNotEmpty) {
      return rawDate.trim();
    }

    final dynamic rawAppointmentDate =
        appointment['appointmentDate'];

    if (rawAppointmentDate is String &&
        rawAppointmentDate.trim().isNotEmpty) {
      return rawAppointmentDate.trim();
    }

    return 'Date not available';
  }

  // =========================================================
  // TIME
  // =========================================================

  String getTime(
    Map<String, dynamic> appointment,
  ) {
    // ---------------------------------------------------------
    // TIME FIELD
    // ---------------------------------------------------------

    final dynamic rawTime =
        appointment['time'];

    if (rawTime is Timestamp) {
      return _formatTime(
        rawTime.toDate(),
      );
    }

    if (rawTime is DateTime) {
      return _formatTime(rawTime);
    }

    if (rawTime is String &&
        rawTime.trim().isNotEmpty) {
      return _formatTimeString(
        rawTime.trim(),
      );
    }

    // ---------------------------------------------------------
    // APPOINTMENT TIME
    // ---------------------------------------------------------

    final dynamic appointmentTime =
        appointment['appointmentTime'];

    if (appointmentTime is Timestamp) {
      return _formatTime(
        appointmentTime.toDate(),
      );
    }

    if (appointmentTime is DateTime) {
      return _formatTime(
        appointmentTime,
      );
    }

    if (appointmentTime is String &&
        appointmentTime.trim().isNotEmpty) {
      return _formatTimeString(
        appointmentTime.trim(),
      );
    }

    // ---------------------------------------------------------
    // DATE WITH TIME
    // ---------------------------------------------------------

    final dynamic rawDate =
        appointment['date'];

    if (rawDate is Timestamp) {
      return _formatTime(
        rawDate.toDate(),
      );
    }

    if (rawDate is DateTime) {
      return _formatTime(rawDate);
    }

    if (rawDate is String &&
        rawDate.trim().isNotEmpty) {
      final DateTime? parsed =
          DateTime.tryParse(
        rawDate.trim(),
      );

      if (parsed != null) {
        return _formatTime(parsed);
      }
    }

    return 'Time not available';
  }

  // =========================================================
  // GET DATE VALUE
  // =========================================================

  DateTime? _getDateValue(
    Map<String, dynamic> appointment,
  ) {
    final dynamic rawDate =
        appointment['date'];

    if (rawDate is Timestamp) {
      return rawDate.toDate();
    }

    if (rawDate is DateTime) {
      return rawDate;
    }

    if (rawDate is String &&
        rawDate.trim().isNotEmpty) {
      final DateTime? parsed =
          DateTime.tryParse(
        rawDate.trim(),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    // ---------------------------------------------------------
    // APPOINTMENT DATE
    // ---------------------------------------------------------

    final dynamic appointmentDate =
        appointment['appointmentDate'];

    if (appointmentDate is Timestamp) {
      return appointmentDate.toDate();
    }

    if (appointmentDate is DateTime) {
      return appointmentDate;
    }

    if (appointmentDate is String &&
        appointmentDate.trim().isNotEmpty) {
      return DateTime.tryParse(
        appointmentDate.trim(),
      );
    }

    return null;
  }

  // =========================================================
  // APPOINTMENT DATE + TIME
  // =========================================================

  DateTime? _appointmentDateTime(
    Map<String, dynamic> appointment,
  ) {
    final DateTime? date =
        _getDateValue(appointment);

    if (date == null) {
      return null;
    }

    final dynamic rawTime =
        appointment['time'] ??
            appointment['appointmentTime'];

    if (rawTime is String &&
        rawTime.trim().isNotEmpty) {
      final String time =
          rawTime.trim();

      final RegExp regex =
          RegExp(
        r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM|am|pm))?$',
      );

      final Match? match =
          regex.firstMatch(time);

      if (match != null) {
        int hour =
            int.tryParse(
                  match.group(1) ?? '0',
                ) ??
                0;

        final int minute =
            int.tryParse(
                  match.group(2) ?? '0',
                ) ??
                0;

        final String? period =
            match.group(3)
                ?.toUpperCase();

        if (period == 'PM' &&
            hour < 12) {
          hour += 12;
        }

        if (period == 'AM' &&
            hour == 12) {
          hour = 0;
        }

        return DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
      }
    }

    if (rawTime is Timestamp) {
      final DateTime time =
          rawTime.toDate();

      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    if (rawTime is DateTime) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        rawTime.hour,
        rawTime.minute,
      );
    }

    return date;
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(
    DateTime date,
  ) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

  String _formatTime(
    DateTime time,
  ) {
    int hour = time.hour;

    final int minute =
        time.minute;

    final String period =
        hour >= 12
            ? 'PM'
            : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  // =========================================================
  // FORMAT TIME STRING
  // =========================================================

  String _formatTimeString(
    String value,
  ) {
    final DateTime? parsed =
        DateTime.tryParse(value);

    if (parsed != null) {
      return _formatTime(parsed);
    }

    final RegExp regex =
        RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM|am|pm))?$',
    );

    final Match? match =
        regex.firstMatch(value);

    if (match == null) {
      return value;
    }

    int hour =
        int.tryParse(
              match.group(1) ?? '0',
            ) ??
            0;

    final int minute =
        int.tryParse(
              match.group(2) ?? '0',
            ) ??
            0;

    String? period =
        match.group(3);

    if (period != null) {
      period = period.toUpperCase();
    }

    if (hour > 23 ||
        minute > 59) {
      return value;
    }

    if (period == 'PM' &&
        hour < 12) {
      hour += 12;
    }

    if (period == 'AM' &&
        hour == 12) {
      hour = 0;
    }

    return _formatTime(
      DateTime(
        2020,
        1,
        1,
        hour,
        minute,
      ),
    );
  }

  // =========================================================
  // DOCTOR NAME
  // =========================================================

  String getDoctorName(
    Map<String, dynamic> appointment,
  ) {
    final List<String> fields = [
      'doctorName',
      'doctor_name',
      'name',
    ];

    for (final String field in fields) {
      final String value =
          appointment[field]
                  ?.toString()
                  .trim() ??
              '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    final dynamic doctor =
        appointment['doctor'];

    if (doctor is Map) {
      final String name =
          doctor['name']
                  ?.toString()
                  .trim() ??
              '';

      if (name.isNotEmpty) {
        return name;
      }
    }

    return 'Doctor';
  }

  // =========================================================
  // SPECIALIST
  // =========================================================

  String getSpecialist(
    Map<String, dynamic> appointment,
  ) {
    final List<String> fields = [
      'specialist',
      'doctorSpecialist',
      'specialty',
      'category',
    ];

    for (final String field in fields) {
      final String value =
          appointment[field]
                  ?.toString()
                  .trim() ??
              '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    final dynamic doctor =
        appointment['doctor'];

    if (doctor is Map) {
      final List<String> fields = [
        'specialist',
        'specialty',
        'category',
      ];

      for (final String field in fields) {
        final String value =
            doctor[field]
                    ?.toString()
                    .trim() ??
                '';

        if (value.isNotEmpty) {
          return value;
        }
      }
    }

    return 'Medical Specialist';
  }

  // =========================================================
  // DOCTOR IMAGE
  // =========================================================

  String getDoctorImage(
    Map<String, dynamic> appointment,
  ) {
    final List<String> fields = [
      'doctorImage',
      'doctorImageUrl',
      'imageUrl',
      'doctorPhoto',
      'photoUrl',
    ];

    for (final String field in fields) {
      final String value =
          appointment[field]
                  ?.toString()
                  .trim() ??
              '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    final dynamic doctor =
        appointment['doctor'];

    if (doctor is Map) {
      final List<String> nestedFields = [
        'imageUrl',
        'photoUrl',
        'image',
        'doctorImage',
      ];

      for (final String field
          in nestedFields) {
        final String value =
            doctor[field]
                    ?.toString()
                    .trim() ??
                '';

        if (value.isNotEmpty) {
          return value;
        }
      }
    }

    return '';
  }

  // =========================================================
  // DOCTOR ID
  // =========================================================

  String getDoctorId(
    Map<String, dynamic> appointment,
  ) {
    final List<String> fields = [
      'doctorId',
      'doctorID',
    ];

    for (final String field in fields) {
      final String value =
          appointment[field]
                  ?.toString()
                  .trim() ??
              '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    final dynamic doctor =
        appointment['doctor'];

    if (doctor is Map) {
      final String id =
          doctor['id']
                  ?.toString()
                  .trim() ??
              '';

      if (id.isNotEmpty) {
        return id;
      }
    }

    return '';
  }

  // =========================================================
  // CANCEL APPOINTMENT
  // =========================================================

  Future<void> cancelAppointment(
    String appointmentId,
  ) async {
    if (appointmentId.isEmpty) {
      return;
    }

    final User? user =
        _auth.currentUser;

    if (user == null) {
      Get.snackbar(
        'Error',
        'Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      // -------------------------------------------------------
      // SECURITY CHECK
      // -------------------------------------------------------

      final DocumentSnapshot<
              Map<String, dynamic>>
          appointmentDocument =
          await _firestore
              .collection('appointments')
              .doc(appointmentId)
              .get();

      if (!appointmentDocument.exists) {
        Get.snackbar(
          'Error',
          'Appointment not found.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final Map<String, dynamic>? data =
          appointmentDocument.data();

      if (data == null ||
          data['userId']?.toString() !=
              user.uid) {
        Get.snackbar(
          'Error',
          'You cannot cancel this appointment.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      // -------------------------------------------------------
      // UPDATE
      // -------------------------------------------------------

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'Cancelled',
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Appointment Cancelled',
        'Your appointment has been cancelled.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        'CANCEL APPOINTMENT ERROR: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to cancel appointment.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================================================
  // CAPITALIZE
  // =========================================================

  String _capitalize(
    String value,
  ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    _appointmentSubscription?.cancel();
    _authSubscription?.cancel();

    super.onClose();
  }
}