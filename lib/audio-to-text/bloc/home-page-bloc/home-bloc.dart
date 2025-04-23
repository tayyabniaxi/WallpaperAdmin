// // ignore_for_file: prefer_final_fields

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-event.dart';
// import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-state.dart';
// import 'package:new_wall_paper_app/audio-to-text/model/home_icon-mode.dart';
// // import 'package:new_wall_paper_app/audio-to-text/model/home_icon-model.dart';
// import 'package:new_wall_paper_app/utils/app-icon.dart';
// import 'package:new_wall_paper_app/utils/app-text.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class HomePageBloc extends Bloc<HomePageEvent, HomePageSate> {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   ////////////////// text to speech variable //////////////

//   late stt.SpeechToText _speech;
//   String _currentTranscription = '';

//   String _selectedLanguage = 'en-US';

//   String get selectedLanguage => _selectedLanguage;

//   String get currentText => _currentTranscription;

//   HomePageBloc() : super(ItemInitial()) {
//     _speech = stt.SpeechToText();

//     on<LoadItemsEvent>((event, emit) async {
//       emit(ItemLoading());
//       try {
//         final List<Item> items = [
//           Item(text: AppText.file, imageUrl: AppImage.file),
//           Item(text: AppText.gdrive, imageUrl: AppImage.gdive),
//           Item(text: AppText.pic, imageUrl: AppImage.pic),
//           Item(text: AppText.email, imageUrl: AppImage.emial),
//           Item(text: AppText.scan, imageUrl: AppImage.scan),
//           Item(text: AppText.text, imageUrl: AppImage.text),
//           Item(text: AppText.link, imageUrl: AppImage.attach),
//           Item(text: AppText.more, imageUrl: AppImage.plus),
//         ];
//         emit(ItemLoaded(items));
//       } catch (e) {
//         emit(ItemError(AppText.failedToLoadItem,"No Data Exit"));
//       }
//     });

//   on<SliderValueChange>((event, emit) {
//   if (state is ItemLoaded) {
//     final currentState = state as ItemLoaded;

//     // Seek to the new position
//     _audioPlayer.seek(Duration(seconds: event.value.toInt()));

//     // Emit the new state with updated position
//     emit(ItemLoaded(
//       currentState.items,
//       sliderValue: event.value,
//       audioPosition: Duration(seconds: event.value.toInt()),
//       audioSpeed: currentState.audioSpeed,
//       isPlaying: currentState.isPlaying,
//     ));
//   }
// });

//  // for play voice
//     on<PlayAudioEvent>((event, emit) async {
//       if (state is ItemLoaded) {
//         _audioPlayer.play();
//         final currentState = state as ItemLoaded;
//         emit(ItemLoaded(
//           currentState.items,
//           sliderValue: currentState.sliderValue,
//           audioPosition: currentState.audioPosition,
//           audioSpeed: currentState.audioSpeed,
//           isPlaying: true,
//         ));
//       }
//     });
//   // for pause voice
//     on<PauseAudioEvent>((event, emit) {
//       if (state is ItemLoaded) {
//         _audioPlayer.pause();
//         final currentState = state as ItemLoaded;
//         emit(ItemLoaded(
//           currentState.items,
//           sliderValue: currentState.sliderValue,
//           audioPosition: currentState.audioPosition,
//           audioSpeed: currentState.audioSpeed,
//           isPlaying: false,
//         ));
//       }
//     });

//  // seek bar
//     on<SeekAudioEvent>((event, emit) {
//       if (state is ItemLoaded) {
//         _audioPlayer.seek(event.position);
//         final currentState = state as ItemLoaded;
//         emit(ItemLoaded(
//           currentState.items,
//           sliderValue: currentState.sliderValue,
//           audioPosition: event.position,
//           audioSpeed: currentState.audioSpeed,
//           isPlaying: currentState.isPlaying,
//         ));
//       }
//     });

// on<ChangeSpeedEvent>((event, emit) {
//   if (state is ItemLoaded) {
//     // Set the speed of the audio player.
//     _audioPlayer.setSpeed(event.speed);

//     // Get the current state and emit a new state with the updated speed.
//     final currentState = state as ItemLoaded;
//     emit(ItemLoaded(
//       currentState.items,
//       sliderValue: currentState.sliderValue,
//       audioPosition: currentState.audioPosition,
//       audioSpeed: event.speed,
//       isPlaying: currentState.isPlaying,
//     ));
//   }
// });

// // show duration of audio
//     on<AudioDurationLoaded>((event, emit) {
//       if (state is ItemLoaded) {
//         final currentState = state as ItemLoaded;
//         emit(ItemLoaded(
//           currentState.items,
//           sliderValue: currentState.sliderValue,
//           audioPosition: currentState.audioPosition,
//           audioDuration: event.duration,
//           audioSpeed: currentState.audioSpeed,
//           isPlaying: currentState.isPlaying,
//         ));
//       }
//     });
//     // on<ChangeLanguage>(_onChangeLanguage);
//   }

//   //////////////////////////////// text to voice ////////////////////////////
//   final FlutterTts flutterTts = FlutterTts();

// // change text to voive
//   Future<void> speaks(String text, String languageCode) async {
//     if (text.isNotEmpty) {
//       await flutterTts.setSpeechRate(0.4);
//       await flutterTts.setPitch(0.92);
//       await flutterTts.setLanguage(languageCode);
//       await flutterTts.speak(text);
//     }
//   }

//   Future<void> setAudioSource(String url) async {
//     await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
//     final duration = await _audioPlayer.duration ?? Duration.zero;
//     add(AudioDurationLoaded(duration));
//   }

//   void dispose() {
//     _audioPlayer.dispose();
//     super.close();
//   }
// }

// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-state.dart';
import 'package:new_wall_paper_app/audio-to-text/model/home_icon-mode.dart';
import 'package:new_wall_paper_app/utils/app-color.dart';
import 'package:new_wall_paper_app/utils/app-icon.dart';
import 'package:new_wall_paper_app/utils/app-text.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePageBloc extends Bloc<HomePageEvent, HomePageSate> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  ////////////////// text to speech variable //////////////
  late stt.SpeechToText _speech;
  String _currentTranscription = '';
  String _selectedLanguage = 'en-US';

  String get selectedLanguage => _selectedLanguage;
  String get currentText => _currentTranscription;

  HomePageBloc() : super(ItemInitial()) {
    _speech = stt.SpeechToText();

    on<LoadItemsEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        final List<String> texts = [
          "Business",
          "Self-Improvement",
          "Non-Fiction",
          "Non-Fiction",
          "Non-Fiction",
        ];
       
        final List<Item> items = [
          Item(text: AppText.scan, imageUrl: AppImage.scan,gradientColors: [ContainerGradientColor.bluelight, ContainerGradientColor.bluedark]),
          Item(text: AppText.text, imageUrl: AppImage.text,gradientColors: [ContainerGradientColor.orangelight, ContainerGradientColor.orangedark]),
          Item(text: AppText.link, imageUrl: AppImage.attach,gradientColors: [ContainerGradientColor.purplelight, ContainerGradientColor.purpledark]),
          Item(text: AppText.more, imageUrl: AppImage.plus,gradientColors: [ContainerGradientColor.pinklight, ContainerGradientColor.pinkdark]),
          Item(text: AppText.file, imageUrl: AppImage.file,gradientColors: [ContainerGradientColor.amberlight, ContainerGradientColor.amberdark]),
          Item(text: AppText.gdrive, imageUrl: AppImage.gdive,gradientColors: [ContainerGradientColor.gDriverlight, ContainerGradientColor.gDriverdark]),
          Item(text: AppText.email, imageUrl: AppImage.emial,gradientColors: [ContainerGradientColor.maillight, ContainerGradientColor.maildark]),
          Item(text: AppText.pic, imageUrl: AppImage.pic,gradientColors: [ContainerGradientColor.redlight, ContainerGradientColor.reddark],),
        ];
        emit(ItemLoaded(items, texts: texts));
      } catch (e) {
        emit(ItemError(
          AppText.failedToLoadItem,
        ));
      }
    });

    on<SliderValueChange>((event, emit) {
      if (state is ItemLoaded) {
        final currentState = state as ItemLoaded;

        // Seek to the new position
        _audioPlayer.seek(Duration(seconds: event.value.toInt()));

        // Emit the new state with updated position
        emit(ItemLoaded(
          currentState.items,
          sliderValue: event.value,
          audioPosition: Duration(seconds: event.value.toInt()),
          audioSpeed: currentState.audioSpeed,
          isPlaying: currentState.isPlaying,
        ));
      }
    });

    // for play voice
    on<PlayAudioEvent>((event, emit) async {
      if (state is ItemLoaded) {
        _audioPlayer.play();
        final currentState = state as ItemLoaded;
        emit(ItemLoaded(
          currentState.items,
          sliderValue: currentState.sliderValue,
          audioPosition: currentState.audioPosition,
          audioSpeed: currentState.audioSpeed,
          isPlaying: true,
        ));
      }
    });

    // for pause voice
    on<PauseAudioEvent>((event, emit) {
      if (state is ItemLoaded) {
        _audioPlayer.pause();
        final currentState = state as ItemLoaded;
        emit(ItemLoaded(
          currentState.items,
          sliderValue: currentState.sliderValue,
          audioPosition: currentState.audioPosition,
          audioSpeed: currentState.audioSpeed,
          isPlaying: false,
        ));
      }
    });

    // seek bar
    on<SeekAudioEvent>((event, emit) {
      if (state is ItemLoaded) {
        _audioPlayer.seek(event.position);
        final currentState = state as ItemLoaded;
        emit(ItemLoaded(
          currentState.items,
          sliderValue: currentState.sliderValue,
          audioPosition: event.position,
          audioSpeed: currentState.audioSpeed,
          isPlaying: currentState.isPlaying,
        ));
      }
    });

    on<ChangeSpeedEvent>((event, emit) {
      if (state is ItemLoaded) {
        // Set the speed of the audio player.
        _audioPlayer.setSpeed(event.speed);

        // Get the current state and emit a new state with the updated speed.
        final currentState = state as ItemLoaded;
        emit(ItemLoaded(
          currentState.items,
          sliderValue: currentState.sliderValue,
          audioPosition: currentState.audioPosition,
          audioSpeed: event.speed,
          isPlaying: currentState.isPlaying,
        ));
      }
    });

    // show duration of audio
    on<AudioDurationLoaded>((event, emit) {
      if (state is ItemLoaded) {
        final currentState = state as ItemLoaded;
        emit(ItemLoaded(
          currentState.items,
          sliderValue: currentState.sliderValue,
          audioPosition: currentState.audioPosition,
          audioDuration: event.duration,
          audioSpeed: currentState.audioSpeed,
          isPlaying: currentState.isPlaying,
        ));
      }
    });

    // on<ChangeLanguage>(_onChangeLanguage);
  }

  //////////////////////////////// text to voice ////////////////////////////
  final FlutterTts flutterTts = FlutterTts();

  // change text to voice
  Future<void> speaks(String text, String languageCode) async {
    if (text.isNotEmpty) {
      await flutterTts.setSpeechRate(0.4);
      await flutterTts.setPitch(0.92);
      await flutterTts.setLanguage(languageCode);
      await flutterTts.speak(text);
    }
  }

  Future<void> setAudioSource(String url) async {
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
    final duration = await _audioPlayer.duration ?? Duration.zero;
    add(AudioDurationLoaded(duration));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
