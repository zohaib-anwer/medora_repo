import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/chat/chat_view.dart';
import 'package:medicalchat/view/doctordetail/doctor_detail_view.dart';

class ConsultController extends GetxController {
  // =========================================================
  // FIRESTORE
  // =========================================================

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // SELECTED CATEGORY
  // =========================================================

  final RxInt selectedCategory = 0.obs;

  // =========================================================
  // CATEGORIES
  // =========================================================

  final List<String> categories = [
    'All',
    'Eye',
    'Tooth',
    'Ear',
    'Drugs',
    'Nutrition',
  ];

  // =========================================================
  // DOCTORS
  // =========================================================

  final RxList<Map<String, dynamic>> doctors =
      <Map<String, dynamic>>[].obs;

  // =========================================================
  // LOADING
  // =========================================================

  final RxBool isLoading = false.obs;

  // =========================================================
  // ERROR
  // =========================================================

  final RxString errorMessage = ''.obs;

  // =========================================================
  // FIRESTORE SUBSCRIPTION
  // =========================================================

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _doctorsSubscription;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    listenToDoctors();
  }

  // =========================================================
  // REAL-TIME DOCTORS
  // =========================================================

  void listenToDoctors() {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _doctorsSubscription = firestore
          .collection('doctors')
          .snapshots()
          .listen(
        (snapshot) {
          final List<Map<String, dynamic>> loadedDoctors =
              snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();

          // ===================================================
          // SORT
          // Latest doctor first
          // ===================================================

          loadedDoctors.sort((a, b) {
            final dynamic aTime = a['createdAt'];
            final dynamic bTime = b['createdAt'];

            if (aTime is Timestamp &&
                bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }

            if (bTime is Timestamp &&
                aTime is! Timestamp) {
              return 1;
            }

            if (aTime is Timestamp &&
                bTime is! Timestamp) {
              return -1;
            }

            return 0;
          });

          // ===================================================
          // UPDATE RX LIST
          // ===================================================

          doctors.assignAll(loadedDoctors);

          isLoading.value = false;
          errorMessage.value = '';
        },
        onError: (error) {
          debugPrint(
            'CONSULT REALTIME ERROR: $error',
          );

          isLoading.value = false;

          errorMessage.value =
              'Unable to load doctors. Please try again.';
        },
      );
    } catch (e) {
      debugPrint(
        'CONSULT LISTENER ERROR: $e',
      );

      isLoading.value = false;

      errorMessage.value =
          'Unable to load doctors. Please try again.';
    }
  }

  // =========================================================
  // SELECT CATEGORY
  // =========================================================

  void selectCategory(int index) {
    if (index < 0 ||
        index >= categories.length) {
      return;
    }

    selectedCategory.value = index;
  }

  // =========================================================
  // FILTERED DOCTORS
  // =========================================================

  List<Map<String, dynamic>> get filteredDoctors {
    if (selectedCategory.value == 0) {
      return doctors.toList();
    }

    final String selectedCategoryName =
        categories[selectedCategory.value]
            .trim()
            .toLowerCase();

    return doctors.where((doctor) {
      final String doctorCategory =
          _normalize(doctor['category']);

      final String doctorSpecialist =
          _normalize(doctor['specialist']);

      if (_matchesCategory(
        selectedCategoryName,
        doctorCategory,
      )) {
        return true;
      }

      if (_matchesCategory(
        selectedCategoryName,
        doctorSpecialist,
      )) {
        return true;
      }

      return false;
    }).toList();
  }

  // =========================================================
  // CATEGORY MATCHING
  // =========================================================

  bool _matchesCategory(
    String selected,
    String value,
  ) {
    if (value.isEmpty) {
      return false;
    }

    if (selected == 'eye') {
      return value.contains('eye') ||
          value.contains('ophthalm') ||
          value.contains('optomet') ||
          value.contains('vision');
    }

    if (selected == 'tooth') {
      return value.contains('tooth') ||
          value.contains('dental') ||
          value.contains('dentist') ||
          value.contains('oral');
    }

    if (selected == 'ear') {
      return value.contains('ear') ||
          value.contains('ent') ||
          value.contains('otology') ||
          value.contains('otolaryng');
    }

    if (selected == 'drugs') {
      return value.contains('drug') ||
          value.contains('medicine') ||
          value.contains('pharma') ||
          value.contains('pharmac');
    }

    if (selected == 'nutrition') {
      return value.contains('nutrition') ||
          value.contains('nutrit') ||
          value.contains('diet') ||
          value.contains('dietitian') ||
          value.contains('dietician');
    }

    return value.contains(selected);
  }

  // =========================================================
  // NORMALIZE
  // =========================================================

  String _normalize(dynamic value) {
    if (value == null) {
      return '';
    }

    return value
        .toString()
        .trim()
        .toLowerCase();
  }

  // =========================================================
  // OPEN DOCTOR DETAIL
  // =========================================================

  void openDoctor(
    Map<String, dynamic> doctor,
  ) {
    if (doctor.isEmpty) {
      return;
    }

    Get.to(
      () => DoctorDetailView(
        doctor: doctor,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  // =========================================================
  // OPEN CHAT
  // =========================================================

  void openChat(
    Map<String, dynamic> doctor,
  ) {
    if (doctor.isEmpty) {
      return;
    }

    final Map<String, dynamic> doctorData =
        Map<String, dynamic>.from(doctor);

    // =======================================================
    // GET DOCTOR UID
    // =======================================================

    String doctorId =
        doctorData['id']?.toString().trim() ?? '';

    if (doctorId.isEmpty) {
      doctorId =
          doctorData['doctorId']?.toString().trim() ?? '';
    }

    // =======================================================
    // DOCTOR ID REQUIRED FOR CHAT
    // =======================================================

    if (doctorId.isEmpty) {
      Get.snackbar(
        'Chat Unavailable',
        'Doctor information is missing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF172534),
      );
      return;
    }

    // =======================================================
    // MAKE SURE BOTH KEYS EXIST
    // =======================================================

    doctorData['id'] = doctorId;
    doctorData['doctorId'] = doctorId;

    // =======================================================
    // OPEN CHAT
    // =======================================================

    Get.to(
      () => ChatView(
        doctor: doctorData,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshDoctors() async {
    // Real-time listener already updates automatically.
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );
  }

  // =========================================================
  // RETRY
  // =========================================================

  Future<void> retry() async {
    await _doctorsSubscription?.cancel();
    _doctorsSubscription = null;

    listenToDoctors();
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    _doctorsSubscription?.cancel();
    _doctorsSubscription = null;

    super.onClose();
  }
}