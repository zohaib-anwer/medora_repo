import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalchat/controller/doctor_presence_controller.dart';
import 'package:medicalchat/view/chat_list/chat_list_view.dart';

class DoctorDashboardView extends StatefulWidget {
  const DoctorDashboardView({super.key});

  static const Color backgroundColor =
      Color(0xFFF3F7FF);

  static const Color blueColor =
      Color(0xFF2196F3);

  static const Color darkText =
      Color(0xFF172534);

  static const Color greyText =
      Color(0xFF647587);

  static const Color borderColor =
      Color(0xFFDDE3E9);

  static const Color redColor =
      Color(0xFFE53935);

  @override
  State<DoctorDashboardView> createState() => _DoctorDashboardViewState();
}

class _DoctorDashboardViewState extends State<DoctorDashboardView> {
  @override
void initState() {
  super.initState();

  if (!Get.isRegistered<DoctorPresenceController>()) {
    Get.put(
      DoctorPresenceController(),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: DoctorDashboardView.backgroundColor,
        body: Center(
          child: Text(
            'Please login again.',
            style: TextStyle(
              color: DoctorDashboardView.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DoctorDashboardView.backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: DoctorDashboardView.backgroundColor,

        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(
            color: DoctorDashboardView.darkText,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          _chatAppBarButton(user.uid),

          IconButton(
          onPressed: () async {
  try {
    if (Get.isRegistered<DoctorPresenceController>()) {
      await Get.find<DoctorPresenceController>()
          .setOfflineBeforeLogout();
    }

    await FirebaseAuth.instance.signOut();

    Get.offAllNamed('/');
  } catch (e) {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/');
  }
},
            icon: const Icon(
              Icons.logout_rounded,
              color: DoctorDashboardView.darkText,
            ),
          ),
        ],
      ),

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.uid)
            .snapshots(),

        builder: (
          context,
          doctorSnapshot,
        ) {
          if (doctorSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: DoctorDashboardView.blueColor,
              ),
            );
          }

          final Map<String, dynamic>? doctorData =
              doctorSnapshot.data?.data();

          return RefreshIndicator(
            color: DoctorDashboardView.blueColor,

            onRefresh: () async {
              await Future.delayed(
                const Duration(
                  milliseconds: 500,
                ),
              );
            },

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.all(16),

              children: [
                _doctorHeader(
                  user,
                  doctorData,
                ),

                const SizedBox(height: 20),

                _sectionTitle('Dashboard'),

                const SizedBox(height: 12),

                _dashboardGrid(user.uid),

                const SizedBox(height: 24),

                _sectionTitle(
                  'Recent Appointments',
                ),

                const SizedBox(height: 12),

                _appointments(user.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  Widget _chatAppBarButton(
    String doctorId,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where(
            'doctorId',
            isEqualTo: doctorId,
          )
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        int unread = 0;

        if (snapshot.hasData) {
          for (final chat
              in snapshot.data!.docs) {
            final data = chat.data();

            unread +=
                _getUnreadCount(data);
          }
        }

        return Stack(
          clipBehavior: Clip.none,

          children: [
            IconButton(
             
             onPressed: () {
  Get.to(
    () => const ChatListView(),
    transition: Transition.rightToLeft,
  );
},

              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: DoctorDashboardView.darkText,
              ),
            ),

            if (unread > 0)
              Positioned(
                right: 3,
                top: 2,

                child: _redBadge(
                  unread,
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  Widget _doctorHeader(
    User user,
    Map<String, dynamic>? data,
  ) {
    final String name =
        _stringValue(
          data?['name'],
        ).isNotEmpty
            ? _stringValue(data?['name'])
            : user.displayName
                        ?.trim()
                        .isNotEmpty ==
                    true
                ? user.displayName!
                : 'Doctor';

    final String specialist =
        _stringValue(
          data?['specialist'],
        ).isNotEmpty
            ? _stringValue(
                data?['specialist'],
              )
            : 'General';

    final String imageUrl =
        _stringValue(
      data?['imageUrl'],
    );

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: DoctorDashboardView.borderColor,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 34,

            backgroundColor:
                const Color(0xFFEAF7FF),

            backgroundImage:
                imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,

            child: imageUrl.isEmpty
                ? const Icon(
                    Icons
                        .medical_services_rounded,
                    color: DoctorDashboardView.blueColor,
                    size: 34,
                  )
                : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: DoctorDashboardView.greyText,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: DoctorDashboardView.darkText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  specialist,
                  style: const TextStyle(
                    color: DoctorDashboardView.blueColor,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  Widget _dashboardGrid(
    String doctorId,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where(
            'doctorId',
            isEqualTo: doctorId,
          )
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        int total = 0;
        int pending = 0;
        int completed = 0;

        if (snapshot.hasData) {
          total =
              snapshot.data!.docs.length;

          for (final doc
              in snapshot.data!.docs) {
            final String status =
                _stringValue(
              doc.data()['status'],
            ).toLowerCase();

            if (status == 'pending') {
              pending++;
            }

            if (status == 'completed') {
              completed++;
            }
          }
        }

        return GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          childAspectRatio: 1.55,

          children: [
            _statCard(
              title: 'Appointments',
              value: total.toString(),
              icon:
                  Icons.calendar_month_rounded,
            ),

            _statCard(
              title: 'Pending',
              value: pending.toString(),
              icon:
                  Icons.pending_actions_rounded,
            ),

            _statCard(
              title: 'Completed',
              value: completed.toString(),
              icon:
                  Icons.check_circle_outline_rounded,
            ),

            _chatCard(
              doctorId,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  Widget _chatCard(
    String doctorId,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where(
            'doctorId',
            isEqualTo: doctorId,
          )
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        int unread = 0;

        if (snapshot.hasData) {
          for (final chat
              in snapshot.data!.docs) {
            unread +=
                _getUnreadCount(
              chat.data(),
            );
          }
        }

        return InkWell(
          borderRadius:
              BorderRadius.circular(16),

       onTap: () {
  Get.to(
    () => const ChatListView(),
    transition: Transition.rightToLeft,
  );
},

          child: Container(
            padding:
                const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(16),

              border: Border.all(
                color: DoctorDashboardView.borderColor,
              ),
            ),

            child: Row(
              children: [
                Stack(
                  clipBehavior:
                      Clip.none,

                  children: [
                    const Icon(
                      Icons
                          .chat_bubble_outline_rounded,
                      color: DoctorDashboardView.blueColor,
                      size: 28,
                    ),

                    if (unread > 0)
                      Positioned(
                        right: -10,
                        top: -10,
                        child:
                            _redBadge(unread),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    'Chat',
                    style: TextStyle(
                      color: DoctorDashboardView.darkText,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: DoctorDashboardView.borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Icon(
            icon,
            color: DoctorDashboardView.blueColor,
            size: 27,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: DoctorDashboardView.greyText,
                    fontSize: 12,
                  ),
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  color: DoctorDashboardView.darkText,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  Widget _appointments(
    String doctorId,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where(
            'doctorId',
            isEqualTo: doctorId,
          )
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(
              color: DoctorDashboardView.blueColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return _emptyCard(
            'Unable to load appointments.',
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _emptyCard(
            'No appointments yet.',
          );
        }

        final sortedDocs =
            List<
                QueryDocumentSnapshot<
                    Map<String, dynamic>>>.from(
          docs,
        );

        sortedDocs.sort(
          (a, b) {
            final DateTime dateA =
                _dateFromValue(
              a.data()['createdAt'],
            );

            final DateTime dateB =
                _dateFromValue(
              b.data()['createdAt'],
            );

            return dateB.compareTo(dateA);
          },
        );

        return Column(
          children: sortedDocs
              .take(10)
              .map(
                (doc) {
                  return _appointmentCard(
                    doc.id,
                    doc.data(),
                  );
                },
              )
              .toList(),
        );
      },
    );
  }

  // ============================================================
  Widget _appointmentCard(
    String appointmentId,
    Map<String, dynamic> data,
  ) {
    final String userId =
        _stringValue(
      data['userId'],
    );

    return FutureBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      future: userId.isNotEmpty
          ? FirebaseFirestore.instance
              .collection('paitent')
              .doc(userId)
              .get()
          : null,

      builder: (
        context,
        snapshot,
      ) {
        final Map<String, dynamic>?
            userData =
            snapshot.data?.data();

        // --------------------------------------------------------
        // PATIENT NAME
        // --------------------------------------------------------

        String patientName =
            _stringValue(
          data['userName'],
        );

        if (patientName.isEmpty) {
          patientName =
              _stringValue(
            data['patientName'],
          );
        }

        if (patientName.isEmpty) {
          patientName =
              _stringValue(
            userData?['name'],
          );
        }

        if (patientName.isEmpty) {
          patientName = 'Patient';
        }

        // --------------------------------------------------------
        // PROFILE IMAGE
        // --------------------------------------------------------

        String profileImage =
            _stringValue(
          data['userImage'],
        );

        if (profileImage.isEmpty) {
          profileImage =
              _stringValue(
            data['patientImage'],
          );
        }

        if (profileImage.isEmpty) {
          profileImage =
              _stringValue(
            userData?['imageUrl'],
          );
        }

        if (profileImage.isEmpty) {
          profileImage =
              _stringValue(
            userData?['profileImage'],
          );
        }

        if (profileImage.isEmpty) {
          profileImage =
              _stringValue(
            userData?['photoUrl'],
          );
        }

        // --------------------------------------------------------
        // DATE
        // --------------------------------------------------------

        final String appointmentDate =
            _formatDate(
          data['date'],
        );

        // --------------------------------------------------------
        // TIME
        // --------------------------------------------------------

        final String appointmentTime =
            _formatTime(
          data['time'],
        );

        // --------------------------------------------------------
        // STATUS
        // --------------------------------------------------------

        final String status =
            _stringValue(
          data['status'],
        ).isEmpty
                ? 'pending'
                : _stringValue(
                    data['status'],
                  );

        return Container(
          margin:
              const EdgeInsets.only(
            bottom: 10,
          ),

          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(15),

            border: Border.all(
              color: DoctorDashboardView.borderColor,
            ),
          ),

          child: Row(
            children: [
              // --------------------------------------------------
              // PATIENT PROFILE
              // --------------------------------------------------

              CircleAvatar(
                radius: 27,

                backgroundColor:
                    const Color(
                  0xFFEAF7FF,
                ),

                backgroundImage:
                    profileImage.isNotEmpty
                        ? NetworkImage(
                            profileImage,
                          )
                        : null,

                child: profileImage.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: DoctorDashboardView.blueColor,
                        size: 28,
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // --------------------------------------------------
              // PATIENT INFO
              // --------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      patientName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color: DoctorDashboardView.darkText,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          color: DoctorDashboardView.greyText,
                          size: 13,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Flexible(
                          child: Text(
                            appointmentDate
                                    .isNotEmpty
                                ? appointmentDate
                                : 'Date not set',

                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              color:
                                  DoctorDashboardView.greyText,
                              fontSize: 11,
                            ),
                          ),
                        ),

                        if (appointmentTime
                            .isNotEmpty) ...[
                          const SizedBox(
                            width: 9,
                          ),

                          const Icon(
                            Icons
                                .access_time_rounded,
                            color:
                                DoctorDashboardView.greyText,
                            size: 13,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Flexible(
                            child: Text(
                              appointmentTime,

                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                color:
                                    DoctorDashboardView.greyText,
                                fontSize:
                                    11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _statusBadge(status),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  Widget _statusBadge(
    String status,
  ) {
    final String cleanStatus =
        status.trim().toLowerCase();

    final bool completed =
        cleanStatus == 'completed';

    final bool cancelled =
        cleanStatus == 'cancelled' ||
            cleanStatus == 'rejected';

    final Color textColor =
        completed
            ? Colors.green
            : cancelled
                ? Colors.red
                : DoctorDashboardView.blueColor;

    final Color bgColor =
        completed
            ? Colors.green.withOpacity(
                0.10,
              )
            : cancelled
                ? Colors.red.withOpacity(
                    0.08,
                  )
                : const Color(
                    0xFFEAF7FF,
                  );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: bgColor,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        _capitalize(status),

        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  Widget _redBadge(
    int count,
  ) {
    final String text =
        count > 99
            ? '99+'
            : count.toString();

    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 19,
        minHeight: 19,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),

      decoration: BoxDecoration(
        color: DoctorDashboardView.redColor,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),

      child: Center(
        child: Text(
          text,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,

      style: const TextStyle(
        color: DoctorDashboardView.darkText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  Widget _emptyCard(
    String text,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: DoctorDashboardView.borderColor,
        ),
      ),

      child: Center(
        child: Text(
          text,

          textAlign:
              TextAlign.center,

          style: const TextStyle(
            color: DoctorDashboardView.greyText,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  int _getUnreadCount(
  Map<String, dynamic> data,
) {
  dynamic value = data['unreadDoctorCount'];

  // Backward compatibility
  if (value == null) {
    value = data['doctorUnreadCount'];
  }

  if (value == null) {
    value = data['unreadForDoctor'];
  }

  if (value == null) {
    value = data['unreadCountDoctor'];
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

  // ============================================================
  String _stringValue(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ============================================================
  DateTime _dateFromValue(
    dynamic value,
  ) {
    if (value == null) {
      return DateTime(1970);
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final DateTime? parsed =
          DateTime.tryParse(value);

      return parsed ??
          DateTime(1970);
    }

    return DateTime(1970);
  }

  // ============================================================
  String _formatDate(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      final String valueString =
          value.trim();

      if (valueString.isEmpty) {
        return '';
      }

      final DateTime? parsed =
          DateTime.tryParse(
        valueString,
      );

      if (parsed != null) {
        return _formatDateTime(
          parsed,
        );
      }

      return valueString;
    }

    final DateTime? date =
        _tryDate(value);

    if (date == null) {
      return '';
    }

    return _formatDateTime(date);
  }

  String _formatDateTime(
    DateTime date,
  ) {
    final String day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final String month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final String year =
        date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  String _formatTime(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is Timestamp) {
      return _formatClock(
        value.toDate(),
      );
    }

    if (value is DateTime) {
      return _formatClock(value);
    }

    if (value is String) {
      final String clean =
          value.trim();

      if (clean.isEmpty) {
        return '';
      }

      final DateTime? parsed =
          DateTime.tryParse(clean);

      if (parsed != null) {
        return _formatClock(parsed);
      }

      // --------------------------------------------------------
      // Handle values like:
      // 10:30:00
      // 10:30
      // --------------------------------------------------------

      final RegExp timeRegex =
          RegExp(
        r'^(\d{1,2}):(\d{2})(?::(\d{2}))?',
      );

      final Match? match =
          timeRegex.firstMatch(clean);

      if (match != null) {
        final int hour =
            int.tryParse(
                  match.group(1)!,
                ) ??
                0;

        final int minute =
            int.tryParse(
                  match.group(2)!,
                ) ??
                0;

        return _formatHourMinute(
          hour,
          minute,
        );
      }

      return clean;
    }

    return '';
  }

  DateTime? _tryDate(
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

  String _formatClock(
    DateTime date,
  ) {
    return _formatHourMinute(
      date.hour,
      date.minute,
    );
  }

  String _formatHourMinute(
    int hour,
    int minute,
  ) {
    final String period =
        hour >= 12 ? 'PM' : 'AM';

    int displayHour =
        hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    final String minuteText =
        minute.toString().padLeft(
              2,
              '0',
            );

    return '$displayHour:$minuteText $period';
  }

  String _capitalize(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return '';
    }

    final String clean =
        value.trim();

    return clean[0].toUpperCase() +
        clean.substring(1).toLowerCase();
  }
}

// ==================================================================
// DOCTOR CHAT LIST
// ==================================================================

// class DoctorChatsView extends StatelessWidget {
//   final String doctorId;

//   const DoctorChatsView({
//     super.key,
//     required this.doctorId,
//   });

//   static const Color backgroundColor =
//       Color(0xFFF3F7FF);

//   static const Color blueColor =
//       Color(0xFF2196F3);

//   static const Color darkText =
//       Color(0xFF172534);

//   static const Color greyText =
//       Color(0xFF647587);

//   static const Color borderColor =
//       Color(0xFFDDE3E9);

//   static const Color redColor =
//       Color(0xFFE53935);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           backgroundColor,

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor:
//             backgroundColor,

//         title: const Text(
//           'Chat',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: StreamBuilder<
//           QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//             .collection('chats')
//             .where(
//               'doctorId',
//               isEqualTo: doctorId,
//             )
//             .snapshots(),

//         builder: (
//           context,
//           snapshot,
//         ) {
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//               child:
//                   CircularProgressIndicator(
//                 color: blueColor,
//               ),
//             );
//           }

//           if (snapshot.hasError) {
//             return const Center(
//               child: Text(
//                 'Unable to load chats.',
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 15,
//                 ),
//               ),
//             );
//           }

//           final docs =
//               snapshot.data?.docs ?? [];

//           if (docs.isEmpty) {
//             return const Center(
//               child: Padding(
//                 padding:
//                     EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize:
//                       MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons
//                           .chat_bubble_outline_rounded,
//                       color: blueColor,
//                       size: 55,
//                     ),
//                     SizedBox(height: 12),
//                     Text(
//                       'No chats yet.',
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 17,
//                         fontWeight:
//                             FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       'Patient messages will appear here.',
//                       textAlign:
//                           TextAlign.center,
//                       style: TextStyle(
//                         color: greyText,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final sortedDocs =
//               List<
//                   QueryDocumentSnapshot<
//                       Map<String, dynamic>>>.from(
//             docs,
//           );

//           sortedDocs.sort(
//             (a, b) {
//               final DateTime dateA =
//                   _dateFromValue(
//                 a.data()['lastMessageAt'] ??
//                     a.data()['updatedAt'],
//               );

//               final DateTime dateB =
//                   _dateFromValue(
//                 b.data()['lastMessageAt'] ??
//                     b.data()['updatedAt'],
//               );

//               return dateB.compareTo(dateA);
//             },
//           );

//           return ListView.separated(
//             padding:
//                 const EdgeInsets.all(16),

//             itemCount:
//                 sortedDocs.length,

//             separatorBuilder:
//                 (_, __) =>
//                     const SizedBox(
//               height: 10,
//             ),

//             itemBuilder: (
//               context,
//               index,
//             ) {
//               final doc =
//                   sortedDocs[index];

//               return _chatTile(
//                 doc.id,
//                 doc.data(),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // CHAT TILE
//   // ============================================================

//   Widget _chatTile(
//     String chatId,
//     Map<String, dynamic> data,
//   ) {
//     final String userId =
//         _stringValue(
//       data['userId'],
//     );

//     return FutureBuilder<
//         DocumentSnapshot<Map<String, dynamic>>>(
//       future: userId.isNotEmpty
//           ? FirebaseFirestore.instance
//               .collection('users')
//               .doc(userId)
//               .get()
//           : null,

//       builder: (
//         context,
//         snapshot,
//       ) {
//         final Map<String, dynamic>?
//             userData =
//             snapshot.data?.data();

//         String patientName =
//             _stringValue(
//           data['userName'],
//         );

//         if (patientName.isEmpty) {
//           patientName =
//               _stringValue(
//             data['patientName'],
//           );
//         }

//         if (patientName.isEmpty) {
//           patientName =
//               _stringValue(
//             userData?['name'],
//           );
//         }

//         if (patientName.isEmpty) {
//           patientName = 'Patient';
//         }

//         String imageUrl =
//             _stringValue(
//           data['userImage'],
//         );

//         if (imageUrl.isEmpty) {
//           imageUrl =
//               _stringValue(
//             data['patientImage'],
//           );
//         }

//         if (imageUrl.isEmpty) {
//           imageUrl =
//               _stringValue(
//             userData?['imageUrl'],
//           );
//         }

//         if (imageUrl.isEmpty) {
//           imageUrl =
//               _stringValue(
//             userData?['profileImage'],
//           );
//         }

//         if (imageUrl.isEmpty) {
//           imageUrl =
//               _stringValue(
//             userData?['photoUrl'],
//           );
//         }

//         final String lastMessage =
//             _stringValue(
//           data['lastMessage'],
//         );

//         final int unread =
//             _getUnreadCount(data);

//         return InkWell(
//           borderRadius:
//               BorderRadius.circular(16),

//           onTap: () async {
//             await Get.to(
//               () => DoctorChatView(
//                 chatId: chatId,
//                 doctorId: doctorId,
//                 patientId: userId,
//                 patientName:
//                     patientName,
//                 patientImage:
//                     imageUrl,
//               ),
//             );
//           },

//           child: Container(
//             padding:
//                 const EdgeInsets.all(13),

//             decoration: BoxDecoration(
//               color: Colors.white,

//               borderRadius:
//                   BorderRadius.circular(16),

//               border: Border.all(
//                 color: borderColor,
//               ),
//             ),

//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 27,

//                   backgroundColor:
//                       const Color(
//                     0xFFEAF7FF,
//                   ),

//                   backgroundImage:
//                       imageUrl.isNotEmpty
//                           ? NetworkImage(
//                               imageUrl,
//                             )
//                           : null,

//                   child: imageUrl.isEmpty
//                       ? const Icon(
//                           Icons.person_rounded,
//                           color:
//                               blueColor,
//                           size: 28,
//                         )
//                       : null,
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment
//                             .start,

//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               patientName,
//                               maxLines: 1,
//                               overflow:
//                                   TextOverflow
//                                       .ellipsis,

//                               style:
//                                   TextStyle(
//                                 color:
//                                     darkText,
//                                 fontSize:
//                                     15,
//                                 fontWeight:
//                                     unread >
//                                             0
//                                         ? FontWeight
//                                             .bold
//                                         : FontWeight
//                                             .w600,
//                               ),
//                             ),
//                           ),

//                           if (unread > 0)
//                             _redBadge(
//                               unread,
//                             ),
//                         ],
//                       ),

//                       const SizedBox(height: 5),

//                       Text(
//                         lastMessage.isEmpty
//                             ? 'No messages yet'
//                             : lastMessage,

//                         maxLines: 1,
//                         overflow:
//                             TextOverflow
//                                 .ellipsis,

//                         style: TextStyle(
//                           color:
//                               unread > 0
//                                   ? darkText
//                                   : greyText,
//                           fontSize: 12,
//                           fontWeight:
//                               unread > 0
//                                   ? FontWeight
//                                       .w600
//                                   : FontWeight
//                                       .normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // HELPERS
//   // ============================================================

//   int _getUnreadCount(
//     Map<String, dynamic> data,
//   ) {
//     dynamic value =
//         data['doctorUnreadCount'];

//     if (value == null) {
//       value =
//           data['unreadForDoctor'];
//     }

//     if (value == null) {
//       value =
//           data['unreadCountDoctor'];
//     }

//     if (value is int) {
//       return value;
//     }

//     if (value is num) {
//       return value.toInt();
//     }

//     if (value is String) {
//       return int.tryParse(value) ?? 0;
//     }

//     return 0;
//   }

//   DateTime _dateFromValue(
//     dynamic value,
//   ) {
//     if (value is Timestamp) {
//       return value.toDate();
//     }

//     if (value is DateTime) {
//       return value;
//     }

//     if (value is String) {
//       return DateTime.tryParse(
//             value,
//           ) ??
//           DateTime(1970);
//     }

//     return DateTime(1970);
//   }

//   String _stringValue(
//     dynamic value,
//   ) {
//     if (value == null) {
//       return '';
//     }

//     return value.toString().trim();
//   }

//   Widget _redBadge(
//     int count,
//   ) {
//     final String text =
//         count > 99
//             ? '99+'
//             : count.toString();

//     return Container(
//       constraints:
//           const BoxConstraints(
//         minWidth: 19,
//         minHeight: 19,
//       ),

//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 5,
//         vertical: 2,
//       ),

//       decoration: BoxDecoration(
//         color: redColor,
//         borderRadius:
//             BorderRadius.circular(20),

//         border: Border.all(
//           color: Colors.white,
//           width: 1.5,
//         ),
//       ),

//       child: Center(
//         child: Text(
//           text,

//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 9,
//             fontWeight:
//                 FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// ==================================================================
// DOCTOR CHAT SCREEN
// ==================================================================

// class DoctorChatView extends StatefulWidget {
//   final String chatId;
//   final String doctorId;
//   final String patientId;
//   final String patientName;
//   final String patientImage;

//   const DoctorChatView({
//     super.key,
//     required this.chatId,
//     required this.doctorId,
//     required this.patientId,
//     required this.patientName,
//     required this.patientImage,
//   });

//   @override
//   State<DoctorChatView> createState() =>
//       _DoctorChatViewState();
// }

// class _DoctorChatViewState
//     extends State<DoctorChatView> {
//   static const Color backgroundColor =
//       Color(0xFFF3F7FF);

//   static const Color blueColor =
//       Color(0xFF2196F3);

//   static const Color darkText =
//       Color(0xFF172534);

//   static const Color greyText =
//       Color(0xFF647587);

//   static const Color borderColor =
//       Color(0xFFDDE3E9);

//   final TextEditingController
//       messageController =
//       TextEditingController();

//   final ScrollController
//       scrollController =
//       ScrollController();

//   final FirebaseFirestore firestore =
//       FirebaseFirestore.instance;

//   bool sending = false;

//   @override
//   void initState() {
//     super.initState();

//     _markChatAsRead();
//   }

//   @override
//   void dispose() {
//     messageController.dispose();
//     scrollController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // MARK CHAT READ
//   // ============================================================

//   Future<void> _markChatAsRead() async {
//   try {
//     await firestore
//         .collection('chats')
//         .doc(widget.chatId)
//         .set(
//       {
//         'unreadDoctorCount': 0,

//         // Old field compatibility
//         'doctorUnreadCount': 0,
//         'unreadForDoctor': 0,
//         'unreadCountDoctor': 0,

//         'updatedAt':
//             FieldValue.serverTimestamp(),
//       },
//       SetOptions(
//         merge: true,
//       ),
//     );
//   } catch (_) {}
// }

//   // ============================================================
//   // SEND MESSAGE
//   // ============================================================

//   Future<void> _sendMessage() async {
//     final String text =
//         messageController.text.trim();

//     if (text.isEmpty ||
//         sending) {
//       return;
//     }

//     final User? doctor =
//         FirebaseAuth.instance.currentUser;

//     if (doctor == null) {
//       return;
//     }

//     setState(() {
//       sending = true;
//     });

//     try {
//       final DocumentReference
//           chatRef =
//           firestore
//               .collection('chats')
//               .doc(widget.chatId);

//       final DocumentReference
//           messageRef =
//           chatRef
//               .collection('messages')
//               .doc();

//       final WriteBatch batch =
//           firestore.batch();

//       batch.set(
//         messageRef,
//         {
//           'senderId': doctor.uid,
//           'senderType': 'doctor',
//           'text': text,
//           'type': 'text',
//           'imageUrl': '',
//           'createdAt':
//               FieldValue.serverTimestamp(),
//         },
//       );

//       batch.set(
//         chatRef,
//         {
//           'doctorId': widget.doctorId,
//           'userId': widget.patientId,
//           'lastMessage': text,
//           'lastMessageAt':
//               FieldValue.serverTimestamp(),
//           'updatedAt':
//               FieldValue.serverTimestamp(),
//         },
//         SetOptions(
//           merge: true,
//         ),
//       );

//       await batch.commit();

//       messageController.clear();

//       await Future.delayed(
//         const Duration(
//           milliseconds: 100,
//         ),
//       );

//       _scrollToBottom();
//     } catch (e) {
//       Get.snackbar(
//         'Message',
//         'Unable to send message.',
//         backgroundColor:
//             Colors.red,
//         colorText:
//             Colors.white,
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           sending = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // SCROLL
//   // ============================================================

//   void _scrollToBottom() {
//     if (!scrollController
//         .hasClients) {
//       return;
//     }

//     scrollController.animateTo(
//       scrollController.position
//           .maxScrollExtent,

//       duration:
//           const Duration(
//         milliseconds: 250,
//       ),

//       curve: Curves.easeOut,
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       backgroundColor:
//           backgroundColor,

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor:
//             backgroundColor,

//         titleSpacing: 0,

//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,

//               backgroundColor:
//                   const Color(
//                 0xFFEAF7FF,
//               ),

//               backgroundImage:
//                   widget.patientImage
//                           .isNotEmpty
//                       ? NetworkImage(
//                           widget.patientImage,
//                         )
//                       : null,

//               child: widget.patientImage
//                       .isEmpty
//                   ? const Icon(
//                       Icons.person_rounded,
//                       color:
//                           blueColor,
//                       size: 22,
//                     )
//                   : null,
//             ),

//             const SizedBox(width: 10),

//             Expanded(
//               child: Text(
//                 widget.patientName,
//                 maxLines: 1,
//                 overflow:
//                     TextOverflow.ellipsis,

//                 style: const TextStyle(
//                   color: darkText,
//                   fontSize: 18,
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       body: Column(
//         children: [
//           Expanded(
//             child:
//                 _messages(),
//           ),

//           _messageInput(),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // MESSAGES
//   // ============================================================

//   Widget _messages() {
//     return StreamBuilder<
//         QuerySnapshot<Map<String, dynamic>>>(
//       stream: firestore
//           .collection('chats')
//           .doc(widget.chatId)
//           .collection('messages')
//           .orderBy(
//             'createdAt',
//             descending: false,
//           )
//           .snapshots(),

//       builder: (
//         context,
//         snapshot,
//       ) {
//         if (snapshot.connectionState ==
//             ConnectionState.waiting) {
//           return const Center(
//             child:
//                 CircularProgressIndicator(
//               color: blueColor,
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           return const Center(
//             child: Text(
//               'Unable to load messages.',
//               style: TextStyle(
//                 color: darkText,
//               ),
//             ),
//           );
//         }

//         final messages =
//             snapshot.data?.docs ?? [];

//         if (messages.isEmpty) {
//           return const Center(
//             child: Text(
//               'No messages yet.',
//               style: TextStyle(
//                 color: greyText,
//                 fontSize: 14,
//               ),
//             ),
//           );
//         }

//         WidgetsBinding.instance
//             .addPostFrameCallback(
//           (_) {
//             _scrollToBottom();
//           },
//         );

//         return ListView.builder(
//           controller:
//               scrollController,

//           padding:
//               const EdgeInsets.fromLTRB(
//             16,
//             16,
//             16,
//             10,
//           ),

//           itemCount:
//               messages.length,

//           itemBuilder: (
//             context,
//             index,
//           ) {
//             final data =
//                 messages[index].data();

//             return _messageBubble(
//               data,
//             );
//           },
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE BUBBLE
//   // ============================================================

//   Widget _messageBubble(
//     Map<String, dynamic> data,
//   ) {
//     final User? currentUser =
//         FirebaseAuth.instance
//             .currentUser;

//     final String senderId =
//         data['senderId']
//                 ?.toString() ??
//             '';

//     final bool isDoctor =
//         senderId ==
//             currentUser?.uid ||
//         data['senderType']
//                 ?.toString()
//                 .toLowerCase() ==
//             'doctor';

//     final String text =
//         data['text']
//                 ?.toString() ??
//             '';

//     final DateTime? createdAt =
//         _dateFromValue(
//       data['createdAt'],
//     );

//     return Align(
//       alignment: isDoctor
//           ? Alignment.centerRight
//           : Alignment.centerLeft,

//       child: Container(
//         constraints:
//             const BoxConstraints(
//           maxWidth: 300,
//         ),

//         margin:
//             const EdgeInsets.only(
//           bottom: 9,
//         ),

//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 13,
//           vertical: 10,
//         ),

//         decoration: BoxDecoration(
//           color: isDoctor
//               ? blueColor
//               : Colors.white,

//           borderRadius:
//               BorderRadius.circular(15),

//           border: isDoctor
//               ? null
//               : Border.all(
//                   color: borderColor,
//                 ),
//         ),

//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.end,

//           children: [
//             Align(
//               alignment:
//                   Alignment.centerLeft,

//               child: Text(
//                 text,

//                 style: TextStyle(
//                   color: isDoctor
//                       ? Colors.white
//                       : darkText,

//                   fontSize: 14,
//                 ),
//               ),
//             ),

//             if (createdAt != null) ...[
//               const SizedBox(height: 4),

//               Text(
//                 _formatTime(
//                   createdAt,
//                 ),

//                 style: TextStyle(
//                   color: isDoctor
//                       ? Colors.white
//                           .withOpacity(
//                           0.75,
//                         )
//                       : greyText,

//                   fontSize: 9,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT
//   // ============================================================

//   Widget _messageInput() {
//     return SafeArea(
//       top: false,

//       child: Container(
//         padding:
//             const EdgeInsets.fromLTRB(
//           12,
//           8,
//           12,
//           10,
//         ),

//         decoration: BoxDecoration(
//           color: Colors.white,

//           border: Border(
//             top: BorderSide(
//               color: borderColor,
//             ),
//           ),
//         ),

//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller:
//                     messageController,

//                 minLines: 1,
//                 maxLines: 4,

//                 textCapitalization:
//                     TextCapitalization
//                         .sentences,

//                 decoration:
//                     InputDecoration(
//                   hintText:
//                       'Write a message...',

//                   hintStyle:
//                       const TextStyle(
//                     color: greyText,
//                     fontSize: 13,
//                   ),

//                   filled: true,

//                   fillColor:
//                       const Color(
//                     0xFFF3F7FF,
//                   ),

//                   contentPadding:
//                       const EdgeInsets
//                           .symmetric(
//                     horizontal: 14,
//                     vertical: 11,
//                   ),

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                       24,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),

//                   enabledBorder:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                       24,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),

//                   focusedBorder:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                       24,
//                     ),

//                     borderSide:
//                         const BorderSide(
//                       color: blueColor,
//                       width: 1,
//                     ),
//                   ),
//                 ),

//                 onSubmitted: (_) {
//                   _sendMessage();
//                 },
//               ),
//             ),

//             const SizedBox(width: 8),

//             GestureDetector(
//               onTap:
//                   sending
//                       ? null
//                       : _sendMessage,

//               child: Container(
//                 width: 46,
//                 height: 46,

//                 decoration:
//                     const BoxDecoration(
//                   color: blueColor,
//                   shape: BoxShape.circle,
//                 ),

//                 child: sending
//                     ? const Padding(
//                         padding:
//                             EdgeInsets.all(
//                           13,
//                         ),

//                         child:
//                             CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color:
//                               Colors.white,
//                         ),
//                       )
//                     : const Icon(
//                         Icons
//                             .send_rounded,
//                         color:
//                             Colors.white,
//                         size: 21,
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HELPERS
//   // ============================================================

//   DateTime? _dateFromValue(
//     dynamic value,
//   ) {
//     if (value is Timestamp) {
//       return value.toDate();
//     }

//     if (value is DateTime) {
//       return value;
//     }

//     if (value is String) {
//       return DateTime.tryParse(
//         value,
//       );
//     }

//     return null;
//   }

//   String _formatTime(
//     DateTime date,
//   ) {
//     final int hour =
//         date.hour;

//     final String period =
//         hour >= 12 ? 'PM' : 'AM';

//     int displayHour =
//         hour % 12;

//     if (displayHour == 0) {
//       displayHour = 12;
//     }

//     final String minute =
//         date.minute
//             .toString()
//             .padLeft(
//               2,
//               '0',
//             );

//     return '$displayHour:$minute $period';
//   }
// }