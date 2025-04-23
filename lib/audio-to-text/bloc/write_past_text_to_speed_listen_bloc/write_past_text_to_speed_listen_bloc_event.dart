// text_to_speech_event.dart
// ignore_for_file: camel_case_types, override_on_non_overriding_member, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/model/country_model.dart';

abstract class TextToSpeechEvent {}

class TextChanged extends TextToSpeechEvent {
  final String texts;

  TextChanged(this.texts);
}

class Speak extends TextToSpeechEvent {
  final Duration startFrom;
  // final BuildContext context;

  Speak({this.startFrom = Duration.zero});
}

class Stop extends TextToSpeechEvent {}

class Pause extends TextToSpeechEvent {}

class TogglePlayPause extends TextToSpeechEvent {}

class ChangeSpeechRate extends TextToSpeechEvent {
  final double rate;

  ChangeSpeechRate(this.rate);
}

class SeekBy extends TextToSpeechEvent {
  final Duration offset;

  SeekBy(this.offset);
}

class SeekTo extends TextToSpeechEvent {
  final Duration position;

  SeekTo(
    this.position,
  );
}

class Reset extends TextToSpeechEvent {}

class Seek extends TextToSpeechEvent {
  final Duration position;

  Seek({required this.position});
}

class SelectCountry extends TextToSpeechEvent {
  final String country;

  SelectCountry(this.country);

  @override
  List<Object> get props => [country];
}

class SelectCountryPic extends TextToSpeechEvent {
  final String countrypic;

  SelectCountryPic(this.countrypic);

  @override
  List<Object> get props => [countrypic];
}

class SelectLanguage extends TextToSpeechEvent {
  final Language language;
  // final Country country;

  SelectLanguage(this.language);
}

class WordSelected extends TextToSpeechEvent {
  final int wordIndex;

  WordSelected(this.wordIndex);
}

class ToggleLanguageOn extends TextToSpeechEvent {
  String selectLang;
  ToggleLanguageOn(this.selectLang);
}

class ToggleSubCategory extends TextToSpeechEvent {
  final String selectCountriesCode;
  final String CountryFlag;
  ToggleSubCategory(this.selectCountriesCode, this.CountryFlag);
}

class PitchValueChange extends TextToSpeechEvent {
  final double value;

  PitchValueChange(
    this.value,
  );
}

class setVolumeValueChange extends TextToSpeechEvent {
  final double volumeValue;
  setVolumeValueChange(this.volumeValue);
}

class IncreaseTextSize extends TextToSpeechEvent {}

class DecreaseTextSize extends TextToSpeechEvent {}

class InitializeWordKeys extends TextToSpeechEvent {
  final String text;

  InitializeWordKeys(this.text);
}

class UserStartedScrolling extends TextToSpeechEvent {}

class UserStoppedScrolling extends TextToSpeechEvent {}

class AddOpenedPdf extends TextToSpeechEvent {
  final String pdfPath;

  AddOpenedPdf(this.pdfPath);
}

class SelectFont extends TextToSpeechEvent {
  final String fontName;

  SelectFont(this.fontName);

  @override
  List<Object> get props => [fontName];
}

class PlayAudio extends TextToSpeechEvent {}

// Event to change the entire theme
class ChangeTheme extends TextToSpeechEvent {
  final ThemeData themeData;

  ChangeTheme(this.themeData);
}

// Event to change the background color
class ChangeBackgroundColor extends TextToSpeechEvent {
  final Color backgroundColor;

  ChangeBackgroundColor(this.backgroundColor);
}

// to change text color
class ChangeColorToggle extends TextToSpeechEvent {}

// to send request permission
class RequestStoragePermission extends TextToSpeechEvent {}

// to download extract audio
class DownloadAudio extends TextToSpeechEvent {
  final String text;

  DownloadAudio(this.text);
}

// to summerize text
class SummarizeText extends TextToSpeechEvent {
  final String text;

  SummarizeText(this.text);
}

// to hide player
class HideShowPlayerToggle extends TextToSpeechEvent {}

class ScreenTouched extends TextToSpeechEvent {}

class UpdateText extends TextToSpeechEvent {
  final String editText;
  UpdateText(this.editText);
}
