import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/medicine_controller.dart';

class MedicineView extends StatelessWidget {
  MedicineView({super.key});

  final MedicineController controller =
      Get.put(MedicineController());

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: RefreshIndicator(
          color: blue,
          onRefresh: controller.refreshMedicines,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            padding: EdgeInsets.fromLTRB(
              Get.width * .053,
              Get.height * .025,
              Get.width * .053,
              Get.height * .035,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =================================================
                // HEADER
                // =================================================

                Text(
                  'Medicine',
                  style: TextStyle(
                    color: darkText,
                    fontSize:
                        Get.width * .053,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .007,
                ),

                Text(
                  'Manage your prescribed medicines',
                  style: TextStyle(
                    color: greyText,
                    fontSize:
                        Get.width * .028,
                  ),
                ),

                // =================================================
                // MEDICINE SUMMARY
                // =================================================

                SizedBox(
                  height:
                      Get.height * .030,
                ),

                Obx(
                  () {
                    return Container(
                      width: double.infinity,

                      padding:
                          EdgeInsets.all(
                        Get.width * .040,
                      ),

                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFFD9F0FF),
                            Color(0xFFEAF7FF),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          Get.width * .040,
                        ),
                      ),

                      child: Row(
                        children: [

                          // =================================================
                          // MEDICINE ICON
                          // =================================================

                          Container(
                            width:
                                Get.width * .14,

                            height:
                                Get.width * .14,

                            decoration:
                                const BoxDecoration(
                              color:
                                  Colors.white,
                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                Icon(
                              Icons
                                  .medication_outlined,
                              color:
                                  blue,
                              size:
                                  Get.width * .070,
                            ),
                          ),

                          SizedBox(
                            width:
                                Get.width * .030,
                          ),

                          // =================================================
                          // SUMMARY TEXT
                          // =================================================

                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  'Active Medicines',
                                  style:
                                      TextStyle(
                                    color:
                                        darkText,
                                    fontSize:
                                        Get.width *
                                            .034,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      Get.height *
                                          .005,
                                ),

                                Text(
                                  '${controller.medicines.length} medicines prescribed',

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      TextStyle(
                                    color:
                                        greyText,
                                    fontSize:
                                        Get.width *
                                            .024,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // =================================================
                // TITLE
                // =================================================

                SizedBox(
                  height:
                      Get.height * .035,
                ),

                Text(
                  'My Medicines',
                  style: TextStyle(
                    color: darkText,
                    fontSize:
                        Get.width * .035,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .018,
                ),

                // =================================================
                // MEDICINE LIST
                // =================================================

                Obx(
                  () {

                    // =================================================
                    // LOADING
                    // =================================================

                    if (controller
                        .isLoading
                        .value) {
                      return const Padding(
                        padding:
                            EdgeInsets.only(
                          top: 30,
                        ),

                        child:
                            Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                blue,
                          ),
                        ),
                      );
                    }

                    // =================================================
                    // EMPTY
                    // =================================================

                    if (controller
                        .medicines
                        .isEmpty) {
                      return Container(
                        width:
                            double.infinity,

                        padding:
                            EdgeInsets.all(
                          Get.width * .050,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            Get.width * .035,
                          ),

                          border:
                              Border.all(
                            color:
                                borderColor,
                          ),
                        ),

                        child:
                            Column(
                          children: [

                            Icon(
                              Icons
                                  .medication_outlined,
                              size: 45,
                              color:
                                  greyText,
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              'No medicines prescribed',
                              style:
                                  TextStyle(
                                color:
                                    greyText,
                                fontSize:
                                    Get.width *
                                        .027,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // =================================================
                    // LIST
                    // =================================================

                    return ListView.builder(
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          controller
                              .medicines
                              .length,

                      itemBuilder:
                          (
                        context,
                        index,
                      ) {

                        final Map<String,
                                dynamic>
                            medicine =
                            controller
                                .medicines[
                                    index];

                        return _medicineItem(
                          medicine,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MEDICINE ITEM
  // =========================================================

  Widget _medicineItem(
    Map<String, dynamic> medicine,
  ) {
    final String imageUrl =
        medicine['imageUrl']
                ?.toString()
                .trim() ??
            '';

    final String name =
        medicine['name']
                ?.toString()
                .trim() ??
            '';

    final String category =
        medicine['category']
                ?.toString()
                .trim() ??
            '';

    final String dosage =
        medicine['dosage']
                ?.toString()
                .trim() ??
            '';

    final String price =
        medicine['price']
                ?.toString()
                .trim() ??
            '';

    final String manufacturer =
        medicine['manufacturer']
                ?.toString()
                .trim() ??
            '';

    return GestureDetector(
      onTap: () =>
          controller.showMedicineDetails(
        medicine,
      ),

      child: Container(
        width: double.infinity,

        margin:
            EdgeInsets.only(
          bottom:
              Get.height * .018,
        ),

        padding:
            EdgeInsets.all(
          Get.width * .030,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            Get.width * .037,
          ),

          border:
              Border.all(
            color:
                borderColor,
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =====================================================
            // MEDICINE IMAGE
            // =====================================================

            _medicineListImage(
              imageUrl,
            ),

            SizedBox(
              width:
                  Get.width * .030,
            ),

            // =====================================================
            // MEDICINE INFORMATION
            // =====================================================

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // =================================================
                  // NAME
                  // =================================================

                  Text(
                    name.isNotEmpty
                        ? name
                        : 'Medicine',

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

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

                  // =================================================
                  // CATEGORY
                  // =================================================

                  if (category.isNotEmpty) ...[
                    SizedBox(
                      height:
                          Get.height * .005,
                    ),

                    Text(
                      category,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          TextStyle(
                        color:
                            greyText,

                        fontSize:
                            Get.width * .024,

                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],

                  SizedBox(
                    height:
                        Get.height * .010,
                  ),

                  // =================================================
                  // DOSAGE + PRICE
                  // =================================================

                  Row(
                    children: [

                      if (dosage.isNotEmpty)
                        Flexible(
                          child:
                              _smallInfo(
                            Icons
                                .medication,
                            dosage,
                          ),
                        ),

                      if (dosage.isNotEmpty &&
                          price.isNotEmpty)
                        SizedBox(
                          width:
                              Get.width * .020,
                        ),

                      if (price.isNotEmpty)
                        Flexible(
                          child:
                              _smallInfo(
                            Icons
                                .attach_money,
                            price,
                          ),
                        ),
                    ],
                  ),

                  // =================================================
                  // MANUFACTURER
                  // =================================================

                  if (manufacturer.isNotEmpty) ...[
                    SizedBox(
                      height:
                          Get.height * .007,
                    ),

                    Text(
                      manufacturer,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          TextStyle(
                        color:
                            blue,

                        fontSize:
                            Get.width * .022,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // =====================================================
            // ARROW
            // =====================================================

            Padding(
              padding:
                  const EdgeInsets.only(
                top: 5,
              ),

              child:
                  Icon(
                Icons.arrow_forward_ios,
                color:
                    const Color(
                  0xFFB7C1C9,
                ),
                size:
                    Get.width * .038,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MEDICINE LIST IMAGE
  // =========================================================

  Widget _medicineListImage(
    String imageUrl,
  ) {
    return Container(
      width:
          Get.width * .16,

      height:
          Get.width * .16,

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEAF7FF),

        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),
      ),

      child:
          ClipRRect(
        borderRadius:
            BorderRadius.circular(
          Get.width * .030,
        ),

        child:
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,

                    width:
                        Get.width * .16,

                    height:
                        Get.width * .16,

                    fit:
                        BoxFit.cover,

                    loadingBuilder:
                        (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress ==
                          null) {
                        return child;
                      }

                      return const Center(
                        child:
                            SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                blue,
                          ),
                        ),
                      );
                    },

                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _medicineIcon();
                    },
                  )
                : _medicineIcon(),
      ),
    );
  }

  // =========================================================
  // MEDICINE ICON
  // =========================================================

  Widget _medicineIcon() {
    return const Center(
      child:
          Icon(
        Icons.medication_outlined,
        color:
            blue,
        size: 32,
      ),
    );
  }

  // =========================================================
  // SMALL INFO
  // =========================================================

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [

        Icon(
          icon,
          color:
              blue,
          size: 12,
        ),

        const SizedBox(
          width: 4,
        ),

        Flexible(
          child:
              Text(
            text,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                TextStyle(
              color:
                  greyText,

              fontSize:
                  Get.width * .020,
            ),
          ),
        ),
      ],
    );
  }
}