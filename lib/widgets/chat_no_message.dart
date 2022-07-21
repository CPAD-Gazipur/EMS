import 'package:flutter/material.dart';

class ChatNoMessage extends StatelessWidget {
  final Function() onSendMessage;
  const ChatNoMessage({
    Key? key,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> greetingImageList = [
      'assets/gif/hello.gif',
      'assets/gif/hello1.gif',
      'assets/gif/hello2.gif',
      'assets/gif/hello3.gif',
      'assets/gif/hello4.gif',
      'assets/gif/hello5.gif',
    ];

    greetingImageList.shuffle();

    String greetingImage = greetingImageList[0];

    return Center(
      child: InkWell(
        onTap: onSendMessage,
        child: Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No message send yet...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Send a message or tap to the greeting!',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                greetingImage,
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
