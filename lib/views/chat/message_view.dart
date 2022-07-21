import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:ems/widgets/chat_no_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/config.dart';
import '../../controller/controller.dart';
import '../../widgets/widgets.dart';
import '../view.dart';

// ignore: must_be_immutable
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
  bool isSendMessage = false;

  File? profileImage;

  String myUID = '';
  // ignore: prefer_typing_uninitialized_variables
  var screenHeight;
  // ignore: prefer_typing_uninitialized_variables
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
        onClearChatPressed: () {
          dataController!.clearAllChatFromFirebase(
            groupID: widget.groupID!,
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => dataController!.isMessageSending.value
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      builder: (context, snapshot) {
                        if (!snapshot.hasData && !isSendMessage) {
                          return const ChatShimmerEffect();
                        } else if (snapshot.hasData) {
                          List<DocumentSnapshot> data =
                              snapshot.data!.docs.reversed.toList();
                          if (data.isEmpty) {
                            return ChatNoMessage(onSendMessage: () {
                              Map<String, dynamic> data = {
                                'type': 'iSentText',
                                'message': 'Hi',
                                'timeStamp': DateTime.now(),
                                'uID': myUID,
                              };

                              dataController!.sendMessageToFirebase(
                                data: data,
                                groupID: widget.groupID,
                                lastMessage: 'Hi',
                              );

                              setState(() {
                                isSendMessage = true;
                              });
                            });
                          } else {
                            return ListView.builder(
                              reverse: true,
                              itemBuilder: (context, index) {
                                String messageUserID = data[index].get('uID');
                                String messageType = data[index].get('type');

                                Widget messageWidget = Container();

                                if (messageUserID == myUID) {
                                  switch (messageType) {
                                    case 'iSentText':
                                      messageWidget = TextMessageISent(
                                        doc: data[index],
                                        onDeletePressed: () {
                                          dataController!
                                              .deleteMessageFromFirebaseDatabase(
                                            doc: data[index],
                                            groupID: widget.groupID!,
                                          );
                                        },
                                      );
                                      break;
                                    case 'iSentImage':
                                      messageWidget = ImageMessageISent(
                                        doc: data[index],
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                        onDeletePressed: () {
                                          dataController!
                                              .deleteMessageFromFirebaseDatabase(
                                            doc: data[index],
                                            groupID: widget.groupID!,
                                            imagePath:
                                                data[index].get('message'),
                                          );
                                        },
                                      );
                                      break;
                                  }
                                } else {
                                  switch (messageType) {
                                    case 'iSentText':
                                      messageWidget = TextMessageIGot(
                                        doc: data[index],
                                      );
                                      break;
                                    case 'iSentImage':
                                      messageWidget = ImageMessageIGot(
                                        doc: data[index],
                                        screenHeight: screenHeight,
                                        screenWidth: screenWidth,
                                      );
                                      break;
                                  }
                                }
                                return messageWidget;
                              },
                              itemCount: data.length,
                            );
                          }
                        } else {
                          return Container();
                        }
                      },
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.groupID)
                          .collection('chatroom')
                          .orderBy('timeStamp', descending: false)
                          .snapshots(),
                    ),
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
                        child: Icon(
                          Icons.tag_faces_outlined,
                          color: isEmojiPickerOpen ? Colors.blue : null,
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
                          onFieldSubmitted: (value) {
                            sendMessage();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
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
                                        IconButton(
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            semanticLabel: 'Camera',
                                          ),
                                          onPressed: () {
                                            openCameraOrGallery(
                                              imageSource: ImageSource.camera,
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons
                                                .photo_size_select_actual_outlined,
                                            semanticLabel: 'Gallery',
                                          ),
                                          onPressed: () async {
                                            openCameraOrGallery(
                                              imageSource: ImageSource.gallery,
                                            );
                                          },
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
                          SizedBox(width: screenWidth * 0.03),
                          InkWell(
                            onTap: () {
                              sendMessage();
                            },
                            child: SizedBox(
                              width: 41,
                              height: 41,
                              child: Image.asset(
                                  'assets/images/blackSendIcon.png'),
                            ),
                          ),
                        ],
                      ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openCameraOrGallery({required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: imageSource);

    if (image != null) {
      dataController!.isMessageSending(true);

      File compressedFile;

      try {
        compressedFile = await FlutterNativeImage.compressImage(
          image.path,
          quality: 50,
        );
      } catch (e) {
        compressedFile = File(image.path);
        debugPrint('Error: $e');
      }

      Get.back();

      var decodedImage =
          await decodeImageFromList(compressedFile.readAsBytesSync());
      bool isHorizontalImage = decodedImage.width > decodedImage.height;

      String imageUrl = await dataController!.uploadImageToFirebase(
        compressedFile,
        isSendMessage: true,
      );

      Map<String, dynamic> data = {
        'type': 'iSentImage',
        'message': imageUrl,
        'timeStamp': DateTime.now(),
        'uID': myUID,
        'isHorizontalImage': isHorizontalImage,
      };

      dataController!.sendMessageToFirebase(
        data: data,
        groupID: widget.groupID,
        lastMessage: 'Image',
      );

      dataController!.isMessageSending(false);
    }
  }

  void sendMessage() {
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
  }
}

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  String name, image;
  DocumentSnapshot userDoc;
  final Function() onClearChatPressed;

  CustomAppBar({
    Key? key,
    required this.name,
    required this.image,
    required this.userDoc,
    required this.onClearChatPressed,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
            const SizedBox(width: 20),
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
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              margin: EdgeInsets.only(
                top: Get.height * 0.054,
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
                    address.isEmpty ? 'No address found' : address,
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
          ],
        ),
        Container(
          margin: EdgeInsets.only(
            top: Get.height * 0.04,
          ),
          padding: const EdgeInsets.only(right: 10),
          child: FocusedMenuHolder(
            onPressed: () {},
            openWithTap: true,
            animateMenuItems: true,
            duration: const Duration(microseconds: 100),
            menuOffset: 10.0,
            bottomOffsetHeight: 10,
            blurSize: 1,
            menuWidth: MediaQuery.of(context).size.width / 3,
            menuItems: [
              FocusedMenuItem(
                title: const Text(
                  "Clear Chat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailingIcon: const Icon(
                  Icons.cleaning_services_rounded,
                  color: Colors.grey,
                ),
                onPressed: onClearChatPressed,
              ),
              FocusedMenuItem(
                title: const Text(
                  "Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailingIcon: const Icon(
                  Icons.settings,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Get.showSnackbar(
                    const GetSnackBar(
                      message: 'Developing...',
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class ImageDialog extends StatelessWidget {
  final String imageURL;
  final bool isHorizontalImage;

  const ImageDialog({
    Key? key,
    required this.imageURL,
    required this.isHorizontalImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CachedNetworkImage(
        imageUrl: imageURL,
        fit: BoxFit.contain,
        imageBuilder: (context, imageProvider) => Container(
          height: isHorizontalImage ? 220 : 500,
          width: double.infinity - 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => SizedBox(
          height: isHorizontalImage ? 220 : 500,
          width: double.infinity - 40,
          child: Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.white,
            direction: ShimmerDirection.ltr,
            child: Image.asset(
              'assets/images/placeholder-image.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) => SizedBox(
          height: isHorizontalImage ? 220 : 500,
          width: double.infinity - 40,
          child: Image.asset(
            'assets/images/placeholder-image.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class TextMessageISent extends StatelessWidget {
  final DocumentSnapshot doc;
  final Function() onDeletePressed;

  const TextMessageISent({
    Key? key,
    required this.doc,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message = doc.get('message');
    Timestamp time = doc.get('timeStamp') as Timestamp;

    DateTime dateTime = time.toDate();
    String timeString = DateFormat('hh:mm:ss aa').format(dateTime);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FocusedMenuHolder(
            onPressed: () {},
            openWithTap: true,
            animateMenuItems: true,
            duration: const Duration(microseconds: 100),
            menuOffset: 10.0,
            bottomOffsetHeight: 10,
            blurSize: 1,
            menuWidth: MediaQuery.of(context).size.width / 2,
            menuItems: [
              FocusedMenuItem(
                title: const Text(
                  "Copy Text",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailingIcon: const Icon(
                  Icons.copy,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  Get.showSnackbar(
                    const GetSnackBar(
                      message: 'Messaged Copied',
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),
              FocusedMenuItem(
                title: const Text(
                  "Delete",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailingIcon: const Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                ),
                onPressed: onDeletePressed,
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(
                right: 10,
                left: 40,
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  topRight: Radius.zero,
                  topLeft: Radius.circular(18),
                ),
                color: Colors.blue,
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
          ),
          Container(
            margin: const EdgeInsets.only(
              right: 25,
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

class TextMessageIGot extends StatelessWidget {
  final DocumentSnapshot doc;

  const TextMessageIGot({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message = doc.get('message');
    Timestamp time = doc.get('timeStamp') as Timestamp;
    DateTime dateTime = time.toDate();
    String timeString = DateFormat('hh:mm:ss aa').format(dateTime);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FocusedMenuHolder(
            onPressed: () {},
            openWithTap: true,
            animateMenuItems: true,
            duration: const Duration(microseconds: 100),
            menuOffset: 10.0,
            bottomOffsetHeight: 10,
            blurSize: 1,
            menuWidth: MediaQuery.of(context).size.width / 2,
            menuItems: [
              FocusedMenuItem(
                title: const Text(
                  "Copy Text",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailingIcon: const Icon(
                  Icons.copy,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  Get.showSnackbar(
                    const GetSnackBar(
                      message: 'Messaged Copied',
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 40,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  topLeft: Radius.zero,
                ),
                color: Colors.grey.withOpacity(0.2),
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
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 25,
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

class ImageMessageISent extends StatelessWidget {
  final DocumentSnapshot doc;
  final double screenHeight;
  final double screenWidth;
  final Function() onDeletePressed;

  const ImageMessageISent({
    Key? key,
    required this.doc,
    required this.screenHeight,
    required this.screenWidth,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageLink = doc.get('message');
    Timestamp time = doc.get('timeStamp') as Timestamp;
    bool isHorizontalImage = doc.get('isHorizontalImage');
    DateTime dateTime = time.toDate();
    String timeString = DateFormat('hh:mm:ss aa').format(dateTime);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: screenHeight * 0.18,
            width: screenWidth * 0.42,
            margin: const EdgeInsets.only(
              right: 10,
              left: 40,
            ),
            child: CachedNetworkImage(
              imageUrl: imageLink,
              fit: BoxFit.contain,
              imageBuilder: (context, imageProvider) => FocusedMenuHolder(
                onPressed: () {},
                openWithTap: true,
                animateMenuItems: true,
                duration: const Duration(microseconds: 100),
                menuOffset: 10.0,
                bottomOffsetHeight: 10,
                blurSize: 1,
                menuWidth: MediaQuery.of(context).size.width / 2,
                menuItems: [
                  FocusedMenuItem(
                    title: const Text(
                      "Full View",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    trailingIcon: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(
                          imageURL: imageLink,
                          isHorizontalImage: isHorizontalImage,
                        ),
                      );
                    },
                  ),
                  FocusedMenuItem(
                    title: const Text(
                      "Delete",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    trailingIcon: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                    ),
                    onPressed: onDeletePressed,
                  ),
                ],
                child: Container(
                  height: screenHeight * 0.18,
                  width: screenWidth * 0.42,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.zero,
                      topLeft: Radius.circular(18),
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              placeholder: (context, url) => SizedBox(
                height: screenHeight * 0.18,
                width: screenWidth * 0.42,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  direction: ShimmerDirection.ltr,
                  child: Image.asset(
                    'assets/images/placeholder-image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => SizedBox(
                height: screenHeight * 0.18,
                width: screenWidth * 0.42,
                child: Image.asset(
                  'assets/images/placeholder-image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              right: 25,
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

class ImageMessageIGot extends StatelessWidget {
  final DocumentSnapshot doc;
  final double screenHeight;
  final double screenWidth;

  const ImageMessageIGot({
    Key? key,
    required this.doc,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageLink = doc.get('message');
    bool isHorizontalImage = doc.get('isHorizontalImage');
    Timestamp time = doc.get('timeStamp') as Timestamp;
    DateTime dateTime = time.toDate();
    String timeString = DateFormat('hh:mm:ss aa').format(dateTime);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: screenHeight * 0.18,
            width: screenWidth * 0.42,
            margin: const EdgeInsets.only(
              left: 10,
              right: 40,
            ),
            child: CachedNetworkImage(
              imageUrl: imageLink,
              fit: BoxFit.contain,
              imageBuilder: (context, imageProvider) => FocusedMenuHolder(
                onPressed: () {},
                openWithTap: true,
                animateMenuItems: true,
                duration: const Duration(microseconds: 100),
                menuOffset: 10.0,
                bottomOffsetHeight: 10,
                blurSize: 1,
                menuWidth: MediaQuery.of(context).size.width / 2,
                menuItems: [
                  FocusedMenuItem(
                    title: const Text(
                      "Full View",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    trailingIcon: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(
                          imageURL: imageLink,
                          isHorizontalImage: isHorizontalImage,
                        ),
                      );
                    },
                  ),
                ],
                child: Container(
                  height: screenHeight * 0.18,
                  width: screenWidth * 0.42,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      topLeft: Radius.zero,
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              placeholder: (context, url) => SizedBox(
                height: screenHeight * 0.18,
                width: screenWidth * 0.42,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  direction: ShimmerDirection.ltr,
                  child: Image.asset(
                    'assets/images/placeholder-image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => SizedBox(
                height: screenHeight * 0.18,
                width: screenWidth * 0.42,
                child: Image.asset(
                  'assets/images/placeholder-image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 25,
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
