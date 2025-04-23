// gmail_event.dart
import 'package:equatable/equatable.dart';

abstract class GmailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInEvent extends GmailEvent {}

class FetchFoldersEvent extends GmailEvent {}

class FetchMessagesEvent extends GmailEvent {
  final String folderId;
  final String accessToken;

  FetchMessagesEvent(this.folderId, this.accessToken);
}
