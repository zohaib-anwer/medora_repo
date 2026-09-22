import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicineController extends GetxController {
  // =========================================================
  // FIREBASE
  // =========================================================

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // MEDICINES
  // =========================================================

  final RxList<Map<String, dynamic>> medicines =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();
    loadMedicines();
  }

  // =========================================================
  // LOAD MEDICINES
  // =========================================================

  Future<void> loadMedicines() async {
    try {
      isLoading.value = true;

      final snapshot = await firestore
          .collection('medicines')
          .orderBy('name')
          .get();

      final List<Map<String, dynamic>> loadedMedicines =
          snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      medicines.assignAll(loadedMedicines);
    } on FirebaseException catch (e) {
      debugPrint(
        'LOAD MEDICINES FIREBASE ERROR: ${e.code} - ${e.message}',
      );

      showMessage(
        'Unable to load medicines.',
      );
    } catch (e) {
      debugPrint(
        'LOAD MEDICINES ERROR: $e',
      );

      showMessage(
        'Unable to load medicines.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // MEDICINE DETAILS
  // =========================================================

  void showMedicineDetails(
    Map<String, dynamic> medicine,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            14,
            24,
            24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // HANDLE
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFDDE3E9,
                      ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // IMAGE
                _medicineImage(
                  medicine,
                ),

                const SizedBox(height: 20),

                // NAME
                Text(
                  _stringValue(
                    medicine['name'],
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color: Color(
                      0xFF172534,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // CATEGORY
                if (_stringValue(
                  medicine['category'],
                ).isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFEAF7FF,
                      ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      _stringValue(
                        medicine['category'],
                      ),
                      style: const TextStyle(
                        color: Color(
                          0xFF2196F3,
                        ),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                _detailRow(
                  Icons.medication_outlined,
                  'Dosage',
                  medicine['dosage'],
                ),

                _detailRow(
                  Icons.attach_money,
                  'Price',
                  medicine['price'],
                ),

                _detailRow(
                  Icons.business_outlined,
                  'Manufacturer',
                  medicine['manufacturer'],
                ),

                if (_stringValue(
                  medicine['description'],
                ).isNotEmpty) ...[
                  const SizedBox(height: 12),

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color: Color(
                        0xFF172534,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _stringValue(
                      medicine['description'],
                    ),
                    style: const TextStyle(
                      height: 1.5,
                      color: Color(
                        0xFF647587,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // CLOSE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: Get.back,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF2196F3,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // =========================================================
  // MEDICINE IMAGE
  // =========================================================

  Widget _medicineImage(
    Map<String, dynamic> medicine,
  ) {
    final String imageUrl =
        _stringValue(
      medicine['imageUrl'],
    );

    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(
            0xFFF3F7FF,
          ),
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.medication_outlined,
          size: 70,
          color: Color(
            0xFF2196F3,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: double.infinity,
            height: 180,
            color: const Color(
              0xFFF3F7FF,
            ),
            child: const Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: Color(
                0xFF647587,
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow(
    IconData icon,
    String title,
    dynamic value,
  ) {
    final String text =
        _stringValue(value);

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(
              0xFF2196F3,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(
                    0xFF172534,
                  ),
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style:
                        const TextStyle(
                      color: Color(
                        0xFF647587,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshMedicines() async {
    await loadMedicines();
  }

  // =========================================================
  // HELPERS
  // =========================================================

  String _stringValue(
    dynamic value,
  ) {
    return value?.toString().trim() ?? '';
  }

  // =========================================================
  // MESSAGES
  // =========================================================

  void showMessage(
    String message,
  ) {
    Get.snackbar(
      'Error',
      message,
      snackPosition:
          SnackPosition.TOP,
      margin:
          const EdgeInsets.all(15),
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