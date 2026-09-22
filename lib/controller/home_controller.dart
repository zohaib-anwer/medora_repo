import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/chat_list/chat_list_view.dart';
import 'package:medicalchat/view/doctordetail/doctor_detail_view.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================================================
  // STREAM SUBSCRIPTIONS
  // =========================================================

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _doctorSubscription;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _appointmentSubscription;

  // =========================================================
  // SEARCH
  // =========================================================

  final TextEditingController searchController =
      TextEditingController();

  final RxString searchText = ''.obs;

  // =========================================================
  // DOCTORS
  // =========================================================

  final RxList<Map<String, dynamic>> doctors =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> filteredDoctors =
      <Map<String, dynamic>>[].obs;

  // =========================================================
  // CATEGORIES
  // =========================================================

  final RxString selectedCategory =
      'All'.obs;

  final RxList<HomeCategory> categories =
      <HomeCategory>[
    HomeCategory(
      name: 'Eye',
      icon: Icons.visibility_outlined,
      firestoreName: 'Eye',
    ),
    HomeCategory(
      name: 'Tooth',
      image: 'assets/tooth (3).png',
      firestoreName: 'Dentist',
    ),
    HomeCategory(
      name: 'Ear',
      icon: Icons.hearing_outlined,
      firestoreName: 'Ear',
    ),
    HomeCategory(
      name: 'Drugs',
      image: 'assets/drugs.png',
      firestoreName: 'Drugs',
    ),
    HomeCategory(
      name: 'Nutrition',
      icon: Icons.restaurant_outlined,
      firestoreName: 'Nutrition',
    ),
    HomeCategory(
      name: 'Psychology',
      icon: Icons.psychology_outlined,
      firestoreName: 'Psychology',
    ),
    HomeCategory(
      name: 'General',
      icon: Icons.medical_services_outlined,
      firestoreName: 'General',
    ),
  ].obs;

  // =========================================================
  // LOADING
  // =========================================================

  final RxBool isLoading =
      true.obs;

  final RxBool hasError =
      false.obs;

  // =========================================================
  // USER
  // =========================================================

  final RxString userName =
      'User'.obs;

  final RxString userEmail =
      ''.obs;

  final RxString userImage =
      ''.obs;

  // =========================================================
  // APPOINTMENT
  // =========================================================

  final Rxn<Map<String, dynamic>> upcomingAppointment =
      Rxn<Map<String, dynamic>>();

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    // Search
    searchController.addListener(() {
      searchText.value =
          searchController.text.trim();

      filterDoctors();
    });

    // Realtime user/profile listener
    listenToUser();

    // Realtime doctors listener
    listenToDoctors();

    // Realtime appointment listener
    listenToAppointments();
  }

  // =========================================================
  // REALTIME USER / PROFILE
  // =========================================================

  void listenToUser() {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      userName.value = 'User';
      userEmail.value = '';
      userImage.value = '';
      return;
    }

    // Cancel old listener if any
    _userSubscription?.cancel();

    // Listen to Firestore users/{uid}
    _userSubscription = _firestore
      .collection('paitent')
        .doc(user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        final Map<String, dynamic>? data =
            snapshot.data();

        // -----------------------------------------------------
        // EMAIL
        // -----------------------------------------------------

        userEmail.value =
            data?['email']?.toString() ??
                user.email ??
                '';

        // -----------------------------------------------------
        // NAME
        // -----------------------------------------------------

        final String firestoreName =
            data?['name']
                    ?.toString()
                    .trim() ??
                '';

        if (firestoreName.isNotEmpty) {
          userName.value =
              firestoreName;
        } else {
          final String displayName =
              user.displayName
                      ?.trim() ??
                  '';

          if (displayName.isNotEmpty) {
            userName.value =
                displayName;
          } else {
            userName.value =
                user.email
                        ?.split('@')
                        .first ??
                    'User';
          }
        }

        // -----------------------------------------------------
        // PROFILE PHOTO
        // -----------------------------------------------------

        final String firestoreImage =
            data?['photoUrl']?.toString().trim() ??
                data?['imageUrl']?.toString().trim() ??
                '';

        if (firestoreImage.isNotEmpty) {
          userImage.value =
              firestoreImage;
        } else {
          userImage.value =
              user.photoURL ?? '';
        }
      },
      onError: (error) {
        debugPrint(
          'User realtime stream error: $error',
        );

        // Fallback to Firebase Auth
        loadUser();
      },
    );

    // Initial Firebase Auth values
    loadUser();
  }

  // =========================================================
  // LOAD USER FALLBACK
  // =========================================================

  void loadUser() {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      userName.value = 'User';
      userEmail.value = '';
      userImage.value = '';
      return;
    }

    userEmail.value =
        user.email ?? '';

    userImage.value =
        user.photoURL ?? '';

    final String? displayName =
        user.displayName?.trim();

    if (displayName != null &&
        displayName.isNotEmpty) {
      userName.value =
          displayName;
    } else {
      final String emailName =
          user.email
                  ?.split('@')
                  .first ??
              'User';

      userName.value =
          emailName;
    }
  }

  // =========================================================
  // DOCTORS REALTIME STREAM
  // =========================================================

  void listenToDoctors() {
    isLoading.value = true;
    hasError.value = false;

    _doctorSubscription?.cancel();

    _doctorSubscription =
        _firestore
            .collection('doctors')
            .snapshots()
            .listen(
      (snapshot) {
        final List<Map<String, dynamic>>
            loaded = [];

        for (final document
            in snapshot.docs) {
          final Map<String, dynamic>
              data =
              Map<String, dynamic>.from(
            document.data(),
          );

          data['id'] =
              document.id;

          loaded.add(data);
        }

        doctors.assignAll(
          loaded,
        );

        filterDoctors();

        isLoading.value =
            false;

        hasError.value =
            false;
      },
      onError: (error) {
        debugPrint(
          'Doctors stream error: $error',
        );

        hasError.value =
            true;

        isLoading.value =
            false;
      },
    );
  }

  // =========================================================
  // FILTER DOCTORS
  // =========================================================

 void filterDoctors() {
  final String search =
      searchText.value.toLowerCase().trim();

  final String selected =
      selectedCategory.value.toLowerCase().trim();

  final List<Map<String, dynamic>> result =
      doctors.where((doctor) {
    final String name =
        doctor['name']?.toString().toLowerCase() ?? '';

    final String specialist =
        doctor['specialist']?.toString().toLowerCase() ?? '';

    final String category =
        doctor['category']?.toString().toLowerCase() ?? '';

    final bool matchesSearch =
        search.isEmpty ||
        name.contains(search) ||
        specialist.contains(search) ||
        category.contains(search);

    // Category OR Specialist dono check karo
    final bool matchesCategory =
        selected == 'all' ||
        category == selected ||
        specialist == selected;

    return matchesSearch && matchesCategory;
  }).toList();

  filteredDoctors.assignAll(result);
}

  // =========================================================
  // SELECT CATEGORY
  // =========================================================

  void selectCategory(
    HomeCategory category,
  ) {
    if (selectedCategory.value ==
        category.firestoreName) {
      selectedCategory.value =
          'All';
    } else {
      selectedCategory.value =
          category.firestoreName;
    }

    filterDoctors();
  }

  // =========================================================
  // VIEW ALL
  // =========================================================

  void viewAllCategories() {
    selectedCategory.value =
        'All';

    filterDoctors();
  }

  // =========================================================
  // CLEAR SEARCH
  // =========================================================

  void clearSearch() {
    searchController.clear();

    searchText.value =
        '';

    filterDoctors();
  }

  // =========================================================
  // REALTIME APPOINTMENTS
  // =========================================================

  void listenToAppointments() {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      upcomingAppointment.value =
          null;
      return;
    }

    _appointmentSubscription?.cancel();

    _appointmentSubscription =
        _firestore
            .collection('appointments')
            .where(
              'userId',
              isEqualTo: user.uid,
            )
            .snapshots()
            .listen(
      (snapshot) {
        final List<Map<String, dynamic>>
            appointments = [];

        for (final document
            in snapshot.docs) {
          final Map<String, dynamic>
              data =
              Map<String, dynamic>.from(
            document.data(),
          );

          data['id'] =
              document.id;

          appointments.add(data);
        }

        // -----------------------------------------------------
        // REMOVE CANCELLED / REJECTED APPOINTMENTS
        // -----------------------------------------------------

        final List<Map<String, dynamic>>
            activeAppointments =
            appointments.where(
          (appointment) {
            final String status =
                appointment['status']
                        ?.toString()
                        .toLowerCase()
                        .trim() ??
                    '';

            return status != 'cancelled' &&
                status != 'canceled' &&
                status != 'rejected' &&
                status != 'completed';
          },
        ).toList();

        // -----------------------------------------------------
        // SORT BY DATE
        // -----------------------------------------------------

        activeAppointments.sort(
          (a, b) {
            final DateTime dateA =
                _appointmentDate(a);

            final DateTime dateB =
                _appointmentDate(b);

            return dateA.compareTo(
              dateB,
            );
          },
        );

        // -----------------------------------------------------
        // FIND UPCOMING
        // -----------------------------------------------------

        final DateTime now =
            DateTime.now();

        final List<Map<String, dynamic>>
            upcoming =
            activeAppointments.where(
          (appointment) {
            final DateTime appointmentDate =
                _appointmentDate(
              appointment,
            );

            return appointmentDate
                    .isAfter(now) ||
                _sameDay(
                  appointmentDate,
                  now,
                );
          },
        ).toList();

        if (upcoming.isNotEmpty) {
          upcomingAppointment.value =
              upcoming.first;
        } else {
          upcomingAppointment.value =
              null;
        }
      },
      onError: (error) {
        debugPrint(
          'Appointment realtime stream error: $error',
        );

        upcomingAppointment.value =
            null;
      },
    );
  }

  // =========================================================
  // LOAD UPCOMING APPOINTMENT
  // =========================================================

  Future<void> loadUpcomingAppointment() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      upcomingAppointment.value =
          null;

      return;
    }

    try {
      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await _firestore
              .collection('appointments')
              .where(
                'userId',
                isEqualTo: user.uid,
              )
              .limit(20)
              .get();

      final List<Map<String, dynamic>>
          appointments =
          snapshot.docs.map(
        (doc) {
          final Map<String, dynamic>
              data =
              Map<String, dynamic>.from(
            doc.data(),
          );

          data['id'] =
              doc.id;

          return data;
        },
      ).toList();

      appointments.sort(
        (a, b) {
          return _appointmentDate(a)
              .compareTo(
            _appointmentDate(b),
          );
        },
      );

      final DateTime now =
          DateTime.now();

      final upcoming =
          appointments.where(
        (appointment) {
          final String status =
              appointment['status']
                      ?.toString()
                      .toLowerCase()
                      .trim() ??
                  '';

          if (status == 'cancelled' ||
              status == 'canceled' ||
              status == 'rejected' ||
              status == 'completed') {
            return false;
          }

          final DateTime date =
              _appointmentDate(
            appointment,
          );

          return date.isAfter(now) ||
              _sameDay(
                date,
                now,
              );
        },
      ).toList();

      if (upcoming.isNotEmpty) {
        upcomingAppointment.value =
            upcoming.first;
      } else {
        upcomingAppointment.value =
            null;
      }
    } catch (e) {
      debugPrint(
        'Appointment error: $e',
      );

      upcomingAppointment.value =
          null;
    }
  }

  // =========================================================
  // APPOINTMENT DATE
  // =========================================================

  DateTime _appointmentDate(
    Map<String, dynamic> data,
  ) {
    final dynamic value =
        data['appointmentDate'] ??
            data['date'];

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final DateTime? parsed =
          DateTime.tryParse(
        value,
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  // =========================================================
  // SAME DAY
  // =========================================================

  bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // =========================================================
  // OPEN DOCTOR
  // =========================================================

  void openDoctorDetail(
    Map<String, dynamic> doctor,
  ) {
    Get.to(
      () => DoctorDetailView(
        doctor: doctor,
      ),
      transition:
          Transition.rightToLeft,
      duration:
          const Duration(
        milliseconds: 300,
      ),
    );
  }

  // =========================================================
  // OPEN CHATS
  // =========================================================

  void openChats() {
    Get.to(
      () => const ChatListView(),
      transition:
          Transition.rightToLeft,
      duration:
          const Duration(
        milliseconds: 300,
      ),
    );
  }

  // =========================================================
  // MANUAL REFRESH
  // =========================================================

  Future<void> refreshDoctors() async {
    try {
      // Doctors
      final snapshot =
          await _firestore
              .collection('doctors')
              .get();

      final List<Map<String, dynamic>>
          loaded = [];

      for (final document
          in snapshot.docs) {
        final Map<String, dynamic>
            data =
            Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] =
            document.id;

        loaded.add(data);
      }

      doctors.assignAll(
        loaded,
      );

      filterDoctors();

      // User
      loadUser();

      // Appointment
      await loadUpcomingAppointment();
    } catch (e) {
      debugPrint(
        'Refresh error: $e',
      );
    }
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    _doctorSubscription?.cancel();
    _userSubscription?.cancel();
    _appointmentSubscription?.cancel();

    searchController.dispose();

    super.onClose();
  }
}

// =============================================================
// CATEGORY MODEL
// =============================================================

class HomeCategory {
  final String name;
  final IconData? icon;
  final String? image;
  final String firestoreName;

  HomeCategory({
    required this.name,
    this.icon,
    this.image,
    required this.firestoreName,
  });
}