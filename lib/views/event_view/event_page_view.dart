import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/config/app_colors.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:ems/views/checkout/checkout_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventPageView extends StatefulWidget {
  final DocumentSnapshot eventData, user;
  const EventPageView({Key? key, required this.eventData, required this.user})
      : super(key: key);

  @override
  State<EventPageView> createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
  String userName = '';
  String userAddress = '';
  String profileImage = '';
  String eventImage = '';
  String eventAccess = '';

  List joinedUser = [];
  DataController dataController = Get.find<DataController>();

  List tags = [];
  String tagCollectively = '';

  List eventSaveUserList = [];
  List eventLikedUserList = [];

  int likes = 0;
  int comments = 0;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    analytics.setCurrentScreen(screenName: 'EventView Screen');

    try {
      userName = widget.user.get('name');
    } catch (e) {
      userName = '';
    }

    try {
      userAddress = widget.user.get('location');
    } catch (e) {
      userAddress = '';
    }

    try {
      profileImage = widget.user.get('image');
    } catch (e) {
      profileImage = '';
    }

    try {
      eventAccess = widget.eventData.get('event_invite_access');
    } catch (e) {
      eventAccess = '';
    }

    try {
      List media = widget.eventData.get('event_media') as List;
      Map mediaMap =
          media.firstWhere((element) => element['isImage'] == true) as Map;
      eventImage = mediaMap['url'];
    } catch (e) {
      eventImage = '';
    }

    try {
      joinedUser = widget.eventData.get('event_joined');
    } catch (e) {
      joinedUser = [];
    }

    try {
      tags = widget.eventData.get('event_tags') as List;
    } catch (e) {
      tags = [];
    }

    tagCollectively = '';
    for (String element in tags) {
      tagCollectively += '#${element.trim()} ';
    }

    try {
      likes = widget.eventData.get('likes').length;
      eventLikedUserList = widget.eventData.get('likes');
    } catch (e) {
      likes = 0;
      eventLikedUserList = [];
    }

    try {
      comments = widget.eventData.get('comments').length;
    } catch (e) {
      comments = 0;
    }

    try {
      eventSaveUserList = widget.eventData.get('saved_user_list');
    } catch (e) {
      eventSaveUserList = [];
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50, bottom: 20),
                width: 30,
                height: 30,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: CachedNetworkImage(
                      imageUrl: profileImage,
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
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        userAddress,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          eventAccess,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      widget.eventData.get('event_start_time'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.eventData.get('event_name'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.eventData.get('event_date').toString().split(',')[0],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.eventData.get('event_location'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.activeColor,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CachedNetworkImage(
                imageUrl: eventImage,
                fit: BoxFit.contain,
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  height: Get.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => SizedBox(
                  width: double.infinity,
                  height: Get.width * 0.5,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => SizedBox(
                    width: double.infinity,
                    height: Get.width * 0.5,
                    child: const Center(child: Icon(Icons.error))),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: Get.width * 0.6,
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: joinedUser.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot user = dataController.allUsers
                            .firstWhere(
                                (element) => joinedUser[index] == element.id);

                        String image = '';
                        try {
                          image = user.get('image');
                        } catch (e) {
                          image = '';
                        }
                        return Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            minRadius: 15,
                            backgroundImage: NetworkImage(image),
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$ ${widget.eventData.get('event_price')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${widget.eventData.get('event_max_entries')} spots left',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: widget.eventData.get('event_details'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      )),
                ]),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.blue.withOpacity(0.9),
                        ),
                        child: const Center(
                          child: Text(
                            'Invite Friends',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => CheckOutScreen(eventData: widget.eventData),
                        );
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 0.1,
                                blurRadius: 20,
                                offset: const Offset(0, 1),
                              ),
                            ]),
                        child: const Center(
                          child: Text(
                            'Join',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tagCollectively,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      dataController.likeEvent(
                          eventLikedUserList, widget.eventData);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: eventLikedUserList.contains(
                                    FirebaseAuth.instance.currentUser!.uid)
                                ? const Color(0xFFD24698).withOpacity(0.05)
                                : Colors.transparent,
                          ),
                        ],
                      ),
                      child: Icon(
                        eventLikedUserList.contains(
                                FirebaseAuth.instance.currentUser!.uid)
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: eventLikedUserList.contains(
                                FirebaseAuth.instance.currentUser!.uid)
                            ? Colors.pinkAccent
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$likes',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Get.snackbar(
                          'Developing...', 'This feature is under development');
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      padding: const EdgeInsets.all(0.5),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$comments',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      Get.snackbar('Developing....',
                          'This feature is under development');
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      padding: const EdgeInsets.all(0.5),
                      child: const Icon(
                        Icons.share,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      dataController.savedEvent(
                          eventSaveUserList, widget.eventData);
                      if (eventSaveUserList
                          .contains(FirebaseAuth.instance.currentUser!.uid)) {
                        eventSaveUserList
                            .remove(FirebaseAuth.instance.currentUser!.uid);
                      } else {
                        eventSaveUserList
                            .add(FirebaseAuth.instance.currentUser!.uid);
                      }
                      setState(() {});
                    },
                    child: Icon(
                      eventSaveUserList
                              .contains(FirebaseAuth.instance.currentUser!.uid)
                          ? Icons.bookmark_added
                          : Icons.bookmark_border_outlined,
                      size: 24,
                      color: eventSaveUserList
                              .contains(FirebaseAuth.instance.currentUser!.uid)
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Subscribe',
                        style: TextStyle(
                          color: AppColors.activeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
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
}
