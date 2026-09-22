import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicalchat/controller/chat_controller.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    this.doctor,
  });

  final Map<String, dynamic>? doctor;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final String _tag;
  late final ChatController controller;

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
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    final String firstId =
        widget.doctor?['id']?.toString() ??
        widget.doctor?['doctorId']?.toString() ??
        widget.doctor?['userId']?.toString() ??
        widget.doctor?['patientId']?.toString() ??
        '';

    _tag = firstId.isNotEmpty
        ? 'chat_$firstId'
        : 'chat_${DateTime.now().microsecondsSinceEpoch}';

    controller = Get.put(
      ChatController(),
      tag: _tag,
    );

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        controller.initializeChat(
          widget.doctor,
        );
      },
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    if (Get.isRegistered<ChatController>(
      tag: _tag,
    )) {
      Get.delete<ChatController>(
        tag: _tag,
      );
    }

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.isSelectionMode) {
          controller.clearSelection();
          return false;
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              _chatHeader(),

              Expanded(
                child: Obx(
                  () {
                    if (controller
                        .isLoading.value) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color: blue,
                        ),
                      );
                    }

                    if (controller
                        .messages.isEmpty) {
                      return _emptyChat();
                    }

                    return ListView.builder(
                      controller:
                          controller
                              .scrollController,
                      padding:
                          EdgeInsets.fromLTRB(
                        Get.width * .045,
                        Get.height * .018,
                        Get.width * .045,
                        Get.height * .018,
                      ),
                      physics:
                          const BouncingScrollPhysics(),
                      itemCount:
                          controller
                              .messages
                              .length,
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final ChatMessage
                            message =
                            controller
                                .messages[index];

                        return _messageBubble(
                          message,
                        );
                      },
                    );
                  },
                ),
              ),

              Obx(
                () {
                  if (controller
                      .isSelectionMode) {
                    return const SizedBox
                        .shrink();
                  }

                  return _messageInput();
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

  Widget _chatHeader() {
    return Obx(
      () {
        if (controller
            .isSelectionMode) {
          return _selectionHeader();
        }

        final bool online =
            controller
                .otherParticipantIsOnline;

        return Container(
          height:
              Get.height * .095,
          decoration:
              const BoxDecoration(
            color: Colors.white,
            border:
                Border(
              bottom:
                  BorderSide(
                color:
                    borderColor,
                width:
                    .7,
              ),
            ),
          ),
          padding:
              EdgeInsets.symmetric(
            horizontal:
                Get.width * .025,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed:
                    controller.goBack,
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      darkText,
                  size:
                      Get.width * .065,
                ),
              ),

              Container(
                width:
                    Get.width * .080,
                height:
                    Get.width * .080,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFD9F0FF),
                  shape:
                      BoxShape.circle,
                ),
                clipBehavior:
                    Clip.antiAlias,
                child:
                    _participantAvatar(
                  controller
                      .otherParticipantImage,
                  Get.width * .080,
                ),
              ),

              SizedBox(
                width:
                    Get.width * .025,
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      controller
                          .otherParticipantName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            darkText,
                        fontSize:
                            Get.width *
                                .030,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    SizedBox(
                      height:
                          Get.height *
                              .003,
                    ),

                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration:
                              BoxDecoration(
                            color: online
                                ? Colors.green
                                : const Color(
                                    0xFF9AA6B2,
                                  ),
                            shape:
                                BoxShape.circle,
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Flexible(
                          child: Text(
                            controller
                                .otherParticipantStatusText,
                            maxLines:
                                1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              color: online
                                  ? Colors.green
                                  : greyText,
                              fontSize:
                                  Get.width *
                                      .020,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // SELECTION HEADER
  // =========================================================

  Widget _selectionHeader() {
    return Container(
      height:
          Get.height * .095,
      decoration:
          const BoxDecoration(
        color: Colors.white,
        border:
            Border(
          bottom:
              BorderSide(
            color:
                borderColor,
            width:
                .7,
          ),
        ),
      ),
      padding:
          EdgeInsets.symmetric(
        horizontal:
            Get.width * .010,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                controller.clearSelection,
            icon: Icon(
              Icons.close,
              color:
                  darkText,
              size:
                  Get.width * .065,
            ),
          ),

          Text(
            controller.selectedCount
                .toString(),
            style:
                TextStyle(
              color:
                  darkText,
              fontSize:
                  Get.width * .040,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(
            width:
                Get.width * .020,
          ),

          const Text(
            'selected',
            style:
                TextStyle(
              color:
                  greyText,
              fontSize:
                  14,
            ),
          ),

          const Spacer(),

          IconButton(
            tooltip:
                'Select all',
            onPressed:
                controller
                    .selectAllMessages,
            icon: Icon(
              controller
                      .isAllMessagesSelected
                  ? Icons
                      .deselect_outlined
                  : Icons.select_all,
              color:
                  blue,
              size:
                  Get.width * .060,
            ),
          ),

          Obx(
            () => IconButton(
              tooltip:
                  'Delete',
              onPressed:
                  controller
                          .isDeletingMessages
                          .value
                      ? null
                      : _confirmDelete,
              icon: controller
                      .isDeletingMessages
                      .value
                  ? SizedBox(
                      width:
                          Get.width *
                              .050,
                      height:
                          Get.width *
                              .050,
                      child:
                          const CircularProgressIndicator(
                        strokeWidth:
                            2.2,
                        color:
                            Colors.red,
                      ),
                    )
                  : Icon(
                      Icons
                          .delete_outline,
                      color:
                          Colors.red,
                      size:
                          Get.width *
                              .065,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DELETE CONFIRMATION
  // =========================================================

  void _confirmDelete() {
    final int count =
        controller.selectedCount;

    if (count == 0) {
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor:
            Colors.white,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        title:
            const Text(
          'Delete message',
          style:
              TextStyle(
            color:
                darkText,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        content:
            Text(
          count == 1
              ? 'Are you sure you want to delete this message?'
              : 'Are you sure you want to delete these $count messages?',
          style:
              const TextStyle(
            color:
                greyText,
            height:
                1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                () => Get.back(),
            child:
                const Text(
              'Cancel',
              style:
                  TextStyle(
                color:
                    greyText,
              ),
            ),
          ),

          ElevatedButton(
            onPressed:
                () async {
              Get.back();

              await controller
                  .deleteSelectedMessages();
            },
            style:
                ElevatedButton
                    .styleFrom(
              backgroundColor:
                  Colors.red,
              foregroundColor:
                  Colors.white,
              elevation:
                  0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
                ),
              ),
            ),
            child:
                const Text(
              'Delete',
            ),
          ),
        ],
      ),
      barrierDismissible:
          false,
    );
  }

  // =========================================================
  // EMPTY CHAT
  // =========================================================

  Widget _emptyChat() {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          Get.width * .080,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Container(
              width:
                  Get.width * .200,
              height:
                  Get.width * .200,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFD9F0FF),
                shape:
                    BoxShape.circle,
              ),
              child:
                  Icon(
                Icons
                    .chat_bubble_outline,
                color:
                    blue,
                size:
                    Get.width * .100,
              ),
            ),

            SizedBox(
              height:
                  Get.height * .018,
            ),

            Text(
              'Start your conversation',
              textAlign:
                  TextAlign.center,
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
                  Get.height * .008,
            ),

            Text(
              controller.isDoctor
                  ? 'Send a message or image to your patient.'
                  : 'Send a message or image to your doctor.',
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
      ),
    );
  }

  // =========================================================
  // MESSAGE INPUT
  // =========================================================

  Widget _messageInput() {
    return Container(
      color:
          Colors.white,
      padding:
          EdgeInsets.fromLTRB(
        Get.width * .025,
        Get.height * .010,
        Get.width * .025,
        Get.height * .015,
      ),
      child:
          Container(
        constraints:
            BoxConstraints(
          minHeight:
              Get.height * .060,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFF8FAFC,
          ),
          borderRadius:
              BorderRadius.circular(
            Get.width * .025,
          ),
          border:
              Border.all(
            color:
                borderColor,
          ),
        ),
        child:
            Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Obx(
              () => IconButton(
                onPressed:
                    controller
                            .isUploadingImage
                            .value
                        ? null
                        : controller
                            .pickAndSendImage,
                icon: controller
                        .isUploadingImage
                        .value
                    ? SizedBox(
                        width:
                            Get.width *
                                .045,
                        height:
                            Get.width *
                                .045,
                        child:
                            const CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              blue,
                        ),
                      )
                    : Icon(
                        Icons
                            .add_photo_alternate_outlined,
                        color:
                            blue,
                        size:
                            Get.width *
                                .060,
                      ),
              ),
            ),

            Expanded(
              child:
                  TextField(
                controller:
                    controller
                        .messageController,
                minLines:
                    1,
                maxLines:
                    4,
                textInputAction:
                    TextInputAction
                        .send,
                onSubmitted:
                    (_) {
                  controller
                      .sendMessage();
                },
                style:
                    TextStyle(
                  color:
                      darkText,
                  fontSize:
                      Get.width * .028,
                ),
                decoration:
                    InputDecoration(
                  hintText:
                      'Write a message...',
                  hintStyle:
                      TextStyle(
                    color:
                        const Color(
                      0xFFAEB8C1,
                    ),
                    fontSize:
                        Get.width *
                            .026,
                  ),
                  border:
                      InputBorder.none,
                  contentPadding:
                      EdgeInsets
                          .symmetric(
                    horizontal:
                        Get.width *
                            .010,
                    vertical:
                        Get.height *
                            .012,
                  ),
                ),
              ),
            ),

            Obx(
              () => GestureDetector(
                onTap:
                    controller
                            .isSending
                            .value
                        ? null
                        : controller
                            .sendMessage,
                child:
                    Padding(
                  padding:
                      EdgeInsets.only(
                    right:
                        Get.width *
                            .030,
                    left:
                        Get.width *
                            .010,
                    bottom:
                        Get.height *
                            .012,
                  ),
                  child:
                      controller
                              .isSending
                              .value
                          ? SizedBox(
                              width:
                                  Get.width *
                                      .050,
                              height:
                                  Get.width *
                                      .050,
                              child:
                                  const CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    blue,
                              ),
                            )
                          : Icon(
                              Icons
                                  .send_outlined,
                              color:
                                  blue,
                              size:
                                  Get.width *
                                      .060,
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MESSAGE BUBBLE
  // =========================================================

  Widget _messageBubble(
    ChatMessage message,
  ) {
    return Obx(
      () {
        final bool selected =
            controller
                .selectedMessageIds
                .contains(
              message.id,
            );

        if (message.type ==
                'image' &&
            message.imageUrl
                .isNotEmpty) {
          return _imageMessage(
            message,
            selected,
          );
        }

        return GestureDetector(
          onLongPress:
              () {
            controller
                .startSelection(
              message.id,
            );
          },
          onTap:
              controller
                      .isSelectionMode
                  ? () {
                      controller
                          .selectMessage(
                        message.id,
                      );
                    }
                  : null,
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds:
                  150,
            ),
            decoration:
                selected
                    ? BoxDecoration(
                        color:
                            blue.withOpacity(
                          .10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      )
                    : null,
            padding:
                EdgeInsets.symmetric(
              vertical:
                  Get.height *
                      .004,
            ),
            child:
                _textMessageContent(
              message,
              selected,
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // TEXT MESSAGE
  // =========================================================

  Widget _textMessageContent(
    ChatMessage message,
    bool selected,
  ) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom:
            Get.height * .014,
      ),
      child:
          Column(
        crossAxisAlignment:
            message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment
                    .start,
        children: [
          Row(
            mainAxisAlignment:
                message.isMe
                    ? MainAxisAlignment
                        .end
                    : MainAxisAlignment
                        .start,
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,
            children: [
              if (!message.isMe)
                _smallParticipantAvatar(),

              Flexible(
                child:
                    Container(
                  constraints:
                      BoxConstraints(
                    maxWidth:
                        Get.width *
                            .680,
                  ),
                  padding:
                      EdgeInsets
                          .symmetric(
                    horizontal:
                        Get.width *
                            .030,
                    vertical:
                        Get.height *
                            .012,
                  ),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? const Color(
                            0xFF1976D2,
                          )
                        : message.isMe
                            ? blue
                            : Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      Get.width *
                          .020,
                    ),
                    border:
                        message.isMe
                            ? null
                            : Border.all(
                                color:
                                    borderColor,
                              ),
                  ),
                  child:
                      Text(
                    message.text,
                    style:
                        TextStyle(
                      color:
                          message.isMe
                              ? Colors.white
                              : darkText,
                      fontSize:
                          Get.width *
                              .026,
                      height:
                          1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height:
                Get.height * .004,
          ),

          _time(message),
        ],
      ),
    );
  }

  // =========================================================
  // IMAGE MESSAGE
  // =========================================================

  Widget _imageMessage(
    ChatMessage message,
    bool selected,
  ) {
    return GestureDetector(
      onLongPress:
          () {
        controller
            .startSelection(
          message.id,
        );
      },
      onTap:
          controller
                  .isSelectionMode
              ? () {
                  controller
                      .selectMessage(
                    message.id,
                  );
                }
              : null,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              150,
        ),
        margin:
            EdgeInsets.only(
          bottom:
              Get.height * .014,
        ),
        padding:
            EdgeInsets.all(
          selected ? 4 : 0,
        ),
        decoration:
            selected
                ? BoxDecoration(
                    color:
                        blue.withOpacity(
                      .18,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  )
                : null,
        child:
            Column(
          crossAxisAlignment:
              message.isMe
                  ? CrossAxisAlignment
                      .end
                  : CrossAxisAlignment
                      .start,
          children: [
            Row(
              mainAxisAlignment:
                  message.isMe
                      ? MainAxisAlignment
                          .end
                      : MainAxisAlignment
                          .start,
              children: [
                if (!message.isMe)
                  _smallParticipantAvatar(),

                Container(
                  width:
                      Get.width * .600,
                  height:
                      Get.height * .250,
                  padding:
                      const EdgeInsets
                          .all(
                    3,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      Get.width *
                          .020,
                    ),
                    border:
                        Border.all(
                      color:
                          selected
                              ? blue
                              : borderColor,
                      width:
                          selected
                              ? 2
                              : 1,
                    ),
                  ),
                  child:
                      ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      Get.width *
                          .015,
                    ),
                    child:
                        Image.network(
                      message
                          .imageUrl,
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
                            color:
                                blue,
                          ),
                        );
                      },
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Center(
                          child:
                              Icon(
                            Icons
                                .broken_image_outlined,
                            color:
                                blue,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height:
                  Get.height * .004,
            ),

            _time(message),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TIME
  // =========================================================

  Widget _time(
    ChatMessage message,
  ) {
    return Padding(
      padding:
          EdgeInsets.only(
        left:
            message.isMe
                ? 0
                : Get.width * .090,
        right:
            message.isMe
                ? Get.width * .010
                : 0,
      ),
      child:
          Text(
        message.formattedTime,
        style:
            TextStyle(
          color:
              const Color(
            0xFFAEB8C1,
          ),
          fontSize:
              Get.width * .019,
        ),
      ),
    );
  }

  // =========================================================
  // SMALL AVATAR
  // =========================================================

  Widget _smallParticipantAvatar() {
    return Container(
      width:
          Get.width * .070,
      height:
          Get.width * .070,
      margin:
          EdgeInsets.only(
        right:
            Get.width * .018,
      ),
      decoration:
          const BoxDecoration(
        color:
            Color(0xFFD9F0FF),
        shape:
            BoxShape.circle,
      ),
      clipBehavior:
          Clip.antiAlias,
      child:
          _participantAvatar(
        controller
            .otherParticipantImage,
        Get.width * .070,
      ),
    );
  }

  // =========================================================
  // PARTICIPANT AVATAR
  // =========================================================

  Widget _participantAvatar(
    String image,
    double size,
  ) {
    if (image.trim().isEmpty) {
      return Icon(
        Icons.person,
        color:
            blue,
        size:
            size * .65,
      );
    }

    return Image.network(
      image,
      width:
          size,
      height:
          size,
      fit:
          BoxFit.cover,
      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons.person,
          color:
              blue,
          size:
              size * .65,
        );
      },
    );
  }
}