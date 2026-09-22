import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  // =========================================================
  // FIREBASE
  // =========================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final ImagePicker _picker =
      ImagePicker();

  // =========================================================
  // DOCTOR PRESENCE
  // =========================================================

  final RxBool doctorIsOnline =
      false.obs;

  final Rxn<DateTime> doctorLastSeen =
      Rxn<DateTime>();

  // =========================================================
  // PATIENT PRESENCE
  // =========================================================

  final RxBool patientIsOnline =
      false.obs;

  final Rxn<DateTime> patientLastSeen =
      Rxn<DateTime>();

  // =========================================================
  // CLOUDINARY
  // =========================================================

  static const String _cloudName =
      'dvlvfm5ky';

  static const String _uploadPreset =
      'bitebuddy_upload';

  // =========================================================
  // INPUT
  // =========================================================

  final TextEditingController messageController =
      TextEditingController();

  // =========================================================
  // SCROLL
  // =========================================================

  final ScrollController scrollController =
      ScrollController();

  // =========================================================
  // MESSAGES
  // =========================================================

  final RxList<ChatMessage> messages =
      <ChatMessage>[].obs;

  // =========================================================
  // STATES
  // =========================================================

  final RxBool isLoading =
      true.obs;

  final RxBool isSending =
      false.obs;

  final RxBool isUploadingImage =
      false.obs;

  final RxBool isDeletingMessages =
      false.obs;

  // =========================================================
  // ROLE
  // =========================================================

  final RxString currentRole =
      'patient'.obs;

  bool get isDoctor =>
      currentRole.value == 'doctor';

  bool get isPatient =>
      currentRole.value == 'patient';

  bool get isUser =>
      isPatient;

  bool get isAdmin =>
      currentRole.value == 'admin';

  // =========================================================
  // CURRENT USER
  // =========================================================

  final RxString currentUserId =
      ''.obs;

  final RxString currentUserName =
      ''.obs;

  final RxString currentUserImage =
      ''.obs;

  // =========================================================
  // DOCTOR
  // =========================================================

  final RxString doctorId =
      ''.obs;

  final RxString doctorName =
      'Doctor'.obs;

  final RxString doctorImage =
      ''.obs;

  final RxString doctorSpecialist =
      ''.obs;

  // =========================================================
  // PATIENT
  // =========================================================

  final RxString patientId =
      ''.obs;

  final RxString patientName =
      'Patient'.obs;

  final RxString patientImage =
      ''.obs;

  // =========================================================
  // UNREAD
  // =========================================================

  final RxInt unreadCount =
      0.obs;

  // =========================================================
  // SUBSCRIPTIONS
  // =========================================================

  StreamSubscription<
          DocumentSnapshot<Map<String, dynamic>>>?
      _doctorSubscription;

  StreamSubscription<
          DocumentSnapshot<Map<String, dynamic>>>?
      _doctorPresenceSubscription;

  StreamSubscription<
          DocumentSnapshot<Map<String, dynamic>>>?
      _patientSubscription;

  StreamSubscription<
          QuerySnapshot<Map<String, dynamic>>>?
      _messageSubscription;

  // =========================================================
  // INITIALIZED
  // =========================================================

  bool _isInitialized = false;

  // =========================================================
  // GETTERS
  // =========================================================

  bool get isSelectionMode =>
      selectedMessageIds.isNotEmpty;

  int get selectedCount =>
      selectedMessageIds.length;

  bool get isAllMessagesSelected =>
      messages.isNotEmpty &&
      selectedMessageIds.length ==
          messages.length;

  // =========================================================
  // OTHER PARTICIPANT
  // =========================================================

  String get otherParticipantName {
    if (isDoctor) {
      return patientName.value.isNotEmpty
          ? patientName.value
          : 'Patient';
    }

    return doctorName.value.isNotEmpty
        ? doctorName.value
        : 'Doctor';
  }

  String get otherParticipantImage {
    if (isDoctor) {
      return patientImage.value;
    }

    return doctorImage.value;
  }

  bool get otherParticipantIsOnline {
    if (isDoctor) {
      return patientIsOnline.value;
    }

    return doctorIsOnline.value;
  }

  DateTime? get otherParticipantLastSeen {
    if (isDoctor) {
      return patientLastSeen.value;
    }

    return doctorLastSeen.value;
  }

  String get otherParticipantStatusText {
    if (isDoctor) {
      return patientStatusText;
    }

    return doctorStatusText;
  }

  String get otherParticipantSpecialist {
    if (isDoctor) {
      return '';
    }

    return doctorSpecialist.value;
  }

  // =========================================================
  // SELECTION
  // =========================================================

  final RxSet<String> selectedMessageIds =
      <String>{}.obs;

  // =========================================================
  // INITIALIZE CHAT
  // =========================================================

  Future<void> initializeChat(
    Map<String, dynamic>? chatData,
  ) async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    final User? user =
        _auth.currentUser;

    if (user == null) {
      isLoading.value = false;
      _loginRequired();
      return;
    }

    currentUserId.value =
        user.uid;

    await _loadCurrentUserRole();

    debugPrint(
      '========================================',
    );

    debugPrint(
      'CHAT INITIALIZATION START',
    );

    debugPrint(
      'CHAT CURRENT UID => ${user.uid}',
    );

    debugPrint(
      'CHAT CURRENT ROLE => ${currentRole.value}',
    );

    debugPrint(
      '========================================',
    );

    // =======================================================
    // PATIENT
    // =======================================================

    if (isPatient) {
      await _initializePatientChat(
        chatData,
        user.uid,
      );

      return;
    }

    // =======================================================
    // DOCTOR
    // =======================================================

    if (isDoctor) {
      await _initializeDoctorChat(
        chatData,
        user.uid,
      );

      return;
    }

    // =======================================================
    // ADMIN
    // =======================================================

    isLoading.value = false;

    _error(
      'Chat is not available for this account.',
    );
  }

  // =========================================================
  // LOAD CURRENT USER ROLE
  // =========================================================

  Future<void> _loadCurrentUserRole() async {
    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        return;
      }

      final DocumentSnapshot<
              Map<String, dynamic>>
          snapshot =
          await _firestore
              .collection('paitent')
              .doc(user.uid)
              .get();

      debugPrint(
        'CHAT PROFILE EXISTS => ${snapshot.exists}',
      );

      debugPrint(
        'CHAT PROFILE PATH => paitent/${user.uid}',
      );

      if (!snapshot.exists) {
        currentRole.value =
            'patient';

        currentUserName.value =
            user.displayName ?? '';

        debugPrint(
          'CHAT PROFILE NOT FOUND. DEFAULT ROLE => patient',
        );

        return;
      }

      final Map<String, dynamic>
          data =
          snapshot.data() ?? {};

      final String role =
          data['role']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      currentRole.value =
          role.isNotEmpty
              ? role
              : 'patient';

      final String name =
          data['name']
                  ?.toString()
                  .trim() ??
              '';

      currentUserName.value =
          name.isNotEmpty
              ? name
              : user.displayName ?? '';

      currentUserImage.value =
          _getImageFromData(data);

      debugPrint(
        'CHAT ROLE FROM FIRESTORE => "$role"',
      );

      debugPrint(
        'CHAT USER NAME => ${currentUserName.value}',
      );
    } catch (e) {
      debugPrint(
        'LOAD USER ROLE ERROR => $e',
      );

      currentRole.value =
          'patient';

      final User? user =
          _auth.currentUser;

      currentUserName.value =
          user?.displayName ?? '';
    }
  }

  // =========================================================
  // IMAGE FROM DATA
  // =========================================================

  String _getImageFromData(
    Map<String, dynamic> data,
  ) {
    final List<String> fields = [
      'imageUrl',
      'photoUrl',
      'image',
      'profileImage',
      'profileImageUrl',
    ];

    for (final field in fields) {
      final String value =
          data[field]
                  ?.toString()
                  .trim() ??
              '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  // =========================================================
  // INITIALIZE PATIENT CHAT
  // =========================================================

  Future<void> _initializePatientChat(
    Map<String, dynamic>? doctor,
    String patientUid,
  ) async {
    patientId.value =
        patientUid;

    patientName.value =
        currentUserName.value.isNotEmpty
            ? currentUserName.value
            : 'Patient';

    patientImage.value =
        currentUserImage.value;

    // -------------------------------------------------------
    // DOCTOR ID
    // -------------------------------------------------------

    doctorId.value =
        doctor?['id']?.toString() ??
        doctor?['doctorId']?.toString() ??
        doctor?['uid']?.toString() ??
        '';

    // -------------------------------------------------------
    // DOCTOR NAME
    // -------------------------------------------------------

    doctorName.value =
        doctor?['name']?.toString() ??
        doctor?['doctorName']?.toString() ??
        'Doctor';

    // -------------------------------------------------------
    // DOCTOR IMAGE
    // -------------------------------------------------------

    doctorImage.value =
        doctor?['imageUrl']?.toString() ??
        doctor?['photoUrl']?.toString() ??
        doctor?['image']?.toString() ??
        doctor?['doctorImage']?.toString() ??
        '';

    // -------------------------------------------------------
    // SPECIALIST
    // -------------------------------------------------------

    doctorSpecialist.value =
        doctor?['specialist']?.toString() ??
        doctor?['specialty']?.toString() ??
        doctor?['doctorSpecialist']?.toString() ??
        '';

    debugPrint(
      'PATIENT CHAT => '
      'patient=$patientUid '
      'doctor=${doctorId.value}',
    );

    if (doctorId.value.isEmpty) {
      isLoading.value = false;

      _error(
        'Doctor ID is missing.',
      );

      return;
    }

    _listenToDoctorProfile(
      doctorId.value,
    );

    _listenToDoctorPresence(
      doctorId.value,
    );

    // =======================================================
    // IMPORTANT:
    // CREATE CHAT DOCUMENT BEFORE MESSAGE LISTENER
    // =======================================================

    try {
      await _ensureChatDocument();

      _listenToMessages(
        patientUid,
        doctorId.value,
      );
    } catch (e) {
      debugPrint(
        'PATIENT CHAT INITIALIZATION ERROR => $e',
      );

      isLoading.value = false;

      _error(
        'Unable to load chat.',
      );
    }
  }

  // =========================================================
  // INITIALIZE DOCTOR CHAT
  // =========================================================

  Future<void> _initializeDoctorChat(
    Map<String, dynamic>? chat,
    String doctorUid,
  ) async {
    doctorId.value =
        doctorUid;

    doctorName.value =
        currentUserName.value.isNotEmpty
            ? currentUserName.value
            : 'Doctor';

    doctorImage.value =
        currentUserImage.value;

    // -------------------------------------------------------
    // PATIENT ID
    // -------------------------------------------------------

    patientId.value =
        chat?['patientId']?.toString() ??
        '';

    // -------------------------------------------------------
    // PATIENT NAME
    // -------------------------------------------------------

    patientName.value =
        chat?['patientName']?.toString() ??
        'Patient';

    // -------------------------------------------------------
    // PATIENT IMAGE
    // -------------------------------------------------------

    patientImage.value =
        chat?['patientImage']?.toString() ??
        '';

    debugPrint(
      'DOCTOR CHAT => '
      'doctor=$doctorUid '
      'patient=${patientId.value}',
    );

    if (patientId.value.isEmpty) {
      isLoading.value = false;

      _error(
        'Patient information is missing.',
      );

      return;
    }

    _listenToPatient();

    // =======================================================
    // IMPORTANT:
    // CREATE CHAT DOCUMENT BEFORE MESSAGE LISTENER
    // =======================================================

    try {
      await _ensureChatDocument();

      _listenToMessages(
        patientId.value,
        doctorUid,
      );
    } catch (e) {
      debugPrint(
        'DOCTOR CHAT INITIALIZATION ERROR => $e',
      );

      isLoading.value = false;

      _error(
        'Unable to load chat.',
      );
    }
  }

  // =========================================================
  // ENSURE CHAT DOCUMENT
  //
  // This fixes:
  // "Unable to load chat"
  // "Unable to send message"
  // =========================================================

 Future<void> _ensureChatDocument() async {
  if (patientId.value.isEmpty ||
      doctorId.value.isEmpty) {
    throw Exception(
      'Patient ID or Doctor ID is missing.',
    );
  }

  final String id = currentChatId;

  final DocumentReference<Map<String, dynamic>> chatRef =
      _firestore.collection('chats').doc(id);

  try {
    debugPrint('========================================');
    debugPrint('ENSURE CHAT DOCUMENT');
    debugPrint('CHAT ID => $id');
    debugPrint('PATIENT ID => ${patientId.value}');
    debugPrint('DOCTOR ID => ${doctorId.value}');
    debugPrint('CURRENT UID => ${currentUserId.value}');
    debugPrint('CURRENT ROLE => ${currentRole.value}');
    debugPrint('========================================');

    // IMPORTANT:
    // Do NOT call chatRef.get() here.
    //
    // If the document does not exist, Firestore rules may reject
    // the read before we get a chance to create it.
    //
    // merge:true works for both:
    // 1. New chat  -> creates document
    // 2. Existing chat -> updates document
    await chatRef.set(
      {
        'patientId': patientId.value,
        'patientName': patientName.value,
        'patientImage': patientImage.value,

        'doctorId': doctorId.value,
        'doctorName': doctorName.value,
        'doctorImage': doctorImage.value,
        'doctorSpecialist': doctorSpecialist.value,

        'lastMessage': '',
        'lastMessageAt': null,

        'updatedAt':
            FieldValue.serverTimestamp(),

        'unreadPatientCount': 0,
        'unreadDoctorCount': 0,
      },
      SetOptions(
        merge: true,
      ),
    );

    debugPrint(
      'CHAT DOCUMENT READY => chats/$id',
    );
  } catch (e) {
    debugPrint(
      'ENSURE CHAT DOCUMENT ERROR => $e',
    );

    rethrow;
  }
}

  // =========================================================
  // DOCTOR PROFILE REAL-TIME
  // =========================================================

  void _listenToDoctorProfile(
    String id,
  ) {
    _doctorSubscription?.cancel();

    _doctorSubscription =
        _firestore
            .collection('doctors')
            .doc(id)
            .snapshots()
            .listen(
      (snapshot) {
        if (!snapshot.exists) {
          return;
        }

        final Map<String, dynamic>
            data =
            snapshot.data() ?? {};

        final String name =
            data['name']
                    ?.toString()
                    .trim() ??
                '';

        if (name.isNotEmpty) {
          doctorName.value =
              name;
        }

        final String image =
            _getImageFromData(data);

        if (image.isNotEmpty) {
          doctorImage.value =
              image;
        }

        final String specialist =
            data['specialist']
                    ?.toString()
                    .trim() ??
                data['specialty']
                    ?.toString()
                    .trim() ??
                '';

        if (specialist.isNotEmpty) {
          doctorSpecialist.value =
              specialist;
        }
      },
      onError: (error) {
        debugPrint(
          'DOCTOR PROFILE REALTIME ERROR => $error',
        );
      },
    );
  }

  // =========================================================
  // DOCTOR PRESENCE
  //
  // paitent/{doctorId}
  // =========================================================

  void _listenToDoctorPresence(
    String id,
  ) {
    _doctorPresenceSubscription
        ?.cancel();

    _doctorPresenceSubscription =
        _firestore
            .collection('paitent')
            .doc(id)
            .snapshots()
            .listen(
      (snapshot) {
        if (!snapshot.exists) {
          doctorIsOnline.value =
              false;

          doctorLastSeen.value =
              null;

          return;
        }

        final Map<String, dynamic>
            data =
            snapshot.data() ?? {};

        doctorIsOnline.value =
            data['isOnline'] == true;

        doctorLastSeen.value =
            _parseTimestamp(
          data['lastSeen'],
        );
      },
      onError: (error) {
        debugPrint(
          'DOCTOR PRESENCE REALTIME ERROR => $error',
        );
      },
    );
  }

  // =========================================================
  // PATIENT REAL-TIME
  //
  // paitent/{patientId}
  // =========================================================

  void _listenToPatient() {
    _patientSubscription?.cancel();

    if (patientId.value.isEmpty) {
      return;
    }

    final String id =
        patientId.value;

    debugPrint(
      'STARTING PATIENT PRESENCE LISTENER => $id',
    );

    _patientSubscription =
        _firestore
            .collection('paitent')
            .doc(id)
            .snapshots()
            .listen(
      (snapshot) {
        if (!snapshot.exists) {
          patientIsOnline.value =
              false;

          patientLastSeen.value =
              null;

          return;
        }

        final Map<String, dynamic>
            data =
            snapshot.data() ?? {};

        final String name =
            data['name']
                    ?.toString()
                    .trim() ??
                '';

        if (name.isNotEmpty) {
          patientName.value =
              name;
        }

        final String image =
            _getImageFromData(data);

        if (image.isNotEmpty) {
          patientImage.value =
              image;
        }

        patientIsOnline.value =
            data['isOnline'] == true;

        patientLastSeen.value =
            _parseTimestamp(
          data['lastSeen'],
        );

        debugPrint(
          'PATIENT PRESENCE => '
          'uid=$id | '
          'online=${patientIsOnline.value} | '
          'lastSeen=${patientLastSeen.value}',
        );
      },
      onError: (error) {
        debugPrint(
          'PATIENT PRESENCE ERROR => $error',
        );
      },
    );
  }

  // =========================================================
  // PARSE TIMESTAMP
  // =========================================================

  DateTime? _parseTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // =========================================================
  // CHAT ID
  // =========================================================

  String chatId(
    String patientId,
    String doctorId,
  ) {
    return '${patientId}_$doctorId';
  }

  // =========================================================
  // CURRENT CHAT ID
  // =========================================================

  String get currentChatId {
    return chatId(
      patientId.value,
      doctorId.value,
    );
  }

  // =========================================================
  // LISTEN TO MESSAGES
  // =========================================================

  void _listenToMessages(
    String patientUid,
    String doctorUid,
  ) {
    _messageSubscription?.cancel();

    final String id =
        chatId(
      patientUid,
      doctorUid,
    );

    debugPrint(
      '========================================',
    );

    debugPrint(
      'CHAT MESSAGE PATH => chats/$id/messages',
    );

    debugPrint(
      'PATIENT ID => $patientUid',
    );

    debugPrint(
      'DOCTOR ID => $doctorUid',
    );

    debugPrint(
      '========================================',
    );

    _messageSubscription =
        _firestore
            .collection('chats')
            .doc(id)
            .collection('messages')
            .orderBy(
              'createdAt',
              descending: false,
            )
            .snapshots()
            .listen(
      (snapshot) async {
        final List<ChatMessage>
            loadedMessages =
            [];

        for (final doc
            in snapshot.docs) {
          loadedMessages.add(
            ChatMessage.fromMap(
              doc.id,
              doc.data(),
              currentUserId.value,
            ),
          );
        }

        messages.assignAll(
          loadedMessages,
        );

        final Set<String>
            existingIds =
            loadedMessages
                .map(
                  (message) =>
                      message.id,
                )
                .toSet();

        selectedMessageIds
            .removeWhere(
          (id) =>
              !existingIds
                  .contains(id),
        );

        selectedMessageIds.refresh();

        _calculateUnreadCount(
          loadedMessages,
        );

        isLoading.value =
            false;

        await _markIncomingMessagesAsRead(
          snapshot.docs,
        );

        _scrollToBottom();
      },
      onError: (error) {
        debugPrint(
          '========================================',
        );

        debugPrint(
          'CHAT STREAM ERROR => $error',
        );

        debugPrint(
          'CHAT PATH => chats/$id/messages',
        );

        debugPrint(
          '========================================',
        );

        isLoading.value =
            false;

        _error(
          'Unable to load chat messages.',
        );
      },
    );
  }

  // =========================================================
  // UNREAD COUNT
  // =========================================================

  void _calculateUnreadCount(
    List<ChatMessage> loadedMessages,
  ) {
    int count = 0;

    for (final message
        in loadedMessages) {
      if (message.isMe) {
        continue;
      }

      if (!message.isRead) {
        count++;
      }
    }

    unreadCount.value =
        count;
  }

  // =========================================================
  // MARK INCOMING AS READ
  // =========================================================

  Future<void>
      _markIncomingMessagesAsRead(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) async {
    final String uid =
        currentUserId.value;

    if (uid.isEmpty) {
      return;
    }

    final List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        unreadDocs =
        docs.where(
      (doc) {
        final Map<String, dynamic>
            data =
            doc.data();

        final String senderId =
            data['senderId']
                    ?.toString() ??
                '';

        if (senderId == uid) {
          return false;
        }

        final dynamic readByRaw =
            data['readBy'];

        if (readByRaw is List) {
          return !readByRaw.contains(uid);
        }

        return true;
      },
    ).toList();

    if (unreadDocs.isEmpty) {
      unreadCount.value =
          0;
      return;
    }

    try {
      for (
        int start = 0;
        start < unreadDocs.length;
        start += 450
      ) {
        final int end =
            (start + 450 <
                    unreadDocs.length)
                ? start + 450
                : unreadDocs.length;

        final WriteBatch batch =
            _firestore.batch();

        for (
          int i = start;
          i < end;
          i++
        ) {
          batch.update(
            unreadDocs[i].reference,
            {
              'readBy':
                  FieldValue.arrayUnion(
                [uid],
              ),
            },
          );
        }

        await batch.commit();
      }

      unreadCount.value =
          0;

      await _resetUnreadCounter();
    } catch (e) {
      debugPrint(
        'MARK READ ERROR => $e',
      );
    }
  }

  // =========================================================
  // RESET UNREAD
  // =========================================================

  Future<void>
      _resetUnreadCounter() async {
    if (patientId.value.isEmpty ||
        doctorId.value.isEmpty) {
      return;
    }

    try {
      final DocumentReference<
              Map<String, dynamic>>
          ref =
          _firestore
              .collection('chats')
              .doc(currentChatId);

      if (isDoctor) {
        await ref.set(
          {
            'unreadDoctorCount': 0,
          },
          SetOptions(
            merge: true,
          ),
        );
      } else {
        await ref.set(
          {
            'unreadPatientCount': 0,
          },
          SetOptions(
            merge: true,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'RESET UNREAD COUNTER ERROR => $e',
      );
    }
  }

  // =========================================================
  // SELECT MESSAGE
  // =========================================================

  void selectMessage(
    String messageId,
  ) {
    if (selectedMessageIds
        .contains(messageId)) {
      selectedMessageIds
          .remove(messageId);
    } else {
      selectedMessageIds
          .add(messageId);
    }

    selectedMessageIds.refresh();
  }

  // =========================================================
  // START SELECTION
  // =========================================================

  void startSelection(
    String messageId,
  ) {
    if (!selectedMessageIds
        .contains(messageId)) {
      selectedMessageIds
          .add(messageId);
    }

    selectedMessageIds.refresh();
  }

  // =========================================================
  // CLEAR SELECTION
  // =========================================================

  void clearSelection() {
    selectedMessageIds.clear();
    selectedMessageIds.refresh();
  }

  // =========================================================
  // SELECT ALL
  // =========================================================

  void selectAllMessages() {
    if (messages.isEmpty) {
      return;
    }

    if (isAllMessagesSelected) {
      clearSelection();
      return;
    }

    selectedMessageIds
      ..clear()
      ..addAll(
        messages.map(
          (message) =>
              message.id,
        ),
      );

    selectedMessageIds.refresh();
  }

  // =========================================================
  // DELETE SELECTED
  // =========================================================

  Future<bool>
      deleteSelectedMessages() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      _loginRequired();
      return false;
    }

    if (patientId.value.isEmpty ||
        doctorId.value.isEmpty) {
      _error(
        'Chat information is missing.',
      );

      return false;
    }

    if (selectedMessageIds.isEmpty) {
      return false;
    }

    if (isDeletingMessages.value) {
      return false;
    }

    final List<String>
        idsToDelete =
        selectedMessageIds.toList();

    try {
      isDeletingMessages.value =
          true;

      final CollectionReference<
              Map<String, dynamic>>
          messagesRef =
          _firestore
              .collection('chats')
              .doc(currentChatId)
              .collection('messages');

      for (
        int start = 0;
        start < idsToDelete.length;
        start += 450
      ) {
        final int end =
            (start + 450 <
                    idsToDelete.length)
                ? start + 450
                : idsToDelete.length;

        final WriteBatch batch =
            _firestore.batch();

        for (
          int i = start;
          i < end;
          i++
        ) {
          batch.delete(
            messagesRef.doc(
              idsToDelete[i],
            ),
          );
        }

        await batch.commit();
      }

      clearSelection();

      await _updateLastMessageAfterDelete(
        patientId.value,
        doctorId.value,
      );

      showSuccess(
        '${idsToDelete.length} message'
        '${idsToDelete.length == 1 ? '' : 's'} deleted.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'DELETE SELECTED MESSAGES ERROR => $e',
      );

      _error(
        'Unable to delete messages.',
      );

      return false;
    } finally {
      isDeletingMessages.value =
          false;
    }
  }

  // =========================================================
  // UPDATE LAST MESSAGE AFTER DELETE
  // =========================================================

  Future<void>
      _updateLastMessageAfterDelete(
    String patientUid,
    String doctorUid,
  ) async {
    try {
      final String id =
          chatId(
        patientUid,
        doctorUid,
      );

      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await _firestore
              .collection('chats')
              .doc(id)
              .collection('messages')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(1)
              .get();

      final DocumentReference<
              Map<String, dynamic>>
          chatRef =
          _firestore
              .collection('chats')
              .doc(id);

      if (snapshot.docs.isEmpty) {
        await chatRef.set(
          {
            'lastMessage': '',
            'lastMessageAt':
                FieldValue.delete(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );

        return;
      }

      final Map<String, dynamic>
          data =
          snapshot.docs.first.data();

      final String type =
          data['type']
                  ?.toString() ??
              'text';

      final String text =
          data['text']
                  ?.toString() ??
              '';

      final String lastMessage =
          type == 'image'
              ? '📷 Image'
              : text;

      await chatRef.set(
        {
          'lastMessage':
              lastMessage,
          'lastMessageAt':
              data['createdAt'],
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (e) {
      debugPrint(
        'UPDATE LAST MESSAGE ERROR => $e',
      );
    }
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  Future<void> sendMessage() async {
    final String text =
        messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final User? user =
        _auth.currentUser;

    if (user == null) {
      _loginRequired();
      return;
    }

    if (patientId.value.isEmpty ||
        doctorId.value.isEmpty) {
      _error(
        'Chat information is missing.',
      );

      return;
    }

    if (isSending.value) {
      return;
    }

    try {
      isSending.value =
          true;

      // =====================================================
      // MAKE SURE CHAT EXISTS
      // =====================================================

      await _ensureChatDocument();

      await _createMessage(
        user: user,
        type: 'text',
        text: text,
        imageUrl: '',
      );

      messageController.clear();

      _scrollToBottom(
        delay: const Duration(
          milliseconds: 150,
        ),
      );
    } catch (e) {
      debugPrint(
        'SEND MESSAGE ERROR => $e',
      );

      _error(
        'Unable to send message.',
      );
    } finally {
      isSending.value =
          false;
    }
  }

  // =========================================================
  // PICK IMAGE
  // =========================================================

  Future<void>
      pickAndSendImage() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      _loginRequired();
      return;
    }

    if (patientId.value.isEmpty ||
        doctorId.value.isEmpty) {
      _error(
        'Chat information is missing.',
      );

      return;
    }

    if (isUploadingImage.value) {
      return;
    }

    try {
      final XFile? picked =
          await _picker.pickImage(
        source:
            ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (picked == null) {
        return;
      }

      isUploadingImage.value =
          true;

      final String? imageUrl =
          await _uploadChatImage(
        File(picked.path),
        patientId.value,
      );

      if (imageUrl == null ||
          imageUrl.isEmpty) {
        return;
      }

      // =====================================================
      // MAKE SURE CHAT EXISTS
      // =====================================================

      await _ensureChatDocument();

      await _createMessage(
        user: user,
        type: 'image',
        text: '',
        imageUrl: imageUrl,
      );

      _scrollToBottom(
        delay: const Duration(
          milliseconds: 150,
        ),
      );
    } catch (e) {
      debugPrint(
        'CHAT IMAGE ERROR => $e',
      );

      _error(
        'Unable to upload image.',
      );
    } finally {
      isUploadingImage.value =
          false;
    }
  }

  // =========================================================
  // CLOUDINARY UPLOAD
  // =========================================================

  Future<String?>
      _uploadChatImage(
    File image,
    String patientUid,
  ) async {
    try {
      final Uri url =
          Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$_cloudName/image/upload',
      );

      final http.MultipartRequest
          request =
          http.MultipartRequest(
        'POST',
        url,
      );

      request.fields[
              'upload_preset'] =
          _uploadPreset;

      request.fields[
              'folder'] =
          'chat_images/'
          '$patientUid/'
          '${doctorId.value}';

      request.files.add(
        await http.MultipartFile
            .fromPath(
          'file',
          image.path,
        ),
      );

      final http.StreamedResponse
          response =
          await request.send();

      final String responseData =
          await response.stream
              .bytesToString();

      debugPrint(
        'CLOUDINARY CHAT STATUS => ${response.statusCode}',
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        debugPrint(
          'CLOUDINARY ERROR => $responseData',
        );

        _error(
          'Unable to upload image.',
        );

        return null;
      }

      dynamic decoded;

      try {
        decoded =
            jsonDecode(
          responseData,
        );
      } catch (_) {
        decoded = null;
      }

      if (decoded is Map) {
        final String secureUrl =
            decoded['secure_url']
                    ?.toString() ??
                '';

        if (secureUrl.isNotEmpty) {
          return secureUrl;
        }
      }

      _error(
        'Unable to upload image.',
      );

      return null;
    } catch (e) {
      debugPrint(
        'CLOUDINARY UPLOAD ERROR => $e',
      );

      _error(
        'Unable to upload image.',
      );

      return null;
    }
  }

  // =========================================================
  // CREATE MESSAGE
  // =========================================================

  Future<void> _createMessage({
    required User user,
    required String type,
    required String text,
    required String imageUrl,
  }) async {
    if (patientId.value.isEmpty ||
        doctorId.value.isEmpty) {
      throw Exception(
        'Chat participants are missing.',
      );
    }

    // =======================================================
    // ENSURE PARENT CHAT EXISTS
    // =======================================================

    await _ensureChatDocument();

    final String id =
        currentChatId;

    final DocumentReference<
            Map<String, dynamic>>
        chatRef =
        _firestore
            .collection('chats')
            .doc(id);

    final DocumentReference<
            Map<String, dynamic>>
        messageRef =
        chatRef
            .collection('messages')
            .doc();

    final WriteBatch batch =
        _firestore.batch();

    final String lastMessage =
        type == 'image'
            ? '📷 Image'
            : text;

    // =======================================================
    // SENDER TYPE
    // =======================================================

    final String senderType =
        isDoctor
            ? 'doctor'
            : 'patient';

    // =======================================================
    // CHAT DATA
    // =======================================================

    final Map<String, dynamic>
        chatData = {
      // -----------------------------------------------------
      // PATIENT
      // -----------------------------------------------------

      'patientId':
          patientId.value,

      'patientName':
          patientName.value,

      'patientImage':
          patientImage.value,

      // -----------------------------------------------------
      // DOCTOR
      // -----------------------------------------------------

      'doctorId':
          doctorId.value,

      'doctorName':
          doctorName.value,

      'doctorImage':
          doctorImage.value,

      'doctorSpecialist':
          doctorSpecialist.value,

      // -----------------------------------------------------
      // LAST MESSAGE
      // -----------------------------------------------------

      'lastMessage':
          lastMessage,

      'lastMessageAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    // =======================================================
    // UNREAD
    // =======================================================

    if (senderType == 'doctor') {
      chatData[
          'unreadPatientCount'] =
          FieldValue.increment(1);
    } else {
      chatData[
          'unreadDoctorCount'] =
          FieldValue.increment(1);
    }

    // =======================================================
    // UPDATE CHAT
    // =======================================================

    batch.set(
      chatRef,
      chatData,
      SetOptions(
        merge: true,
      ),
    );

    // =======================================================
    // CREATE MESSAGE
    // =======================================================

    batch.set(
      messageRef,
      {
        'senderId':
            user.uid,

        'senderType':
            senderType,

        'text':
            text,

        'type':
            type,

        'imageUrl':
            imageUrl,

        'createdAt':
            FieldValue.serverTimestamp(),

        'readBy':
            [user.uid],
      },
    );

    await batch.commit();

    debugPrint(
      'MESSAGE SENT SUCCESSFULLY => '
      'chat=$id '
      'senderType=$senderType',
    );
  }

  // =========================================================
  // MARK CHAT AS READ
  // =========================================================

  Future<void> markChatAsRead() async {
    if (currentUserId.value.isEmpty) {
      return;
    }

    if (patientId.value.isEmpty ||
        doctorId.value.isEmpty) {
      return;
    }

    try {
      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await _firestore
              .collection('chats')
              .doc(currentChatId)
              .collection('messages')
              .get();

      await _markIncomingMessagesAsRead(
        snapshot.docs,
      );
    } catch (e) {
      debugPrint(
        'MARK CHAT READ ERROR => $e',
      );
    }
  }

  // =========================================================
  // UNREAD COUNT STREAM
  // =========================================================

  Stream<int> unreadCountStream({
    required String userId,
    required String doctorId,
    required bool forDoctor,
  }) {
    return _firestore
        .collection('chats')
        .doc(
          chatId(
            userId,
            doctorId,
          ),
        )
        .snapshots()
        .map(
      (snapshot) {
        if (!snapshot.exists) {
          return 0;
        }

        final Map<String, dynamic>
            data =
            snapshot.data() ?? {};

        final dynamic value =
            forDoctor
                ? data[
                    'unreadDoctorCount']
                : data[
                    'unreadPatientCount'];

        if (value is int) {
          return value;
        }

        if (value is num) {
          return value.toInt();
        }

        return 0;
      },
    );
  }

  // =========================================================
  // SCROLL
  // =========================================================

  void _scrollToBottom({
    Duration delay =
        const Duration(
      milliseconds: 100,
    ),
  }) {
    Future.delayed(
      delay,
      () {
        if (!scrollController
            .hasClients) {
          return;
        }

        scrollController
            .animateTo(
          scrollController
              .position
              .maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 250,
          ),
          curve:
              Curves.easeOut,
        );
      },
    );
  }

  // =========================================================
  // DOCTOR STATUS
  // =========================================================

  String get doctorStatusText {
    if (doctorIsOnline.value) {
      return 'Online';
    }

    final DateTime? lastSeen =
        doctorLastSeen.value;

    if (lastSeen == null) {
      return 'Offline';
    }

    return 'Last seen '
        '${formatLastSeen(lastSeen)}';
  }

  // =========================================================
  // PATIENT STATUS
  // =========================================================

  String get patientStatusText {
    if (patientIsOnline.value) {
      return 'Online';
    }

    final DateTime? lastSeen =
        patientLastSeen.value;

    if (lastSeen == null) {
      return 'Offline';
    }

    return 'Last seen '
        '${formatLastSeen(lastSeen)}';
  }

  // =========================================================
  // FORMAT LAST SEEN
  // =========================================================

  String formatLastSeen(
    DateTime time,
  ) {
    final DateTime now =
        DateTime.now();

    final DateTime today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime messageDate =
        DateTime(
      time.year,
      time.month,
      time.day,
    );

    final Duration difference =
        today.difference(
      messageDate,
    );

    final String timeText =
        formatTime(time);

    if (difference.inDays == 0) {
      return 'today at $timeText';
    }

    if (difference.inDays == 1) {
      return 'yesterday at $timeText';
    }

    if (time.year == now.year) {
      return '${time.day.toString().padLeft(2, '0')}/'
          '${time.month.toString().padLeft(2, '0')}'
          ' at $timeText';
    }

    return '${time.day.toString().padLeft(2, '0')}/'
        '${time.month.toString().padLeft(2, '0')}/'
        '${time.year} at $timeText';
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

  String formatTime(
    DateTime time,
  ) {
    int hour =
        time.hour;

    final String minute =
        time.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String period =
        hour >= 12
            ? 'pm'
            : 'am';

    hour =
        hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  // =========================================================
  // SUCCESS
  // =========================================================

  void showSuccess(
    String message,
  ) {
    Get.snackbar(
      'Success',
      message,
      snackPosition:
          SnackPosition.TOP,
      backgroundColor:
          const Color(
        0xFF2196F3,
      ),
      colorText:
          Colors.white,
      margin:
          const EdgeInsets.all(
        12,
      ),
      borderRadius: 10,
      duration:
          const Duration(
        seconds: 2,
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  void _error(
    String message,
  ) {
    Get.snackbar(
      'Error',
      message,
      snackPosition:
          SnackPosition.TOP,
      backgroundColor:
          Colors.red,
      colorText:
          Colors.white,
      margin:
          const EdgeInsets.all(
        12,
      ),
      borderRadius: 10,
      duration:
          const Duration(
        seconds: 3,
      ),
    );
  }

  // =========================================================
  // LOGIN REQUIRED
  // =========================================================

  void _loginRequired() {
    Get.snackbar(
      'Login Required',
      'Please login first.',
      snackPosition:
          SnackPosition.TOP,
      backgroundColor:
          Colors.red,
      colorText:
          Colors.white,
      margin:
          const EdgeInsets.all(
        12,
      ),
      borderRadius: 10,
    );
  }

  // =========================================================
  // BACK
  // =========================================================

  void goBack() {
    if (isSelectionMode) {
      clearSelection();
      return;
    }

    if (Get.isOverlaysOpen) {
      return;
    }

    Get.back();
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    _doctorSubscription?.cancel();
    _doctorPresenceSubscription?.cancel();
    _patientSubscription?.cancel();
    _messageSubscription?.cancel();

    messageController.dispose();
    scrollController.dispose();

    super.onClose();
  }
}

// =============================================================
// CHAT MESSAGE
// =============================================================

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime? createdAt;
  final String type;
  final String imageUrl;
  final String senderId;
  final String senderType;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
    required this.type,
    required this.imageUrl,
    required this.senderId,
    required this.senderType,
    required this.isRead,
  });

  factory ChatMessage.fromMap(
    String id,
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final dynamic rawTimestamp =
        data['createdAt'];

    Timestamp? timestamp;

    if (rawTimestamp is Timestamp) {
      timestamp =
          rawTimestamp;
    }

    final String senderId =
        data['senderId']
                ?.toString() ??
            '';

    final String senderType =
        data['senderType']
                ?.toString() ??
            '';

    bool read = false;

    final dynamic readBy =
        data['readBy'];

    if (readBy is List) {
      read =
          readBy.contains(
        currentUserId,
      );
    }

    return ChatMessage(
      id: id,
      text:
          data['text']
                  ?.toString() ??
              '',
      isMe:
          senderId ==
          currentUserId,
      createdAt:
          timestamp?.toDate(),
      type:
          data['type']
                  ?.toString() ??
              'text',
      imageUrl:
          data['imageUrl']
                  ?.toString() ??
              '',
      senderId:
          senderId,
      senderType:
          senderType,
      isRead:
          read,
    );
  }

  // =========================================================
  // FORMATTED TIME
  // =========================================================

  String get formattedTime {
    if (createdAt == null) {
      return '';
    }

    final DateTime time =
        createdAt!;

    int hour =
        time.hour;

    final String minute =
        time.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String period =
        hour >= 12
            ? 'pm'
            : 'am';

    hour =
        hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  // =========================================================
  // FORMATTED DATE
  // =========================================================

  String get formattedDate {
    if (createdAt == null) {
      return '';
    }

    final DateTime time =
        createdAt!;

    final String day =
        time.day
            .toString()
            .padLeft(2, '0');

    final String month =
        time.month
            .toString()
            .padLeft(2, '0');

    return '$day/$month/${time.year}';
  }

  // =========================================================
  // DISPLAY TIME
  // =========================================================

  String get displayTime {
    return formattedTime;
  }
}