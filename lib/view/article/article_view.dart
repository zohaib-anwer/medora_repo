import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/article_controller.dart';

class ArticleView extends StatelessWidget {
  ArticleView({super.key});

  final ArticleController controller =
      Get.put(ArticleController());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              controller.refreshArticles,

          color: blue,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent:
                  BouncingScrollPhysics(),
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
                  'Article',
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
                  'Health tips from medical professionals',
                  style: TextStyle(
                    color: greyText,
                    fontSize:
                        Get.width * .028,
                  ),
                ),

                // =================================================
                // FEATURED ARTICLE
                // =================================================

                SizedBox(
                  height:
                      Get.height * .030,
                ),

                Obx(() {

                  if (controller
                      .isLoading
                      .value &&
                      controller
                          .articles
                          .isEmpty) {
                    return SizedBox(
                      height:
                          Get.height * .200,

                      child: const Center(
                        child:
                            CircularProgressIndicator(
                          color: blue,
                        ),
                      ),
                    );
                  }

                  if (controller
                      .articles
                      .isEmpty) {
                    return _emptyFeatured();
                  }

                  final article =
                      controller
                          .articles[0];

                  return GestureDetector(
                    onTap: () {
                      controller.openArticle(
                        Map<String, dynamic>.from(
                          article,
                        ),
                      );
                    },

                    child:
                        _featuredArticle(
                      article,
                    ),
                  );
                }),

                // =================================================
                // CATEGORIES
                // =================================================

                SizedBox(
                  height:
                      Get.height * .035,
                ),

                Text(
                  'Categories',
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
                      Get.height * .017,
                ),

                SizedBox(
                  height:
                      Get.height * .050,

                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal,

                    itemCount:
                        controller
                            .categories
                            .length,

                    itemBuilder:
                        (context, index) {

                      return _categoryItem(
                        index,
                      );
                    },
                  ),
                ),

                // =================================================
                // LATEST ARTICLES
                // =================================================

                SizedBox(
                  height:
                      Get.height * .035,
                ),

                Text(
                  'Latest Articles',
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

                Obx(() {

                  if (controller
                      .isLoading
                      .value) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: blue,
                      ),
                    );
                  }

                  final articles =
                      controller
                          .filteredArticles;

                  if (articles.isEmpty) {
                    return _emptyArticles();
                  }

                  return ListView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        articles.length,

                    itemBuilder:
                        (context, index) {

                      return _articleItem(
                        articles[index],
                        index,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // FEATURED ARTICLE
  // =========================================================

  Widget _featuredArticle(
    Map<String, dynamic> article,
  ) {
    final title =
        article['title']
                ?.toString() ??
            'Health Article';

    final time =
        controller.getArticleTime(
      article,
    );

    return Container(
      width: double.infinity,

      height:
          Get.height * .230,

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          Get.width * .040,
        ),

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
      ),

      child: Stack(
        children: [

          Padding(
            padding:
                EdgeInsets.all(
              Get.width * .040,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // FEATURED BADGE

                Container(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        Get.width * .022,

                    vertical:
                        Get.height * .006,
                  ),

                  decoration:
                      BoxDecoration(
                    color: blue,

                    borderRadius:
                        BorderRadius.circular(
                      Get.width * .018,
                    ),
                  ),

                  child: Text(
                    'Featured',

                    style:
                        TextStyle(
                      color:
                          Colors.white,

                      fontSize:
                          Get.width * .021,

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      Get.height * .018,
                ),

                SizedBox(
                  width:
                      Get.width * .55,

                  child: Text(
                    title,

                    maxLines: 3,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        TextStyle(
                      color:
                          darkText,

                      fontSize:
                          Get.width * .040,

                      fontWeight:
                          FontWeight.bold,

                      height: 1.15,
                    ),
                  ),
                ),

                const Spacer(),

                if (time.isNotEmpty)
                  Text(
                    time,

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

          // =====================================================
          // YELLOW CIRCLE
          // =====================================================

          Positioned(
            right:
                -Get.width * .02,

            bottom:
                Get.height * .015,

            child: Container(
              width:
                  Get.width * .30,

              height:
                  Get.width * .30,

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFFFD34E),

                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                Icons
                    .health_and_safety_outlined,

                color:
                    Colors.white,

                size:
                    Get.width * .15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY FEATURED
  // =========================================================

  Widget _emptyFeatured() {
    return Container(
      width: double.infinity,

      height:
          Get.height * .150,

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

      child: Center(
        child: Text(
          'No featured article',

          style: TextStyle(
            color: greyText,

            fontSize:
                Get.width * .027,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY
  // =========================================================

  Widget _categoryItem(
    int index,
  ) {
    return Obx(() {

      final selected =
          controller
              .selectedCategory
              .value ==
              index;

      return GestureDetector(
        onTap: () {
          controller.selectCategory(
            index,
          );
        },

        child: Container(
          margin:
              EdgeInsets.only(
            right:
                Get.width * .020,
          ),

          padding:
              EdgeInsets.symmetric(
            horizontal:
                Get.width * .035,
          ),

          alignment:
              Alignment.center,

          decoration:
              BoxDecoration(
            color: selected
                ? blue
                : Colors.white,

            borderRadius:
                BorderRadius.circular(
              Get.width * .025,
            ),

            border: Border.all(
              color: selected
                  ? blue
                  : borderColor,
            ),
          ),

          child: Text(
            controller
                .categories[index],

            style: TextStyle(
              color: selected
                  ? Colors.white
                  : greyText,

              fontSize:
                  Get.width * .024,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  // =========================================================
  // EMPTY ARTICLES
  // =========================================================

  Widget _emptyArticles() {
    return Container(
      width: double.infinity,

      padding:
          EdgeInsets.all(
        Get.width * .050,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          Get.width * .035,
        ),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Center(
        child: Text(
          'No articles available',

          style: TextStyle(
            color: greyText,

            fontSize:
                Get.width * .027,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ARTICLE ITEM
  // =========================================================

  Widget _articleItem(
    Map<String, dynamic> article,
    int index,
  ) {
    final title =
        article['title']
                ?.toString() ??
            'Health Article';

    final category =
        article['category']
                ?.toString() ??
            '';

    final time =
        controller.getArticleTime(
      article,
    );

    return GestureDetector(
      onTap: () {
        controller.openArticle(
          Map<String, dynamic>.from(
            article,
          ),
        );
      },

      child: Container(
        width: double.infinity,

        margin:
            EdgeInsets.only(
          bottom:
              Get.height * .018,
        ),

        decoration:
            BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            Get.width * .037,
          ),

          border: Border.all(
            color: borderColor,
          ),
        ),

        child: Row(
          children: [

            // ===================================================
            // ICON AREA
            // ===================================================

            Container(
              width:
                  Get.width * .25,

              height:
                  Get.height * .125,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEAF7FF,
                ),

                borderRadius:
                    BorderRadius.only(
                  topLeft:
                      Radius.circular(
                    Get.width * .037,
                  ),

                  bottomLeft:
                      Radius.circular(
                    Get.width * .037,
                  ),
                ),
              ),

              child: Icon(
                index % 3 == 0
                    ? Icons
                        .medical_services_outlined
                    : index % 3 == 1
                        ? Icons
                            .health_and_safety_outlined
                        : Icons
                            .medication_outlined,

                color: blue,

                size:
                    Get.width * .090,
              ),
            ),

            SizedBox(
              width:
                  Get.width * .025,
            ),

            // ===================================================
            // ARTICLE INFO
            // ===================================================

            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical:
                      Get.height * .015,

                  horizontal:
                      Get.width * .005,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // CATEGORY

                    if (category.isNotEmpty)
                      Container(
                        padding:
                            EdgeInsets.symmetric(
                          horizontal:
                              Get.width *
                                  .018,

                          vertical:
                              Get.height *
                                  .004,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFEAF7FF,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            Get.width * .012,
                          ),
                        ),

                        child: Text(
                          category,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              TextStyle(
                            color: blue,

                            fontSize:
                                Get.width *
                                    .019,

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                    if (category.isNotEmpty)
                      SizedBox(
                        height:
                            Get.height * .008,
                      ),

                    // TITLE

                    Text(
                      title,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          TextStyle(
                        color: darkText,

                        fontSize:
                            Get.width * .028,

                        fontWeight:
                            FontWeight.w700,

                        height: 1.2,
                      ),
                    ),

                    if (time.isNotEmpty)
                      SizedBox(
                        height:
                            Get.height * .008,
                      ),

                    // TIME

                    if (time.isNotEmpty)
                      Text(
                        time,

                        style:
                            TextStyle(
                          color:
                              greyText,

                          fontSize:
                              Get.width * .021,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ===================================================
            // ARROW
            // ===================================================

            Padding(
              padding:
                  EdgeInsets.only(
                right:
                    Get.width * .025,
              ),

              child: Icon(
                Icons.arrow_forward_ios,
                color:
                    const Color(
                  0xFFB7C1C9,
                ),

                size:
                    Get.width * .035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}