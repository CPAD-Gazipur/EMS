import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../profile/profile_screen.dart';

class MessageView extends StatefulWidget {
  String? image, name, groupID, fcmToken;
  DocumentSnapshot userDoc;

  MessageView({
    Key? key,
    this.image,
    this.name,
    this.groupID,
    this.fcmToken,
    required this.userDoc,
  }) : super(key: key);

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  bool isSendingMessage = false;
  bool isEmojiPickerOpen = false;
  String myUID = '';
  var screenHeight;
  var screenWidth;

  DataController? dataController;
  TextEditingController messageController = TextEditingController();
  FocusNode inputNode = FocusNode();
  String replyMessage = '';

  void openKeyBoard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  onEmojiSelected(Emoji emoji) {
    messageController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }

  onBackSpacePressed() {
    messageController
      ..text = messageController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }

  @override
  void initState() {
    super.initState();
    dataController = Get.find<DataController>();
    myUID = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        name: widget.name!,
        image: widget.image!,
        userDoc: widget.userDoc,
      ),
      body: Column(
        children: [
          Expanded(
            child: dataController!.isMessageSending.value
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : StreamBuilder<QuerySnapshot>(
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      List<DocumentSnapshot> data =
                          snapshot.data!.docs.reversed.toList();

                      return ListView.builder(
                        reverse: true,
                        itemBuilder: (context, index) {
                          String messageUserID = data[index].get('uID');
                          String messageType = data[index].get('type');

                          Widget messageWidget = Container();

                          if (messageUserID == myUID) {
                            switch (messageType) {
                              case 'iSentText':
                                messageWidget = textMessageISent(data[index]);
                                break;
                            }
                          } else {
                            switch (messageType) {
                              case 'iSentText':
                                messageWidget = textMessageIGot(data[index]);
                                break;
                            }
                          }
                          return messageWidget;
                        },
                        itemCount: data.length,
                      );
                    },
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.groupID)
                        .collection('chatroom')
                        .snapshots(),
                  ),
          ),
          Container(
            height: isEmojiPickerOpen ? 300 : 75,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 9,
                  blurRadius: 9,
                  offset: const Offset(3, 0),
                ),
              ],
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 15,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white2.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isEmojiPickerOpen = !isEmojiPickerOpen;
                          });
                        },
                        child: const Icon(
                          Icons.tag_faces_outlined,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: inputNode,
                          controller: messageController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: AppColors.whiteGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.13,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Choose'),
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: const Icon(Icons.camera_alt),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: const Icon(Icons
                                              .photo_size_select_actual_outlined),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Image(
                              image: AssetImage('assets/images/gallery.png'),
                              width: 20,
                              height: 20,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.03,
                          ),
                          InkWell(
                            onTap: () {
                              if (messageController.text.isEmpty) {
                                return;
                              }

                              String message = messageController.text;
                              messageController.clear();

                              Map<String, dynamic> data = {
                                'type': 'iSentText',
                                'message': message,
                                'timeStamp': DateTime.now(),
                                'uID': myUID,
                              };

                              dataController!.sendMessageToFirebase(
                                data: data,
                                groupID: widget.groupID,
                                lastMessage: message,
                              );
                            },
                            child: SizedBox(
                              width: 41,
                              height: 41,
                              child: Image.asset(
                                  'assets/images/blackSendIcon.png'),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Offstage(
                  offstage: !isEmojiPickerOpen,
                  child: SizedBox(
                    height: 230,
                    child: EmojiPicker(
                      onEmojiSelected: (Category category, Emoji emoji) {
                        onEmojiSelected(emoji);
                      },
                      onBackspacePressed: onBackSpacePressed,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
                        bgColor: const Color(0xFFF2F2F2),
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        progressIndicatorColor: Colors.blue,
                        backspaceColor: Colors.blue,
                        showRecentsTab: true,
                        recentsLimit: 28,
                        noRecents: const Text(
                          'No Recent',
                          style: TextStyle(fontSize: 20, color: Colors.black26),
                          textAlign: TextAlign.center,
                        ),
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  textMessageISent(DocumentSnapshot doc) {
    String message = doc.get('message');

    Timestamp time = doc.get('timeStamp') as Timestamp;
    DateTime dateTime = time.toDate();
    String timeString = DateFormat('hh:mm:ss aa').format(dateTime);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(
              right: 20,
            ),
            width: screenWidth * 0.38,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                topRight: Radius.zero,
                topLeft: Radius.circular(18),
              ),
              color: Colors.black,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              right: 32,
              top: 3,
            ),
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  textMessageIGot(DocumentSnapshot doc) {
    String message = doc.get('message');
    Timestamp time = doc.get('timeStamp') as Timestamp;
    DateTime dateTime = time.toDate();
    String timeString = DateFormat('hh:mm:ss aa').format(dateTime);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 20,
            ),
            width: screenWidth * 0.38,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                topLeft: Radius.zero,
              ),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 32,
              top: 3,
            ),
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  String name, image;
  DocumentSnapshot userDoc;

  CustomAppBar({
    Key? key,
    required this.name,
    required this.image,
    required this.userDoc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String address;

    try {
      address = userDoc.get('location');
    } catch (e) {
      address = 'No address found';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: Get.width * 0.03,
            top: Get.height * 0.06,
            bottom: Get.height * 0.02,
          ),
          width: 30,
          height: 30,
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Image.asset('assets/images/back_button.png'),
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        Container(
          margin: EdgeInsets.only(
            top: Get.height * 0.04,
          ),
          child: InkWell(
            onTap: () {
              Get.to(
                () => ProfileScreen(
                  userSnapshot: userDoc,
                  isOtherUser: true,
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.contain,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          margin: EdgeInsets.only(
            top: Get.height * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Text(
                address,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
