import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/home_controller.dart';
import 'package:medicalchat/controller/user_presence_controller.dart';
import 'package:medicalchat/view/chat/chat_view.dart';
import 'package:medicalchat/view/profile/profile_view.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller =
      Get.put(HomeController());

final UserPresenceController presenceController =
    Get.put(
  UserPresenceController(),
  permanent: true,
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

  static const Color background =
      Colors.white;

  static const Color lightBlue =
      Color(0xFFD9F0FF);

  static const Color borderColor =
      Color(0xFFDDE3E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      body: SafeArea(
        child: RefreshIndicator(
          color: blue,

          onRefresh:
              controller.refreshDoctors,

          child: CustomScrollView(
            physics:
                const BouncingScrollPhysics(
              parent:
                  AlwaysScrollableScrollPhysics(),
            ),

            slivers: [
              // =================================================
              // HEADER
              // =================================================

              SliverToBoxAdapter(
                child:
                    _header(),
              ),

              // =================================================
              // UPCOMING APPOINTMENT
              // =================================================

              SliverToBoxAdapter(
                child:
                    _appointmentSection(),
              ),

              // =================================================
              // SEARCH
              // =================================================

              SliverToBoxAdapter(
                child:
                    _searchBox(),
              ),

              // =================================================
              // CATEGORY TITLE
              // =================================================

              SliverToBoxAdapter(
                child:
                    _categoryTitle(),
              ),

              // =================================================
              // CATEGORY ICONS
              // =================================================

              SliverToBoxAdapter(
                child:
                    _categories(),
              ),

              // =================================================
              // DOCTORS
              // =================================================

              Obx(
                () {
                  if (controller
                      .isLoading
                      .value) {
                    return const SliverToBoxAdapter(
                      child:
                          Padding(
                        padding:
                            EdgeInsets.only(
                          top: 50,
                        ),
                        child:
                            Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                blue,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller
                      .hasError
                      .value) {
                    return SliverToBoxAdapter(
                      child:
                          _errorWidget(),
                    );
                  }

                  if (controller
                      .filteredDoctors
                      .isEmpty) {
                    return SliverToBoxAdapter(
                      child:
                          _noDoctorsWidget(),
                    );
                  }

                  return SliverPadding(
                    padding:
                        EdgeInsets.fromLTRB(
                      Get.width * .053,
                      Get.height * .018,
                      Get.width * .053,
                      Get.height * .040,
                    ),

                    sliver:
                        SliverList(
                      delegate:
                          SliverChildBuilderDelegate(
                        (
                          context,
                          index,
                        ) {
                          final doctor =
                              controller
                                  .filteredDoctors[index];

                          return _doctorCard(
                            doctor,
                          );
                        },

                        childCount:
                            controller
                                .filteredDoctors
                                .length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header() {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        Get.width * .053,
        Get.height * .020,
        Get.width * .053,
        Get.height * .020,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          // ---------------------------------------------------
          // TITLE
          // ---------------------------------------------------

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Find Doctor',

                  style:
                      TextStyle(
                    color:
                        darkText,
                    fontSize:
                        Get.width * .060,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .006,
                ),

                Text(
                  'The best from your phone',

                  style:
                      TextStyle(
                    color:
                        greyText,
                    fontSize:
                        Get.width * .030,
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------
          // CHAT
          // ---------------------------------------------------

          GestureDetector(
            onTap:
                controller.openChats,

            child:
                Container(
              width:
                  Get.width * .095,

              height:
                  Get.width * .095,

              decoration:
                  const BoxDecoration(
                color:
                    Colors.white,
                shape:
                    BoxShape.circle,
              ),

              child: _chatIconWithBadge(),
            ),
          ),

          SizedBox(
            width:
                Get.width * .025,
          ),

          // ---------------------------------------------------
          // PROFILE
          // ---------------------------------------------------

         // ---------------------------------------------------
// PROFILE
// ---------------------------------------------------

GestureDetector(
  onTap: () {
    Get.to(
      () => ProfileView(),
      transition: Transition.rightToLeft,
    );
  },

  child: Obx(
    () => Container(
      width: Get.width * .105,
      height: Get.width * .105,

      decoration: const BoxDecoration(
        color: lightBlue,
        shape: BoxShape.circle,
      ),

      clipBehavior: Clip.antiAlias,

      child: _profileImage(
        controller.userImage.value,
      ),
    ),
  ),
),
        ],
      ),
    );
  }



// =========================================================
// UNREAD CHAT BADGE
// =========================================================

Widget _chatIconWithBadge() {
  final String? uid =
      FirebaseAuth.instance.currentUser?.uid;

  if (uid == null || uid.isEmpty) {
    return Image.asset(
      'assets/chat.png',
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('chats')
        .where(
          'userId',
          isEqualTo: uid,
        )
        .snapshots(),
    builder: (context, snapshot) {
      int totalUnread = 0;

      if (snapshot.hasData) {
        for (final doc in snapshot.data!.docs) {
          final data =
              doc.data() as Map<String, dynamic>;

          final dynamic value =
              data['unreadUserCount'];

          if (value is int) {
            totalUnread += value;
          } else if (value is num) {
            totalUnread += value.toInt();
          } else if (value is String) {
            totalUnread +=
                int.tryParse(value) ?? 0;
          }
        }
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/chat.png',
          ),

          if (totalUnread > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  totalUnread > 99
                      ? '99+'
                      : totalUnread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
  // =========================================================
  // APPOINTMENT SECTION
  // =========================================================
  

  Widget _appointmentSection() {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal:
            Get.width * .053,
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(height: Get.height*.015,),
          Text(
            'Upcoming Appointment',

            style:
                TextStyle(
              color:
                  darkText,
              fontSize:
                  Get.width * .038,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(
            height:
                Get.height * .018,
          ),

          Obx(
            () {
              final appointment =
                  controller
                      .upcomingAppointment
                      .value;

            if (appointment == null) {
  return _noUpcomingAppointment();
}

              return _appointmentCard(
                appointment,
              );
            },
          ),
        ],
      ),
    );
  }



Widget _noUpcomingAppointment() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: Get.width * .035,
      vertical: Get.height * .025,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        Get.width * .040,
      ),
      border: Border.all(
        color: borderColor,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: Get.width * .105,
          height: Get.width * .105,
          decoration: const BoxDecoration(
            color: lightBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            color: blue,
          ),
        ),

        SizedBox(
          width: Get.width * .030,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'No upcoming appointment',
                style: TextStyle(
                  color: darkText,
                  fontSize: Get.width * .030,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(
                height: Get.height * .005,
              ),

              Text(
                'Book an appointment with a doctor.',
                style: TextStyle(
                  color: greyText,
                  fontSize: Get.width * .023,
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
  // APPOINTMENT CARD
  // =========================================================

  Widget _appointmentCard(
    Map<String, dynamic> appointment,
  ) {
    final String name =
        appointment['doctorName']
                ?.toString() ??
            appointment['name']
                ?.toString() ??
            'Doctor';

    final String specialist =
        appointment['specialist']
                ?.toString() ??
            appointment['doctorSpecialist']
                ?.toString() ??
            'General Specialist';

    final String image =
        appointment['doctorImage']
                ?.toString() ??
            appointment['imageUrl']
                ?.toString() ??
            '';

    final String time =
        appointment['time']
                ?.toString() ??
            '08:30';

    final dynamic dateValue =
        appointment[
            'appointmentDate'];

    String dateText =
        'Upcoming appointment';

    if (dateValue is Timestamp) {
      final DateTime date =
          dateValue.toDate();

      dateText =
          '${_month(date.month)} ${date.day}, ${date.year} at $time';
    } else if (dateValue
        is DateTime) {
      dateText =
          '${_month(dateValue.month)} ${dateValue.day}, ${dateValue.year} at $time';
    } else if (dateValue
        is String) {
      final DateTime? date =
          DateTime.tryParse(
        dateValue,
      );

      if (date != null) {
        dateText =
            '${_month(date.month)} ${date.day}, ${date.year} at $time';
      }
    }

    return Container(
      height:
          Get.height * .163,
       width: double.infinity,
      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .040,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      clipBehavior:
          Clip.antiAlias,

      child: Stack(
        children: [
          // ---------------------------------------------------
          // TEXT
          // ---------------------------------------------------

          Padding(
            padding:
                EdgeInsets.all(
              Get.width * .035,
            ),

            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

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
                        Get.width * .034,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .006,
                ),

                Text(
                  specialist,

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
                      Get.height * .014,
                ),

                Text(
                  dateText,

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
                      Get.height * .012,
                ),

               GestureDetector(
  onTap: () {
    final String doctorId =
        appointment['doctorId']?.toString() ??
            appointment['id']?.toString() ??
            '';

    if (doctorId.isEmpty) {
      Get.snackbar(
        'Chat Unavailable',
        'Doctor information is missing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: darkText,
      );
      return;
    }

    final Map<String, dynamic> doctorData = {
      'id': doctorId,
      'doctorId': doctorId,
      'name': appointment['doctorName']?.toString() ??
          appointment['doctor']?.toString() ??
          appointment['name']?.toString() ??
          'Doctor',
      'specialist': appointment['doctorSpecialist']?.toString() ??
          appointment['specialist']?.toString() ??
          'General Specialist',
      'imageUrl': appointment['doctorImage']?.toString() ??
          appointment['imageUrl']?.toString() ??
          '',
    };

    Get.to(
      () => ChatView(
        doctor: doctorData,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  },

  child: Container(
    padding: EdgeInsets.symmetric(
      horizontal: Get.width * .035,
      vertical: Get.height * .008,
    ),

    decoration: BoxDecoration(
      color: blue,

      borderRadius: BorderRadius.circular(
        Get.width * .025,
      ),
    ),

    child: Text(
      'Chat Now',

      style: TextStyle(
        color: Colors.white,
        fontSize: Get.width * .023,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),



              ],
            ),
          ),

          // ---------------------------------------------------
          // DOCTOR IMAGE
          // ---------------------------------------------------

          Positioned(
            right:
                -Get.width * .029,

            bottom:
                -Get.height*.086,

            child:
                Container(
              width:
                  Get.width * .3,

              height:
                  Get.height * .2,

              decoration:
                  const BoxDecoration(
                color:
                    blue,
                  shape: BoxShape.circle,
                // borderRadius:
                //     BorderRadius.only(
                //   topLeft:
                //       Radius.circular(
                //     90,
                //   ),

                //   bottomRight:
                //       Radius.circular(
                //     20,
                //   ),
                // ),
              ),

              // clipBehavior:
              //     Clip.antiAlias,

              // child:
              //     _doctorImage(
              //   image,
              // ),
            ),
          ),
          Positioned(
             right:
                -Get.width * .03,

            bottom:
                0,
            child: _doctorImage(image,),height: Get.height*.14,),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Widget _searchBox() {
    return Padding(
      padding:
          EdgeInsets.only(
        left:
            Get.width * .053,
        right:
            Get.width * .053,
        top:
            Get.height * .025,
      ),

      child:
          Container(
        height:
            Get.height * .062,

        decoration:
            BoxDecoration(
          color:
              Color(0xfff8f8fa),

          borderRadius:
              BorderRadius.circular(
            Get.width * .035,
          ),
        ),

        child:
            Row(
          children: [
            

            SizedBox(
              width:
                  Get.width * .035,
            ),

            Expanded(
              child:
                  TextField(
                controller:
                    controller
                        .searchController,

                style:
                    TextStyle(
                  color:
                      darkText,
                  fontSize:
                      Get.width * .027,
                ),

                decoration:
                    InputDecoration(
                  hintText:
                      'Doctor, specialty, or health issue...',

                  hintStyle:
                      TextStyle(
                    color:
                        const Color(
                      0xFFB4BDC5,
                    ),
                    fontSize:
                        Get.width * .024,
                  ),

                  border:
                      InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              width:
                  Get.width * .035,
            ),

            const Icon(
              Icons.search,
              color:
                  greyText,
            ),
            SizedBox(
              width:
                  Get.width * .035,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY TITLE
  // =========================================================

  Widget _categoryTitle() {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        Get.width * .053,
        Get.height * .030,
        Get.width * .053,
        Get.height * .010,
      ),

      child:
          Row(
        children: [
          Text(
            'Categories',

            style:
                TextStyle(
              color:
                  darkText,
              fontSize:
                  Get.width * .038,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap:
                controller
                    .viewAllCategories,
            child:
                Text(
              'View all',

              style:
                  TextStyle(
                color:
                    blue,
                fontSize:
                    Get.width * .032,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CATEGORIES
  // =========================================================

  Widget _categories() {
  return SizedBox(
    height: Get.height * .115,
    child: Obx(
      () => ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * .040,
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category =
              controller.categories[index];

          final bool selected =
              controller.selectedCategory.value
                      .toLowerCase() ==
                  category.firestoreName
                      .toLowerCase();

          return GestureDetector(
            onTap: () {
              controller.selectCategory(
                category,
              );
            },
            child: Container(
              width: Get.width * .190,
              margin: EdgeInsets.only(
                right: Get.width * .010,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    width: Get.width * .105,
                    height: Get.width * .105,
                    decoration: BoxDecoration(
                      color: selected
                          ? lightBlue
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: category.image != null
                          ? Image.asset(
                              category.image!,
                              width: Get.width * .065,
                              height: Get.width * .065,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              category.icon,
                              color: blue,
                              size: Get.width * .070,
                            ),
                    ),
                  ),

                  SizedBox(
                    height: Get.height * .008,
                  ),

                  Text(
                    category.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? blue
                          : greyText,
                      fontSize:
                          Get.width * .025,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
  // =========================================================
  // DOCTOR CARD
  // =========================================================

  Widget _doctorCard(
    Map<String, dynamic> doctor,
  ) {
    final String name =
        doctor['name']
                ?.toString() ??
            'Doctor';

    final String specialist =
        doctor['specialist']
                ?.toString() ??
            'General Specialist';

    final String rating =
        doctor['rating']
                ?.toString() ??
            '5.0';

    final String image =
        doctor['imageUrl']
                ?.toString() ??
            '';

    final bool online =
        doctor['online'] ==
            true;

    return GestureDetector(
      onTap: () =>
          controller
              .openDoctorDetail(
        doctor,
      ),

      child:
          Stack(children: [
             Container(
                   height:
          Get.height * .140,
          width: double.infinity,
            
                    decoration:
              BoxDecoration(
            color:
                Colors.white,
            
            borderRadius:
                BorderRadius.circular(
              Get.width * .040,
            ),
            
            border:
                Border.all(
              color:
                  borderColor,
            ),
                    ),
            
                    child:
              Padding(
                
                padding:  EdgeInsets.all(
              Get.width * .035,
            ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                            Get.width * .033,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                                    
                    SizedBox(
                      height:
                          Get.height * .006,
                    ),
                                    
                    Row(
                      children: [
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
                                Get.width * .025,
                          ),
                        ),
                       SizedBox(
                      width:
                          Get.width * .018,
                    ),
                                    
                         Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color:
                              Color(
                            0xFFFFC107,
                          ),
                          size:
                              13,
                        ),
                                    
                        const SizedBox(
                          width:
                              3,
                        ),
                                    
                        Text(
                          rating,
                                    
                          style:
                              TextStyle(
                            color:
                                darkText,
                            fontSize:
                                Get.width * .023,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                                    
                      ],
                    ),
                    
                    // -------------------------------------------------
                    // IMAGE
                    // -------------------------------------------------
                    
                      
                  ],
                ),
              ),
                  ),

               if(online)
              Positioned(
                        right:
                            13,               
                        top:
                            9,              
                        child:
                            Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                5,
                            vertical:
                                1,
                          ),
                                        
                          decoration:
                              BoxDecoration(
                            color:
                                Color(0xffcafed3),
                                        
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                                        
                          child:
                              Row(
                            children: [
                              Container(
                                width:
                                    6,
                                height:
                                    6,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color(0xff17d922),
                                  shape:
                                      BoxShape.circle,
                                ),
                              ),
                                        
                              const SizedBox(
                                width:
                                    3,
                              ),
                                        
                              const Text(
                                'ONLINE',
                                        
                                style:
                                    TextStyle(
                                  color:
                                       Color(0xff17d922),
                                  fontSize:
                                      6,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


               Positioned(
                 right:
                -Get.width * .06,

               bottom:
                -Get.height*.1,
                 child: Container(
                  width:
                  Get.width * .3,
                  height:
                   Get.height * .2,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xffebf1f6),
                    
                           shape: BoxShape.circle,
                          ),
                        ),
               ),
                Positioned(
             right:
                -Get.width * .0,

            bottom:
                0,
            child: _doctorImage(image,),height: Get.height*.10,),
                  
                  ],
          ),
    );
  }

  // =========================================================
  // DOCTOR IMAGE
  // =========================================================

  Widget _doctorImage(
    String imageUrl,
  ) {
    if (imageUrl.isEmpty) {
      return const Center(
        child:
            Icon(
          Icons.person,
          color:
              blue,
          size:
              55,
        ),
      );
    }

    return Image.network(
      imageUrl,

      fit:
          BoxFit.cover,

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return const Center(
          child:
              Icon(
            Icons.person,
            color:
                blue,
            size:
                55,
          ),
        );
      },
    );
  }

  // =========================================================
  // PROFILE IMAGE
  // =========================================================

  Widget _profileImage(
    String imageUrl,
  ) {
    if (imageUrl.isEmpty) {
      return const Center(
        child:
            Icon(
          Icons.person,
          color:
              blue,
          size:
              30,
        ),
      );
    }

    return Image.network(
      imageUrl,

      fit:
          BoxFit.cover,

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return const Center(
          child:
              Icon(
            Icons.person,
            color:
                blue,
            size:
                30,
          ),
        );
      },
    );
  }

  // =========================================================
  // NO DOCTORS
  // =========================================================

  Widget _noDoctorsWidget() {
    return Padding(
      padding:
          EdgeInsets.all(
        Get.width * .080,
      ),

      child:
          Column(
        children: [
          Icon(
            Icons
                .medical_services_outlined,

            color:
                blue,

            size:
                Get.width * .140,
          ),

          SizedBox(
            height:
                Get.height * .015,
          ),

          Text(
            'No doctors found',

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
                Get.height * .006,
          ),

          Text(
            'Try another search or category.',

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

  Widget _errorWidget() {
    return Padding(
      padding:
          EdgeInsets.all(
        Get.width * .080,
      ),

      child:
          Column(
        children: [
          const Icon(
            Icons.error_outline,
            color:
                Colors.red,
            size:
                45,
          ),

          SizedBox(
            height:
                Get.height * .012,
          ),

          const Text(
            'Unable to load doctors.',
          ),

          TextButton(
            onPressed:
                controller
                    .refreshDoctors,

            child:
                const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MONTH
  // =========================================================

  String _month(
    int month,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[
        month - 1];
  }
}