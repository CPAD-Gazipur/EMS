import 'package:ems/views/home_bottom_bar/widgets/custom_app_bar.dart';
import 'package:ems/views/home_bottom_bar/widgets/event_i_join.dart';
import 'package:ems/views/home_bottom_bar/widgets/events_feed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.03),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(),
                Text('What going on today?',
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
                SizedBox(height: Get.height * 0.02,),
                EventFeeds(),
                EventIJoin(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
