import 'package:flutter/material.dart';
import 'package:get/get.dart';import 'package:medicalchat/controller/profile_controller.dart';
import 'package:medicalchat/view/admin/admin_dashboard_view.dart';
import 'package:medicalchat/view/edit_profile/edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller =
      Get.put(
    ProfileController(),
  );

  // =========================================================
  // COLORS
  // =========================================================

  static const Color blue =
      Color(0xFF2196F3);

  static const Color darkText =
      Color(0xFF172534);

  static const Color greyText =
      Color(0xFF647587);

  static const Color borderColor =
      Color(0xFFDDE3E9);

  static const Color background =
      Color(0xFFF3F7FF);

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          background,

      appBar: AppBar(
        backgroundColor:
            background,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Get.back();
          },

          icon: Icon(
            Icons.arrow_back,
            color: darkText,
            size: Get.width * .065,
          ),
        ),

        title: Text(
          'Profile',
          style: TextStyle(
            color: darkText,
            fontSize:
                Get.width * .050,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              controller.refreshProfile();
            },

            icon: Icon(
              Icons.refresh,
              color: blue,
              size: Get.width * .060,
            ),
          ),
        ],
      ),

      body: Obx(
        () {
          if (controller.isLoading.value &&
              controller.firebaseUser.value ==
                  null) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: blue,
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              color: blue,

              onRefresh:
                  controller.refreshProfile,

              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(
                  parent:
                      BouncingScrollPhysics(),
                ),

                padding:
                    EdgeInsets.fromLTRB(
                  Get.width * .053,
                  Get.height * .020,
                  Get.width * .053,
                  Get.height * .040,
                ),

                child: Column(
                  children: [

                    // =================================================
                    // PROFILE HEADER
                    // =================================================

                    _profileHeader(),

                    SizedBox(
                      height:
                          Get.height * .030,
                    ),

                    // =================================================
                    // ACCOUNT INFORMATION
                    // =================================================

                    _sectionTitle(
                      'Account Information',
                    ),

                    SizedBox(
                      height:
                          Get.height * .015,
                    ),

                    _infoTile(
                      icon:
                          Icons.person_outline,
                      title:
                          'Full Name',
                      value:
                          controller.name,
                    ),

                    _infoTile(
                      icon:
                          Icons.email_outlined,
                      title:
                          'Email',
                      value:
                          controller.email,
                    ),

                    if (controller.phone
                        .isNotEmpty)
                      _infoTile(
                        icon:
                            Icons.phone_outlined,
                        title:
                            'Phone',
                        value:
                            controller.phone,
                      ),

                    SizedBox(
                      height:
                          Get.height * .020,
                    ),

                    // =================================================
                    // ADMIN
                    // =================================================

                    if (controller.isAdmin)
                      Column(
                        children: [

                          _sectionTitle(
                            'Administration',
                          ),

                          SizedBox(
                            height:
                                Get.height * .015,
                          ),

                          _actionTile(
                            icon:
                                Icons
                                    .admin_panel_settings_outlined,
                            title:
                                'Admin Panel',
                            subtitle:
                                'Manage doctors, medicines and articles',
                            onTap: () {
                              Get.to(
                                () =>
                                    AdminDashboardView(),
                                transition:
                                    Transition
                                        .rightToLeft,
                                duration:
                                    const Duration(
                                  milliseconds:
                                      300,
                                ),
                              );
                            },
                          ),

                          SizedBox(
                            height:
                                Get.height * .025,
                          ),
                        ],
                      ),

                    // =================================================
                    // LOGOUT
                    // =================================================

                    _actionTile(
                      icon:
                          Icons.logout,
                      title:
                          'Logout',
                      subtitle:
                          'Sign out from your account',
                      iconColor:
                          Colors.red,
                      onTap:
                          _logoutDialog,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // PROFILE HEADER
  // =========================================================

  Widget _profileHeader() {
    return Container(
      width: double.infinity,

      padding:
          EdgeInsets.all(
        Get.width * .050,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFD9F0FF),
            Color(0xFFEAF7FF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          Get.width * .045,
        ),
      ),

      child: Column(
        children: [

          // =================================================
          // IMAGE
          // =================================================

          Container(
            width:
                Get.width * .25,

            height:
                Get.width * .25,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              color:
                  Colors.white,

              border:
                  Border.all(
                color: blue,
                width: 3,
              ),
            ),

            clipBehavior:
                Clip.antiAlias,

            child:
                _profileImage(),
          ),

          SizedBox(
            height:
                Get.height * .018,
          ),

          // =================================================
          // NAME
          // =================================================

          Text(
            controller.name,

            textAlign:
                TextAlign.center,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              color: darkText,
              fontSize:
                  Get.width * .045,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(
            height:
                Get.height * .007,
          ),

          // =================================================
          // EMAIL
          // =================================================

          Text(
            controller.email.isNotEmpty
                ? controller.email
                : 'No email available',

            textAlign:
                TextAlign.center,

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              color: greyText,
              fontSize:
                  Get.width * .027,
            ),
          ),

          SizedBox(
            height:
                Get.height * .020,
          ),

          // =================================================
          // EDIT PROFILE
          // =================================================

          SizedBox(
            height:
                Get.height * .050,

            child:
                OutlinedButton.icon(
              onPressed: () async {
                await Get.to(
                  () =>
                      const EditProfileView(),
                  transition:
                      Transition.rightToLeft,
                  duration:
                      const Duration(
                    milliseconds: 300,
                  ),
                );

                // Reload after coming back
                await controller
                    .refreshProfile();
              },

              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),

              label: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize:
                      Get.width * .027,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor: blue,

                side:
                    const BorderSide(
                  color: blue,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROFILE IMAGE
  // =========================================================

  Widget _profileImage() {
    final String url =
        controller.photoUrl;

    if (url.isEmpty) {
      return _defaultAvatar();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        // IMPORTANT:
        // Image error par snackbar nahi.
        return _defaultAvatar();
      },
    );
  }

  // =========================================================
  // DEFAULT AVATAR
  // =========================================================

  Widget _defaultAvatar() {
    return Container(
      color:
          const Color(0xFFEAF7FF),

      alignment:
          Alignment.center,

      child: Icon(
        Icons.person,
        color: blue,
        size:
            Get.width * .13,
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Align(
      alignment:
          Alignment.centerLeft,

      child: Text(
        title,

        style: TextStyle(
          color: darkText,
          fontSize:
              Get.width * .035,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // INFO TILE
  // =========================================================

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width:
          double.infinity,

      margin:
          EdgeInsets.only(
        bottom:
            Get.height * .012,
      ),

      padding:
          EdgeInsets.all(
        Get.width * .035,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child: Row(
        children: [

          Container(
            width:
                Get.width * .105,

            height:
                Get.width * .105,

            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFEAF7FF),
              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: blue,
              size:
                  Get.width * .050,
            ),
          ),

          SizedBox(
            width:
                Get.width * .030,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: greyText,
                    fontSize:
                        Get.width * .022,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value.isNotEmpty
                      ? value
                      : 'Not available',

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color: darkText,
                    fontSize:
                        Get.width * .028,
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

  // =========================================================
  // ACTION TILE
  // =========================================================

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = blue,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width:
            double.infinity,

        padding:
            EdgeInsets.all(
          Get.width * .035,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            Get.width * .030,
          ),

          border:
              Border.all(
            color:
                borderColor,
          ),
        ),

        child: Row(
          children: [

            Container(
              width:
                  Get.width * .105,

              height:
                  Get.width * .105,

              decoration:
                  BoxDecoration(
                color:
                    iconColor
                        .withOpacity(.10),
                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                icon,
                color:
                    iconColor,
                size:
                    Get.width * .050,
              ),
            ),

            SizedBox(
              width:
                  Get.width * .030,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: TextStyle(
                      color:
                          darkText,
                      fontSize:
                          Get.width * .030,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          greyText,
                      fontSize:
                          Get.width * .023,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color:
                  const Color(
                0xFFB7C1C9,
              ),
              size:
                  Get.width * .035,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LOGOUT DIALOG
  // =========================================================

  void _logoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            Colors.white,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),

        title: const Text(
          'Logout',
          style: TextStyle(
            color: darkText,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: greyText,
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Get.back();
            },

            child: const Text(
              'Cancel',
              style: TextStyle(
                color: greyText,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  blue,
              foregroundColor:
                  Colors.white,
              elevation: 0,
            ),

            child:
                const Text(
              'Logout',
            ),
          ),
        ],
      ),
    );
  }
}