// import 'package:new_wall_paper_app/audio-to-text/model/home_icon-model.dart';

import 'package:new_wall_paper_app/audio-to-text/model/home_icon-mode.dart';

abstract class HomePageSate {}

class ItemInitial extends HomePageSate {}

class ItemLoading extends HomePageSate {}

class ItemLoaded extends HomePageSate {
  final List<Item> items;
  final double sliderValue;
  final Duration audioDuration;
  final Duration audioPosition;
  final double audioSpeed;
  final bool isPlaying;
  final String selectedCountry;
  final List<String>? texts;

  ItemLoaded(this.items,
      {this.sliderValue = 0.0,
      this.audioDuration = Duration.zero,
      this.audioPosition = Duration.zero,
      this.audioSpeed = 1.0,
      this.isPlaying = false,
      this.selectedCountry = 'en-US',
      this.texts});
}

class ItemError extends HomePageSate {
  final String message;
  ItemError(this.message);
}

class FanTranscriptionUpdated extends HomePageSate {
  final String transcription;
  final int SpeechTextState;
  final bool isValid;
  FanTranscriptionUpdated(
      this.transcription, this.SpeechTextState, this.isValid);
}

class SpeechTextError extends HomePageSate {
  final String error;
  SpeechTextError(this.error);
}
