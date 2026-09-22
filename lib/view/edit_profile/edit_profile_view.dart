import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:medicalchat/controller/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({
    super.key,
  });

  @override
  State<EditProfileView> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState
    extends State<EditProfileView> {
  // =========================================================
  // CONTROLLER
  // =========================================================

  final ProfileController controller =
      Get.find<ProfileController>();

  // =========================================================
  // TEXT CONTROLLER
  // =========================================================

  late final TextEditingController
      nameController;

  // =========================================================
  // SELECTED IMAGE
  // =========================================================

  XFile? selectedImage;

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
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
      text: controller.name,
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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

        surfaceTintColor:
            Colors.transparent,

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
          'Edit Profile',
          style: TextStyle(
            color: darkText,
            fontSize:
                Get.width * .050,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              EdgeInsets.fromLTRB(
            Get.width * .053,
            Get.height * .025,
            Get.width * .053,
            Get.height * .040,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =================================================
              // PROFILE IMAGE
              // =================================================

              Center(
                child: Stack(
                  clipBehavior:
                      Clip.none,

                  children: [
                    Container(
                      width:
                          Get.width * .32,

                      height:
                          Get.width * .32,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            Colors.white,

                        border:
                            Border.all(
                          color:
                              blue,
                          width:
                              3,
                        ),
                      ),

                      clipBehavior:
                          Clip.antiAlias,

                      child:
                          _profileImage(),
                    ),

                    // =================================================
                    // CAMERA BUTTON
                    // =================================================

                    Positioned(
                      right:
                          Get.width * .005,

                      bottom:
                          Get.width * .005,

                      child:
                          Obx(
                        () => GestureDetector(
                          onTap:
                              controller
                                      .isSaving
                                      .value ||
                                  controller
                                      .isUploadingImage
                                      .value
                              ? null
                              : _showImageOptions,

                          child:
                              Container(
                            width:
                                Get.width * .095,

                            height:
                                Get.width * .095,

                            decoration:
                                BoxDecoration(
                              color:
                                  controller
                                          .isUploadingImage
                                          .value
                                      ? Colors
                                          .grey
                                      : blue,

                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                controller
                                        .isUploadingImage
                                        .value
                                    ? const Padding(
                                        padding:
                                            EdgeInsets.all(
                                          13,
                                        ),
                                        child:
                                            CircularProgressIndicator(
                                          color:
                                              Colors.white,
                                          strokeWidth:
                                              2,
                                        ),
                                      )
                                    : Icon(
                                        Icons
                                            .camera_alt_outlined,
                                        color:
                                            Colors.white,
                                        size:
                                            Get.width *
                                                .050,
                                      ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height:
                    Get.height * .018,
              ),

              Center(
                child: Text(
                  'Tap the camera icon to change photo',
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
              ),

              SizedBox(
                height:
                    Get.height * .040,
              ),

              // =================================================
              // NAME LABEL
              // =================================================

              Text(
                'Full Name',
                style:
                    TextStyle(
                  color:
                      darkText,
                  fontSize:
                      Get.width * .032,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              SizedBox(
                height:
                    Get.height * .010,
              ),

              // =================================================
              // NAME FIELD
              // =================================================

              Container(
                height:
                    Get.height * .065,

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

                child:
                    TextField(
                  controller:
                      nameController,

                  enabled:
                      true,

                  textCapitalization:
                      TextCapitalization.words,

                  style:
                      TextStyle(
                    color:
                        darkText,
                    fontSize:
                        Get.width * .030,
                  ),

                  decoration:
                      InputDecoration(
                    prefixIcon:
                        const Icon(
                      Icons
                          .person_outline,
                      color:
                          blue,
                    ),

                    hintText:
                        'Enter your name',

                    hintStyle:
                        TextStyle(
                      color:
                          greyText,
                      fontSize:
                          Get.width * .028,
                    ),

                    border:
                        InputBorder.none,

                    contentPadding:
                        EdgeInsets.symmetric(
                      vertical:
                          Get.height * .020,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height:
                    Get.height * .025,
              ),

              // =================================================
              // EMAIL
              // =================================================

              Text(
                'Email',
                style:
                    TextStyle(
                  color:
                      darkText,
                  fontSize:
                      Get.width * .032,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              SizedBox(
                height:
                    Get.height * .010,
              ),

              Container(
                width:
                    double.infinity,

                padding:
                    EdgeInsets.symmetric(
                  horizontal:
                      Get.width * .035,
                  vertical:
                      Get.height * .019,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEFF3F7,
                  ),

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

                child:
                    Row(
                  children: [
                    const Icon(
                      Icons
                          .email_outlined,
                      color:
                          greyText,
                    ),

                    SizedBox(
                      width:
                          Get.width * .025,
                    ),

                    Expanded(
                      child:
                          Text(
                        controller
                                .email
                                .isNotEmpty
                            ? controller
                                .email
                            : 'No email available',

                        maxLines:
                            2,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            TextStyle(
                          color:
                              greyText,
                          fontSize:
                              Get.width * .028,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height:
                    Get.height * .010,
              ),

              Text(
                'Email cannot be changed here.',
                style:
                    TextStyle(
                  color:
                      greyText,
                  fontSize:
                      Get.width * .022,
                ),
              ),

              SizedBox(
                height:
                    Get.height * .040,
              ),

              // =================================================
              // SAVE BUTTON
              // =================================================

              Obx(
                () => SizedBox(
                  width:
                      double.infinity,

                  height:
                      Get.height * .062,

                  child:
                      ElevatedButton(
                    onPressed:
                        controller
                                .isSaving
                                .value ||
                            controller
                                .isUploadingImage
                                .value
                            ? null
                            : _saveProfile,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          blue,

                      disabledBackgroundColor:
                          const Color(
                        0xFF90CAF9,
                      ),

                      foregroundColor:
                          Colors.white,

                      elevation:
                          0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          Get.width * .035,
                        ),
                      ),
                    ),

                    child:
                        controller
                                .isSaving
                                .value
                            ? const SizedBox(
                                width:
                                    24,
                                height:
                                    24,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth:
                                      2.5,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style:
                                    TextStyle(
                                  fontSize:
                                      Get.width *
                                          .034,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PROFILE IMAGE
  // =========================================================

  Widget _profileImage() {
    // ---------------------------------------------------------
    // NEW SELECTED IMAGE
    // ---------------------------------------------------------

    if (selectedImage != null) {
      return Image.file(
        File(
          selectedImage!.path,
        ),
        fit:
            BoxFit.cover,
        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return _defaultAvatar();
        },
      );
    }

    // ---------------------------------------------------------
    // EXISTING CLOUDINARY IMAGE
    // ---------------------------------------------------------

    final String url =
        controller.photoUrl;

    if (url.isNotEmpty) {
      return Image.network(
        url,

        fit:
            BoxFit.cover,

        loadingBuilder:
            (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child:
                CircularProgressIndicator(
              color:
                  blue,
              strokeWidth:
                  2,
            ),
          );
        },

        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return _defaultAvatar();
        },
      );
    }

    return _defaultAvatar();
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

      child:
          Icon(
        Icons.person,
        color:
            blue,
        size:
            Get.width * .16,
      ),
    );
  }

  // =========================================================
  // IMAGE OPTIONS
  // =========================================================

  void _showImageOptions() {
    Get.bottomSheet(
      Container(
        padding:
            EdgeInsets.fromLTRB(
          Get.width * .050,
          Get.height * .020,
          Get.width * .050,
          Get.height * .035,
        ),

        decoration:
            const BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.vertical(
            top:
                Radius.circular(25),
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            // =================================================
            // HANDLE
            // =================================================

            Container(
              width:
                  Get.width * .12,

              height:
                  4,

              decoration:
                  BoxDecoration(
                color:
                    borderColor,

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),

            SizedBox(
              height:
                  Get.height * .025,
            ),

            Text(
              'Change Profile Photo',
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

            SizedBox(
              height:
                  Get.height * .020,
            ),

            // =================================================
            // CAMERA
            // =================================================

            _imageOption(
              icon:
                  Icons.camera_alt_outlined,
              title:
                  'Camera',
              onTap: () {
                Get.back();

                _selectImage(
                  ImageSource.camera,
                );
              },
            ),

            SizedBox(
              height:
                  Get.height * .012,
            ),

            // =================================================
            // GALLERY
            // =================================================

            _imageOption(
              icon:
                  Icons.photo_library_outlined,
              title:
                  'Gallery',
              onTap: () {
                Get.back();

                _selectImage(
                  ImageSource.gallery,
                );
              },
            ),
          ],
        ),
      ),

      isScrollControlled:
          true,
    );
  }

  // =========================================================
  // IMAGE OPTION
  // =========================================================

  Widget _imageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap,

      child:
          Container(
        width:
            double.infinity,

        padding:
            EdgeInsets.all(
          Get.width * .035,
        ),

        decoration:
            BoxDecoration(
          color:
              background,

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

        child:
            Row(
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

              child:
                  Icon(
                icon,
                color:
                    blue,
                size:
                    Get.width * .050,
              ),
            ),

            SizedBox(
              width:
                  Get.width * .030,
            ),

            Text(
              title,
              style:
                  TextStyle(
                color:
                    darkText,
                fontSize:
                    Get.width * .030,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SELECT IMAGE
  // =========================================================

  Future<void> _selectImage(
    ImageSource source,
  ) async {
    final XFile? image =
        await controller.pickImage(
      source,
    );

    if (image == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedImage =
          image;
    });
  }

  // =========================================================
  // SAVE PROFILE
  // =========================================================

 Future<void> _saveProfile() async {
  FocusScope.of(context).unfocus();

  final bool success = await controller.updateProfile(
    name: nameController.text.trim(),
    image: selectedImage,
  );

  if (!success || !mounted) {
    return;
  }

  // Close Edit Profile screen first
  Get.back();

  // Show success message after returning to Profile screen
  Future.delayed(const Duration(milliseconds: 250), () {
    if (Get.context != null) {
      Get.snackbar(
        'Success',
        'Profile updated successfully.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
        backgroundColor: const Color(0xFF2196F3),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
        ),
      );
    }
  });
}
}