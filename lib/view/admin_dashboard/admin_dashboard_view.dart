import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,

        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: darkText,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      controller.refreshAll();
                    },

              icon: const Icon(
                Icons.refresh_rounded,
                color: darkText,
              ),
            ),
          ),

          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Get.offAllNamed('/');
            },

            icon: const Icon(
              Icons.logout_rounded,
              color: darkText,
            ),
          ),
        ],
      ),

      body: Obx(
        () {
          return RefreshIndicator(
            color: blueColor,

            onRefresh: controller.refreshAll,

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.all(16),

              children: [
                _welcomeCard(),

                const SizedBox(height: 20),

                _stats(),

                const SizedBox(height: 22),

                _tabs(),

                const SizedBox(height: 15),

                _tabContent(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: borderColor,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,

            backgroundColor:
                Color(0xFFEAF7FF),

            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: blueColor,
              size: 32,
            ),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Welcome Admin',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Manage doctors, medicines and articles.',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 13,
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
  // STATS
  // ============================================================

  Widget _stats() {
    return Row(
      children: [
        Expanded(
          child: _stat(
            'Doctors',
            controller.doctors.length
                .toString(),
            Icons.medical_services_rounded,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _stat(
            'Medicines',
            controller.medicines.length
                .toString(),
            Icons.medication_rounded,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _stat(
            'Articles',
            controller.articles.length
                .toString(),
            Icons.article_rounded,
          ),
        ),
      ],
    );
  }

  Widget _stat(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: blueColor,
            size: 27,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              color: darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              color: greyText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _tabs() {
    final tabs = [
      'Doctors',
      'Medicines',
      'Articles',
    ];

    return Container(
      padding: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final bool selected =
                controller.selectedTab.value ==
                    index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.selectTab(index);
                },

                child: AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 11,
                  ),

                  decoration: BoxDecoration(
                    color: selected
                        ? blueColor
                        : Colors.transparent,

                    borderRadius:
                        BorderRadius.circular(10),
                  ),

                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : greyText,

                        fontSize: 13,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TAB CONTENT
  // ============================================================

  Widget _tabContent() {
    switch (controller.selectedTab.value) {
      case 0:
        return _doctors();

      case 1:
        return _medicines();

      case 2:
        return _articles();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // DOCTORS
  // ============================================================

  Widget _doctors() {
    return Column(
      children: [
        _addButton(
          title: 'Add Doctor',
          icon: Icons.person_add_alt_1_rounded,

          onTap: () async {
            await Get.to(
              () => AddDoctorView(),
            );

            await controller.loadDoctors();
          },
        ),

        const SizedBox(height: 12),

        if (controller.doctors.isEmpty)
          _empty('No doctors found.'),

        ...controller.doctors.map(
          (doctor) {
            final String name =
                doctor['name']?.toString() ??
                    'Doctor';

            final String specialist =
                doctor['specialist']?.toString() ??
                    'General';

            final String imageUrl =
                doctor['imageUrl']?.toString() ??
                    '';

            return _listCard(
              imageUrl: imageUrl,
              icon:
                  Icons.medical_services_rounded,

              title: name,
              subtitle: specialist,

              onDelete: () {
                final id =
                    doctor['id']?.toString();

                if (id != null) {
                  _confirmDeleteDoctor(id);
                }
              },

              onEdit: () async {
                await Get.to(
                  () => AddDoctorView(
                    existingData: doctor,
                  ),
                );

                await controller.loadDoctors();
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // MEDICINES
  // ============================================================

  Widget _medicines() {
    return Column(
      children: [
        _addButton(
          title: 'Add Medicine',
          icon: Icons.add_box_rounded,

          onTap: () async {
            await Get.to(
              () => AddMedicineView(),
            );

            await controller.loadMedicines();
          },
        ),

        const SizedBox(height: 12),

        if (controller.medicines.isEmpty)
          _empty('No medicines found.'),

        ...controller.medicines.map(
          (medicine) {
            final String name =
                medicine['name']?.toString() ??
                    'Medicine';

            final String category =
                medicine['category']?.toString() ??
                    '';

            final String imageUrl =
                medicine['imageUrl']?.toString() ??
                    '';

            return _listCard(
              imageUrl: imageUrl,
              icon: Icons.medication_rounded,

              title: name,
              subtitle: category,

              onDelete: () {
                final id =
                    medicine['id']?.toString();

                if (id != null) {
                  _confirmDeleteMedicine(id);
                }
              },

              onEdit: () async {
                await Get.to(
                  () => AddMedicineView(
                    existingData: medicine,
                  ),
                );

                await controller.loadMedicines();
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // ARTICLES
  // ============================================================

  Widget _articles() {
    return Column(
      children: [
        _addButton(
          title: 'Add Article',
          icon: Icons.post_add_rounded,

          onTap: () async {
            await Get.to(
              () => AddArticleView(),
            );

            await controller.loadArticles();
          },
        ),

        const SizedBox(height: 12),

        if (controller.articles.isEmpty)
          _empty('No articles found.'),

        ...controller.articles.map(
          (article) {
            final String title =
                article['title']?.toString() ??
                    'Article';

            final String category =
                article['category']?.toString() ??
                    '';

            final String imageUrl =
                article['imageUrl']?.toString() ??
                    '';

            return _listCard(
              imageUrl: imageUrl,
              icon: Icons.article_rounded,

              title: title,
              subtitle: category,

              onDelete: () {
                final id =
                    article['id']?.toString();

                if (id != null) {
                  _confirmDeleteArticle(id);
                }
              },

              onEdit: () async {
                await Get.to(
                  () => AddArticleView(
                    existingData: article,
                  ),
                );

                await controller.loadArticles();
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget _addButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton.icon(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: blueColor,
          foregroundColor: Colors.white,

          elevation: 0,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),

        icon: Icon(icon),

        label: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIST CARD
  // ============================================================

  Widget _listCard({
    required String imageUrl,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAF7FF),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),

              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (_, __, ___) {
                        return Icon(
                          icon,
                          color: blueColor,
                        );
                      },
                    )
                  : Icon(
                      icon,
                      color: blueColor,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: greyText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onEdit,

            icon: const Icon(
              Icons.edit_outlined,
              color: blueColor,
              size: 21,
            ),
          ),

          IconButton(
            onPressed: onDelete,

            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _empty(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: greyText,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DELETE DOCTOR
  // ============================================================

  void _confirmDeleteDoctor(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Doctor'),

        content: const Text(
          'Are you sure you want to delete this doctor?',
        ),

        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {
              Get.back();

              await controller.deleteDoctor(id);
            },

            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE MEDICINE
  // ============================================================

  void _confirmDeleteMedicine(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Medicine'),

        content: const Text(
          'Are you sure you want to delete this medicine?',
        ),

        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {
              Get.back();

              await controller.deleteMedicine(id);
            },

            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE ARTICLE
  // ============================================================

  void _confirmDeleteArticle(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Article'),

        content: const Text(
          'Are you sure you want to delete this article?',
        ),

        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {
              Get.back();

              await controller.deleteArticle(id);
            },

            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
