import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:medicalchat/controller/admin_controller.dart';

class AddArticleView extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const AddArticleView({
    super.key,
    this.existingData,
  });

  @override
  State<AddArticleView> createState() =>
      _AddArticleViewState();
}

class _AddArticleViewState
    extends State<AddArticleView> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  final AdminController controller =
      Get.find<AdminController>();

  final ImagePicker picker =
      ImagePicker();


      String? selectedCategory;

final List<String> categoryOptions = [
  'Dental',
  'Health',
  'Medicine',
];

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController
      titleController =
      TextEditingController();

  final TextEditingController
      authorController =
      TextEditingController();

  final TextEditingController
      descriptionController =
      TextEditingController();

  final TextEditingController
      contentController =
      TextEditingController();

  // ============================================================
  // IMAGE
  // ============================================================

  File? selectedImage;

  String existingImageUrl = '';

  String existingImagePublicId = '';

  // Keep the original ID so it can be
  // deleted only after successful update.
  String originalImagePublicId = '';

  // ============================================================
  // STATE
  // ============================================================

  bool isSaving = false;

  bool get editing =>
      widget.existingData != null;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final data =
        widget.existingData;

    if (data != null) {
      titleController.text =
          _value(data['title']);

      final String savedCategory =
    _value(data['category']);

if (categoryOptions.contains(savedCategory)) {
  selectedCategory = savedCategory;
} else {
  selectedCategory = null;
}

      authorController.text =
          _value(data['author']);

      descriptionController.text =
          _value(
        data['description'],
      );

      contentController.text =
          _value(
        data['content'],
      );

      existingImageUrl =
          _value(
        data['imageUrl'],
      );

      existingImagePublicId =
          _value(
        data['imagePublicId'],
      );

      originalImagePublicId =
          existingImagePublicId;
    }
  }

  // ============================================================
  // STRING VALUE
  // ============================================================

  String _value(
    dynamic value,
  ) {
    return value?.toString().trim() ?? '';
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    if (isSaving) {
      return;
    }

    try {
      final XFile? image =
          await picker.pickImage(
        source:
            ImageSource.gallery,

        imageQuality:
            85,

        maxWidth:
            1400,
      );

      if (image == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        selectedImage =
            File(image.path);
      });
    } catch (e) {
      debugPrint(
        'Image picker error: $e',
      );

      controller.showMessage(
        'Unable to select image.',
      );
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void removeImage() {
    if (isSaving) {
      return;
    }

    setState(() {
      selectedImage = null;

      existingImageUrl = '';

      existingImagePublicId = '';

      // IMPORTANT:
      // Do not clear originalImagePublicId.
      //
      // It is required to delete the old
      // Cloudinary image after Firestore
      // update succeeds.
    });
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool validate() {
    if (titleController.text
        .trim()
        .isEmpty) {
      controller.showMessage(
        'Please enter article title.',
      );

      return false;
    }

    if (selectedCategory == null ||
    selectedCategory!.trim().isEmpty) {
  controller.showMessage(
    'Please select article category.',
  );

  return false;
}

    if (authorController.text
        .trim()
        .isEmpty) {
      controller.showMessage(
        'Please enter author.',
      );

      return false;
    }

    if (descriptionController.text
        .trim()
        .isEmpty) {
      controller.showMessage(
        'Please enter short description.',
      );

      return false;
    }

    if (contentController.text
        .trim()
        .isEmpty) {
      controller.showMessage(
        'Please enter article content.',
      );

      return false;
    }

    return true;
  }

  // ============================================================
  // SAVE ARTICLE
  // ============================================================

 Future<void> save() async {
  if (isSaving) {
    return;
  }

  if (!validate()) {
    return;
  }

  setState(() {
    isSaving = true;
  });

  String imageUrl = existingImageUrl;

  String imagePublicId = existingImagePublicId;

  String newUploadedImagePublicId = '';

  try {
    // ========================================================
    // UPLOAD NEW IMAGE FIRST
    // ========================================================

    if (selectedImage != null) {
      final uploaded = await controller.uploadImage(
        image: selectedImage!,
        folder: 'articles',
      );

      if (uploaded == null) {
        return;
      }

      imageUrl = _value(
        uploaded['imageUrl'],
      );

      imagePublicId = _value(
        uploaded['imagePublicId'],
      );

      newUploadedImagePublicId = imagePublicId;
    }

    // ========================================================
    // ARTICLE DATA
    // ========================================================

    final Map<String, dynamic> data = <String, dynamic>{
      'title': titleController.text.trim(),

      'category': selectedCategory ?? '',

      'author': authorController.text.trim(),

      'description': descriptionController.text.trim(),

      'content': contentController.text.trim(),

      'imageUrl': imageUrl,

      'imagePublicId': imagePublicId,

      'isActive': true,

      // Used by article UI.
      'time': DateTime.now(),
    };

    // ========================================================
    // ADD / UPDATE FIRESTORE
    // ========================================================

    bool success;

    if (editing) {
      final String articleId = _value(
        widget.existingData!['id'],
      );

      if (articleId.isEmpty) {
        controller.showMessage(
          'Article ID is missing.',
        );

        return;
      }

      success = await controller.updateArticle(
        articleId,
        data,
      );
    } else {
      success = await controller.addArticle(
        data,
      );
    }

    // ========================================================
    // FIRESTORE FAILED
    // ========================================================

    if (!success) {
      // If a new image was uploaded but Firestore
      // operation failed, delete the new image.

      if (newUploadedImagePublicId.isNotEmpty) {
        await controller.deleteCloudinaryImage(
          newUploadedImagePublicId,
        );
      }

      return;
    }

    // ========================================================
    // FIRESTORE SUCCESS
    // ========================================================

    // Delete the old image only after the Firestore
    // update has completed successfully.

    if (editing &&
        originalImagePublicId.isNotEmpty &&
        originalImagePublicId != imagePublicId) {
      await controller.deleteCloudinaryImage(
        originalImagePublicId,
      );
    }

    // ========================================================
    // SUCCESS
    // ========================================================
    //
    // AdminController already shows:
    //
    // Article added successfully.
    // OR
    // Article updated successfully.
    //
    // Do NOT show another snackbar here.
    //
    // Wait briefly so the success message can be seen,
    // then automatically return to the previous screen.

    await Future.delayed(
      const Duration(
        milliseconds: 400,
      ),
    );

    if (mounted) {
      Get.back();
    }
  } catch (e) {
    debugPrint(
      'Article save error: $e',
    );

    // ========================================================
    // CLEANUP NEW IMAGE
    // ========================================================

    if (newUploadedImagePublicId.isNotEmpty) {
      try {
        await controller.deleteCloudinaryImage(
          newUploadedImagePublicId,
        );
      } catch (cleanupError) {
        debugPrint(
          'Image cleanup error: $cleanupError',
        );
      }
    }

    // ========================================================
    // ERROR MESSAGE
    // ========================================================

    controller.showMessage(
      'Unable to save article.',
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F7FF),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF3F7FF),

        elevation: 0,

        leading: IconButton(
          onPressed: isSaving
              ? null
              : () => Get.back(),

          icon: const Icon(
            Icons.arrow_back,
            color:
                Color(0xFF172534),
          ),
        ),

        title: Text(
          editing
              ? 'Edit Article'
              : 'Add Article',

          style:
              const TextStyle(
            color:
                Color(0xFF172534),

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body:
          SafeArea(
        child:
            SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.all(
            20,
          ),

          child:
              Column(
            children: [
              // IMAGE

              _imagePicker(),

              const SizedBox(
                height: 20,
              ),

              // TITLE

              _field(
                'Article Title',
                titleController,
                Icons.title,
              ),

              // CATEGORY

            _categoryDropdown(),

              // AUTHOR

              _field(
                'Author',
                authorController,
                Icons.person_outline,
              ),

              // DESCRIPTION

              _field(
                'Short Description',
                descriptionController,
                Icons.description_outlined,
                maxLines: 4,
              ),

              // CONTENT

              _field(
                'Article Content',
                contentController,
                Icons.article_outlined,
                maxLines: 12,
              ),

              const SizedBox(
                height: 10,
              ),

              // SAVE BUTTON

              SizedBox(
                width:
                    double.infinity,

                height:
                    55,

                child:
                    ElevatedButton(
                  onPressed:
                      isSaving
                          ? null
                          : save,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2196F3,
                    ),

                    disabledBackgroundColor:
                        const Color(
                      0xFF90CAF9,
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

                  child:
                      isSaving
                          ? const SizedBox(
                              width: 23,
                              height: 23,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.5,

                                color:
                                    Colors.white,
                              ),
                            )
                          : Text(
                              editing
                                  ? 'Update Article'
                                  : 'Add Article',

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Widget _imagePicker() {
    final bool hasImage =
        selectedImage != null ||
            existingImageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Align(
          alignment:
              Alignment.centerLeft,

          child:
              Text(
            'Article Image',

            style:
                TextStyle(
              color:
                  Color(0xFF172534),

              fontWeight:
                  FontWeight.bold,

              fontSize: 15,
            ),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        GestureDetector(
          onTap:
              isSaving
                  ? null
                  : pickImage,

          child:
              Container(
            width:
                double.infinity,

            height:
                230,

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              border:
                  Border.all(
                color:
                    const Color(
                  0xFFDDE3E9,
                ),
              ),
            ),

            child:
                selectedImage != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        child:
                            Image.file(
                          selectedImage!,

                          width:
                              double.infinity,

                          height:
                              double.infinity,

                          fit:
                              BoxFit.cover,
                        ),
                      )
                    : existingImageUrl
                            .isNotEmpty
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),

                            child:
                                Image.network(
                              existingImageUrl,

                              width:
                                  double.infinity,

                              height:
                                  double.infinity,

                              fit:
                                  BoxFit.cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return _placeholder();
                              },
                            ),
                          )
                        : _placeholder(),
          ),
        ),

        // ======================================================
        // REMOVE IMAGE
        // ======================================================

        if (hasImage)
          Align(
            alignment:
                Alignment.centerRight,

            child:
                TextButton.icon(
              onPressed:
                  isSaving
                      ? null
                      : removeImage,

              icon:
                  const Icon(
                Icons.delete_outline,
                color:
                    Colors.red,
              ),

              label:
                  const Text(
                'Remove Image',

                style:
                    TextStyle(
                  color:
                      Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _placeholder() {
    return const Center(
      child:
          Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 50,
            color:
                Color(0xFF2196F3),
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'Tap to select article image',

            style:
                TextStyle(
              color:
                  Color(0xFF647587),
            ),
          ),
        ],
      ),
    );
  }




Widget _categoryDropdown() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      value: selectedCategory,
      isExpanded: true,

      decoration: InputDecoration(
        labelText: 'Category',

        labelStyle: const TextStyle(
          color: Color(0xFF647587),
        ),

        prefixIcon: const Icon(
          Icons.category_outlined,
          color: Color(0xFF647587),
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDDE3E9),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDDE3E9),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF2196F3),
            width: 1.5,
          ),
        ),
      ),

      hint: const Text(
        'Select Category',
        style: TextStyle(
          color: Color(0xFF647587),
        ),
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF647587),
      ),

      items: categoryOptions.map(
        (String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
              style: const TextStyle(
                color: Color(0xFF172534),
                fontSize: 15,
              ),
            ),
          );
        },
      ).toList(),

      onChanged: isSaving
          ? null
          : (String? value) {
              setState(() {
                selectedCategory = value;
              });
            },
    ),
  );
}
  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child:
          TextField(
        controller:
            controller,

        maxLines:
            maxLines,

        textInputAction:
            maxLines == 1
                ? TextInputAction.next
                : TextInputAction.newline,

        decoration:
            InputDecoration(
          labelText:
              label,

          labelStyle:
              const TextStyle(
            color:
                Color(0xFF647587),
          ),

          prefixIcon:
              Padding(
            padding:
                EdgeInsets.only(
              bottom:
                  maxLines > 1
                      ? 0
                      : 0,
            ),

            child:
                Icon(
              icon,

              color:
                  const Color(
                0xFF647587,
              ),
            ),
          ),

          filled:
              true,

          fillColor:
              Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(0xFFDDE3E9),
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(0xFFDDE3E9),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(0xFF2196F3),

              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    contentController.dispose();

    super.dispose();
  }
}