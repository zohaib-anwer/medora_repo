import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/admin_controller.dart';
import 'package:medicalchat/view/admin/add_article_view.dart';
import 'package:medicalchat/view/admin/add_doctor_view.dart';
import 'package:medicalchat/view/admin/add_medicine_view.dart';

class AdminDashboardView extends StatelessWidget {
  AdminDashboardView({super.key});

  final AdminController controller =
      Get.put(AdminController());

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

        leading:
            IconButton(
          onPressed:
              Get.back,
          icon:
              Icon(
            Icons.arrow_back,
            color:
                darkText,
            size:
                Get.width * .065,
          ),
        ),

        title:
            Text(
          'Admin Panel',
          style:
              TextStyle(
            color:
                darkText,
            fontSize:
                Get.width * .050,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body:
          SafeArea(
        child:
            Obx(
          () {
            return Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        Get.width * .053,
                  ),
                  child:
                      SizedBox(
                    height:
                        Get.height * .055,
                    child:
                        Row(
                      children: [
                        _tab(
                          index: 0,
                          title:
                              'Doctors',
                          icon:
                              Icons.person_outline,
                        ),

                        SizedBox(
                          width:
                              Get.width * .020,
                        ),

                        _tab(
                          index: 1,
                          title:
                              'Medicine',
                          icon:
                              Icons.medication_outlined,
                        ),

                        SizedBox(
                          width:
                              Get.width * .020,
                        ),

                        _tab(
                          index: 2,
                          title:
                              'Articles',
                          icon:
                              Icons.article_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .020,
                ),

                Expanded(
                  child:
                      _buildSelectedList(),
                ),
              ],
            );
          },
        ),
      ),

      floatingActionButton:
          Obx(
        () {
          final selected =
              controller
                  .selectedTab.value;

          return FloatingActionButton(
            backgroundColor:
                blue,
            elevation:
                3,

            onPressed: () {
              if (selected == 0) {
                Get.to(
                  () =>
                      const AddDoctorView(),
                  transition:
                      Transition.rightToLeft,
                );
              } else if (selected == 1) {
                Get.to(
                  () =>
                   const    AddMedicineView(),
                  transition:
                      Transition.rightToLeft,
                );
              } else {
                Get.to(
                  () =>
                    const   AddArticleView(),
                  transition:
                      Transition.rightToLeft,
                );
              }
            },

            child:
                const Icon(
              Icons.add,
              color:
                  Colors.white,
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // TAB
  // ================================================================

  Widget _tab({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool selected =
        controller.selectedTab.value ==
            index;

    return Expanded(
      child:
          GestureDetector(
        behavior:
            HitTestBehavior.opaque,

        onTap: () {
          controller.selectTab(
            index,
          );
        },

        child:
            Container(
          decoration:
              BoxDecoration(
            color:
                selected
                    ? blue
                    : Colors.white,

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            border:
                Border.all(
              color:
                  selected
                      ? blue
                      : borderColor,
            ),
          ),

          child:
              Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                color:
                    selected
                        ? Colors.white
                        : greyText,
                size:
                    Get.width * .060,
              ),

              SizedBox(
                width:
                    Get.width * .012,
              ),

              Flexible(
                child:
                    Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        selected
                            ? Colors.white
                            : greyText,
                    fontSize:
                        Get.width * .032,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SELECTED LIST
  // ================================================================

  Widget _buildSelectedList() {
    switch (
        controller.selectedTab.value) {
      case 0:
        return _doctorList();

      case 1:
        return _medicineList();

      case 2:
        return _articleList();

      default:
        return const SizedBox();
    }
  }

  // ================================================================
  // DOCTOR LIST
  // ================================================================

  Widget _doctorList() {
    final doctors =
        controller.doctors;

    if (doctors.isEmpty) {
      return _emptyState(
        icon:
            Icons.person_outline,
        title:
            'No Doctors',
        subtitle:
            'Tap + to add a doctor.',
      );
    }

    return ListView.builder(
      physics:
          const BouncingScrollPhysics(),

      padding:
          EdgeInsets.fromLTRB(
        Get.width * .053,
        0,
        Get.width * .053,
        Get.height * .100,
      ),

      itemCount:
          doctors.length,

      itemBuilder:
          (context, index) {
        final doctor =
            doctors[index];

        return _adminCard(
          title:
              _stringValue(
            doctor['name'],
          ),

          subtitle:
              _stringValue(
            doctor['specialist'],
          ),

          imageUrl:
              _stringValue(
            doctor['imageUrl'],
          ),

          icon:
              Icons.person_outline,

          onEdit: () {
            _editDoctor(
              doctor,
            );
          },

          onDelete: () {
            _deleteDoctor(
              doctor,
            );
          },
        );
      },
    );
  }

  // ================================================================
  // MEDICINE LIST
  // ================================================================

  Widget _medicineList() {
    final medicines =
        controller.medicines;

    if (medicines.isEmpty) {
      return _emptyState(
        icon:
            Icons.medication_outlined,
        title:
            'No Medicines',
        subtitle:
            'Tap + to add a medicine.',
      );
    }

    return ListView.builder(
      physics:
          const BouncingScrollPhysics(),

      padding:
          EdgeInsets.fromLTRB(
        Get.width * .053,
        0,
        Get.width * .053,
        Get.height * .100,
      ),

      itemCount:
          medicines.length,

      itemBuilder:
          (context, index) {
        final medicine =
            medicines[index];

        return _adminCard(
          title:
              _stringValue(
            medicine['name'],
          ),

          // FIXED:
          // AddMedicine saves category.
          subtitle:
              _stringValue(
            medicine['category'],
          ),

          imageUrl:
              _stringValue(
            medicine['imageUrl'],
          ),

          icon:
              Icons.medication_outlined,

          onEdit: () {
            _editMedicine(
              medicine,
            );
          },

          onDelete: () {
            _deleteMedicine(
              medicine,
            );
          },
        );
      },
    );
  }

  // ================================================================
  // ARTICLE LIST
  // ================================================================

  Widget _articleList() {
    final articles =
        controller.articles;

    if (articles.isEmpty) {
      return _emptyState(
        icon:
            Icons.article_outlined,
        title:
            'No Articles',
        subtitle:
            'Tap + to add an article.',
      );
    }

    return ListView.builder(
      physics:
          const BouncingScrollPhysics(),

      padding:
          EdgeInsets.fromLTRB(
        Get.width * .053,
        0,
        Get.width * .053,
        Get.height * .100,
      ),

      itemCount:
          articles.length,

      itemBuilder:
          (context, index) {
        final article =
            articles[index];

        return _adminCard(
          title:
              _stringValue(
            article['title'],
          ),

          subtitle:
              _stringValue(
            article['category'],
          ),

          imageUrl:
              _stringValue(
            article['imageUrl'],
          ),

          icon:
              Icons.article_outlined,

          onEdit: () {
            _editArticle(
              article,
            );
          },

          onDelete: () {
            _deleteArticle(
              article,
            );
          },
        );
      },
    );
  }

  // ================================================================
  // EDIT
  // ================================================================

  void _editDoctor(
    Map<String, dynamic> doctor,
  ) {
    Get.to(
      () => AddDoctorView(
        existingData:
            doctor,
      ),
      transition:
          Transition.rightToLeft,
    );
  }

  void _editMedicine(
    Map<String, dynamic> medicine,
  ) {
    Get.to(
      () => AddMedicineView(
        existingData:
            medicine,
      ),
      transition:
          Transition.rightToLeft,
    );
  }

  void _editArticle(
    Map<String, dynamic> article,
  ) {
    Get.to(
      () => AddArticleView(
        existingData:
            article,
      ),
      transition:
          Transition.rightToLeft,
    );
  }

  // ================================================================
  // DELETE
  // ================================================================

  void _deleteDoctor(
    Map<String, dynamic> doctor,
  ) {
    final String id =
        _stringValue(
      doctor['id'],
    );

    if (id.isEmpty) {
      controller.showMessage(
        'Doctor ID not found.',
      );
      return;
    }

    _confirmDelete(
      title:
          'Delete Doctor',
      message:
          'Are you sure you want to delete this doctor?',
      delete: () async {
        await controller.deleteDoctor(
          id,
        );
      },
    );
  }

  void _deleteMedicine(
    Map<String, dynamic> medicine,
  ) {
    final String id =
        _stringValue(
      medicine['id'],
    );

    if (id.isEmpty) {
      controller.showMessage(
        'Medicine ID not found.',
      );
      return;
    }

    _confirmDelete(
      title:
          'Delete Medicine',
      message:
          'Are you sure you want to delete this medicine?',
      delete: () async {
        await controller.deleteMedicine(
          id,
        );
      },
    );
  }

  void _deleteArticle(
    Map<String, dynamic> article,
  ) {
    final String id =
        _stringValue(
      article['id'],
    );

    if (id.isEmpty) {
      controller.showMessage(
        'Article ID not found.',
      );
      return;
    }

    _confirmDelete(
      title:
          'Delete Article',
      message:
          'Are you sure you want to delete this article?',
      delete: () async {
        await controller.deleteArticle(
          id,
        );
      },
    );
  }

  // ================================================================
  // ADMIN CARD
  // ================================================================

  Widget _adminCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required IconData icon,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
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
          Row(
        children: [
          _cardImage(
            imageUrl,
            icon,
          ),

          SizedBox(
            width:
                Get.width * .030,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
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

                const SizedBox(
                  height: 5,
                ),

                Text(
                  subtitle,
                  maxLines: 2,
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
              ],
            ),
          ),

          IconButton(
            onPressed:
                onEdit,
            tooltip:
                'Edit',
            padding:
                EdgeInsets.zero,
            constraints:
                const BoxConstraints(),
            icon:
                const Icon(
              Icons.edit_outlined,
              color:
                  blue,
            ),
          ),

          SizedBox(
            width:
                Get.width * .025,
          ),

          IconButton(
            onPressed:
                onDelete,
            tooltip:
                'Delete',
            padding:
                EdgeInsets.zero,
            constraints:
                const BoxConstraints(),
            icon:
                const Icon(
              Icons.delete_outline,
              color:
                  Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD IMAGE
  // ================================================================

  Widget _cardImage(
    String imageUrl,
    IconData icon,
  ) {
    return Container(
      width:
          Get.width * .14,

      height:
          Get.width * .14,

      clipBehavior:
          Clip.antiAlias,

      decoration:
          const BoxDecoration(
        color:
            Color(0xFFEAF7FF),
        shape:
            BoxShape.circle,
      ),

      child:
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit:
                      BoxFit.cover,
                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      icon,
                      color:
                          blue,
                      size:
                          Get.width * .060,
                    );
                  },
                )
              : Icon(
                  icon,
                  color:
                      blue,
                  size:
                      Get.width * .060,
                ),
    );
  }

  // ================================================================
  // EMPTY
  // ================================================================

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child:
          Padding(
        padding:
            EdgeInsets.symmetric(
          horizontal:
              Get.width * .080,
        ),
        child:
            Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width:
                  Get.width * .20,
              height:
                  Get.width * .20,
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
                    Get.width * .090,
              ),
            ),

            SizedBox(
              height:
                  Get.height * .020,
            ),

            Text(
              title,
              style:
                  TextStyle(
                color:
                    darkText,
                fontSize:
                    Get.width * .040,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(
              height:
                  Get.height * .008,
            ),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    greyText,
                fontSize:
                    Get.width * .028,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // DELETE DIALOG
  // ================================================================

  void _confirmDelete({
    required String title,
    required String message,
    required Future<void> Function() delete,
  }) {
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

        titlePadding:
            EdgeInsets.fromLTRB(
          Get.width * .055,
          Get.height * .025,
          Get.width * .055,
          0,
        ),

        contentPadding:
            EdgeInsets.fromLTRB(
          Get.width * .055,
          Get.height * .015,
          Get.width * .055,
          0,
        ),

        actionsPadding:
            EdgeInsets.fromLTRB(
          Get.width * .035,
          Get.height * .010,
          Get.width * .035,
          Get.height * .020,
        ),

        title:
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
                    Color(0xFFFFEBEE),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.delete_outline,
                color:
                    Colors.red,
              ),
            ),

            SizedBox(
              width:
                  Get.width * .030,
            ),

            Expanded(
              child:
                  Text(
                title,
                style:
                    TextStyle(
                  color:
                      darkText,
                  fontSize:
                      Get.width * .042,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        content:
            Text(
          message,
          style:
              TextStyle(
            color:
                greyText,
            fontSize:
                Get.width * .030,
            height:
                1.4,
          ),
        ),

        actions: [
          TextButton(
            onPressed:
                Get.back,
            child:
                Text(
              'Cancel',
              style:
                  TextStyle(
                color:
                    greyText,
                fontSize:
                    Get.width * .030,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              Get.back();

              await delete();
            },

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
              foregroundColor:
                  Colors.white,
              elevation: 0,
              padding:
                  EdgeInsets.symmetric(
                horizontal:
                    Get.width * .045,
                vertical:
                    Get.height * .012,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),

            child:
                Text(
              'Delete',
              style:
                  TextStyle(
                fontSize:
                    Get.width * .030,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stringValue(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }
}