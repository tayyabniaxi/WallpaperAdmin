
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
import 'package:new_wall_paper_app/widget/sqlite-helper.dart';
import 'dart:convert';

import 'read_email_message_event.dart';
import 'read_email_message_state.dart';
import 'package:new_wall_paper_app/audio-to-text/model/readEmail_modelClass.dart';

class GmailBloc extends Bloc<GmailEvent, GmailState> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/gmail.readonly',
    ],
  );

  GmailBloc() : super(GmailInitial()) {
    on<SignInEvent>(_onSignIn);
    on<FetchFoldersEvent>(_onFetchFolders);
    on<FetchMessagesEvent>(_onFetchMessages);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<GmailState> emit) async {
    emit(GmailLoading());

    try {
      final account = await googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        emit(GmailSignedIn([]));
        await _fetchFolders(auth.accessToken!, emit);
      } else {
        emit(GmailFoldersError('Sign-in failed.'));
      }
    } catch (error) {
      emit(GmailFoldersError('Error signing in: $error'));
    }
  }

  Future<void> _onFetchFolders(
      FetchFoldersEvent event, Emitter<GmailState> emit) async {
    emit(GmailLoading());

    try {
      final account = await googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        await _fetchFolders(auth.accessToken!, emit);
      } else {
        emit(GmailFoldersError('User not signed in'));
      }
    } catch (error) {
      emit(GmailFoldersError('Error fetching folders: $error'));
    }
  }

  Future<void> _fetchFolders(
      String accessToken, Emitter<GmailState> emit) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/gmail/v1/users/me/labels'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<GmailMessage> folders = (data['labels'] as List)
          .map((folder) => GmailMessage.fromJson(folder))
          .toList();
      emit(GmailSignedIn(folders));
    } else {
      emit(GmailFoldersError('Failed to load labels: ${response.body}'));
    }
  }

  Future<void> _onFetchMessages(
      FetchMessagesEvent event, Emitter<GmailState> emit) async {
    emit(GmailLoading());

    try {
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/gmail/v1/users/me/messages?labelIds=${event.folderId}&maxResults=10'),
        headers: {'Authorization': 'Bearer ${event.accessToken}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messageList = data['messages'] as List;

        List<GmailMessage> messages = [];
        for (var message in messageList) {
          final messageDetails = await _fetchMessageDetails(
            event.accessToken,
            message['id'],
          );
          messages.add(messageDetails);
        }

        emit(GmailMessagesLoaded(messages));
      } else {
        emit(GmailMessagesError('Failed to load messages: ${response.body}'));
      }
    } catch (error) {
      emit(GmailMessagesError('Error fetching messages: $error'));
    }
  }
/*
  Future<GmailMessage> _fetchMessageDetails(
      String accessToken, String messageId) async {
    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId?format=full'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final headers = data['payload']['headers'] as List<dynamic>;
      final subjectHeader = headers.firstWhere(
        (header) => header['name'] == 'Subject',
        orElse: () => {'value': 'No Subject'},
      );

      String body = 'No Body Content';
      if (data['payload']['parts'] != null) {
        final parts = data['payload']['parts'] as List<dynamic>;
        final partWithBody = parts.firstWhere(
          (part) =>
              part['mimeType'] == 'text/plain' ||
              part['mimeType'] == 'text/html',
          orElse: () => null,
        );

        if (partWithBody != null && partWithBody['body'] != null) {
          final bodyData = partWithBody['body']['data'];
          if (bodyData != null) {
            body = utf8.decode(base64Url.decode(bodyData));
          }
        }
      } else if (data['payload']['body'] != null &&
          data['payload']['body']['data'] != null) {
        final bodyData = data['payload']['body']['data'];
        body = utf8.decode(base64Url.decode(bodyData));
      }

      return GmailMessage(
        id: data['id'],
        subject: subjectHeader['value'] ?? 'No Subject',
        body: body,
      );
    } else {
      throw Exception('Failed to fetch message details: ${response.body}');
    }
  }
*/
Future<GmailMessage> _fetchMessageDetails(
    String accessToken, String messageId) async {
  final response = await http.get(
    Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId?format=full'),
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Extract headers
    final headers = data['payload']['headers'] as List<dynamic>;
    final subjectHeader = headers.firstWhere(
      (header) => header['name'] == 'Subject',
      orElse: () => {'value': 'No Subject'},
    );

    // Extract email body
    String body = 'No Body Content';
    if (data['payload']['parts'] != null) {
      final parts = data['payload']['parts'] as List<dynamic>;
      final partWithBody = parts.firstWhere(
        (part) =>
            part['mimeType'] == 'text/plain' ||
            part['mimeType'] == 'text/html',
        orElse: () => null,
      );

      if (partWithBody != null && partWithBody['body'] != null) {
        final bodyData = partWithBody['body']['data'];
        if (bodyData != null) {
          body = utf8.decode(base64Url.decode(bodyData));
        }
      }
    } else if (data['payload']['body'] != null &&
        data['payload']['body']['data'] != null) {
      final bodyData = data['payload']['body']['data'];
      body = utf8.decode(base64Url.decode(bodyData));
    }

    // Save email content to the database
    final dbHelper = DatabaseHelper();
    final document = Document(
      name: subjectHeader['value'] ?? 'No Subject', // Use the subject as the document name
      pdfContent: body, // Store the email body
      description: DateTime.now().toIso8601String(), // Save timestamp
      contentType: "Email", // Mark as email content
    );
    await dbHelper.insertDocument(document);

    return GmailMessage(
      id: data['id'],
      subject: subjectHeader['value'] ?? 'No Subject',
      body: body,
    );
  } else {
    throw Exception('Failed to fetch message details: ${response.body}');
  }
}

  Future<void> signOut() async {
    await googleSignIn.signOut();
    emit(GmailInitial());
  }
}
