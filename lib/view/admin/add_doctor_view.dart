import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:medicalchat/controller/admin_controller.dart';

class AddDoctorView extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const AddDoctorView({
    super.key,
    this.existingData,
  });

  @override
  State<AddDoctorView> createState() => _AddDoctorViewState();
}

class _AddDoctorViewState extends State<AddDoctorView> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  final AdminController controller =
      Get.find<AdminController>();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final ImagePicker _picker =
      ImagePicker();


      String? selectedSpecialist;

final List<String> specialistOptions = [
  'Eye',
  'Tooth',
  'Ear',
  'Drugs',
  'Nutrition',
  'Psychology',
  'General',
];

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController specialistController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController experienceController =
      TextEditingController();

  final TextEditingController patientsController =
      TextEditingController();

  final TextEditingController ratingController =
      TextEditingController();

  final TextEditingController practiceController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  // ============================================================
  // GETX STATE
  // ============================================================

  final RxBool isSaving = false.obs;

  final RxBool obscurePassword =
      true.obs;

  // ============================================================
  // IMAGE
  // ============================================================

  File? selectedImage;

  String existingImageUrl = '';

  String originalImagePublicId = '';

  // ============================================================
  // COLORS
  // ============================================================

  final Color blue =
      const Color(0xFF2196F3);

  final Color darkText =
      const Color(0xFF172534);

  final Color greyText =
      const Color(0xFF647587);

  final Color background =
      const Color(0xFFF3F7FF);

  final Color borderColor =
      const Color(0xFFDDE3E9);

  final Color lightBlue =
      const Color(0xFFD9F0FF);

  // ============================================================
  // DAYS
  // ============================================================

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late Map<String, Map<String, dynamic>>
      weeklySchedule;

  // ============================================================
  // EDIT MODE
  // ============================================================

  bool get isEditMode =>
      widget.existingData != null;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    weeklySchedule = {
      for (final day in days)
        day: {
          'enabled': true,
          'start': '09:00 AM',
          'end': '05:00 PM',
        },
    };

    _loadExistingData();
  }

  // ============================================================
  // LOAD EXISTING DOCTOR
  // ============================================================

  void _loadExistingData() {
    final Map<String, dynamic>? data =
        widget.existingData;

    if (data == null) {
      return;
    }

    nameController.text =
        data['name']?.toString() ?? '';

    emailController.text =
        data['email']?.toString() ?? '';

    final String savedSpecialist =
    data['specialist']?.toString() ??
        data['category']?.toString() ??
        '';

if (specialistOptions.contains(savedSpecialist)) {
  selectedSpecialist = savedSpecialist;
} else {
  selectedSpecialist = null;
}

    phoneController.text =
        data['phone']?.toString() ?? '';

    experienceController.text =
        data['experience']?.toString() ?? '';

    patientsController.text =
        data['patients']?.toString() ?? '';

    ratingController.text =
        data['rating']?.toString() ?? '';

    practiceController.text =
        data['place']?.toString() ??
            data['practice']?.toString() ??
            data['placeOfPractice']?.toString() ??
            data['clinic']?.toString() ??
            data['clinicName']?.toString() ??
            data['hospital']?.toString() ??
            data['hospitalName']?.toString() ??
            data['location']?.toString() ??
            data['address']?.toString() ??
            '';

    descriptionController.text =
        data['description']?.toString() ?? '';

    existingImageUrl =
        data['imageUrl']?.toString() ?? '';

    originalImagePublicId =
        data['imagePublicId']?.toString() ?? '';

    _loadSchedule(
      data['schedule'],
    );
  }

  // ============================================================
  // LOAD SCHEDULE
  // ============================================================

  void _loadSchedule(
    dynamic schedule,
  ) {
    if (schedule is! Map) {
      return;
    }

    for (final String day in days) {
      dynamic value;

      if (schedule.containsKey(day)) {
        value = schedule[day];
      } else if (
          schedule.containsKey(
        day.toLowerCase(),
      )) {
        value =
            schedule[day.toLowerCase()];
      }

      if (value is Map) {
        weeklySchedule[day] = {
          'enabled':
              value['enabled'] == true,
          'start':
              value['start']?.toString() ??
                  '09:00 AM',
          'end':
              value['end']?.toString() ??
                  '05:00 PM',
        };
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    specialistController.dispose();
    phoneController.dispose();
    experienceController.dispose();
    patientsController.dispose();
    ratingController.dispose();
    practiceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
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
        'PICK DOCTOR IMAGE ERROR => $e',
      );

      _showError(
        'Unable to select image.',
      );
    }
  }

  // ============================================================
  // PICK TIME
  // ============================================================

  Future<void> _pickTime(
    String day,
    bool isStart,
  ) async {
    final String currentValue =
        weeklySchedule[day]?[
                isStart ? 'start' : 'end']
            ?.toString() ??
            '09:00 AM';

    final TimeOfDay initialTime =
        _parseTime(currentValue);

    final TimeOfDay? picked =
        await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) {
      return;
    }

    final String formatted =
        picked.format(context);

    if (!mounted) {
      return;
    }

    setState(() {
      weeklySchedule[day]![
              isStart ? 'start' : 'end'] =
          formatted;
    });
  }

  // ============================================================
  // PARSE TIME
  // ============================================================

  TimeOfDay _parseTime(
    String value,
  ) {
    try {
      final List<String> parts =
          value.trim().split(' ');

      if (parts.isEmpty) {
        return const TimeOfDay(
          hour: 9,
          minute: 0,
        );
      }

      final List<String> timeParts =
          parts[0].split(':');

      int hour =
          int.tryParse(
                timeParts[0],
              ) ??
              9;

      final int minute =
          timeParts.length > 1
              ? int.tryParse(
                    timeParts[1],
                  ) ??
                  0
              : 0;

      if (parts.length > 1) {
        final String period =
            parts[1].toUpperCase();

        if (period == 'PM' &&
            hour != 12) {
          hour += 12;
        }

        if (period == 'AM' &&
            hour == 12) {
          hour = 0;
        }
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return const TimeOfDay(
        hour: 9,
        minute: 0,
      );
    }
  }

  // ============================================================
  // SAVE DOCTOR
  // ============================================================

 Future<void> _saveDoctor() async {
  // ----------------------------------------------------------
  // VALIDATE FORM
  // ----------------------------------------------------------

  if (!_formKey.currentState!.validate()) {
    return;
  }

  // ----------------------------------------------------------
  // PASSWORD ONLY REQUIRED WHEN ADDING
  // ----------------------------------------------------------

  if (!isEditMode &&
      passwordController.text.trim().length < 6) {
    _showError(
      'Password must be at least 6 characters.',
    );
    return;
  }

  // ----------------------------------------------------------
  // PREVENT DOUBLE TAP
  // ----------------------------------------------------------

  if (isSaving.value) {
    return;
  }

  isSaving.value = true;

  try {
    // --------------------------------------------------------
    // DOCTOR DATA
    // --------------------------------------------------------

    final Map<String, dynamic> doctorData = {
      'name':
          nameController.text.trim(),

      'specialist':
          selectedSpecialist ?? '',

      'phone':
          phoneController.text.trim(),

      'experience':
          experienceController.text.trim(),

      'patients':
          patientsController.text.trim(),

      'rating':
          double.tryParse(
                ratingController.text.trim(),
              ) ??
              0.0,

      'place':
          practiceController.text.trim(),

      'practice':
          practiceController.text.trim(),

      'description':
          descriptionController.text.trim(),

      'schedule':
          weeklySchedule,

      'isActive':
          true,
    };

    // --------------------------------------------------------
    // IMAGE VALUES
    // --------------------------------------------------------

    String newImageUrl =
        existingImageUrl;

    String newImagePublicId =
        originalImagePublicId;

    // --------------------------------------------------------
    // UPLOAD NEW IMAGE
    // --------------------------------------------------------

    if (selectedImage != null) {
      final Map<String, String>? uploadResult =
          await controller.uploadImage(
        image: selectedImage!,
        folder: 'doctors',
      );

      if (uploadResult == null) {
        return;
      }

      newImageUrl =
          uploadResult['imageUrl'] ?? '';

      newImagePublicId =
          uploadResult['imagePublicId'] ?? '';
    }

    doctorData['imageUrl'] =
        newImageUrl;

    doctorData['imagePublicId'] =
        newImagePublicId;

    // ========================================================
    // EDIT DOCTOR
    // ========================================================

    if (isEditMode) {
      final String doctorId =
          widget.existingData?['id']
                  ?.toString() ??
              widget.existingData?['doctorId']
                  ?.toString() ??
              widget.existingData?['uid']
                  ?.toString() ??
              '';

      if (doctorId.isEmpty) {
        _showError(
          'Doctor ID is missing.',
        );
        return;
      }

      final bool success =
          await controller.updateDoctor(
        doctorId,
        doctorData,
      );

      // Update failed
      if (!success) {
        return;
      }

      // ------------------------------------------------------
      // DELETE OLD IMAGE
      // ------------------------------------------------------

      if (selectedImage != null &&
          originalImagePublicId.isNotEmpty &&
          newImagePublicId !=
              originalImagePublicId) {
        await controller
            .deleteCloudinaryImage(
          originalImagePublicId,
        );
      }

      // ------------------------------------------------------
      // SUCCESS
      // ------------------------------------------------------
      //
      // Controller already shows:
      // "Doctor updated successfully."
      //

     if (mounted) {
  Get.back();
}

      return;
    }

    // ========================================================
    // ADD NEW DOCTOR
    // ========================================================

    final String email =
        emailController.text.trim();

    final String password =
        passwordController.text.trim();

    final bool success =
        await controller.addDoctor(
      doctorData,
      email: email,
      password: password,
    );

    // --------------------------------------------------------
    // ADD FAILED
    // --------------------------------------------------------

    if (!success) {
      return;
    }

    // --------------------------------------------------------
    // SUCCESS
    // --------------------------------------------------------
    //
    // AdminController already shows:
    // "Doctor account created successfully."
    //
    // Wait briefly, then go back.
    //

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
      'SAVE DOCTOR ERROR => $e',
    );

    _showError(
      'Unable to save doctor. Please try again.',
    );
  } finally {
    isSaving.value = false;
  }
}
  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(
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
          Colors.white,
      colorText: darkText,
      duration:
          const Duration(seconds: 3),
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
    );
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
          background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            background,
        foregroundColor:
            darkText,
        title: Text(
          isEditMode
              ? 'Edit Doctor'
              : 'Add Doctor',
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Form(
          key: _formKey,
          child:
              SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // ------------------------------------------------
                // IMAGE
                // ------------------------------------------------

                _imagePicker(),

                const SizedBox(
                  height: 24,
                ),

                // ------------------------------------------------
                // DOCTOR INFORMATION
                // ------------------------------------------------

                _sectionTitle(
                  'Doctor Information',
                ),

                const SizedBox(
                  height: 14,
                ),

                _textField(
                  controller:
                      nameController,
                  label:
                      'Doctor Name',
                  hint:
                      'Enter doctor name',
                  icon:
                      Icons.person_outline,
                  validator:
                      (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Doctor name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

              _specialistDropdown(),

const SizedBox(
  height: 14,
),
                _textField(
                  controller:
                      phoneController,
                  label:
                      'Phone',
                  hint:
                      'Enter phone number',
                  icon:
                      Icons.phone_outlined,
                  keyboardType:
                      TextInputType.phone,
                ),

                const SizedBox(
                  height: 14,
                ),

                _textField(
                  controller:
                      practiceController,
                  label:
                      'Place of Practice',
                  hint:
                      'Clinic / Hospital',
                  icon:
                      Icons.location_on_outlined,
                ),

                const SizedBox(
                  height: 14,
                ),

                _textField(
                  controller:
                      experienceController,
                  label:
                      'Experience',
                  hint:
                      'e.g. 8 Years',
                  icon:
                      Icons.workspace_premium_outlined,
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _textField(
                        controller:
                            patientsController,
                        label:
                            'Patients',
                        hint:
                            'e.g. 1200+',
                        icon:
                            Icons.people_outline,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          _textField(
                        controller:
                            ratingController,
                        label:
                            'Rating',
                        hint:
                            'e.g. 4.8',
                        icon:
                            Icons.star_outline,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                // ------------------------------------------------
                // ACCOUNT
                // ------------------------------------------------

                _sectionTitle(
                  'Account',
                ),

                const SizedBox(
                  height: 14,
                ),

                _textField(
                  controller:
                      emailController,
                  label:
                      'Email',
                  hint:
                      'doctor@example.com',
                  icon:
                      Icons.email_outlined,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  enabled:
                      !isEditMode,
                  validator:
                      (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Email is required';
                    }

                    if (!GetUtils
                        .isEmail(
                      value.trim(),
                    )) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ------------------------------------------------
                // PASSWORD ONLY FOR ADD
                // ------------------------------------------------

                if (!isEditMode)
                  Obx(
                    () => _textField(
                      controller:
                          passwordController,
                      label:
                          'Password',
                      hint:
                          'Create doctor password',
                      icon:
                          Icons.lock_outline,
                      obscureText:
                          obscurePassword
                              .value,
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          obscurePassword
                              .toggle();
                        },
                        icon: Icon(
                          obscurePassword
                                  .value
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          color:
                              greyText,
                        ),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length <
                            6) {
                          return 'Minimum 6 characters';
                        }

                        return null;
                      },
                    ),
                  ),

                if (!isEditMode)
                  const SizedBox(
                    height: 24,
                  ),

                // ------------------------------------------------
                // DESCRIPTION
                // ------------------------------------------------

                _sectionTitle(
                  'Description',
                ),

                const SizedBox(
                  height: 14,
                ),

                _textField(
                  controller:
                      descriptionController,
                  label:
                      'About Doctor',
                  hint:
                      'Write doctor description...',
                  icon:
                      Icons
                          .description_outlined,
                  maxLines: 5,
                ),

                const SizedBox(
                  height: 24,
                ),

                // ------------------------------------------------
                // WEEKLY AVAILABILITY
                // ------------------------------------------------

                _sectionTitle(
                  'Weekly Availability',
                ),

                const SizedBox(
                  height: 14,
                ),

                _scheduleList(),

                const SizedBox(
                  height: 30,
                ),

                // ------------------------------------------------
                // SAVE BUTTON
                // ------------------------------------------------

                Obx(
                  () => SizedBox(
                    width:
                        double.infinity,
                    height: 54,
                    child:
                        ElevatedButton(
                      onPressed:
                          isSaving.value
                              ? null
                              : _saveDoctor,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            blue,
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            blue.withOpacity(
                          0.6,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      child:
                          isSaving.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                      Colors
                                          .white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isEditMode
                                      ? 'Update Doctor'
                                      : 'Create Doctor',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Widget _imagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    lightBlue,
                border:
                    Border.all(
                  color:
                      blue.withOpacity(
                    0.15,
                  ),
                  width: 2,
                ),
              ),
              child:
                  ClipOval(
                child:
                    selectedImage !=
                            null
                        ? Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : existingImageUrl
                                .isNotEmpty
                            ? Image.network(
                                existingImageUrl,
                                fit: BoxFit
                                    .cover,
                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Icon(
                                    Icons
                                        .person_outline,
                                    size: 55,
                                    color:
                                        blue,
                                  );
                                },
                              )
                            : Icon(
                                Icons
                                    .person_outline,
                                size: 55,
                                color:
                                    blue,
                              ),
              ),
            ),

            Positioned(
              right: 2,
              bottom: 2,
              child:
                  Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(
                  color:
                      blue,
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color:
                        Colors.white,
                    width: 3,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .camera_alt_outlined,
                  color:
                      Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight:
            FontWeight.w700,
        color:
            darkText,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)?
        validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller:
          controller,
      enabled:
          enabled,
      validator:
          validator,
      keyboardType:
          keyboardType,
      obscureText:
          obscureText,
      maxLines:
          obscureText
              ? 1
              : maxLines,
      style:
          TextStyle(
        color:
            darkText,
        fontSize:
            15,
      ),
      decoration:
          InputDecoration(
        labelText:
            label,
        hintText:
            hint,
        prefixIcon:
            Icon(
          icon,
          color:
              blue,
        ),
        suffixIcon:
            suffixIcon,
        labelStyle:
            TextStyle(
          color:
              greyText,
        ),
        hintStyle:
            TextStyle(
          color:
              greyText.withOpacity(
            0.65,
          ),
        ),
        filled:
            true,
        fillColor:
            Colors.white,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal:
              16,
          vertical:
              16,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide(
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
              BorderSide(
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
              BorderSide(
            color:
                blue,
            width:
                1.5,
          ),
        ),
        disabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide(
            color:
                borderColor,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.red,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.red,
            width:
                1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCHEDULE LIST
  // ============================================================

Widget _scheduleList() {
  return Column(
    children: days.map(
      (String day) {
        final Map<String, dynamic> schedule =
            weeklySchedule[day]!;

        final bool enabled =
            schedule['enabled'] == true;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      day,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Switch(
                    value: enabled,
                    activeColor: blue,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    onChanged: (bool value) {
                      setState(() {
                        weeklySchedule[day]![
                            'enabled'] = value;
                      });
                    },
                  ),
                ],
              ),

              if (enabled) ...[
                const SizedBox(height: 8),

                // Responsive time section
                LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                  ) {
                    return Row(
                      children: [
                        // START TIME
                        Expanded(
                          child: _timeButton(
                            label:
                                schedule['start'].toString(),
                            onTap: () => _pickTime(
                              day,
                              true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // ARROW
                        SizedBox(
                          width: 24,
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: greyText,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // END TIME
                        Expanded(
                          child: _timeButton(
                            label:
                                schedule['end'].toString(),
                            onTap: () => _pickTime(
                              day,
                              false,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    ).toList(),
  );
}

  // ============================================================
  // TIME BUTTON
  // ============================================================

 Widget _timeButton({
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 44,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: blue,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


// ============================================================
// SPECIALIST DROPDOWN
// ============================================================

Widget _specialistDropdown() {
  return DropdownButtonFormField<String>(
    value: selectedSpecialist,
    isExpanded: true,

    decoration: InputDecoration(
      labelText: 'Specialist',
      hintText: 'Select specialist',

      prefixIcon: Icon(
        Icons.medical_services_outlined,
        color: blue,
      ),

      labelStyle: TextStyle(
        color: greyText,
      ),

      hintStyle: TextStyle(
        color: greyText.withOpacity(0.65),
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: blue,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    ),

    icon: Icon(
      Icons.keyboard_arrow_down_rounded,
      color: greyText,
    ),

    items: specialistOptions.map(
      (String specialist) {
        return DropdownMenuItem<String>(
          value: specialist,
          child: Text(
            specialist,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: darkText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    ).toList(),

    onChanged: (String? value) {
      setState(() {
        selectedSpecialist = value;
      });
    },

    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a specialist';
      }

      return null;
    },
  );
}

}