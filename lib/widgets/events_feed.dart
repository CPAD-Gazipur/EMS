import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/controller.dart';
import '../views/view.dart';

class EventFeeds extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  EventFeeds({Key? key}) : super(key: key);

  createDynamicLink(String docID) async {
    String url = 'https://emsapp.page.link';

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://emsapp.page.link',
      link: Uri.parse('$url/$docID'),
      androidParameters: const AndroidParameters(
        packageName: 'com.alaminkarno.ems.ems',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.alaminkarno.ems.ems',
        minimumVersion: '0',
      ),
    );

    final ShortDynamicLink shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    Uri shortUri = shortLink.shortUrl;
    String shortUrl = shortUri.toString();
    await Share.share(shortUrl);
  }

  @override
  Widget build(BuildContext context) {
    DataController dataController = Get.find<DataController>();
    return Obx(
      () => dataController.isEventLoading.value
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dataController.allEvents.length,
              itemBuilder: (context, index) {
                return eventItem(dataController.allEvents[index]);
              },
            ),
    );
  }

  Widget eventItem(DocumentSnapshot event) {
    DataController dataController = Get.find<DataController>();

    DocumentSnapshot user = dataController.allUsers
        .firstWhere((element) => event.get('event_creator_uID') == element.id);

    String userName = '';
    String profileImage = '';
    String eventImage = '';

    try {
      userName = user.get('name');
    } catch (e) {
      userName = '';
    }

    try {
      profileImage = user.get('image');
      debugPrint('ProfileImage: $profileImage');
    } catch (e) {
      profileImage = '';
    }

    try {
      List media = event.get('event_media') as List;
      Map mediaMap =
          media.firstWhere((element) => element['isImage'] == true) as Map;
      eventImage = mediaMap['url'];
      debugPrint('EventImage: $eventImage');
    } catch (e) {
      eventImage = '';
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(
              () => ProfileScreen(
                userSnapshot: user,
                isOtherUser: true,
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue,
                child: CachedNetworkImage(
                  imageUrl: profileImage,
                  fit: BoxFit.contain,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                userName,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Get.height * 0.01,
        ),
        buildCard(
          image: eventImage,
          eventName: event.get('event_name'),
          eventData: event,
          user: user,
          onEventClick: () {
            Get.to(
              () => EventPageView(
                eventData: event,
                user: user,
              ),
            );

            analytics.logEvent(name: 'EventClicked', parameters: {
              'event_name':
                  event.get('event_name').toString().replaceAll(' ', '_'),
            });

            debugPrint(
                'Event Clicked: ${event.get('event_name').toString().replaceAll(' ', '_')}');
          },
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget buildCard({
    required String image,
    required String eventName,
    required Function onEventClick,
    required DocumentSnapshot eventData,
    required DocumentSnapshot user,
  }) {
    DataController dataController = Get.find<DataController>();

    List joinedUser = [];
    List eventSaveUserList = [];
    List eventLikedUserList = [];

    int likes = 0;
    int comments = 0;

    try {
      eventSaveUserList = eventData.get('saved_user_list');
    } catch (e) {
      eventSaveUserList = [];
    }

    try {
      joinedUser = eventData.get('event_joined');
    } catch (e) {
      joinedUser = [];
    }

    try {
      likes = eventData.get('likes').length;
      eventLikedUserList = eventData.get('likes');
    } catch (e) {
      likes = 0;
      eventLikedUserList = [];
    }

    try {
      comments = eventData.get('comments').length;
    } catch (e) {
      comments = 0;
    }

    return InkWell(
      onTap: () {
        onEventClick();
      },
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: const Color(0x000602d3).withOpacity(0.15),
              spreadRadius: 0.1,
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                onEventClick();
              },
              onDoubleTap: () {
                dataController.likeEvent(eventLikedUserList, eventData);
              },
              child: Hero(
                tag: image,
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.contain,
                  imageBuilder: (context, imageProvider) => Container(
                    width: double.infinity,
                    height: Get.width * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(
                    width: double.infinity,
                    height: Get.width * 0.5,
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
                    width: double.infinity,
                    height: Get.width * 0.5,
                    child: Image.asset(
                      'assets/images/placeholder-image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFADD8E6),
                      ),
                    ),
                    child: Text(
                      eventData.get('event_date').toString().split(',')[0],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  Text(
                    eventName,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      dataController.savedEvent(eventSaveUserList, eventData);
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
                          minRadius: 13,
                          backgroundImage: NetworkImage(image),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Get.height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () {
                    dataController.likeEvent(eventLikedUserList, eventData);
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
                      eventLikedUserList
                              .contains(FirebaseAuth.instance.currentUser!.uid)
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color: eventLikedUserList
                              .contains(FirebaseAuth.instance.currentUser!.uid)
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
                        'Developing....', 'This feature is under development');
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
                    createDynamicLink('event/${eventData.id}/${user.id}');
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
              ],
            )
          ],
        ),
      ),
    );
  }
}
