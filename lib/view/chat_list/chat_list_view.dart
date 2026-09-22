import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/chat/chat_view.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({
    super.key,
  });

  @override
  State<ChatListView> createState() =>
      _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
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

  // =========================================================
  // SELECTION
  // =========================================================

  final Set<String> selectedChatIds = {};

  bool isSelectionMode = false;

  bool isDeleting = false;

  // =========================================================
  // ROLE
  // =========================================================

  String currentRole = 'patient';

  bool isLoadingRole = true;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _roleSubscription;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  // =========================================================
  // LOAD CURRENT USER ROLE
  // =========================================================

 Future<void> _loadRole() async {
  final User? user =
      FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (mounted) {
      setState(() {
        isLoadingRole = false;
      });
    }
    return;
  }

  try {
    _roleSubscription =
        FirebaseFirestore.instance
            .collection('paitent')
            .doc(user.uid)
            .snapshots()
            .listen(
      (snapshot) {
        final Map<String, dynamic> data =
            snapshot.data() ?? {};

        final String role =
            data['role']
                    ?.toString()
                    .trim()
                    .toLowerCase() ??
                'patient';

        debugPrint(
          '========================================',
        );

        debugPrint(
          'CHAT LIST CURRENT UID => ${user.uid}',
        );

        debugPrint(
          'CHAT LIST FIRESTORE ROLE => "$role"',
        );

        debugPrint(
          '========================================',
        );

        if (!mounted) return;

        setState(() {
          // IMPORTANT:
          // Use actual Firestore role.
          currentRole = role;
          isLoadingRole = false;
        });
      },
      onError: (error) {
        debugPrint(
          'CHAT LIST ROLE ERROR: $error',
        );

        if (!mounted) return;

        setState(() {
          currentRole = 'patient';
          isLoadingRole = false;
        });
      },
    );
  } catch (e) {
    debugPrint(
      'LOAD ROLE ERROR: $e',
    );

    if (!mounted) return;

    setState(() {
      currentRole = 'patient';
      isLoadingRole = false;
    });
  }
}

  // =========================================================
  // ROLE HELPERS
  // =========================================================

  bool get isDoctor =>
      currentRole == 'doctor';

  bool get isAdmin =>
      currentRole == 'admin';

  bool get isUser =>
      !isDoctor && !isAdmin;

  // =========================================================
  // CHAT QUERY
  // =========================================================

 Stream<QuerySnapshot<Map<String, dynamic>>>
    _chatStream(String uid) {
  if (isDoctor) {
    debugPrint(
      'CHAT LIST QUERY => doctorId = $uid',
    );

    return FirebaseFirestore
        .instance
        .collection('chats')
        .where(
          'doctorId',
          isEqualTo: uid,
        )
        .snapshots();
  }

  debugPrint(
    'CHAT LIST QUERY => patientId = $uid',
  );

  return FirebaseFirestore
      .instance
      .collection('chats')
      .where(
        'patientId',
        isEqualTo: uid,
      )
      .snapshots();
}

  // =========================================================
  // SELECT CHAT
  // =========================================================

  void _selectChat(
    String chatId,
  ) {
    setState(() {
      if (selectedChatIds.contains(chatId)) {
        selectedChatIds.remove(chatId);
      } else {
        selectedChatIds.add(chatId);
      }

      isSelectionMode =
          selectedChatIds.isNotEmpty;
    });
  }

  // =========================================================
  // START SELECTION
  // =========================================================

  void _startSelection(
    String chatId,
  ) {
    setState(() {
      isSelectionMode = true;

      selectedChatIds.add(
        chatId,
      );
    });
  }

  // =========================================================
  // CLEAR
  // =========================================================

  void _clearSelection() {
    setState(() {
      selectedChatIds.clear();
      isSelectionMode = false;
    });
  }

  // =========================================================
  // SELECT ALL
  // =========================================================

  void _selectAll(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    setState(() {
      if (selectedChatIds.length ==
          docs.length) {
        selectedChatIds.clear();
        isSelectionMode = false;
      } else {
        selectedChatIds
          ..clear()
          ..addAll(
            docs.map(
              (doc) => doc.id,
            ),
          );

        isSelectionMode = true;
      }
    });
  }

  // =========================================================
  // DELETE CONFIRMATION
  // =========================================================

  void _showDeleteConfirmation() {
    if (selectedChatIds.isEmpty) {
      return;
    }

    final int count =
        selectedChatIds.length;

    Get.dialog(
      AlertDialog(
        backgroundColor:
            Colors.white,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        title: const Text(
          'Delete Chat',
          style: TextStyle(
            color: darkText,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        content: Text(
          count == 1
              ? 'Are you sure you want to delete this chat?'
              : 'Are you sure you want to delete these $count chats?',
          style: const TextStyle(
            color: greyText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                () => Get.back(),
            child:
                const Text(
              'Cancel',
              style: TextStyle(
                color: greyText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed:
                isDeleting
                    ? null
                    : () async {
                        Get.back();

                        await
                            _deleteSelectedChats();
                      },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
              foregroundColor:
                  Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
            child:
                const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DELETE SELECTED CHATS
  // =========================================================

  Future<void>
      _deleteSelectedChats() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
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
      );

      return;
    }

    if (selectedChatIds.isEmpty ||
        isDeleting) {
      return;
    }

    try {
      setState(() {
        isDeleting = true;
      });

      final List<String> ids =
          selectedChatIds.toList();

      for (
        int start = 0;
        start < ids.length;
        start += 450
      ) {
        final int end =
            (start + 450 < ids.length)
                ? start + 450
                : ids.length;

        final WriteBatch batch =
            FirebaseFirestore
                .instance
                .batch();

        for (
          int i = start;
          i < end;
          i++
        ) {
          final DocumentReference<
                  Map<String, dynamic>>
              chatRef =
              FirebaseFirestore
                  .instance
                  .collection(
                    'chats',
                  )
                  .doc(
                    ids[i],
                  );

          batch.delete(
            chatRef,
          );
        }

        await batch.commit();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        selectedChatIds.clear();
        isSelectionMode = false;
        isDeleting = false;
      });

      Get.snackbar(
        'Success',
        ids.length == 1
            ? 'Chat deleted successfully.'
            : '${ids.length} chats deleted successfully.',
        snackPosition:
            SnackPosition.TOP,
        backgroundColor:
            blue,
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
    } catch (e) {
      debugPrint(
        'DELETE CHAT ERROR: $e',
      );

      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }

      Get.snackbar(
        'Error',
        'Unable to delete chat.',
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
  }

  // =========================================================
  // BACK
  // =========================================================

  Future<bool> _onWillPop() async {
    if (isSelectionMode) {
      _clearSelection();
      return false;
    }

    return true;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor:
            background,
        appBar: AppBar(
          backgroundColor:
              Colors.white,
          elevation: 0,
          foregroundColor:
              darkText,
          title:
              const Text(
            'My Chats',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width:
                    Get.width * .200,
                height:
                    Get.width * .200,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFD9F0FF),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: blue,
                  size:
                      Get.width * .100,
                ),
              ),
              SizedBox(
                height:
                    Get.height * .018,
              ),
              Text(
                'Please login first.',
                style:
                    TextStyle(
                  color:
                      darkText,
                  fontSize:
                      Get.width * .032,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isLoadingRole) {
      return Scaffold(
        backgroundColor:
            background,
        appBar: AppBar(
          backgroundColor:
              Colors.white,
          elevation: 0,
          foregroundColor:
              darkText,
          title: Text(
            'My Chats',
            style:
                TextStyle(
              color:
                  darkText,
              fontSize:
                  Get.width * .040,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(
            color: blue,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop:
          _onWillPop,
      child: Scaffold(
        backgroundColor:
            background,
        appBar:
            _buildAppBar(),
        body:
            StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
          stream:
              _chatStream(
            user.uid,
          ),
          builder:
              (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color: blue,
                ),
              );
            }

            if (snapshot.hasError) {
              return _errorView(
                snapshot.error
                    .toString(),
              );
            }

            final List<
                    QueryDocumentSnapshot<
                        Map<String, dynamic>>>
                docs =
                snapshot.data?.docs ??
                    [];

            if (docs.isEmpty) {
              return _emptyView();
            }

            final List<
                    QueryDocumentSnapshot<
                        Map<String, dynamic>>>
                sortedDocs =
                List.from(docs);

            sortedDocs.sort(
              (
                a,
                b,
              ) {
                final Timestamp?
                    timeA =
                    _getTimestamp(
                  a.data()['updatedAt'],
                );

                final Timestamp?
                    timeB =
                    _getTimestamp(
                  b.data()['updatedAt'],
                );

                if (timeA == null &&
                    timeB == null) {
                  return 0;
                }

                if (timeA == null) {
                  return 1;
                }

                if (timeB == null) {
                  return -1;
                }

                return timeB.compareTo(
                  timeA,
                );
              },
            );

            return RefreshIndicator(
              color: blue,
              onRefresh: () async {
                await Future.delayed(
                  const Duration(
                    milliseconds: 400,
                  ),
                );
              },
              child:
                  ListView.builder(
                padding:
                    EdgeInsets.all(
                  Get.width * .040,
                ),
                physics:
                    const AlwaysScrollableScrollPhysics(
                  parent:
                      BouncingScrollPhysics(),
                ),
                itemCount:
                    sortedDocs.length,
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final doc =
                      sortedDocs[index];

                  return _ChatRealtimeItem(
                    key: ValueKey(
                      doc.id,
                    ),
                    chatId:
                        doc.id,
                    chatData:
                        doc.data(),
                    isDoctor:
                        isDoctor,
                    isSelectionMode:
                        isSelectionMode,
                    isSelected:
                        selectedChatIds
                            .contains(
                      doc.id,
                    ),
                    onTap: () {
                      if (isSelectionMode) {
                        _selectChat(
                          doc.id,
                        );
                      }
                    },
                    onLongPress: () {
                      _startSelection(
                        doc.id,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget
      _buildAppBar() {
    if (!isSelectionMode) {
      return AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,
        foregroundColor:
            darkText,
        title: Text(
          'My Chats',
          style:
              TextStyle(
            color:
                darkText,
            fontSize:
                Get.width * .040,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor:
          Colors.white,
      elevation: 0,
      leading:
          IconButton(
        onPressed:
            _clearSelection,
        icon:
            Icon(
          Icons.close,
          color:
              darkText,
          size:
              Get.width * .065,
        ),
      ),
      title: Text(
        '${selectedChatIds.length} selected',
        style:
            TextStyle(
          color:
              darkText,
          fontSize:
              Get.width * .035,
          fontWeight:
              FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          tooltip:
              'Select all',
          onPressed:
              () async {
            final User? user =
                FirebaseAuth.instance
                    .currentUser;

            if (user == null) {
              return;
            }

            Query<Map<String, dynamic>>
                query =
                FirebaseFirestore
                    .instance
                    .collection(
                      'chats',
                    );

            if (isDoctor) {
              query = query.where(
                'doctorId',
                isEqualTo:
                    user.uid,
              );
            } else {
              query = query.where(
                'patientId',
                isEqualTo:
                    user.uid,
              );
            }

            final snapshot =
                await query.get();

            _selectAll(
              snapshot.docs,
            );
          },
          icon:
              Icon(
            Icons.select_all,
            color:
                blue,
            size:
                Get.width * .060,
          ),
        ),
        IconButton(
          tooltip:
              'Delete',
          onPressed:
              selectedChatIds
                          .isEmpty ||
                      isDeleting
                  ? null
                  : _showDeleteConfirmation,
          icon:
              isDeleting
                  ? SizedBox(
                      width:
                          Get.width * .050,
                      height:
                          Get.width * .050,
                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.red,
                      ),
                    )
                  : Icon(
                      Icons.delete_outline,
                      color:
                          selectedChatIds
                                  .isEmpty
                              ? greyText
                              : Colors.red,
                      size:
                          Get.width * .065,
                    ),
        ),
        SizedBox(
          width:
              Get.width * .015,
        ),
      ],
    );
  }

  // =========================================================
  // TIMESTAMP
  // =========================================================

  Timestamp? _getTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value;
    }

    return null;
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _emptyView() {
    final String message =
        isDoctor
            ? 'No patient conversations yet.'
            : 'Start a conversation with a doctor.';

    return Center(
      child:
          Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width:
                Get.width * .200,
            height:
                Get.width * .200,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFD9F0FF),
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color:
                  blue,
              size:
                  Get.width * .100,
            ),
          ),
          SizedBox(
            height:
                Get.height * .018,
          ),
          Text(
            'No chats yet',
            style:
                TextStyle(
              color:
                  darkText,
              fontSize:
                  Get.width * .035,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          SizedBox(
            height:
                Get.height * .008,
          ),
          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  greyText,
              fontSize:
                  Get.width * .025,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _errorView(
    String error,
  ) {
    return Center(
      child:
          Padding(
        padding:
            EdgeInsets.all(
          Get.width * .060,
        ),
        child:
            Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color:
                  Colors.red,
              size:
                  Get.width * .140,
            ),
            SizedBox(
              height:
                  Get.height * .018,
            ),
            Text(
              'Unable to load chats.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    darkText,
                fontSize:
                    Get.width * .034,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(
              height:
                  Get.height * .010,
            ),
            Text(
              'Please check your Firebase connection '
              'and Firestore permissions.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    greyText,
                fontSize:
                    Get.width * .025,
              ),
            ),
            SizedBox(
              height:
                  Get.height * .020,
            ),
            ElevatedButton(
              onPressed:
                  () {
                setState(() {});
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    blue,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child:
                  const Text(
                'Try Again',
              ),
            ),
            SizedBox(
              height:
                  Get.height * .020,
            ),
            ExpansionTile(
              title:
                  Text(
                'Firebase error details',
                style:
                    TextStyle(
                  color:
                      greyText,
                  fontSize:
                      Get.width * .023,
                ),
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  child:
                      SelectableText(
                    error,
                    style:
                        TextStyle(
                      color:
                          Colors.red,
                      fontSize:
                          Get.width * .020,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _roleSubscription?.cancel();
    super.dispose();
  }
}

// =============================================================
// REAL-TIME ROLE-BASED CHAT ITEM
// =============================================================

class _ChatRealtimeItem
    extends StatelessWidget {
  const _ChatRealtimeItem({
    super.key,
    required this.chatId,
    required this.chatData,
    required this.isDoctor,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final String chatId;

  final Map<String, dynamic>
      chatData;

  final bool isDoctor;

  final bool isSelectionMode;

  final bool isSelected;

  final VoidCallback onTap;

  final VoidCallback onLongPress;

  static const Color blue =
      Color(0xFF2196F3);

  static const Color darkText =
      Color(0xFF172534);

  static const Color greyText =
      Color(0xFF647587);

  static const Color borderColor =
      Color(0xFFDDE3E9);




 int _getUnreadCount(
  Map<String, dynamic> data,
) {
  dynamic value;

  if (isDoctor) {
    // Doctor receives message from patient
    value = data['unreadDoctorCount'];

    // Old field compatibility
    if (value == null) {
      value = data['doctorUnreadCount'];
    }

    if (value == null) {
      value = data['unreadForDoctor'];
    }

    if (value == null) {
      value = data['unreadCountDoctor'];
    }
  } else {
    // User receives message from doctor
    value = data['unreadUserCount'];

    // Optional old field compatibility
    if (value == null) {
      value = data['userUnreadCount'];
    }

    if (value == null) {
      value = data['unreadForUser'];
    }

    if (value == null) {
      value = data['unreadCountUser'];
    }
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  return 0;
}

  // =========================================================
  // GET OTHER PARTICIPANT ID
  // =========================================================

  String get otherParticipantId {
   if (isDoctor) {
  return chatData['patientId']
          ?.toString() ??
      '';
}

    return chatData['doctorId']
            ?.toString() ??
        '';
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (otherParticipantId.isEmpty) {
      return _buildCard(
        name: isDoctor
            ? chatData['patientName']
                    ?.toString() ??
                chatData['userName']
                    ?.toString() ??
                'Patient'
            : chatData['doctorName']
                    ?.toString() ??
                'Doctor',
        image: isDoctor
            ? chatData['patientImage']
                    ?.toString() ??
                chatData['userImage']
                    ?.toString() ??
                ''
            : chatData['doctorImage']
                    ?.toString() ??
                '',
        specialist: isDoctor
            ? ''
            : chatData['doctorSpecialist']
                    ?.toString() ??
                '',
        isOnline: false,
        lastSeen: null,
        unreadCount: _getUnreadCount(chatData),
        lastMessage:
            chatData['lastMessage']
                    ?.toString() ??
                '',
      );
    }

    // =========================================================
    // DOCTOR SIDE
    // PATIENT DATA FROM users/{patientId}
    // =========================================================

    if (isDoctor) {
      return StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream:
            FirebaseFirestore
                .instance
              .collection('paitent')
                .doc(
                  otherParticipantId,
                )
                .snapshots(),
        builder:
            (
          context,
          snapshot,
        ) {
          final Map<String, dynamic>
              patientData =
              snapshot.data?.data() ??
                  {};

          final String name =
              _firstNonEmpty([
            patientData['name'],
            chatData['patientName'],
            chatData['userName'],
          ]) ??
                  'Patient';

          final String image =
              _firstNonEmpty([
            patientData['imageUrl'],
            patientData['photoUrl'],
            patientData['image'],
            chatData['patientImage'],
            chatData['userImage'],
          ]) ??
                  '';

          final bool isOnline =
              patientData['isOnline'] ==
                  true;

          final Timestamp? lastSeen =
              _getTimestamp(
            patientData['lastSeen'],
          );

          return _buildCard(
            name: name,
            image: image,
            specialist: '',
            isOnline: isOnline,
            lastSeen: lastSeen,
            unreadCount: _getUnreadCount(chatData),
            lastMessage:
                chatData['lastMessage']
                        ?.toString() ??
                    '',
          );
        },
      );
    }

    // =========================================================
    // USER SIDE
    // DOCTOR PROFILE FROM doctors/{doctorId}
    // =========================================================

    return StreamBuilder<
        DocumentSnapshot<
            Map<String, dynamic>>>(
      stream:
          FirebaseFirestore
              .instance
              .collection('doctors')
              .doc(
                otherParticipantId,
              )
              .snapshots(),
      builder:
          (
        context,
        doctorSnapshot,
      ) {
        final Map<String, dynamic>
            doctorData =
            doctorSnapshot.data?.data() ??
                {};

        return StreamBuilder<
            DocumentSnapshot<
                Map<String, dynamic>>>(
          stream:
              FirebaseFirestore
                  .instance
                 .collection('paitent')
                  .doc(
                    otherParticipantId,
                  )
                  .snapshots(),
          builder:
              (
            context,
            presenceSnapshot,
          ) {
            final Map<String, dynamic>
                presenceData =
                presenceSnapshot
                        .data
                        ?.data() ??
                    {};

            final String name =
                _firstNonEmpty([
              doctorData['name'],
              chatData['doctorName'],
              chatData['name'],
            ]) ??
                    'Doctor';

            final String image =
                _firstNonEmpty([
              doctorData['imageUrl'],
              doctorData['photoUrl'],
              doctorData['image'],
              chatData['doctorImage'],
            ]) ??
                    '';

            final String specialist =
                _firstNonEmpty([
              doctorData['specialist'],
              doctorData['specialty'],
              chatData['doctorSpecialist'],
            ]) ??
                    '';

            final bool isOnline =
                presenceData['isOnline'] ==
                    true;

            final Timestamp? lastSeen =
                _getTimestamp(
              presenceData['lastSeen'],
            );

            return _buildCard(
              name: name,
              image: image,
              specialist: specialist,
              isOnline: isOnline,
              lastSeen: lastSeen,
              unreadCount: _getUnreadCount(chatData),
              lastMessage:
                  chatData['lastMessage']
                          ?.toString() ??
                      '',
            );
          },
        );
      },
    );
  }

  // =========================================================
  // CARD
  // =========================================================

  Widget _buildCard({
    required String name,
    required String image,
    required String specialist,
    required bool isOnline,
    required Timestamp? lastSeen,
    required String lastMessage,
    required int unreadCount,
  }) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onTap();
          return;
        }

        if (chatId.isEmpty) {
          return;
        }

        final Map<String, dynamic>
            participantData;

        if (isDoctor) {
          participantData = {
            'id':
                otherParticipantId,
            'userId':
                otherParticipantId,
            'patientId':
                otherParticipantId,
            'name':
                name,
            'patientName':
                name,
            'userName':
                name,
            'imageUrl':
                image,
            'patientImage':
                image,
            'userImage':
                image,
            'isOnline':
                isOnline,
            'lastSeen':
                lastSeen,
          };
        } else {
          participantData = {
            'id':
                otherParticipantId,
            'doctorId':
                otherParticipantId,
            'name':
                name,
            'imageUrl':
                image,
            'specialist':
                specialist,
            'doctorSpecialist':
                specialist,
            'isOnline':
                isOnline,
            'lastSeen':
                lastSeen,
          };
        }

        Get.to(
          () => ChatView(
            doctor:
                participantData,
          ),
          transition:
              Transition.rightToLeft,
        );
      },
      onLongPress:
          onLongPress,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        margin:
            EdgeInsets.only(
          bottom:
              Get.height * .015,
        ),
        padding:
            EdgeInsets.all(
          Get.width * .030,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? const Color(
                  0xFFE6F4FF,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            Get.width * .030,
          ),
          border:
              Border.all(
            color: isSelected
                ? blue
                : borderColor,
            width:
                isSelected
                    ? 1.5
                    : 1,
          ),
        ),
        child:
            Row(
          children: [
            // =================================================
            // SELECTION
            // =================================================

            if (isSelectionMode)
              Container(
                width:
                    Get.width * .065,
                height:
                    Get.width * .065,
                margin:
                    EdgeInsets.only(
                  right:
                      Get.width * .020,
                ),
                decoration:
                    BoxDecoration(
                  color: isSelected
                      ? blue
                      : Colors.transparent,
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color: isSelected
                        ? blue
                        : borderColor,
                    width:
                        isSelected
                            ? 2
                            : 1.5,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(
                            Icons.check,
                            color:
                                Colors.white,
                            size:
                                Get.width * .040,
                          )
                        : null,
              ),

            // =================================================
            // PROFILE IMAGE
            // =================================================

            Stack(
              clipBehavior:
                  Clip.none,
              children: [
                Container(
                  width:
                      Get.width * .120,
                  height:
                      Get.width * .120,
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xFFD9F0FF),
                    shape:
                        BoxShape.circle,
                  ),
                  clipBehavior:
                      Clip.antiAlias,
                  child:
                      image.isEmpty
                          ? Icon(
                              Icons.person,
                              color:
                                  blue,
                              size:
                                  Get.width * .065,
                            )
                          : Image.network(
                              image,
                              fit:
                                  BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Icon(
                                  Icons.person,
                                  color:
                                      blue,
                                  size:
                                      Get.width * .065,
                                );
                              },
                            ),
                ),

                // =================================================
                // ONLINE INDICATOR
                // =================================================

                if (isOnline)
                  Positioned(
                    right:
                        0,
                    bottom:
                        0,
                    child:
                        Container(
                      width:
                          Get.width * .030,
                      height:
                          Get.width * .030,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.green,
                        shape:
                            BoxShape.circle,
                        border:
                            Border.all(
                          color:
                              Colors.white,
                          width:
                              2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(
              width:
                  Get.width * .030,
            ),

            // =================================================
            // INFORMATION
            // =================================================

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    name,
                    maxLines:
                        1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      color:
                          darkText,
                      fontSize:
                          Get.width * .030,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  // =================================================
                  // SPECIALIST
                  // =================================================

                  if (specialist
                      .isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.only(
                        top:
                            Get.height * .004,
                      ),
                      child:
                          Text(
                        specialist,
                        maxLines:
                            1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            TextStyle(
                          color:
                              greyText,
                          fontSize:
                              Get.width * .022,
                        ),
                      ),
                    ),

                  // =================================================
                  // ONLINE / LAST SEEN
                  // =================================================

                  Padding(
                    padding:
                        EdgeInsets.only(
                      top:
                          Get.height * .004,
                    ),
                    child:
                        Text(
                      isOnline
                          ? 'Online'
                          : _formatLastSeen(
                              lastSeen,
                            ),
                      maxLines:
                          1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            isOnline
                                ? Colors.green
                                : greyText,
                        fontSize:
                            Get.width * .020,
                        fontWeight:
                            isOnline
                                ? FontWeight.w600
                                : FontWeight.w400,
                      ),
                    ),
                  ),

                  // =================================================
                  // LAST MESSAGE
                  // =================================================

                  if (lastMessage
                      .isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.only(
                        top:
                            Get.height * .005,
                      ),
                      child:
                          Text(
                        lastMessage,
                        maxLines:
                            1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            TextStyle(
                          color:
                              greyText,
                          fontSize:
                              Get.width * .023,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // =================================================
            // RIGHT ICON
            // =================================================

            if (!isSelectionMode)
  unreadCount > 0
      ? Container(
          constraints: BoxConstraints(
            minWidth: Get.width * .055,
            minHeight: Get.width * .055,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * .015,
            vertical: Get.width * .008,
          ),
          decoration: const BoxDecoration(
           color: Colors.green,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            unreadCount > 99
                ? '99+'
                : unreadCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: Get.width * .020,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      : Icon(
          Icons.chevron_right,
          color: greyText,
          size: Get.width * .060,
        )
else
  Icon(
    isSelected
        ? Icons.check_circle
        : Icons.radio_button_unchecked,
    color: isSelected
        ? blue
        : borderColor,
    size: Get.width * .055,
  ),
          
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FIRST NON EMPTY
  // =========================================================

  String? _firstNonEmpty(
    List<dynamic> values,
  ) {
    for (final dynamic value in values) {
      final String text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  // =========================================================
  // TIMESTAMP
  // =========================================================

  Timestamp? _getTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value;
    }

    return null;
  }

  // =========================================================
  // LAST SEEN
  // =========================================================

  String _formatLastSeen(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return 'Offline';
    }

    final DateTime lastSeen =
        timestamp.toDate();

    final Duration difference =
        DateTime.now()
            .difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Last seen just now';
    }

    if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    }

    return 'Last seen ${lastSeen.day}/'
        '${lastSeen.month}/'
        '${lastSeen.year}';
  }
}