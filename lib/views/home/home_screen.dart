import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/controller.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    analytics.setCurrentScreen(screenName: 'HomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    DataController dataController = Get.find<DataController>();
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
                const CustomAppBar(),
                Text(
                  'What going on today?',
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                EventFeeds(),
                Obx(
                  () => dataController.isUserLoading.value
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : const EventIJoin(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
