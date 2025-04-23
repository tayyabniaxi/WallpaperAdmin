// message_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/read_email/MessageDetailScreen%20.dart';


class MessageScreen extends StatelessWidget {
  final String folderId;
  final String accessToken;

  const MessageScreen({Key? key, required this.folderId, required this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<GmailBloc>().add(FetchMessagesEvent(folderId, accessToken));

    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: BlocBuilder<GmailBloc, GmailState>(
        builder: (context, state) {
          if (state is GmailLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GmailMessagesError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is GmailMessagesLoaded) {
            if (state.messages.isEmpty) {
              return Center(child: Text('No messages found.'));
            }
            return ListView.builder(
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return ListTile(
                  title: Text(message.subject),
                  subtitle: Text('ID: ${message.id}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailScreen(
                          subject: message.subject,
                          body: message.body,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(child: Text('No messages found.'));
        },
      ),
    );
  }
}
