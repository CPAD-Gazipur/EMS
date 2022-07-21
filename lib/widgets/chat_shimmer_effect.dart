import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmerEffect extends StatelessWidget {
  const ChatShimmerEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                direction: ShimmerDirection.ltr,
                child: Container(
                  margin: const EdgeInsets.only(
                    right: 10,
                    left: 150,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.zero,
                      topLeft: Radius.circular(18),
                    ),
                    color: Colors.grey.withOpacity(.5),
                  ),
                  width: double.infinity,
                  height: 50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                direction: ShimmerDirection.ltr,
                child: Container(
                  margin: const EdgeInsets.only(
                    right: 150,
                    left: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      topLeft: Radius.zero,
                    ),
                    color: Colors.grey.withOpacity(.5),
                  ),
                  width: double.infinity,
                  height: 50,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
