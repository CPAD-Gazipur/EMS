import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/config/app_colors.dart';
import 'package:ems/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const HeaderTitle(title: 'Notifications'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('MyNotifications')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final List<DocumentSnapshot> data = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    String name, title, image;
                    bool isClicked;
                    DateTime date;

                    try {
                      name = data[index].get('senderName');
                    } catch (e) {
                      name = '';
                    }
                    try {
                      title = data[index].get('message');
                    } catch (e) {
                      title = '';
                    }
                    try {
                      date = data[index].get('time').toDate();
                    } catch (e) {
                      date = DateTime.now();
                    }
                    try {
                      image = data[index].get('senderImage');
                    } catch (e) {
                      image = '';
                    }
                    try {
                      isClicked = data[index].get('isClicked');
                    } catch (e) {
                      isClicked = false;
                    }

                    return NotificationDesign(
                      name: name,
                      title: title,
                      subTitle: timeago.format(date),
                      image: image,
                      isClicked: isClicked,
                      docID: data[index].id,
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class NotificationDesign extends StatelessWidget {
  final String name, title, subTitle, image, docID;
  final bool isClicked;
  const NotificationDesign({
    Key? key,
    required this.docID,
    required this.name,
    required this.title,
    required this.subTitle,
    required this.image,
    required this.isClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isClicked) {
          FirebaseFirestore.instance
              .collection('notifications')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('MyNotifications')
              .doc(docID)
              .update({
            'isClicked': true,
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
        ),
        color:
            isClicked ? Colors.white : const Color(0xFFEEEEEE).withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
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
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$name ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 73,
              ),
              child: Text(
                subTitle,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.genderTextColor,
                ),
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
            )
          ],
        ),
      ),
    );
  }
}
