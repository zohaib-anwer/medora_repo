import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DoctorPresenceController extends GetxController
    with WidgetsBindingObserver {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // SUBSCRIPTIONS
  // ============================================================

  StreamSubscription<User?>? _authSubscription;

  // ============================================================
  // STATE
  // ============================================================

  bool _initialized = false;

  bool _isUpdatingPresence = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _initializePresence();
  }

  // ============================================================
  // INITIALIZE PRESENCE
  // ============================================================

  Future<void> _initializePresence() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    final User? currentUser =
        _auth.currentUser;

    if (currentUser != null) {
      await _setOnline();
    }

    // Listen for login/logout changes.
    _authSubscription =
        _auth.authStateChanges().listen(
      (User? user) async {
        if (user != null) {
          await _setOnline();
        }
      },
    );
  }

  // ============================================================
  // SET ONLINE
  // ============================================================

  Future<void> _setOnline() async {
    if (_isUpdatingPresence) {
      return;
    }

    final User? user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    _isUpdatingPresence = true;

    try {
      await _firestore
        .collection('paitent')
          .doc(user.uid)
          .set(
        {
          'isOnline': true,
          'lastSeen':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        'DOCTOR ONLINE => ${user.uid}',
      );
    } catch (e) {
      debugPrint(
        'DOCTOR SET ONLINE ERROR => $e',
      );
    } finally {
      _isUpdatingPresence = false;
    }
  }

  // ============================================================
  // SET OFFLINE
  // ============================================================

  Future<void> _setOffline() async {
    if (_isUpdatingPresence) {
      return;
    }

    final User? user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    _isUpdatingPresence = true;

    try {
      await _firestore
        .collection('paitent')
          .doc(user.uid)
          .set(
        {
          'isOnline': false,
          'lastSeen':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        'DOCTOR OFFLINE => ${user.uid}',
      );
    } catch (e) {
      debugPrint(
        'DOCTOR SET OFFLINE ERROR => $e',
      );
    } finally {
      _isUpdatingPresence = false;
    }
  }

  // ============================================================
  // LOGOUT PRESENCE
  // ============================================================
  //
  // DoctorDashboardView ke logout button se
  // ye method call hoga.
  //
  // ============================================================

  Future<void> setOfflineBeforeLogout() async {
    await _setOffline();
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    debugPrint(
      'DOCTOR APP LIFECYCLE => $state',
    );

    switch (state) {
      case AppLifecycleState.resumed:
        // Doctor app foreground mein aa gayi.
        _setOnline();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Doctor app background/hidden ho gayi.
        _setOffline();
        break;
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _authSubscription?.cancel();

    _setOffline();

    super.onClose();
  }
}