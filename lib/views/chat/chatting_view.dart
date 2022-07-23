import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../profile/profile_screen.dart';
import '../view.dart';

class ChattingView extends StatefulWidget {
  const ChattingView({Key? key}) : super(key: key);

  @override
  State<ChattingView> createState() => _ChattingViewState();
}

class _ChattingViewState extends State<ChattingView> {
  DataController dataController = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  top: Get.width * 0.03,
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      errorBorder: InputBorder.none,
                      errorStyle: const TextStyle(
                        fontSize: 0,
                        height: 0,
                      ),
                      focusedErrorBorder: InputBorder.none,
                      fillColor: Colors.deepOrangeAccent[2],
                      filled: true,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Search...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    onChanged: (searchValue) {
                      if (searchValue.isEmpty) {
                        dataController.filterUsers
                            .assignAll(dataController.allUsers);
                      } else {
                        List<DocumentSnapshot> searchUserList =
                            dataController.allUsers.value.where((element) {
                          String name;
                          try {
                            name = element.get('name');
                          } catch (_) {
                            name = 'Anonymous User';
                          }
                          return name
                              .toLowerCase()
                              .contains(searchValue.toLowerCase());
                        }).toList();

                        dataController.filterUsers.value
                            .assignAll(searchUserList);

                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: dataController.filterUsers.length,
                    itemBuilder: (context, index) {
                      String name, profileImageUrl, lastMessage, myUid;

                      try {
                        myUid = FirebaseAuth.instance.currentUser!.uid;
                      } catch (_) {
                        myUid = '';
                      }

                      try {
                        name = dataController.filterUsers[index].get('name');
                      } catch (_) {
                        name = 'Anonymous User';
                      }

                      try {
                        profileImageUrl =
                            dataController.filterUsers[index].get('image');
                      } catch (_) {
                        profileImageUrl = '';
                      }

                      try {
                        lastMessage = dataController.filterUsers[index]
                            .get('lastMessage');
                      } catch (_) {
                        lastMessage = 'No last message found';
                      }

                      return dataController.filterUsers[index].id ==
                              FirebaseAuth.instance.currentUser!.uid
                          ? Container()
                          : Container(
                              width: screenWidth * 0.01,
                              height: screenHeight * 0.08,
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: InkWell(
                                onTap: () {
                                  String chatRoomID = '';

                                  if (myUid.hashCode >
                                      dataController
                                          .filterUsers[index].id.hashCode) {
                                    chatRoomID =
                                        '$myUid-${dataController.filterUsers[index].id}';
                                  } else {
                                    chatRoomID =
                                        '${dataController.filterUsers[index].id}-$myUid';
                                  }

                                  Get.to(
                                    () => MessageView(
                                      name: name,
                                      image: profileImageUrl,
                                      groupID: chatRoomID,
                                      userDoc:
                                          dataController.filterUsers[index],
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Get.to(
                                            () => ProfileScreen(
                                              userSnapshot: dataController
                                                  .filterUsers[index],
                                              isOtherUser: true,
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blue,
                                          child: CachedNetworkImage(
                                            imageUrl: profileImageUrl,
                                            fit: BoxFit.contain,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator
                                                  .adaptive(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.06),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              lastMessage,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: Get.width * 0.05),
                                      Image(
                                        image: const AssetImage(
                                            'assets/images/camera.png'),
                                        width: screenWidth * 0.1,
                                        height: screenHeight * 0.1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
