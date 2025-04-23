
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/read_email/MessageScreen.dart';

// class EmailFolderScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Gmail Folders'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await context.read<GmailBloc>().signOut(); 
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<GmailBloc, GmailState>(
//         builder: (context, state) {
//           if (state is GmailLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is GmailFoldersError) {
//             return Center(child: Text(state.message));
//           } else if (state is GmailSignedIn) {
//             return ListView.builder(
//               itemCount: state.folders.length,
//               itemBuilder: (context, index) {
//                 final folder = state.folders[index];
//                 return ListTile(
//                   title: Text(folder.name),
//                   subtitle: Text(folder.id),
//                   onTap: () {
//                     final accessToken = _getAccessToken(); 
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MessageScreen(
//                           folderId: folder.id,
//                           accessToken: accessToken,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//           return Center(child: Text('Please sign in to view folders.'));
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.read<GmailBloc>().add(SignInEvent());
//         },
//         child: Icon(Icons.login),
//       ),
//     );
//   }

//   String _getAccessToken() {
   
//     return ''; 
//   }
// }

class EmailFolderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gmail Folders'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await context.read<GmailBloc>().signOut();
            },
          ),
        ],
      ),
      body: BlocBuilder<GmailBloc, GmailState>(
        builder: (context, state) {
          if (state is GmailLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GmailFoldersError) {
            return Center(child: Text(state.message));
          } else if (state is GmailSignedIn) {
            return ListView.builder(
              itemCount: state.folders.length,
              itemBuilder: (context, index) {
                final folder = state.folders[index];
                return ListTile(
                  title: Text(folder.subject),
                  subtitle: Text(folder.id),
                  onTap: () async {
                    final account = context.read<GmailBloc>().googleSignIn.currentUser;
                    if (account != null) {
                      final auth = await account.authentication;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(
                            folderId: folder.id,
                            accessToken: auth.accessToken!,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
          return Center(child: Text('Please sign in to view folders.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<GmailBloc>().add(SignInEvent());
        },
        child: Icon(Icons.login),
      ),
    );
  }
}
