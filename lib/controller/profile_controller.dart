import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:medicalchat/controller/user_presence_controller.dart';
import 'package:medicalchat/view/login/login_view.dart';

class ProfileController extends GetxController {
  // =========================================================
  // FIREBASE
  // =========================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // IMAGE PICKER
  // =========================================================

  final ImagePicker _picker =
      ImagePicker();

  // =========================================================
  // USER
  // =========================================================

  final Rxn<User> firebaseUser =
      Rxn<User>();

  final RxMap<String, dynamic> userData =
      <String, dynamic>{}.obs;

  // =========================================================
  // LOADING
  // =========================================================

  final RxBool isLoading =
      false.obs;

  final RxBool isSaving =
      false.obs;

  final RxBool isUploadingImage =
      false.obs;

  bool _profileLoading = false;

  // =========================================================
  // CLOUDINARY
  // Same configuration as AdminController
  // =========================================================

  static const String cloudName =
      'dvlvfm5ky';

  static const String uploadPreset =
      'bitebuddy_upload';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    firebaseUser.value =
        _auth.currentUser;

    loadProfile();
  }

  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> loadProfile({
    bool showError = false,
  }) async {
    if (_profileLoading) {
      return;
    }

    final User? user =
        _auth.currentUser;

    if (user == null) {
      firebaseUser.value = null;
      userData.clear();
      return;
    }

    try {
      _profileLoading = true;
      isLoading.value = true;

      firebaseUser.value = user;

      final DocumentSnapshot<
          Map<String, dynamic>> document =
          await _firestore
             .collection('paitent')
              .doc(user.uid)
              .get();

      if (document.exists) {
        final Map<String, dynamic>? data =
            document.data();

        if (data != null) {
          userData.assignAll(data);
        }
      } else {
        userData.clear();
      }
    } catch (e) {
      debugPrint(
        'PROFILE LOAD ERROR => $e',
      );

      if (showError) {
        showMessage(
          'Unable to load profile. Please try again.',
          isError: true,
        );
      }
    } finally {
      _profileLoading = false;
      isLoading.value = false;
    }
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshProfile() async {
    await loadProfile(
      showError: false,
    );
  }

  // =========================================================
  // NAME
  // =========================================================

  String get name {
    final String firestoreName =
        userData['name']
                ?.toString()
                .trim() ??
            '';

    if (firestoreName.isNotEmpty) {
      return firestoreName;
    }

    final String authName =
        firebaseUser.value
                ?.displayName
                ?.trim() ??
            '';

    if (authName.isNotEmpty) {
      return authName;
    }

    return 'User';
  }

  // =========================================================
  // EMAIL
  // =========================================================

  String get email {
    final String firestoreEmail =
        userData['email']
                ?.toString()
                .trim() ??
            '';

    if (firestoreEmail.isNotEmpty) {
      return firestoreEmail;
    }

    return firebaseUser.value?.email ??
        '';
  }

  // =========================================================
  // PHONE
  // =========================================================

  String get phone {
    return userData['phone']
            ?.toString()
            .trim() ??
        '';
  }

  // =========================================================
  // PROFILE PHOTO URL
  // =========================================================

  String get photoUrl {
    final String firestorePhoto =
        userData['photoUrl']
                ?.toString()
                .trim() ??
            '';

    if (firestorePhoto.isNotEmpty) {
      return firestorePhoto;
    }

    return firebaseUser.value?.photoURL ??
        '';
  }

  // =========================================================
  // CLOUDINARY PUBLIC ID
  // =========================================================

  String get photoPublicId {
    return userData['photoPublicId']
            ?.toString()
            .trim() ??
        '';
  }

  // =========================================================
  // ADMIN
  // =========================================================

  bool get isAdmin {
    final String role =
        userData['role']
                ?.toString()
                .toLowerCase()
                .trim() ??
            '';

    return role == 'admin';
  }

  // =========================================================
  // PICK IMAGE
  // =========================================================

  Future<XFile?> pickImage(
    ImageSource source,
  ) async {
    try {
      final XFile? image =
          await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      return image;
    } catch (e) {
      debugPrint(
        'IMAGE PICKER ERROR => $e',
      );

      showMessage(
        'Unable to select image.',
        isError: true,
      );

      return null;
    }
  }

  // =========================================================
  // CLOUDINARY UPLOAD
  // =========================================================

  Future<Map<String, String>?> uploadProfileImage(
    XFile image,
  ) async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      showMessage(
        'Please login again.',
        isError: true,
      );

      return null;
    }

    try {
      isUploadingImage.value = true;

      final File file =
          File(image.path);

      if (!await file.exists()) {
        showMessage(
          'Selected image was not found.',
          isError: true,
        );

        return null;
      }

      // -------------------------------------------------------
      // CLOUDINARY URL
      // -------------------------------------------------------

      final Uri url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final http.MultipartRequest request =
          http.MultipartRequest(
        'POST',
        url,
      );

      // -------------------------------------------------------
      // UPLOAD PRESET
      // -------------------------------------------------------

      request.fields['upload_preset'] =
          uploadPreset;

      // -------------------------------------------------------
      // PROFILE FOLDER
      // -------------------------------------------------------

      request.fields['folder'] =
          'medicalchat/profile_images/${user.uid}';

      // -------------------------------------------------------
      // IMAGE FILE
      // -------------------------------------------------------

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      // -------------------------------------------------------
      // SEND
      // -------------------------------------------------------

      final http.StreamedResponse response =
          await request.send();

      final String responseData =
          await response.stream.bytesToString();

      debugPrint(
        'PROFILE CLOUDINARY RESPONSE => '
        '$responseData',
      );

      // -------------------------------------------------------
      // PARSE RESPONSE
      // -------------------------------------------------------

      final dynamic decoded =
          jsonDecode(responseData);

      if (decoded is! Map<String, dynamic>) {
        showMessage(
          'Invalid Cloudinary response.',
          isError: true,
        );

        return null;
      }

      // -------------------------------------------------------
      // SUCCESS
      // -------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final String secureUrl =
            decoded['secure_url']
                    ?.toString() ??
                '';

        final String publicId =
            decoded['public_id']
                    ?.toString() ??
                '';

        if (secureUrl.isEmpty ||
            publicId.isEmpty) {
          showMessage(
            'Cloudinary image information is missing.',
            isError: true,
          );

          return null;
        }

        return {
          'imageUrl': secureUrl,
          'imagePublicId': publicId,
        };
      }

      // -------------------------------------------------------
      // CLOUDINARY ERROR
      // -------------------------------------------------------

      debugPrint(
        'PROFILE CLOUDINARY ERROR => '
        '$responseData',
      );

      showMessage(
        'Unable to upload profile photo.',
        isError: true,
      );

      return null;
    } catch (e) {
      debugPrint(
        'PROFILE CLOUDINARY UPLOAD ERROR => $e',
      );

      showMessage(
        'Unable to upload profile photo.',
        isError: true,
      );

      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  // =========================================================
  // DELETE OLD CLOUDINARY IMAGE
  //
  // IMPORTANT:
  // Cloudinary API SECRET should NEVER be placed
  // inside Flutter application.
  //
  // Use your secure backend endpoint here.
  // =========================================================

  Future<bool> deleteCloudinaryImage(
    String? publicId,
  ) async {
    if (publicId == null ||
        publicId.trim().isEmpty) {
      return true;
    }

    try {
      // -------------------------------------------------------
      // REPLACE THIS WITH YOUR BACKEND URL
      // -------------------------------------------------------

      const String deleteApi =
          'https://YOUR-BACKEND-URL/delete-cloudinary-image';

      final http.Response response =
          await http.post(
        Uri.parse(deleteApi),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'publicId':
              publicId.trim(),
        }),
      );

      debugPrint(
        'PROFILE CLOUDINARY DELETE => '
        '${response.statusCode} '
        '${response.body}',
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        'PROFILE CLOUDINARY DELETE ERROR => $e',
      );

      return false;
    }
  }

  // =========================================================
  // UPDATE PROFILE
  // =========================================================

  Future<bool> updateProfile({
    required String name,
    XFile? image,
  }) async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      showMessage(
        'Please login again.',
        isError: true,
      );

      return false;
    }

    final String cleanName =
        name.trim();

    // -------------------------------------------------------
    // NAME VALIDATION
    // -------------------------------------------------------

    if (cleanName.isEmpty) {
      showMessage(
        'Please enter your name.',
        isError: true,
      );

      return false;
    }

    if (cleanName.length < 2) {
      showMessage(
        'Name must contain at least 2 characters.',
        isError: true,
      );

      return false;
    }

    try {
      isSaving.value = true;

      // =====================================================
      // OLD IMAGE
      // =====================================================

      final String oldPublicId =
          photoPublicId;

      final String oldPhotoUrl =
          photoUrl;

      String newPhotoUrl =
          oldPhotoUrl;

      String newPhotoPublicId =
          oldPublicId;

      // =====================================================
      // UPLOAD NEW IMAGE TO CLOUDINARY
      // =====================================================

      if (image != null) {
        final Map<String, String>?
            uploadedImage =
            await uploadProfileImage(
          image,
        );

        if (uploadedImage == null) {
          return false;
        }

        newPhotoUrl =
            uploadedImage['imageUrl'] ??
                '';

        newPhotoPublicId =
            uploadedImage[
                    'imagePublicId'] ??
                '';

        if (newPhotoUrl.isEmpty ||
            newPhotoPublicId.isEmpty) {
          showMessage(
            'Profile photo upload failed.',
            isError: true,
          );

          return false;
        }
      }

      // =====================================================
      // UPDATE FIREBASE AUTH
      // =====================================================

      await user.updateDisplayName(
        cleanName,
      );

      if (newPhotoUrl.isNotEmpty) {
        await user.updatePhotoURL(
          newPhotoUrl,
        );
      }

      // =====================================================
      // UPDATE FIRESTORE
      // =====================================================

      final Map<String, dynamic>
          updateData = {
        'name': cleanName,
        'email': email,
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (newPhotoUrl.isNotEmpty) {
        updateData['photoUrl'] =
            newPhotoUrl;

        updateData['photoPublicId'] =
            newPhotoPublicId;
      }

      await _firestore
         .collection('paitent')
          .doc(user.uid)
          .set(
            updateData,
            SetOptions(
              merge: true,
            ),
          );

      // =====================================================
      // DELETE OLD CLOUDINARY IMAGE
      //
      // Do this only AFTER the new image has successfully
      // uploaded and Firestore has been updated.
      // =====================================================

      if (image != null &&
          oldPublicId.isNotEmpty &&
          oldPublicId != newPhotoPublicId) {
        final bool deleted =
            await deleteCloudinaryImage(
          oldPublicId,
        );

        if (!deleted) {
          debugPrint(
            'OLD PROFILE IMAGE COULD NOT BE DELETED.',
          );
        }
      }

      // =====================================================
      // UPDATE LOCAL DATA
      // =====================================================

      userData['name'] =
          cleanName;

      if (newPhotoUrl.isNotEmpty) {
        userData['photoUrl'] =
            newPhotoUrl;

        userData['photoPublicId'] =
            newPhotoPublicId;
      }

      firebaseUser.value =
          _auth.currentUser;

      // =====================================================
      // SUCCESS
      // =====================================================

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE PROFILE ERROR => $e',
      );

      showMessage(
        'Unable to update profile. Please try again.',
        isError: true,
      );

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

 Future<void> logout() async {
  try {
    isLoading.value = true;

    // =========================================================
    // MARK USER OFFLINE BEFORE FIREBASE LOGOUT
    // =========================================================

    if (Get.isRegistered<UserPresenceController>()) {
      await Get.find<UserPresenceController>()
          .setOfflineBeforeLogout();
    } else {
      // Fallback in case UserPresenceController
      // is not registered.
      final User? user = _auth.currentUser;

      if (user != null) {
        await _firestore
           .collection('paitent')
            .doc(user.uid)
            .set(
          {
            'isOnline': false,
            'lastSeen': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    }

    // =========================================================
    // FIREBASE LOGOUT
    // =========================================================

    await _auth.signOut();

    firebaseUser.value = null;
    userData.clear();

    // =========================================================
    // GO TO LOGIN
    // =========================================================

    Get.offAll(
      () => LoginView(),
      transition: Transition.leftToRight,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  } catch (e) {
    debugPrint(
      'LOGOUT ERROR => $e',
    );

    showMessage(
      'Unable to logout. Please try again.',
      isError: true,
    );
  } finally {
    isLoading.value = false;
  }
}

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(
    String message, {
    bool isError = true,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      isError
          ? 'Error'
          : 'Success',
      message,
      snackPosition:
          SnackPosition.TOP,
      margin:
          const EdgeInsets.all(15),
      borderRadius: 12,
      backgroundColor:
          isError
              ? const Color(0xFF172534)
              : const Color(0xFF2196F3),
      colorText:
          Colors.white,
      duration:
          const Duration(
        seconds: 3,
      ),
    );
  }
}