// gmail_state.dart
import 'package:equatable/equatable.dart';
import 'package:new_wall_paper_app/audio-to-text/model/readEmail_modelClass.dart';
// import 'package:new_wall_paper_app/audio-to-text/model/readEmail_modelClass.dart';

abstract class GmailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GmailInitial extends GmailState {}

class GmailLoading extends GmailState {}

class GmailSignedIn extends GmailState {
  final List<GmailMessage > folders;

  GmailSignedIn(this.folders);

  @override
  List<Object?> get props => [folders];
}

class GmailFoldersError extends GmailState {
  final String message;

  GmailFoldersError(this.message);

  @override
  List<Object?> get props => [message];
}

class GmailMessagesLoaded extends GmailState {
  final List<GmailMessage> messages;

  GmailMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class GmailMessagesError extends GmailState {
  final String message;

  GmailMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}
