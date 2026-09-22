import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AdminController extends GetxController {
  // ============================================================
  // FIRESTORE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GETX
  // ============================================================

  final RxInt selectedTab = 0.obs;

  final RxBool isLoading = false.obs;

  final RxBool isLoadingDoctors = false.obs;
  final RxBool isLoadingMedicines = false.obs;
  final RxBool isLoadingArticles = false.obs;

  // ============================================================
  // LISTS
  // ============================================================

  final RxList<Map<String, dynamic>> doctors =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> medicines =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> articles =
      <Map<String, dynamic>>[].obs;

  // ============================================================
  // CLOUDINARY
  // ============================================================

  static const String cloudName = 'dvlvfm5ky';

  static const String uploadPreset =
      'bitebuddy_upload';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadDoctors();
    loadMedicines();
    loadArticles();
  }

  // ============================================================
  // TAB
  // ============================================================

  void selectTab(int index) {
    if (index < 0 || index > 2) {
      return;
    }

    selectedTab.value = index;
  }

  // ============================================================
  // REFRESH ALL
  // ============================================================

  Future<void> refreshAll() async {
    await Future.wait([
      loadDoctors(),
      loadMedicines(),
      loadArticles(),
    ]);
  }

  // ============================================================
  // CLOUDINARY UPLOAD
  // ============================================================

  Future<Map<String, String>?> uploadImage({
    required File image,
    required String folder,
  }) async {
    try {
      final Uri url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final http.MultipartRequest request =
          http.MultipartRequest(
        'POST',
        url,
      );

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      final http.StreamedResponse response =
          await request.send();

      final String responseData =
          await response.stream.bytesToString();

      debugPrint(
        'CLOUDINARY RESPONSE => $responseData',
      );

      final dynamic decoded =
          jsonDecode(responseData);

      if (decoded is! Map<String, dynamic>) {
        showMessage(
          'Invalid Cloudinary response.',
        );
        return null;
      }

      if (response.statusCode == 200) {
        final String secureUrl =
            _stringValue(
          decoded['secure_url'],
        );

        final String publicId =
            _stringValue(
          decoded['public_id'],
        );

        if (secureUrl.isEmpty ||
            publicId.isEmpty) {
          showMessage(
            'Cloudinary image information is missing.',
          );

          return null;
        }

        return {
          'imageUrl': secureUrl,
          'imagePublicId': publicId,
        };
      }

      debugPrint(
        'CLOUDINARY ERROR => $responseData',
      );

      showMessage(
        'Unable to upload image.',
      );

      return null;
    } catch (e) {
      debugPrint(
        'CLOUDINARY UPLOAD ERROR => $e',
      );

      showMessage(
        'Unable to upload image.',
      );

      return null;
    }
  }

  // ============================================================
  // CLOUDINARY DELETE
  //
  // IMPORTANT:
  // Never put Cloudinary API Secret inside Flutter.
  //
  // Replace the endpoint below with your own secure backend.
  // ============================================================

  Future<bool> deleteCloudinaryImage(
    String? publicId,
  ) async {
    if (publicId == null ||
        publicId.trim().isEmpty) {
      return true;
    }

    try {
      const String deleteApi =
          'https://YOUR-BACKEND-URL/delete-cloudinary-image';

      final http.Response response =
          await http.post(
        Uri.parse(deleteApi),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'publicId': publicId.trim(),
        }),
      );

      debugPrint(
        'CLOUDINARY DELETE RESPONSE => '
        '${response.statusCode} ${response.body}',
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        'CLOUDINARY DELETE ERROR => $e',
      );

      return false;
    }
  }

  // ============================================================
  // DOCTORS
  // ============================================================

  Future<void> loadDoctors() async {
    try {
      isLoadingDoctors.value = true;

      final QuerySnapshot<
          Map<String, dynamic>> snapshot =
          await _firestore
              .collection('doctors')
              .get();

      final List<Map<String, dynamic>> data =
          snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      data.sort(
        (a, b) => _compareCreatedAt(
          a['createdAt'],
          b['createdAt'],
        ),
      );

      doctors.assignAll(data);
    } catch (e) {
      debugPrint(
        'LOAD DOCTORS ERROR => $e',
      );

      showMessage(
        'Unable to load doctors.',
      );
    } finally {
      isLoadingDoctors.value = false;
    }
  }

  // ============================================================
  // ADD DOCTOR
  //
  // Creates:
  //
  // Firebase Authentication
  //        |
  //        +--> users/{uid}
  //        |
  //        +--> doctors/{uid}
  //
  // IMPORTANT:
  // Email verification is NOT required for doctor creation.
  //
  // If verification email fails, doctor is still created.
  //
  // The Admin account remains logged in because a secondary
  // Firebase app is used for doctor account creation.
  // ============================================================

  Future<bool> addDoctor(
    Map<String, dynamic> data, {
    required String email,
    required String password,
  }) async {
    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;

    User? createdUser;

    bool firestoreSaved = false;

    try {
      isLoading.value = true;

      // ----------------------------------------------------------
      // CLEAN EMAIL & PASSWORD
      // ----------------------------------------------------------

      final String cleanEmail =
          email.trim().toLowerCase();

      final String cleanPassword =
          password.trim();

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------

      if (cleanEmail.isEmpty) {
        showMessage(
          'Doctor email is required.',
        );

        return false;
      }

      if (cleanPassword.length < 6) {
        showMessage(
          'Doctor password must be at least 6 characters.',
        );

        return false;
      }

      // ----------------------------------------------------------
      // CHECK DUPLICATE EMAIL IN FIRESTORE
      // ----------------------------------------------------------

      final QuerySnapshot<
          Map<String, dynamic>> existingUsers =
          await _firestore
              .collection('paitent')
              .where(
                'email',
                isEqualTo: cleanEmail,
              )
              .limit(1)
              .get();

      if (existingUsers.docs.isNotEmpty) {
        showMessage(
          'A paitent or doctor already exists with this email.',
        );

        return false;
      }

      // ----------------------------------------------------------
      // CREATE SECONDARY FIREBASE APP
      // ----------------------------------------------------------

      final FirebaseApp primaryApp =
          Firebase.app();

      final String appName =
          'doctorCreation_${DateTime.now().millisecondsSinceEpoch}';

      secondaryApp =
          await Firebase.initializeApp(
        name: appName,
        options: primaryApp.options,
      );

      secondaryAuth =
          FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      // ----------------------------------------------------------
      // CREATE DOCTOR FIREBASE AUTH ACCOUNT
      // ----------------------------------------------------------

      debugPrint(
        'CREATING DOCTOR AUTH ACCOUNT => $cleanEmail',
      );

      final UserCredential credential =
          await secondaryAuth
              .createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      createdUser = credential.user;

      if (createdUser == null) {
        showMessage(
          'Unable to create doctor account.',
        );

        return false;
      }

      final String doctorUid =
          createdUser.uid;

      debugPrint(
        'DOCTOR AUTH CREATED => $doctorUid',
      );

      // ----------------------------------------------------------
      // DOCTOR NAME
      // ----------------------------------------------------------

      final String doctorName =
          _stringValue(
        data['name'],
      );

      if (doctorName.isNotEmpty) {
        try {
          await createdUser.updateDisplayName(
            doctorName,
          );
        } catch (e) {
          debugPrint(
            'UPDATE DOCTOR DISPLAY NAME ERROR => $e',
          );
        }
      }

      // ----------------------------------------------------------
      // EMAIL VERIFICATION
      //
      // IMPORTANT:
      // This must NOT stop doctor creation.
      //
      // If Firebase cannot send the email, we only log the
      // error and continue with Firestore creation.
      // ----------------------------------------------------------

      try {
        await createdUser.sendEmailVerification();

        debugPrint(
          'DOCTOR VERIFICATION EMAIL SENT => $cleanEmail',
        );
      } catch (e) {
        debugPrint(
          'VERIFICATION EMAIL ERROR => $e',
        );

        // Do NOT return false here.
        // Doctor creation continues.
      }

      // ----------------------------------------------------------
      // DOCTOR DATA
      // ----------------------------------------------------------

      final Map<String, dynamic> doctorData =
          Map<String, dynamic>.from(data);

      // Never save password.
      doctorData.remove('password');
      doctorData.remove('confirmPassword');

      // ID is Firestore generated/managed separately.
      doctorData.remove('id');

      doctorData['uid'] =
          doctorUid;

      doctorData['email'] =
          cleanEmail;

      doctorData['role'] =
          'doctor';

      doctorData['isActive'] =
          true;

      doctorData['emailVerified'] =
          false;

      doctorData['createdAt'] =
          FieldValue.serverTimestamp();

      doctorData['updatedAt'] =
          FieldValue.serverTimestamp();

      // ----------------------------------------------------------
      // USER DATA
      // ----------------------------------------------------------

      final Map<String, dynamic> userData = {
        'uid': doctorUid,
        'name': doctorName,
        'email': cleanEmail,
        'role': 'doctor',
        'isActive': true,
        'emailVerified': false,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      final String phone =
          _stringValue(
        data['phone'],
      );

      if (phone.isNotEmpty) {
        userData['phone'] =
            phone;
      }

      // ----------------------------------------------------------
      // FIRESTORE BATCH
      // ----------------------------------------------------------

      final WriteBatch batch =
          _firestore.batch();

      batch.set(
        _firestore
           .collection('paitent')
            .doc(doctorUid),
        userData,
      );

      batch.set(
        _firestore
            .collection('doctors')
            .doc(doctorUid),
        doctorData,
      );

      debugPrint(
        'SAVING DOCTOR TO FIRESTORE => $doctorUid',
      );

      await batch.commit();

      firestoreSaved = true;

      debugPrint(
        'DOCTOR FIRESTORE SAVE SUCCESS => $doctorUid',
      );

      // ----------------------------------------------------------
      // REFRESH DOCTOR LIST
      //
      // IMPORTANT:
      // If refresh fails, doctor creation is still successful.
      // ----------------------------------------------------------

      try {
        await loadDoctors();

        debugPrint(
          'DOCTOR LIST REFRESH SUCCESS',
        );
      } catch (e) {
        debugPrint(
          'LOAD DOCTORS AFTER ADD ERROR => $e',
        );
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      showSuccess(
        'Doctor account created successfully.',
      );

      debugPrint(
        'ADD DOCTOR COMPLETED SUCCESSFULLY',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'ADD DOCTOR AUTH ERROR => '
        '${e.code}: ${e.message}',
      );

      // ----------------------------------------------------------
      // ROLLBACK AUTH
      //
      // Only rollback when Firestore was NOT saved.
      // ----------------------------------------------------------

      if (createdUser != null &&
          !firestoreSaved) {
        try {
          await createdUser.delete();

          debugPrint(
            'DOCTOR AUTH ROLLBACK SUCCESS',
          );
        } catch (deleteError) {
          debugPrint(
            'ROLLBACK AUTH ERROR => $deleteError',
          );
        }
      }

      showMessage(
        _firebaseDoctorErrorMessage(
          e.code,
        ),
      );

      return false;
    } catch (e) {
      debugPrint(
        'ADD DOCTOR ERROR => $e',
      );

      // ----------------------------------------------------------
      // ROLLBACK AUTH
      //
      // Only rollback when Firestore was NOT saved.
      // ----------------------------------------------------------

      if (createdUser != null &&
          !firestoreSaved) {
        try {
          await createdUser.delete();

          debugPrint(
            'DOCTOR AUTH ROLLBACK SUCCESS',
          );
        } catch (deleteError) {
          debugPrint(
            'ROLLBACK AUTH ERROR => $deleteError',
          );
        }
      }

      showMessage(
        'Unable to create doctor account.',
      );

      return false;
    } finally {
      isLoading.value = false;

      // ----------------------------------------------------------
      // DELETE SECONDARY APP
      // ----------------------------------------------------------

      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();

          debugPrint(
            'SECONDARY FIREBASE APP DELETED',
          );
        } catch (e) {
          debugPrint(
            'SECONDARY APP DELETE ERROR => $e',
          );
        }
      }
    }
  }

  // ============================================================
  // UPDATE DOCTOR
  //
  // IMPORTANT:
  // This updates profile information only.
  //
  // Doctor email/password are NOT changed here.
  // ============================================================

  Future<bool> updateDoctor(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;

      final DocumentReference<
          Map<String, dynamic>> doctorRef =
          _firestore
              .collection('doctors')
              .doc(id);

      final DocumentSnapshot<
          Map<String, dynamic>> doctorSnapshot =
          await doctorRef.get();

      if (!doctorSnapshot.exists) {
        showMessage(
          'Doctor not found.',
        );

        return false;
      }

      final Map<String, dynamic> cleanData =
          Map<String, dynamic>.from(data);

      // --------------------------------------------------------
      // Never update these from profile form.
      // --------------------------------------------------------

      cleanData.remove('id');
      cleanData.remove('uid');
      cleanData.remove('password');
      cleanData.remove('confirmPassword');
      cleanData.remove('email');

      cleanData['updatedAt'] =
          FieldValue.serverTimestamp();

      // --------------------------------------------------------
      // Update doctor profile.
      // --------------------------------------------------------

      await doctorRef.update(
        cleanData,
      );

      // --------------------------------------------------------
      // Keep users/{uid} profile synchronized.
      // --------------------------------------------------------

      final Map<String, dynamic> userData =
          {};

      if (data.containsKey('name')) {
        userData['name'] =
            _stringValue(data['name']);
      }

      if (data.containsKey('phone')) {
        userData['phone'] =
            _stringValue(data['phone']);
      }

      if (data.containsKey('imageUrl')) {
        userData['imageUrl'] =
            _stringValue(data['imageUrl']);
      }

      userData['updatedAt'] =
          FieldValue.serverTimestamp();

      await _firestore
         .collection('paitent')
          .doc(id)
          .set(
            userData,
            SetOptions(merge: true),
          );

      // --------------------------------------------------------
      // Refresh list
      // --------------------------------------------------------

      await loadDoctors();

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      showSuccess(
        'Doctor updated successfully.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE DOCTOR ERROR => $e',
      );

      showMessage(
        'Unable to update doctor.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE DOCTOR
  //
  // Client-side Firebase Auth cannot delete another user's Auth
  // account while Admin is signed in.
  //
  // Therefore:
  // - doctors/{uid} is deleted
  // - users/{uid} is deleted
  // - Cloudinary image is deleted
  //
  // For complete Auth deletion, use Firebase Admin SDK /
  // Cloud Function later.
  // ============================================================

  Future<void> deleteDoctor(
    String id,
  ) async {
    try {
      isLoading.value = true;

      final DocumentSnapshot<
          Map<String, dynamic>> doctorSnapshot =
          await _firestore
              .collection('doctors')
              .doc(id)
              .get();

      if (!doctorSnapshot.exists) {
        showMessage(
          'Doctor not found.',
        );

        return;
      }

      final Map<String, dynamic>? data =
          doctorSnapshot.data();

      final String publicId =
          _stringValue(
        data?['imagePublicId'],
      );

      final String storedUid =
          _stringValue(
        data?['uid'],
      );

      final String doctorUid =
          storedUid.isNotEmpty
              ? storedUid
              : id;

      // --------------------------------------------------------
      // Delete doctor profile.
      // --------------------------------------------------------

      await _firestore
          .collection('doctors')
          .doc(id)
          .delete();

      // --------------------------------------------------------
      // Delete common user profile.
      // --------------------------------------------------------

      await _firestore
          .collection('paitent')
          .doc(doctorUid)
          .delete();

      // --------------------------------------------------------
      // Delete Cloudinary image.
      // --------------------------------------------------------

      if (publicId.isNotEmpty) {
        await deleteCloudinaryImage(
          publicId,
        );
      }

      // --------------------------------------------------------
      // Refresh doctor list.
      // --------------------------------------------------------

      await loadDoctors();

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      showSuccess(
        'Doctor deleted successfully.',
      );
    } catch (e) {
      debugPrint(
        'DELETE DOCTOR ERROR => $e',
      );

      showMessage(
        'Unable to delete doctor.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // MEDICINES
  // ============================================================

  Future<void> loadMedicines() async {
    try {
      isLoadingMedicines.value = true;

      final QuerySnapshot<
          Map<String, dynamic>> snapshot =
          await _firestore
              .collection('medicines')
              .get();

      final List<Map<String, dynamic>> data =
          snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      data.sort(
        (a, b) => _compareCreatedAt(
          a['createdAt'],
          b['createdAt'],
        ),
      );

      medicines.assignAll(data);
    } catch (e) {
      debugPrint(
        'LOAD MEDICINES ERROR => $e',
      );

      showMessage(
        'Unable to load medicines.',
      );
    } finally {
      isLoadingMedicines.value = false;
    }
  }

  // ============================================================
  // ADD MEDICINE
  // ============================================================

  Future<bool> addMedicine(
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;

      await _firestore
          .collection('medicines')
          .add({
        ...data,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      await loadMedicines();

      showSuccess(
        'Medicine added successfully.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'ADD MEDICINE ERROR => $e',
      );

      showMessage(
        'Unable to add medicine.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // UPDATE MEDICINE
  // ============================================================

  Future<bool> updateMedicine(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;

      await _firestore
          .collection('medicines')
          .doc(id)
          .update({
        ...data,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      await loadMedicines();

      showSuccess(
        'Medicine updated successfully.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE MEDICINE ERROR => $e',
      );

      showMessage(
        'Unable to update medicine.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE MEDICINE
  // ============================================================

  Future<void> deleteMedicine(
    String id,
  ) async {
    try {
      isLoading.value = true;

      final DocumentSnapshot<
          Map<String, dynamic>> snapshot =
          await _firestore
              .collection('medicines')
              .doc(id)
              .get();

      if (!snapshot.exists) {
        showMessage(
          'Medicine not found.',
        );

        return;
      }

      final Map<String, dynamic>? data =
          snapshot.data();

      final String publicId =
          _stringValue(
        data?['imagePublicId'],
      );

      await _firestore
          .collection('medicines')
          .doc(id)
          .delete();

      if (publicId.isNotEmpty) {
        await deleteCloudinaryImage(
          publicId,
        );
      }

      await loadMedicines();

      showSuccess(
        'Medicine deleted successfully.',
      );
    } catch (e) {
      debugPrint(
        'DELETE MEDICINE ERROR => $e',
      );

      showMessage(
        'Unable to delete medicine.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // ARTICLES
  // ============================================================

  Future<void> loadArticles() async {
    try {
      isLoadingArticles.value = true;

      final QuerySnapshot<
          Map<String, dynamic>> snapshot =
          await _firestore
              .collection('articles')
              .get();

      final List<Map<String, dynamic>> data =
          snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      data.sort(
        (a, b) => _compareCreatedAt(
          a['createdAt'],
          b['createdAt'],
        ),
      );

      articles.assignAll(data);
    } catch (e) {
      debugPrint(
        'LOAD ARTICLES ERROR => $e',
      );

      showMessage(
        'Unable to load articles.',
      );
    } finally {
      isLoadingArticles.value = false;
    }
  }

  // ============================================================
  // ADD ARTICLE
  // ============================================================

  Future<bool> addArticle(
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;

      await _firestore
          .collection('articles')
          .add({
        ...data,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      await loadArticles();

      showSuccess(
        'Article added successfully.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'ADD ARTICLE ERROR => $e',
      );

      showMessage(
        'Unable to add article.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // UPDATE ARTICLE
  // ============================================================

  Future<bool> updateArticle(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;

      await _firestore
          .collection('articles')
          .doc(id)
          .update({
        ...data,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      await loadArticles();

      showSuccess(
        'Article updated successfully.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE ARTICLE ERROR => $e',
      );

      showMessage(
        'Unable to update article.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE ARTICLE
  // ============================================================

  Future<void> deleteArticle(
    String id,
  ) async {
    try {
      isLoading.value = true;

      final DocumentSnapshot<
          Map<String, dynamic>> snapshot =
          await _firestore
              .collection('articles')
              .doc(id)
              .get();

      if (!snapshot.exists) {
        showMessage(
          'Article not found.',
        );

        return;
      }

      final Map<String, dynamic>? data =
          snapshot.data();

      final String publicId =
          _stringValue(
        data?['imagePublicId'],
      );

      await _firestore
          .collection('articles')
          .doc(id)
          .delete();

      if (publicId.isNotEmpty) {
        await deleteCloudinaryImage(
          publicId,
        );
      }

      await loadArticles();

      showSuccess(
        'Article deleted successfully.',
      );
    } catch (e) {
      debugPrint(
        'DELETE ARTICLE ERROR => $e',
      );

      showMessage(
        'Unable to delete article.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FIREBASE DOCTOR ERROR
  // ============================================================

  String _firebaseDoctorErrorMessage(
    String code,
  ) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      case 'operation-not-allowed':
        return 'Email/password authentication is disabled.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      default:
        return 'Unable to create doctor account.';
    }
  }

  // ============================================================
  // SORT
  // ============================================================

  int _compareCreatedAt(
    dynamic a,
    dynamic b,
  ) {
    final DateTime? dateA =
        _dateFromValue(a);

    final DateTime? dateB =
        _dateFromValue(b);

    if (dateA == null &&
        dateB == null) {
      return 0;
    }

    if (dateA == null) {
      return 1;
    }

    if (dateB == null) {
      return -1;
    }

    return dateB.compareTo(dateA);
  }

  // ============================================================
  // DATE CONVERTER
  // ============================================================

  DateTime? _dateFromValue(
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

  // ============================================================
  // STRING
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
  // SUCCESS
  // ============================================================

  void showSuccess(
    String message,
  ) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      backgroundColor:
          const Color(0xFF2196F3),
      colorText: Colors.white,
      duration:
          const Duration(seconds: 2),
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void showMessage(
    String message,
  ) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      backgroundColor:
          const Color(0xFF172534),
      colorText: Colors.white,
      duration:
          const Duration(seconds: 3),
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
    );
  }
}