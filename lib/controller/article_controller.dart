import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArticleController extends GetxController {
  // =========================================================
  // FIREBASE
  // =========================================================

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // SELECTED CATEGORY
  // =========================================================

  final RxInt selectedCategory = 0.obs;

  // =========================================================
  // CATEGORIES
  // =========================================================

  final List<String> categories = [
    'All',
    'Dental',
    'Health',
    'Medicine',
  ];

  // =========================================================
  // ARTICLES
  // =========================================================

  final RxList<Map<String, dynamic>> articles =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    loadArticles();
  }

  // =========================================================
  // LOAD ARTICLES
  // =========================================================

  Future<void> loadArticles() async {
    try {
      isLoading.value = true;

      QuerySnapshot<Map<String, dynamic>> snapshot;

      // -------------------------------------------------------
      // TRY ORDERED QUERY
      // -------------------------------------------------------

      try {
        snapshot = await firestore
            .collection('articles')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();
      } catch (e) {
        // -----------------------------------------------------
        // FALLBACK IF createdAt INDEX/FIELD IS NOT AVAILABLE
        // -----------------------------------------------------

        debugPrint(
          'Ordered article query failed: $e',
        );

        snapshot = await firestore
            .collection('articles')
            .get();
      }

      // -------------------------------------------------------
      // CONVERT FIRESTORE DOCUMENTS
      // -------------------------------------------------------

      final List<Map<String, dynamic>> loadedArticles = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        loadedArticles.add({
          'id': doc.id,
          ...data,
        });
      }

      // -------------------------------------------------------
      // SORT LOCALLY
      // -------------------------------------------------------

      loadedArticles.sort(
        (a, b) {
          return _compareCreatedAt(
            a['createdAt'],
            b['createdAt'],
          );
        },
      );

      articles.assignAll(
        loadedArticles,
      );
    } catch (e) {
      debugPrint(
        'Error loading articles: $e',
      );

      articles.clear();

      showMessage(
        'Unable to load articles.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // SELECT CATEGORY
  // =========================================================

  void selectCategory(int index) {
    if (index < 0 ||
        index >= categories.length) {
      return;
    }

    selectedCategory.value = index;
  }

  // =========================================================
  // FILTER ARTICLES
  // =========================================================

  List<Map<String, dynamic>> get filteredArticles {
    if (selectedCategory.value == 0) {
      return articles.toList();
    }

    final String selectedCategoryName =
        categories[selectedCategory.value]
            .trim()
            .toLowerCase();

    return articles.where(
      (article) {
        final String category =
            _stringValue(
          article['category'],
        ).toLowerCase();

        return category ==
            selectedCategoryName;
      },
    ).toList();
  }

  // =========================================================
  // OPEN ARTICLE
  // =========================================================

  void openArticle(
    Map<String, dynamic> article,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,

        insetPadding: EdgeInsets.symmetric(
          horizontal: Get.width * .055,
          vertical: Get.height * .035,
        ),

        child: Container(
          width: double.infinity,

          constraints: BoxConstraints(
            maxHeight: Get.height * .86,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              Get.width * .045,
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =================================================
              // HEADER
              // =================================================

              Container(
                width: double.infinity,

                padding: EdgeInsets.all(
                  Get.width * .045,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD9F0FF),
                      Color(0xFFEAF7FF),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: Get.width * .12,
                      height: Get.width * .12,

                      decoration:
                          const BoxDecoration(
                        color: Color(0xFFFFD34E),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons
                            .health_and_safety_outlined,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(
                      width: Get.width * .03,
                    ),

                    Expanded(
                      child: Text(
                        _stringValue(
                                  article['title'],
                                )
                                .isEmpty
                            ? 'Article'
                            : _stringValue(
                                article['title'],
                              ),

                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,

                        style: TextStyle(
                          color:
                              const Color(
                            0xFF172534,
                          ),
                          fontSize:
                              Get.width * .040,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        if (Get.isDialogOpen ==
                            true) {
                          Get.back();
                        }
                      },

                      icon: const Icon(
                        Icons.close,
                        color:
                            Color(0xFF647587),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // ARTICLE BODY
              // =================================================

              Flexible(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding: EdgeInsets.all(
                    Get.width * .045,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =========================================
                      // IMAGE
                      // =========================================

                      if (_stringValue(
                        article['imageUrl'],
                      ).isNotEmpty)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            Get.width * .035,
                          ),

                          child: Image.network(
                            _stringValue(
                              article['imageUrl'],
                            ),

                            width:
                                double.infinity,

                            height:
                                Get.height * .22,

                            fit: BoxFit.cover,

                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return _imagePlaceholder();
                            },
                          ),
                        ),

                      if (_stringValue(
                        article['imageUrl'],
                      ).isNotEmpty)
                        SizedBox(
                          height:
                              Get.height * .020,
                        ),

                      // =========================================
                      // CATEGORY
                      // =========================================

                      if (_stringValue(
                        article['category'],
                      ).isNotEmpty)
                        Container(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                Get.width * .025,
                            vertical:
                                Get.height * .006,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEAF7FF,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              Get.width * .015,
                            ),
                          ),

                          child: Text(
                            _stringValue(
                              article['category'],
                            ),

                            style: TextStyle(
                              color:
                                  const Color(
                                0xFF2196F3,
                              ),

                              fontSize:
                                  Get.width * .022,

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                      SizedBox(
                        height:
                            Get.height * .018,
                      ),

                      // =========================================
                      // TITLE
                      // =========================================

                      Text(
                        _stringValue(
                          article['title'],
                        ),

                        style: TextStyle(
                          color:
                              const Color(
                            0xFF172534,
                          ),

                          fontSize:
                              Get.width * .045,

                          fontWeight:
                              FontWeight.bold,

                          height: 1.3,
                        ),
                      ),

                      SizedBox(
                        height:
                            Get.height * .012,
                      ),

                      // =========================================
                      // AUTHOR
                      // =========================================

                      if (_stringValue(
                        article['author'],
                      ).isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color:
                                  Color(
                                0xFF2196F3,
                              ),
                              size: 17,
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            Expanded(
                              child: Text(
                                'By ${_stringValue(article['author'])}',

                                style:
                                    TextStyle(
                                  color:
                                      const Color(
                                    0xFF647587,
                                  ),

                                  fontSize:
                                      Get.width *
                                          .024,

                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(
                        height:
                            Get.height * .018,
                      ),

                      // =========================================
                      // DESCRIPTION
                      // =========================================

                      if (_stringValue(
                        article['description'],
                      ).isNotEmpty) ...[
                        Text(
                          _stringValue(
                            article['description'],
                          ),

                          style: TextStyle(
                            color:
                                const Color(
                              0xFF647587,
                            ),

                            fontSize:
                                Get.width * .028,

                            height: 1.6,
                          ),
                        ),

                        SizedBox(
                          height:
                              Get.height * .022,
                        ),
                      ],

                      // =========================================
                      // CONTENT
                      // =========================================

                      if (_stringValue(
                        article['content'],
                      ).isNotEmpty) ...[
                        Text(
                          'Article',

                          style: TextStyle(
                            color:
                                const Color(
                              0xFF172534,
                            ),

                            fontSize:
                                Get.width * .034,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height:
                              Get.height * .010,
                        ),

                        Text(
                          _stringValue(
                            article['content'],
                          ),

                          style: TextStyle(
                            color:
                                const Color(
                              0xFF172534,
                            ),

                            fontSize:
                                Get.width * .028,

                            height: 1.7,
                          ),
                        ),
                      ],

                      SizedBox(
                        height:
                            Get.height * .020,
                      ),

                      // =========================================
                      // DATE
                      // =========================================

                      if (getArticleTime(
                        article,
                      ).isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color:
                                  Color(
                                0xFF2196F3,
                              ),
                              size: 16,
                            ),

                            const SizedBox(
                              width: 7,
                            ),

                            Text(
                              getArticleTime(
                                article,
                              ),

                              style:
                                  TextStyle(
                                color:
                                    const Color(
                                  0xFF647587,
                                ),

                                fontSize:
                                    Get.width *
                                        .022,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // =================================================
              // CLOSE BUTTON
              // =================================================

              Padding(
                padding: EdgeInsets.fromLTRB(
                  Get.width * .045,
                  0,
                  Get.width * .045,
                  Get.height * .025,
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: Get.height * .055,

                  child: ElevatedButton(
                    onPressed: () {
                      if (Get.isDialogOpen ==
                          true) {
                        Get.back();
                      }
                    },

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
                          Get.width * .025,
                        ),
                      ),
                    ),

                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
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
  // IMAGE PLACEHOLDER
  // =========================================================

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: Get.height * .22,

      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),

        borderRadius:
            BorderRadius.circular(
          Get.width * .035,
        ),
      ),

      child: const Center(
        child: Icon(
          Icons.article_outlined,
          size: 55,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshArticles() async {
    await loadArticles();
  }

  // =========================================================
  // GET ARTICLE TIME
  // =========================================================

  String getArticleTime(
    Map<String, dynamic> article,
  ) {
    dynamic value =
        article['time'] ??
        article['createdAt'];

    if (value == null) {
      return '';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date != null) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return value.toString();
  }

  // =========================================================
  // SORT CREATED AT
  // =========================================================

  int _compareCreatedAt(
    dynamic first,
    dynamic second,
  ) {
    DateTime? firstDate =
        _toDateTime(first);

    DateTime? secondDate =
        _toDateTime(second);

    if (firstDate == null &&
        secondDate == null) {
      return 0;
    }

    if (firstDate == null) {
      return 1;
    }

    if (secondDate == null) {
      return -1;
    }

    return secondDate.compareTo(
      firstDate,
    );
  }

  // =========================================================
  // CONVERT DATE
  // =========================================================

  DateTime? _toDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // =========================================================
  // STRING VALUE
  // =========================================================

  String _stringValue(
    dynamic value,
  ) {
    return value?.toString().trim() ?? '';
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(
    String message,
  ) {
    Get.snackbar(
      'Error',
      message,

      snackPosition:
          SnackPosition.BOTTOM,

      backgroundColor:
          Colors.red,

      colorText:
          Colors.white,

      margin:
          const EdgeInsets.all(12),

      duration:
          const Duration(
        seconds: 2,
      ),
    );
  }
}