import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:medicalchat/controller/admin_controller.dart';

class AddMedicineView extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const AddMedicineView({
    super.key,
    this.existingData,
  });

  @override
  State<AddMedicineView> createState() =>
      _AddMedicineViewState();
}

class _AddMedicineViewState
    extends State<AddMedicineView> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor =
      Color(0xFFF3F7FF);

  static const Color blueColor =
      Color(0xFF2196F3);

  static const Color darkTextColor =
      Color(0xFF172534);

  static const Color greyTextColor =
      Color(0xFF647587);

  static const Color borderColor =
      Color(0xFFDDE3E9);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final AdminController controller =
      Get.find<AdminController>();

  final ImagePicker picker =
      ImagePicker();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController categoryController =
      TextEditingController();

  final TextEditingController dosageController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController manufacturerController =
      TextEditingController();

  // ============================================================
  // IMAGE
  // ============================================================

  File? selectedImage;

  String existingImageUrl = '';

  String existingImagePublicId = '';

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

    final Map<String, dynamic>? data =
        widget.existingData;

    if (data != null) {
      nameController.text =
          _value(data['name']);

      categoryController.text =
          _value(data['category']);

      dosageController.text =
          _value(data['dosage']);

      priceController.text =
          _value(data['price']);

      descriptionController.text =
          _value(data['description']);

      manufacturerController.text =
          _value(data['manufacturer']);

      existingImageUrl =
          _value(data['imageUrl']);

      existingImagePublicId =
          _value(data['imagePublicId']);

      originalImagePublicId =
          existingImagePublicId;
    }
  }

  // ============================================================
  // VALUE HELPER
  // ============================================================

  String _value(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    if (isSaving) return;

    try {
      final XFile? image =
          await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage =
            File(image.path);
      });
    } catch (e) {
      debugPrint(
        'PICK MEDICINE IMAGE ERROR: $e',
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
    if (isSaving) return;

    setState(() {
      selectedImage = null;
      existingImageUrl = '';
      existingImagePublicId = '';
    });
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  bool validate() {
    if (nameController.text.trim().isEmpty) {
      controller.showMessage(
        'Please enter medicine name.',
      );
      return false;
    }

    if (categoryController.text.trim().isEmpty) {
      controller.showMessage(
        'Please enter medicine category.',
      );
      return false;
    }

    if (dosageController.text.trim().isEmpty) {
      controller.showMessage(
        'Please enter dosage.',
      );
      return false;
    }

    if (priceController.text.trim().isEmpty) {
      controller.showMessage(
        'Please enter price.',
      );
      return false;
    }

    final double? price =
        double.tryParse(
      priceController.text.trim(),
    );

    if (price == null || price < 0) {
      controller.showMessage(
        'Please enter a valid price.',
      );
      return false;
    }

    if (manufacturerController.text.trim().isEmpty) {
      controller.showMessage(
        'Please enter manufacturer.',
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      controller.showMessage(
        'Please enter description.',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> save() async {
  if (isSaving) return;

  if (!validate()) return;

  setState(() {
    isSaving = true;
  });

  String imageUrl = existingImageUrl;
  String imagePublicId = existingImagePublicId;

  String newUploadedImagePublicId = '';

  try {
    // ----------------------------------------------------------
    // UPLOAD IMAGE
    // ----------------------------------------------------------

    if (selectedImage != null) {
      final Map<String, String>? uploaded =
          await controller.uploadImage(
        image: selectedImage!,
        folder: 'medicines',
      );

      if (uploaded == null) {
        return;
      }

      imageUrl = uploaded['imageUrl'] ?? '';
      imagePublicId = uploaded['imagePublicId'] ?? '';

      newUploadedImagePublicId = imagePublicId;
    }

    // ----------------------------------------------------------
    // DATA
    // ----------------------------------------------------------

    final Map<String, dynamic> data = <String, dynamic>{
      'name': nameController.text.trim(),
      'category': categoryController.text.trim(),
      'dosage': dosageController.text.trim(),
      'price': priceController.text.trim(),
      'description': descriptionController.text.trim(),
      'manufacturer': manufacturerController.text.trim(),
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'isActive': true,
    };

    bool success = false;

    // ----------------------------------------------------------
    // UPDATE
    // ----------------------------------------------------------

    if (editing) {
      success = await controller.updateMedicine(
        widget.existingData!['id'].toString(),
        data,
      );
    }

    // ----------------------------------------------------------
    // ADD
    // ----------------------------------------------------------

    else {
      success = await controller.addMedicine(
        data,
      );
    }

    // ----------------------------------------------------------
    // FAILED
    // ----------------------------------------------------------

    if (!success) {
      if (newUploadedImagePublicId.isNotEmpty) {
        await controller.deleteCloudinaryImage(
          newUploadedImagePublicId,
        );
      }

      return;
    }

    // ----------------------------------------------------------
    // DELETE OLD IMAGE
    // ----------------------------------------------------------

    if (editing &&
        originalImagePublicId.isNotEmpty &&
        originalImagePublicId != imagePublicId) {
      await controller.deleteCloudinaryImage(
        originalImagePublicId,
      );
    }

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------
    //
    // AdminController already displays:
    //
    // Medicine added successfully.
    // OR
    // Medicine updated successfully.
    //
    // So we do NOT show another snackbar here.
    //

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (mounted) {
      Get.back();
    }
  } catch (e) {
    debugPrint(
      'SAVE MEDICINE ERROR: $e',
    );

    if (newUploadedImagePublicId.isNotEmpty) {
      await controller.deleteCloudinaryImage(
        newUploadedImagePublicId,
      );
    }

    controller.showMessage(
      'Unable to save medicine.',
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
          backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            backgroundColor,

        elevation: 0,

        leading: IconButton(
          onPressed:
              isSaving ? null : Get.back,

          icon: const Icon(
            Icons.arrow_back,
            color:
                darkTextColor,
          ),
        ),

        title: Text(
          editing
              ? 'Edit Medicine'
              : 'Add Medicine',

          style: const TextStyle(
            color:
                darkTextColor,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [

              // ==================================================
              // IMAGE
              // ==================================================

              _imagePicker(),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // MEDICINE NAME
              // ==================================================

              _field(
                'Medicine Name',
                nameController,
                Icons.medication_outlined,
              ),

              // ==================================================
              // CATEGORY
              // ==================================================

              _field(
                'Category',
                categoryController,
                Icons.category_outlined,
              ),

              // ==================================================
              // DOSAGE
              // ==================================================

              _field(
                'Dosage',
                dosageController,
                Icons.local_hospital_outlined,
              ),

              // ==================================================
              // PRICE
              // ==================================================

              _field(
                'Price',
                priceController,
                Icons.attach_money,
                keyboard:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              // ==================================================
              // MANUFACTURER
              // ==================================================

              _field(
                'Manufacturer',
                manufacturerController,
                Icons.business_outlined,
              ),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              _field(
                'Description',
                descriptionController,
                Icons.description_outlined,
                keyboard:
                    TextInputType.multiline,
                maxLines: 5,
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // SAVE BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton(
                  onPressed:
                      isSaving
                          ? null
                          : save,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        blueColor,

                    disabledBackgroundColor:
                        const Color(
                      0xFF9CCCF3,
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

                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:
                                Colors.white,
                          ),
                        )
                      : Text(
                          editing
                              ? 'Update Medicine'
                              : 'Add Medicine',

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
        const Text(
          'Medicine Image',

          style: TextStyle(
            color:
                darkTextColor,
            fontWeight:
                FontWeight.bold,
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

          child: Container(
            width:
                double.infinity,

            height: 230,

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
                    borderColor,
              ),
            ),

            child:
                ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              child:
                  selectedImage != null
                      ? Image.file(
                          selectedImage!,
                          fit:
                              BoxFit.cover,
                        )
                      : existingImageUrl.isNotEmpty
                          ? Image.network(
                              existingImageUrl,

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
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                    color:
                                        blueColor,
                                  ),
                                );
                              },

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return _placeholder();
                              },
                            )
                          : _placeholder(),
            ),
          ),
        ),

        // ========================================================
        // REMOVE IMAGE
        // ========================================================

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

                style: TextStyle(
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
  // PLACEHOLDER
  // ============================================================

  Widget _placeholder() {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 50,
            color:
                blueColor,
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'Tap to select medicine image',

            style: TextStyle(
              color:
                  greyTextColor,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'Optional',

            style: TextStyle(
              fontSize: 12,
              color:
                  greyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard =
        TextInputType.text,

    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: TextField(
        controller:
            controller,

        // --------------------------------------------------------
        // KEYBOARD
        // --------------------------------------------------------

        keyboardType:
            keyboard,

        // --------------------------------------------------------
        // IMPORTANT:
        //
        // NO textInputAction HERE.
        //
        // This is intentional because the previous error was:
        //
        // TextInputAction.newline
        // +
        // TextInputType.text
        //
        // We completely remove textInputAction.
        // --------------------------------------------------------

        maxLines:
            maxLines,

        decoration:
            InputDecoration(
          labelText:
              label,

          // ------------------------------------------------------
          // ICON
          // ------------------------------------------------------

          prefixIcon:
              Icon(
            icon,
            color:
                greyTextColor,
          ),

          // ------------------------------------------------------
          // BACKGROUND
          // ------------------------------------------------------

          filled:
              true,

          fillColor:
              Colors.white,

          // ------------------------------------------------------
          // PADDING
          // ------------------------------------------------------

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          // ------------------------------------------------------
          // BORDER
          // ------------------------------------------------------

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            borderSide:
                const BorderSide(
              color:
                  borderColor,
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
                  borderColor,
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
                  blueColor,
              width: 1.5,
            ),
          ),

          // ------------------------------------------------------
          // LABEL
          // ------------------------------------------------------

          labelStyle:
              const TextStyle(
            color:
                greyTextColor,
          ),

          floatingLabelStyle:
              const TextStyle(
            color:
                blueColor,
            fontWeight:
                FontWeight.w600,
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
    nameController.dispose();
    categoryController.dispose();
    dosageController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    manufacturerController.dispose();

    super.dispose();
  }
}