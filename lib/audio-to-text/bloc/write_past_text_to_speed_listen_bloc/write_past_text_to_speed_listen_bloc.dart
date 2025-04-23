// ignore_for_file: prefer_const_declarations, non_constant_identifier_names, unused_element, prefer_final_fields

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_state.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
import 'package:new_wall_paper_app/widget/common-text.dart';
import 'package:new_wall_paper_app/widget/common_bottomsheet.dart';
import 'package:new_wall_paper_app/widget/language_selected_history.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TextToSpeechBloc extends Bloc<TextToSpeechEvent, TextToSpeechState> {
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _progressTimer;
  BuildContext? context;
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  String selectedCountry = '';
  String CountryFlat = '';
  String selectLang = '';
  String selectCountriesCode = '';
  static const int _maxChunkSize = 100;
  late Future<List<Document>> savedDocuments;
  final TextEditingController editTextController = TextEditingController();
  List<String> _textChunks = [];
  int _currentChunkIndex = 0;
  Timer? _timer;
  bool _isProcessingChunk = false;
  TextToSpeechBloc() : super(TextToSpeechState.initial()) {
    on<TextChanged>(_onTextChanged);
    on<Speak>(_onSpeak);
    on<Stop>(_onStop);
    on<Pause>(_onPause);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<ChangeColorToggle>(_onToggleChangeColor);
    on<ChangeSpeechRate>(_onChangeSpeechRate);
    on<SeekBy>(_onSeekBy);
    on<SeekTo>(_onSeekTo);
    on<Reset>(_onReset);
    on<SelectCountry>(_onCountrySelected);
    on<SelectCountryPic>(_onCountryPicSelected);
    on<SelectLanguage>(_onLanguageSelected);
    on<ToggleLanguageOn>(isSelectLanguageOnn);
    on<ToggleSubCategory>(ToggleSubCategries);
    on<WordSelected>(_onWordSelected);
    on<PitchValueChange>(_onSliderValueChanged);
    on<setVolumeValueChange>(_onSlidersetVolumeValueChange);
    on<IncreaseTextSize>(_onIncreaseTextSize);
    on<DecreaseTextSize>(_onDecreaseTextSize);
    on<InitializeWordKeys>(_onInitializeWordKeys);
    on<SelectFont>(_onFontSelected);
    on<ChangeTheme>(_onChangeThemeColor);
    on<ChangeBackgroundColor>(_onChangeBackgroundColor);

    on<RequestStoragePermission>(_onRequestStoragePermission);
    on<DownloadAudio>(_onDownloadAudio);
    on<SummarizeText>(_onSummarizeText);
    on<HideShowPlayerToggle>(_onHideShowPlayerToggle);
    on<UpdateText>(_onUpdateText);

    on<ScreenTouched>(_onTouchScreenEvent);
  }

  Future<void> _initializeTts() async {
    // await _flutterTts.setLanguage("${state.selectLang}-${state.countryCode}");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      if (_currentChunkIndex < _textChunks.length - 1) {
        _currentChunkIndex++;
        _speakCurrentChunk();
      } else {
        add(Stop());
      }
    });

    _flutterTts.setProgressHandler(
      (String text, int startOffset, int endOffset, String word) {
        if (!_isProcessingChunk) {
          _updateHighlightedWord(word, startOffset, endOffset);
        }
      },
    );

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      add(Stop());
    });
  }

  void _onUpdateText(UpdateText event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(text: event.editText));
  }

  // change theme  Color
  _onChangeThemeColor(ChangeTheme event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(themeData: event.themeData));
  }

  // change background  Color
  _onChangeBackgroundColor(
      ChangeBackgroundColor event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(
      themeData: state.themeData.copyWith(
        scaffoldBackgroundColor: event.backgroundColor,
      ),
    ));
  }

  void _updateHighlightedWord(String word, int startOffset, int endOffset) {
    if (state.isPlaying) {
      List<String> currentChunkWords =
          _textChunks[_currentChunkIndex].split(' ');
      List<String> allWords = state.text.split(' ');

      int localIndex = currentChunkWords.indexOf(word);

      if (localIndex != -1) {
        int globalIndex = _getGlobalWordIndex(localIndex);
        emit(state.copyWith(currentWordIndex: globalIndex, isLoading: false));
      }
    }
  }


  _onWordSelected(WordSelected event, Emitter emit) async {
    if (state.text.isEmpty) return;
    // var updateText= state.editText : state.text;
    final List words = state.text.split(' ');
    if (event.wordIndex < 0 || event.wordIndex >= words.length) return;

    await _flutterTts.stop();
    // _progressTimer?.cancel();

    Duration position = Duration.zero;
    for (int i = 0; i < event.wordIndex && i < state.wordTimings.length; i++) {
      position += state.wordTimings[i];
    }

    int totalWords = 0;

    int targetChunkIndex = 0;

    for (int i = 0; i < _textChunks.length; i++) {
      int chunkWordCount = _textChunks[i].split(' ').length;
      if (totalWords + chunkWordCount > event.wordIndex) {
        targetChunkIndex = i;
        break;
      }
      totalWords += chunkWordCount;
    }

    int wordIndexInChunk = event.wordIndex - totalWords;
    // await _speakCurrentChunk(startWordIndex: wordIndexInChunk);
    _currentChunkIndex = targetChunkIndex;
    add(SeekTo(position));
    emit(state.copyWith(
      currentWordIndex: event.wordIndex,
      currentPosition: position,
      isPlaying: true,
      isPaused: false,
    ));

    scrollToHighlightedWord(context!, event.wordIndex);
    await _speakCurrentChunk(startWordIndex: wordIndexInChunk);
    _startTimer(state.wordTimings, state.speechRate);
  }

  void isSelectLanguageOnn(
      ToggleLanguageOn event, Emitter<TextToSpeechState> emit) {
    selectLang = event.selectLang;
    state.languageCode = event.selectLang;
    emit(state.copyWith(
        isLanguageSelectOn: !state.isLanguageSelectOn,
        selectCountriesCode: selectLang,
        countryFlat: state.countryFlat));
  }

  void ToggleSubCategries(
      ToggleSubCategory event, Emitter<TextToSpeechState> emit) {
    selectCountriesCode = event.selectCountriesCode;
    CountryFlat = event.CountryFlag;
    state.countryCode = event.selectCountriesCode;
    emit(state.copyWith(
        ToggleSubCategory: !state.ToggleSubCategory,
        selectLang: selectCountriesCode,
        countryFlat: CountryFlat));
  }

// righ

  void _prepareTextChunks(String text) {
    _textChunks.clear();
    if (text.isEmpty) return;

    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    String currentChunk = '';
    for (final sentence in sentences) {
      if ((currentChunk + sentence).length <= _maxChunkSize) {
        currentChunk += '$sentence ';
      } else {
        _textChunks.add(currentChunk.trim());
        currentChunk = '$sentence ';
      }
    }
    if (currentChunk.isNotEmpty) {
      _textChunks.add(currentChunk.trim());
    }
  }

  void _onCountrySelected(
      SelectCountry event, Emitter<TextToSpeechState> emit) {
    String newSelectedCountry = event.country;

    emit(state.copyWith(selectedCountry: newSelectedCountry));

    final updatedHistory = List<String>.from(state.countryHistory);
    if (!updatedHistory.contains(newSelectedCountry)) {
      updatedHistory.add(newSelectedCountry);
      emit(state.copyWith(countryHistory: updatedHistory));
    }
  }

  void _onCountryPicSelected(
      SelectCountryPic event, Emitter<TextToSpeechState> emit) async {
    if (state.isPlaying) {
      await _flutterTts.stop();
    }
    String newSelectedCountry = event.countrypic;

    emit(state.copyWith(countryFlat: newSelectedCountry));
  }

  Future<void> _onLanguageSelected(
      SelectLanguage event, Emitter<TextToSpeechState> emit) async {
    if (state.isPlaying) {
      await _flutterTts.stop();
    }
    emit(state.copyWith(
      selectedLanguage: event.language,
      selectedCountry: '',
      countryFlat: "",
      isPlaying: false,
      currentPosition: Duration.zero,
    ));
  }


  Future<void> _speakCurrentChunk({int startWordIndex = 0}) async {
    if (_currentChunkIndex >= _textChunks.length) return;

    String chunk = _textChunks[_currentChunkIndex];
    List<String> words = chunk.split(' ');

    startWordIndex = startWordIndex.clamp(0, words.length - 1);

    String adjustedChunk = words.sublist(startWordIndex).join(' ');

    await _flutterTts.setLanguage("${state.selectLang}-${state.countryCode}");
    await _flutterTts.setPitch(state.setPitch);
    await _flutterTts.setSpeechRate(state.speechRate.clamp(0.5, 2.0));
    await _flutterTts.setVolume(state.setValume);

    int globalWordIndexStart = 0;
    for (int i = 0; i < _currentChunkIndex; i++) {
      globalWordIndexStart += _textChunks[i].split(' ').length;
    }

    await _flutterTts.speak(adjustedChunk);

    _flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      final int localWordIndex = _getWordIndexByOffset(startOffset, words);
      final int globalWordIndex =
          globalWordIndexStart + localWordIndex + startWordIndex;

      emit(state.copyWith(currentWordIndex: globalWordIndex));
      scrollToHighlightedWord(context!, globalWordIndex);
      
    });

    _flutterTts.setCompletionHandler(() async {
      if (_currentChunkIndex < _textChunks.length - 1) {
        _currentChunkIndex++;
        await Future.delayed(const Duration(milliseconds: 100));
        await _speakCurrentChunk();
      } else {
        add(Stop());
      }
    });
  }

  void _onInitializeWordKeys(
      InitializeWordKeys event, Emitter<TextToSpeechState> emit) {
    final List<GlobalKey> wordKeys =
        event.text.split(' ').map((_) => GlobalKey()).toList();
    emit(state.copyWith(wordKeys: wordKeys, text: event.text));
  }

  int _getWordIndexByOffset(int offset, List<String> words) {
    int cumulativeOffset = 0;
    for (int i = 0; i < words.length; i++) {
      cumulativeOffset += words[i].length + 1;
      if (cumulativeOffset > offset) return i;
    }
    return words.length - 1;
  }


  int _getGlobalWordIndex(int localIndex) {
    int globalIndex = 0;
    for (int i = 0; i < _currentChunkIndex; i++) {
      globalIndex += _textChunks[i].split(' ').length;
    }
    return globalIndex + localIndex;
  }

  void _onTextChanged(TextChanged event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(text: event.texts));
  }

  Future<void> _onSpeak(Speak event, Emitter<TextToSpeechState> emit) async {
    if (state.text.isEmpty) return;

    emit(state.copyWith(isLoading: true, isPaused: false));

    // .setLanguage("fr-NP");
    await _flutterTts.setPitch(state.setPitch);
    await _flutterTts.setSpeechRate(state.speechRate.clamp(0.5, 2.0));
    await _flutterTts.setVolume(state.setValume);

    List<String> words = state.text.split(' ');
    // _prepareTextChunks(state.text);
    _prepareTextChunks(state.editText.isNotEmpty ? state.editText : state.text);

    _currentChunkIndex = _calculateStartChunk(event.startFrom);
    Duration estimatedDuration = _estimateTotalDuration();

    List<Duration> wordTimings = words.map((word) {
      return Duration(
        milliseconds: ((word.length / 8) * (600 / state.speechRate)).toInt(),
      );
    }).toList();

    emit(state.copyWith(
      isPlaying: true,
      isLoading: false,
      originalAudioDuration: estimatedDuration,
      wordTimings: wordTimings,
    ));

    _speakCurrentChunk(startWordIndex: state.currentWordIndex);

    _startTimer(wordTimings, state.speechRate);
  }

  void _onFontSelected(SelectFont event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(selectedFont: event.fontName));
  }

  int _findWordIndexForTime(Duration elapsedTime, List<Duration> wordTimings) {
    Duration cumulativeDuration = Duration.zero;

    for (int i = 0; i < wordTimings.length; i++) {
      cumulativeDuration += wordTimings[i];
      if (elapsedTime < cumulativeDuration) {
        return i;
      }
    }

    return wordTimings.length - 1;
  }

  void _startTimer(List<Duration> wordTimings, double speechRate) {
    _progressTimer?.cancel();

    const int baseInterval = 50;
    int lastWordIndex = -1;
    Duration elapsedTime = state.currentPosition;

    _progressTimer =
        Timer.periodic(const Duration(milliseconds: baseInterval), (timer) {
      if (!state.isPlaying) {
        timer.cancel();
        return;
      }

      elapsedTime += const Duration(milliseconds: baseInterval);

      if (elapsedTime >= state.originalAudioDuration) {
        add(Stop());
        timer.cancel();
        return;
      }
      int currentWordIndex = _findWordIndexForTime(elapsedTime, wordTimings);

      if (currentWordIndex < lastWordIndex) {
        currentWordIndex = lastWordIndex;
      }

      // Emit state changes only if necessary
      if (currentWordIndex < lastWordIndex) {
        currentWordIndex = lastWordIndex;
        emit(state.copyWith(
          currentPosition: elapsedTime,
          currentWordIndex: currentWordIndex,
        ));
      } else {
        emit(state.copyWith(currentPosition: elapsedTime));
      }
    });
  }

  int _findWordIndexAtPosition(Duration position) {
    Duration cumulativeDuration = Duration.zero;
    for (int i = 0; i < state.wordTimings.length; i++) {
      cumulativeDuration += state.wordTimings[i];
      if (position < cumulativeDuration) {
        return i;
      }
    }
    return state.wordTimings.length - 1;
  }


  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (state.isPlaying) {
        final updatedPosition =
            state.currentPosition + const Duration(milliseconds: 200);

        if (updatedPosition >= state.originalAudioDuration) {
          emit(state.copyWith(currentPosition: state.originalAudioDuration));
          add(Stop());
        } else {
          emit(state.copyWith(currentPosition: updatedPosition));
        }
      }
    });
  }

// the get total voice
  Future<List<String>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices
          .where((voice) => voice
              .toString()
              .toLowerCase()
              .contains(state.selectedLanguage.code.toLowerCase()))
          .map((voice) => voice.toString())
          .toList();
    } catch (e) {
      print('Error getting voices: $e');
      return [];
    }
  }
// stop audio
  Future<void> _onStop(Stop event, Emitter<TextToSpeechState> emit) async {
    await _flutterTts.stop();
    emit(state.copyWith(
      isPlaying: false,
      currentPosition: Duration.zero,
    ));
    _progressTimer?.cancel();
  }

// pause button
  void _onPause(Pause event, Emitter<TextToSpeechState> emit) async {
    await _flutterTts.stop();
    emit(state.copyWith(isPlaying: false, isPaused: true));
    _progressTimer?.cancel();
  }

// click play and pause button
  void _onTogglePlayPause(
      TogglePlayPause event, Emitter<TextToSpeechState> emit) {
    if (state.isPlaying) {
      add(Pause());
    } else if (state.isPaused) {
      add(Speak(startFrom: state.currentPosition));
    } else {
      add(Speak());
    }
  }

  // onchangeColor

  void _onToggleChangeColor(
      ChangeColorToggle event, Emitter<TextToSpeechState> emit) {
    if (state.isChangeColor) {
      emit(state.copyWith(isChangeColor: !state.isChangeColor));
    } else {
      emit(state.copyWith(isChangeColor: !state.isChangeColor));
    }
  } // on Switch to show and hide player

  void _onHideShowPlayerToggle(
      HideShowPlayerToggle event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(
        isSwitchedToHideShowPlayer: !state.isSwitchedToHideShowPlayer));
  }

// touch screen show player button
  void _onTouchScreenEvent(
      ScreenTouched event, Emitter<TextToSpeechState> emit) {
    emit(state.copyWith(isSwitchedToHideShowPlayer: false));
  }

// reset every thing when go back
  void _onReset(Reset event, Emitter<TextToSpeechState> emit) {
    emit(TextToSpeechState.initial());
    _progressTimer?.cancel();
    _flutterTts.stop();
  }

// to change speed audio
  void _onChangeSpeechRate(
      ChangeSpeechRate event, Emitter<TextToSpeechState> emit) {
    final newSpeechRate = event.rate;

    final newDuration = _estimateDuration(state.text, newSpeechRate);

    emit(state.copyWith(
      speechRate: newSpeechRate,
      originalAudioDuration: newDuration,
    ));
    emit(state.copyWith(speechRate: event.rate));
    if (state.isPlaying) {
      add(Stop());
      add(Speak(startFrom: state.currentPosition));
    }
    if (state.isPlaying) {
      add(Stop());
      add(Speak(startFrom: state.currentPosition));
    }
  }

  // sound pitch
  void _onSliderValueChanged(
      PitchValueChange event, Emitter<TextToSpeechState> emit) async {
    await _flutterTts.stop();

    await _flutterTts.stop();
    _progressTimer?.cancel();

    emit(state.copyWith(
      isPlaying: false,
      isPaused: false,
    ));
    emit(state.copyWith(setPitch: event.value));
  }

  // change volume
  void _onSlidersetVolumeValueChange(
      setVolumeValueChange event, Emitter<TextToSpeechState> emit) async {
    await _flutterTts.stop();

    _progressTimer?.cancel();

    emit(state.copyWith(
      isPlaying: false,
      isPaused: false,
    ));
    emit(state.copyWith(setValume: event.volumeValue));
  }

// increase text size

  void _onIncreaseTextSize(
      IncreaseTextSize event, Emitter<TextToSpeechState> emit) async {
    await _flutterTts.stop();

    _progressTimer?.cancel();
    emit(state.copyWith(textSize: state.textSize + 1));
    emit(state.copyWith(
      isPlaying: false,
      isPaused: false,
    ));
  }

// decrease text size
  void _onDecreaseTextSize(
      DecreaseTextSize event, Emitter<TextToSpeechState> emit) async {
    await _flutterTts.stop();

    _progressTimer?.cancel();
    emit(state.copyWith(textSize: state.textSize - 1));
    emit(state.copyWith(
      isPlaying: false,
      isPaused: false,
    ));
  }


  void _onSeekBy(SeekBy event, Emitter<TextToSpeechState> emit) async {
    final Duration newPosition = state.currentPosition + event.offset;

    if (newPosition >= Duration.zero &&
        newPosition <= state.originalAudioDuration) {
      await _flutterTts.stop();
      _progressTimer?.cancel();
      await _flutterTts.startHandler;
      _currentChunkIndex = _calculateStartChunk(newPosition);
      int wordIndex = _findWordIndexAtPosition(newPosition);

      emit(state.copyWith(
        currentPosition: newPosition,
        currentWordIndex: wordIndex,
        isPlaying: true,
        isPaused: false,
      ));
      _speakCurrentChunk(startWordIndex: wordIndex - _getGlobalWordIndex(0));
      scrollToHighlightedWord(context!, wordIndex); // Scroll to the new word
      _speakCurrentChunk(startWordIndex: wordIndex - _getGlobalWordIndex(0));
      _startTimer(state.wordTimings, state.speechRate);
    }
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<TextToSpeechState> emit) async {
    final Duration maxDuration = state.originalAudioDuration;
    final Duration newPosition = event.position < Duration.zero
        ? Duration.zero
        : (event.position > maxDuration ? maxDuration : event.position);

    // Stop the TTS and the timer
    await _flutterTts.stop();
    _progressTimer?.cancel();

    // Calculate the chunk index and word index
    _currentChunkIndex = _calculateStartChunk(newPosition);
    int wordIndex = _findWordIndexAtPosition(newPosition);

    // Update the state with the new position and word index
    emit(state.copyWith(
      currentPosition: newPosition,
      currentWordIndex: wordIndex,
      isPlaying: true, // Set to true for playback to start
      isPaused: false,
    ));

    // Restart the timer
    _startTimer(state.wordTimings, state.speechRate);

    // Start speaking from the new word
    await _speakCurrentChunk(
        startWordIndex: wordIndex - _getGlobalWordIndex(0));

    // Scroll to the highlighted word
    scrollToHighlightedWord(context!, wordIndex);
  }

  String _getTextAtPosition(Duration position) {
    Duration cumulativeDuration = Duration.zero;
    List<String> words = state.text.split(' ');

    for (int i = 0; i < state.wordTimings.length; i++) {
      cumulativeDuration += state.wordTimings[i];
      if (position < cumulativeDuration) {
        return words.sublist(i).join(' ');
      }
    }

    return state.text;
  }

// show all country bottomsheet
  void showLanguageSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Select Language',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  // LanguageSelectionWidget(),
                  const SizedBox(height: 10),
                  const Divider(),
                  if (state.languageHistory.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonText(
                        title: "Recently",
                        color: Colors.black,
                        size: 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  CountryHistoryWidget(
                    countryHistory: state.countryHistory,
                    onDelete: (country) {
                      final updatedHistory =
                          List<String>.from(state.countryHistory);
                      updatedHistory.remove(country);
                      context.read<TextToSpeechBloc>().emit(state.copyWith(
                            countryHistory: updatedHistory,
                          ));
                    },
                  ),
                  state.ToggleSubCategory || state.isLanguageSelectOn
                      ? SubCategoryWidget()
                      : allCountryListBottomSheet(
                          scrollController: scrollController),
                ],
              ),
            );
          },
        );
      },
    );
  }

/*
  List<TextSpan> buildHighlightedTextSpans({
    required String text,
    required int currentWordIndex,
    required BuildContext context,
  }) {
    // Split the input text into words
    List<String> words = text.split(' ');

    // Add auto-scrolling logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentWordIndex < state.wordKeys.length &&
          state.wordKeys[currentWordIndex].currentContext != null) {
        Scrollable.ensureVisible(
          state.wordKeys[currentWordIndex].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5, 
        );
      }
    });

    // Create a wrapper RenderObject to hold our keys
    return words.asMap().entries.map((entry) {
      final int index = entry.key;
      final String word = entry.value;
      final bool isHighlighted = index == currentWordIndex;

      return TextSpan(
        text: '$word ',
        style: TextStyle(
            fontSize: state.textSize.toDouble(),
            color: isHighlighted
                ? Colors.white
                : state.isChangeColor
                    ? Colors.white
                    : Colors.black,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            backgroundColor: isHighlighted ? Colors.blue : null,
            fontFamily: state.selectedFont),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            context.read<TextToSpeechBloc>().add(ScreenTouched());
            context.read<TextToSpeechBloc>().add(WordSelected(index));
          },
      );
    }).toList();
  }
*/

List<TextSpan> buildHighlightedTextSpans({
  required String text,
  required int currentWordIndex,
  required BuildContext context,
}) {
  List<String> words = text.split(' ');

  // Ensure the highlighted word scrolls into view
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scrollToHighlightedWord(context, currentWordIndex);
  });

  return words.asMap().entries.map((entry) {
    final int index = entry.key;
    final String word = entry.value;
    final bool isHighlighted = index == currentWordIndex;

    return TextSpan(
      text: '$word ',
      style: TextStyle(
        fontSize: state.textSize.toDouble(),
        color: isHighlighted ? Colors.white : Colors.black,
        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
        backgroundColor: isHighlighted ? Colors.blue : null,
        fontFamily: state.selectedFont,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          context.read<TextToSpeechBloc>().add(ScreenTouched());
          context.read<TextToSpeechBloc>().add(WordSelected(index));
        },
    );
  }).toList();
}

/*
// scroll content with audio base
  void scrollToHighlightedWord(BuildContext context, int wordIndex) async {
    if (state.wordKeys.isEmpty ||
        wordIndex < 0 ||
        wordIndex >= state.wordKeys.length) {
      return;
    }

    final key = state.wordKeys[wordIndex];

    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
*/
void scrollToHighlightedWord(BuildContext context, int wordIndex) {
  if (state.wordKeys.isEmpty || wordIndex < 0 || wordIndex >= state.wordKeys.length) {
    return;
  }

  final key = state.wordKeys[wordIndex];

  if (key.currentContext != null) {
    Scrollable.ensureVisible(
      key.currentContext!,
      alignment: 0.5, // Center the highlighted word in the view
      duration: const Duration(milliseconds: 200), // Smooth scrolling
      curve: Curves.easeInOut,
    );
  }
}

  Duration _calculateCumulativeDuration(
      List<String> words, BuildContext context) {
    final speechRate = context.read<TextToSpeechBloc>().state.speechRate;
    Duration totalDuration = Duration.zero;

    for (var word in words) {
      Duration wordDuration = Duration(
          milliseconds: ((word.length / 8) * (600 / speechRate)).toInt());
      totalDuration += wordDuration;
    }
    return totalDuration;
  }

//


// check current index
  int _calculateCurrentWordIndex(Duration position) {
    const int wordsPerMinute = 150;
    int wordsToSkip = ((position.inSeconds / 60) * wordsPerMinute).toInt();
    return wordsToSkip;
  }


  Duration _estimateTotalDuration() {
    // const double wordsPerMinute = 150.0;
    // int totalWords = state.text.split(' ').length;
    // double minutes = totalWords / (wordsPerMinute * state.speechRate);
    // return Duration(milliseconds: (minutes * 60 * 1000).round());
  
   return _calculateWordTimings(state.text).fold(
      Duration.zero, (total, duration) => total + duration);
  }


// show total text audio duration
  Duration _estimateDuration(String text, double speechRate) {
    const double baseWordsPerMinute = 150.0;

    final String cleanText = text.trim();
    if (cleanText.isEmpty) return Duration.zero;

    final List<String> words = cleanText.split(RegExp(r'\s+'));
    final int wordCount = words.length;

    final double adjustedWordsPerMinute = baseWordsPerMinute * speechRate;
    final double minutes = wordCount / adjustedWordsPerMinute;
    final int milliseconds = (minutes * 60 * 850).round();

    final int minDuration = 850;

    return Duration(milliseconds: math.max(milliseconds, minDuration));
  }


  int _calculateStartChunk(Duration position) {
Duration cumulativeDuration = Duration.zero;
  for (int i = 0; i < _textChunks.length; i++) {
    Duration chunkDuration = _calculateWordTimings(_textChunks[i])
        .fold(Duration.zero, (total, duration) => total + duration);
    cumulativeDuration += chunkDuration;
    if (position < cumulativeDuration) {
      return i;
    }
  }
  return _textChunks.length - 1;
/*
    Duration cumulativeDuration = Duration.zero;

    for (int i = 0; i < _textChunks.length; i++) {
      String chunk = _textChunks[i];
      List<String> words = chunk.split(' ');

      Duration chunkDuration = Duration.zero;

      for (String word in words) {
        chunkDuration += Duration(
            milliseconds:
                ((word.length / 8) * (600 / state.speechRate)).toInt());
      }

      cumulativeDuration += chunkDuration;

      if (position < cumulativeDuration) {
        return i;
      }
    }

    return _textChunks.length - 1;
  */

  }

 Duration _calculatePositionForWord(int wordIndex) {
    // List<String> words = state.text.split(' ');
    Duration position = Duration.zero;

    for (int i = 0; i < wordIndex && i < state.wordTimings.length; i++) {
      position += state.wordTimings[i];
    }
    return position;
  }

  List<Duration> _calculateWordTimings(String text) {
    List<String> words = text.split(' ');
    return words.map((word) {
      return Duration(
        milliseconds: ((word.length / 8) * (600 / state.speechRate)).toInt(),
      );
    }).toList();
  }

  Duration _calculateAdjustedAudioDuration() {
    return Duration(
        seconds: (_estimateDuration(state.text, state.speechRate).inSeconds));
  }

  Duration _adjustedAudioDuration() {
    return Duration(
        seconds:
            (state.originalAudioDuration.inSeconds / state.speechRate).round());
  }

  int _calculateWordsToSkip(Duration duration) {
    const int wordsPerMinute = 150;
    int wordsToSkip = ((duration.inSeconds / 60) * wordsPerMinute).toInt();
    return wordsToSkip;
  }

  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Show a dialog to retry permission
      bool shouldRequestAgain = await _showPermissionDialog(
        context!,
        'Storage permission is required to save audio files.',
        'Grant Permission',
      );
      if (shouldRequestAgain) {
        return await _requestPermission();
      }
    } else if (status.isPermanentlyDenied) {
      // Redirect to app settings
      bool openSettings = await _showPermissionDialog(
        context!,
        'Storage permission is permanently denied. Open settings to enable it.',
        'Open Settings',
      );
      if (openSettings) {
        await openAppSettings();
      }
    }
    return false;
  }

  Future<bool> _showPermissionDialog(
      BuildContext context, String message, String buttonText) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Required'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(buttonText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _onRequestStoragePermission(
      RequestStoragePermission event, Emitter<TextToSpeechState> emit) async {
    try {
      if (Platform.isAndroid) {
        if (await Permission.storage.isGranted ||
            await Permission.manageExternalStorage.isGranted) {
          emit(state.copyWith(isPermissionGranted: true));
          return;
        }

        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          emit(state.copyWith(isPermissionGranted: true));
          return;
        }

        if (await Permission.storage.isPermanentlyDenied ||
            await Permission.manageExternalStorage.isPermanentlyDenied) {
          emit(state.copyWith(isPermissionGranted: false));
        }
      }
    } catch (e) {
      print('Permission error: $e');
      emit(state.copyWith(isPermissionGranted: false));
    }
  }

// download audio
  Future<void> _onDownloadAudio(
      DownloadAudio event, Emitter<TextToSpeechState> emit) async {
    if (!state.isPermissionGranted) {
      add(RequestStoragePermission());
      return;
    }

    emit(state.copyWith(isDownloading: true));

    try {
      Directory directory = Directory('/storage/emulated/0/QaiserF');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath =
          '${directory.path}/converted_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      _flutterTts.stop();
      _progressTimer?.cancel();
      var result = await _flutterTts.synthesizeToFile(event.text, filePath);

      if (result == 1) {
        emit(state.copyWith(
          isDownloading: false,
          downloadedFilePath: filePath,
        ));
        print('Audio file saved successfully at $filePath');
      } else {
        emit(state.copyWith(isDownloading: false));
        print('Error: TTS synthesis failed');
      }
    } catch (e) {
      print('Error downloading audio: $e');
      emit(state.copyWith(isDownloading: false));
    }
  }

// summerize text
  void _onSummarizeText(SummarizeText event, Emitter<TextToSpeechState> emit) {
    final text = event.text;

    if (text.isEmpty) {
      emit(state.copyWith(summarizedText: 'No text to summarize.'));
      return;
    }

    // Split the text into sentences
    final sentences = text.split(RegExp(r'(?<=\.)\s+'));

    if (sentences.length <= 2) {
      // If text is too short , return same
      emit(state.copyWith(summarizedText: text));
      return;
    }

    final wordFrequency = <String, int>{};
    final words =
        text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ');

    for (var word in words) {
      if (word.isNotEmpty) {
        wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      }
    }

    final sentenceScores = <String, double>{};
    for (var sentence in sentences) {
      final sentenceWords =
          sentence.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ');

      double sentenceScore = 0.0;
      for (var word in sentenceWords) {
        if (wordFrequency.containsKey(word)) {
          sentenceScore += wordFrequency[word]!;
        }
      }

      if (sentenceWords.isNotEmpty) {
        sentenceScore /= sentenceWords.length;
      }

      sentenceScores[sentence] = sentenceScore;
    }

    final rankedSentences = sentenceScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSentences = rankedSentences
        .take((sentences.length * 0.3).ceil())
        .map((entry) => entry.key)
        .toList();

    final summary = topSentences.join(' ');

    emit(state.copyWith(summarizedText: summary));
  }

  @override
  Future<void> close() {
    _flutterTts.stop();
    _progressTimer?.cancel();
    return super.close();
  }
}
