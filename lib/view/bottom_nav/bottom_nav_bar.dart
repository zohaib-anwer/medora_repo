import 'package:flutter/material.dart';
import 'package:medicalchat/view/article/article_view.dart';
import 'package:medicalchat/view/consult/consult_view.dart';
import 'package:medicalchat/view/home/home_view.dart';
import 'package:medicalchat/view/medicine/medicine_view.dart';
import 'package:medicalchat/view/status/status_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() =>
      _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int pageIndex = 0;

  final List<Widget> pages = [
    HomeView(),
    ConsultView(),
    StatusView(),
    MedicineView(),
    ArticleView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: pages[pageIndex],

      bottomNavigationBar:
          buildMyNavBar(context),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION BAR
  // =========================================================

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,

      decoration: const BoxDecoration(
        color: Colors.white,

        // =====================================================
        // BOX SHADOW
        // =====================================================

        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(
              0,
              -3,
            ),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.only(
          top: 5.0,
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [
            // =================================================
            // HOME
            // =================================================

            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 0;
                });
              },

              icon: pageIndex == 0
                  ? const Icon(
                      Icons.home_filled,
                      size: 25,
                      color: Colors.blue,
                    )
                  : Image.asset(
                      'assets/home3.png',
                      height: 20,
                    ),
            ),

            // =================================================
            // CONSULT
            // =================================================

            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 1;
                });
              },

              icon: pageIndex == 1
                  ? Image.asset(
                      'assets/consult3.png',
                      height: 20,
                    )
                  : Image.asset(
                      'assets/consult2.png',
                      height: 20,
                    ),
            ),

            // =================================================
            // STATUS
            // =================================================

            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 2;
                });
              },

              icon: pageIndex == 2
                  ? Image.asset(
                      'assets/status3.png',
                      height: 20,
                    )
                  : Image.asset(
                      'assets/status1.png',
                      height: 20,
                    ),
            ),

            // =================================================
            // MEDICINE
            // =================================================

            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 3;
                });
              },

              icon: pageIndex == 3
                  ? const Icon(
                      Icons.medical_services,
                      size: 25,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.medical_services_outlined,
                      size: 25,
                      color: Color(0xffd0d7d9),
                    ),
            ),

            // =================================================
            // ARTICLE
            // =================================================

            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 4;
                });
              },

              icon: pageIndex == 4
                  ? const Icon(
                      Icons.article,
                      size: 25,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.article_outlined,
                      size: 25,
                      color: Color(0xffd0d7d9),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}