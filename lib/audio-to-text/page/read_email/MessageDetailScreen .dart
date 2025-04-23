// message_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';

class MessageDetailScreen extends StatelessWidget {
  final String subject;
  final String body;

  const MessageDetailScreen(
      {Key? key, required this.subject, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteAndTextPage(
                    text: subject + body,
                    isText: false,
                  ),
                ),
              );
            },
            child: const Text("Next"),
          )
        ],
      ),
      appBar: AppBar(title: Text('Message Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
