import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/config.dart';
import '../../controller/controller.dart';
import '../../widgets/widgets.dart';
import '../view.dart';

class CommunityScreen extends StatelessWidget {
  CommunityScreen({Key? key}) : super(key: key);

  final TextEditingController searchController = TextEditingController();
  final DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              iconWithTitle(
                text: 'Community',
                onBackIconPress: () {},
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      dataController.filterEvents
                          .assignAll(dataController.allEvents);
                    } else {
                      List<DocumentSnapshot> data =
                          dataController.allEvents.value.where((element) {
                        List tags = [];
                        bool isTagContain = false;
                        try {
                          tags = element.get('event_tags');
                          for (int i = 0; i < tags.length; i++) {
                            tags[i] = tags[i].toString().toLowerCase();
                            if (tags[i].toString().contains(
                                searchController.text.toLowerCase())) {
                              isTagContain = true;
                            }
                          }
                        } catch (e) {
                          tags = [];
                        }
                        return (element
                                .get('event_location')
                                .toString()
                                .toLowerCase()
                                .contains(
                                    searchController.text.toLowerCase()) ||
                            isTagContain ||
                            element
                                .get('event_name')
                                .toString()
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()));
                      }).toList();

                      dataController.filterEvents.assignAll(data);
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    hintText: 'Dhaka, Bangladesh',
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 30,
                    childAspectRatio: 0.53,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dataController.filterEvents.length,
                  itemBuilder: (context, index) {
                    String userName = '';
                    String userImage = '';
                    String eventCreatorUserID = '';
                    String eventName = '';
                    String eventLocation = '';
                    String eventImage = '';
                    String eventTags = '';

                    eventCreatorUserID = dataController
                        .filterEvents.value[index]
                        .get('event_creator_uID');

                    DocumentSnapshot userDoc = dataController.allUsers
                        .firstWhere((user) => user.id == eventCreatorUserID);

                    try {
                      userName = userDoc.get('name');
                    } catch (e) {
                      userName = '';
                    }

                    try {
                      userImage = userDoc.get('image');
                    } catch (e) {
                      userImage = '';
                    }

                    try {
                      eventName = dataController.filterEvents.value[index]
                          .get('event_name');
                    } catch (e) {
                      eventName = '';
                    }

                    try {
                      eventLocation = dataController.filterEvents.value[index]
                          .get('event_location');
                    } catch (e) {
                      eventLocation = '';
                    }

                    try {
                      List media = dataController.filterEvents.value[index]
                          .get('event_media') as List;
                      eventImage = media.firstWhere(
                          (image) => image['isImage'] == true)['url'];
                    } catch (e) {
                      eventImage = '';
                    }

                    List tags = [];

                    try {
                      tags = dataController.filterEvents.value[index]
                          .get('event_tags') as List;
                    } catch (e) {
                      tags = [];
                    }

                    if (tags.isEmpty) {
                      eventTags = dataController.filterEvents.value[index]
                          .get('event_details');
                    } else {
                      for (String tag in tags) {
                        eventTags += '#${tag.trim().replaceAll(' ', '_')} ';
                      }
                    }

                    return InkWell(
                      onTap: () {
                        Get.to(
                          () => EventPageView(
                            eventData: dataController.filterEvents[index],
                            user: userDoc,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => ProfileScreen(
                                  userSnapshot: userDoc,
                                  isOtherUser: true,
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.blue,
                                  child: CachedNetworkImage(
                                    imageUrl: userImage,
                                    fit: BoxFit.contain,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.black54,
                                size: 14,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  eventLocation,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.activeColor,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: Hero(
                              tag: eventImage,
                              child: CachedNetworkImage(
                                imageUrl: eventImage,
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                placeholder: (context, url) => const SizedBox(
                                  width: double.infinity,
                                  height: 100,
                                  child: Center(
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const SizedBox(
                                        width: double.infinity,
                                        height: 100,
                                        child:
                                            Center(child: Icon(Icons.error))),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              eventName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              eventTags,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
