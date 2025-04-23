// // ignore_for_file: prefer_const_declarations, non_constant_identifier_names, unused_element, prefer_final_fields

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
// import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_state.dart';
// import 'dart:async';
// import 'dart:math' as math;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:new_wall_paper_app/audio-to-text/model/country_model.dart';
// import 'package:new_wall_paper_app/widget/common-text.dart';
// import 'package:new_wall_paper_app/widget/common_bottomsheet.dart';
// // import 'package:new_wall_paper_app/widget/common_bottomsheet.dart';
// import 'package:new_wall_paper_app/widget/language_selected_history.dart';

// class TextToSpeechBloc extends Bloc<TextToSpeechEvent, TextToSpeechState> {
//   final FlutterTts _flutterTts = FlutterTts();
//   Timer? _progressTimer;
//   final AudioPlayer audioPlayer = AudioPlayer();
//   Duration totalDuration = Duration.zero;
//   Duration currentPosition = Duration.zero;
//   String selectedCountry = '';
//   String selectLang = '';
//   String selectCountriesCode = '';

//   static const int _maxChunkSize = 500;
//   List<String> _textChunks = [];
//   int _currentChunkIndex = 0;

//   bool _isProcessingChunk = false;
//   TextToSpeechBloc() : super(TextToSpeechState.initial()) {
//     on<TextChanged>(_onTextChanged);
//     on<Speak>(_onSpeak);
//     on<Stop>(_onStop);
//     on<Pause>(_onPause);
//     on<TogglePlayPause>(_onTogglePlayPause);
//     on<ChangeSpeechRate>(_onChangeSpeechRate);
//     on<SeekBy>(_onSeekBy);
//     on<SeekTo>(_onSeekTo);
//     on<Reset>(_onReset);
//     on<SelectCountry>(_onCountrySelected);
//     on<SelectLanguage>(_onLanguageSelected);
//     on<ToggleLanguageOn>(isSelectLanguageOnn);
//     on<ToggleSubCategory>(ToggleSubCategries);
//     on<WordSelected>(_onWordSelected);
//     on<PitchValueChange>(_onSliderValueChanged);
//     on<setVolumeValueChange>(_onSlidersetVolumeValueChange);
//     on<IncreaseTextSize>(_onIncreaseTextSize);
//     on<DecreaseTextSize>(_onDecreaseTextSize);
//     on<InitializeWordKeys>(_onInitializeWordKeys);
//   }

//   Future<void> _initializeTts(BuildContext context) async {
//     await _flutterTts.setLanguage("en-US");
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.setSpeechRate(0.5);

//     _flutterTts.setCompletionHandler(() {
//       if (_currentChunkIndex < _textChunks.length - 1) {
//         _currentChunkIndex++;
//         _speakCurrentChunk();
//       } else {
//         add(Stop());
//       }
//     });

//     _flutterTts.setProgressHandler(
//       (String text, int startOffset, int endOffset, String word) {
//         if (!_isProcessingChunk) {
//           buildHighlightedTextSpans(
//             context,
//             word,
//             state.currentWordIndex,
//           );
//         }
//       },
//     );

//     _flutterTts.setErrorHandler((msg) {
//       print("TTS Error: $msg");
//       add(Stop());
//     });
//   }

//   void _onInitializeWordKeys(
//       InitializeWordKeys event, Emitter<TextToSpeechState> emit) {
//     final List<GlobalKey> wordKeys =
//         event.text.split(' ').map((_) => GlobalKey()).toList();
//     emit(state.copyWith(wordKeys: wordKeys, text: event.text));
//   }

//   void _onWordSelected(WordSelected event, Emitter<TextToSpeechState> emit) {
//     emit(state.copyWith(currentWordIndex: event.wordIndex));
//   }

//   Duration _calculatePositionForWord(int wordIndex) {
//     List<String> words = state.text.split(' ');
//     Duration position = Duration.zero;

//     for (int i = 0; i < wordIndex && i < state.wordTimings.length; i++) {
//       position += state.wordTimings[i];
//     }
//     return position;
//   }

//   void isSelectLanguageOnn(
//       ToggleLanguageOn event, Emitter<TextToSpeechState> emit) {
//     selectLang = event.selectLang;
//     emit(state.copyWith(
//         isLanguageSelectOn: !state.isLanguageSelectOn,
//         selectCountriesCode: selectLang));
//   }

//   void ToggleSubCategries(
//       ToggleSubCategory event, Emitter<TextToSpeechState> emit) {
//     selectCountriesCode = event.selectCountriesCode;
//     emit(state.copyWith(
//         ToggleSubCategory: !state.ToggleSubCategory,
//         selectLang: selectCountriesCode));
//   }

// // right
//   void _prepareTextChunks(String text) {
//     _textChunks.clear();
//     if (text.isEmpty) return;

//     final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
//     String currentChunk = '';
//     for (final sentence in sentences) {
//       if ((currentChunk + sentence).length <= _maxChunkSize) {
//         currentChunk += '$sentence ';
//       } else {
//         _textChunks.add(currentChunk.trim());
//         currentChunk = '$sentence ';
//       }
//     }
//     if (currentChunk.isNotEmpty) {
//       _textChunks.add(currentChunk.trim());
//     }
//   }

//   void _onCountrySelected(
//       SelectCountry event, Emitter<TextToSpeechState> emit) {
//     String newSelectedCountry = event.country;

//     emit(state.copyWith(selectedCountry: newSelectedCountry));

//     final updatedHistory = List<String>.from(state.countryHistory);
//     if (!updatedHistory.contains(newSelectedCountry)) {
//       updatedHistory.add(newSelectedCountry);
//       emit(state.copyWith(countryHistory: updatedHistory));
//     }
//   }

//   Future<void> _onLanguageSelected(
//       SelectLanguage event, Emitter<TextToSpeechState> emit) async {
//     if (state.isPlaying) {
//       await _flutterTts.stop();
//     }

//     await _flutterTts.setLanguage('${selectLang}-${selectCountriesCode}');

//     emit(state.copyWith(
//       selectedLanguage: event.language,
//       selectedCountry: '',
//       isPlaying: false,
//       currentPosition: Duration.zero,
//     ));
//   }

//   Future<void> _speakCurrentChunk({int startWordIndex = 0}) async {
//     if (_currentChunkIndex >= _textChunks.length) return;

//     String chunk = _textChunks[_currentChunkIndex];
//     List<String> words = chunk.split(' ');

//     String adjustedChunk = words.sublist(startWordIndex).join(' ');

//     await _flutterTts.speak(adjustedChunk);

//     _flutterTts.setProgressHandler((text, startOffset, endOffset, word) {
//       final int wordIndex = _getWordIndexByOffset(startOffset, words);
//       emit(state.copyWith(currentWordIndex: _getGlobalWordIndex(wordIndex)));
//     });

//     _flutterTts.setCompletionHandler(() async {
//       if (_currentChunkIndex < _textChunks.length - 1) {
//         _currentChunkIndex++;
//         await Future.delayed(const Duration(milliseconds: 100));
//         _speakCurrentChunk();
//       } else {
//         add(Stop());
//       }
//     });

//     _flutterTts.setErrorHandler((msg) {
//       print("TTS Error: $msg");
//       add(Stop());
//     });
//   }

//   int _getWordIndexByOffset(int offset, List<String> words) {
//     int cumulativeOffset = 0;
//     for (int i = 0; i < words.length; i++) {
//       cumulativeOffset += words[i].length + 1;
//       if (cumulativeOffset > offset) return i;
//     }
//     return words.length - 1;
//   }

//   int _getGlobalWordIndex(int localIndex) {
//     int globalIndex = 0;
//     for (int i = 0; i < _currentChunkIndex; i++) {
//       globalIndex += _textChunks[i].split(' ').length;
//     }
//     return globalIndex + localIndex;
//   }

//   void _onTextChanged(TextChanged event, Emitter<TextToSpeechState> emit) {
//     emit(state.copyWith(text: event.texts));
//   }

//   Future<void> _onSpeak(Speak event, Emitter<TextToSpeechState> emit) async {
//     if (state.text.isEmpty) return;

//     emit(state.copyWith(isLoading: true, isPaused: false));

//     await _flutterTts
//         .setLanguage("${state.selectedLanguage.code}-${state.selectedCountry}");
//     await _flutterTts.setPitch(state.setPitch);
//     await _flutterTts.setSpeechRate(state.speechRate.clamp(0.5, 2.0));
//     await _flutterTts.setVolume(state.setValume);

//     List<String> words = state.text.split(' ');
//     _prepareTextChunks(state.text);

//     _currentChunkIndex = _calculateStartChunk(event.startFrom);
//     Duration estimatedDuration = _estimateTotalDuration();

//     List<Duration> wordTimings = words.map((word) {
//       return Duration(
//         milliseconds: ((word.length / 8) * (600 / state.speechRate)).toInt(),
//       );
//     }).toList();

//     emit(state.copyWith(
//       isPlaying: true,
//       isLoading: false,
//       originalAudioDuration: estimatedDuration,
//       wordTimings: wordTimings,
//     ));

//     _speakCurrentChunk(startWordIndex: state.currentWordIndex);

//     _startTimer(wordTimings, state.speechRate);
//   }

//   void _startTimer(List<Duration> wordTimings, double speechRate) {
//     _progressTimer?.cancel();
//     const int interval = 50;

//     _progressTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
//       if (state.isPlaying) {
//         final newPosition =
//             state.currentPosition + Duration(milliseconds: interval);

//         if (newPosition >= state.originalAudioDuration) {
//           add(Stop());
//         } else {
//           int newWordIndex = _findWordIndexAtPosition(newPosition);

//           emit(state.copyWith(
//             currentPosition: newPosition,
//             currentWordIndex: newWordIndex,
//           ));
//         }
//       }
//     });
//   }

//   int _findWordIndexAtPosition(Duration position) {
//     Duration cumulativeDuration = Duration.zero;
//     for (int i = 0; i < state.wordTimings.length; i++) {
//       cumulativeDuration += state.wordTimings[i];
//       if (position < cumulativeDuration) {
//         return i;
//       }
//     }
//     return state.wordTimings.length - 1; // Return the last word if out of range
//   }

//   int _calculateStartChunk(Duration position) {
//     double totalDurationMs = _estimateTotalDuration().inMilliseconds.toDouble();
//     double positionMs = position.inMilliseconds.toDouble();

//     int chunkIndex =
//         ((positionMs / totalDurationMs) * _textChunks.length).floor();
//     return math.min(chunkIndex, _textChunks.length - 1);
//   }

//   Duration _estimateTotalDuration() {
//     const double wordsPerMinute = 150.0;
//     int totalWords = state.text.split(' ').length;
//     double minutes = totalWords / (wordsPerMinute * state.speechRate);
//     return Duration(milliseconds: (minutes * 60 * 1000).round());
//   }

//   void _startProgressTimer() {
//     _progressTimer?.cancel();
//     _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
//       if (state.isPlaying) {
//         final updatedPosition =
//             state.currentPosition + const Duration(milliseconds: 200);

//         if (updatedPosition >= state.originalAudioDuration) {
//           emit(state.copyWith(currentPosition: state.originalAudioDuration));
//           add(Stop());
//         } else {
//           emit(state.copyWith(currentPosition: updatedPosition));
//         }
//       }
//     });
//   }

//   Future<List<String>> getAvailableVoices() async {
//     try {
//       final voices = await _flutterTts.getVoices;
//       return voices
//           .where((voice) => voice
//               .toString()
//               .toLowerCase()
//               .contains(state.selectedLanguage.code.toLowerCase()))
//           .map((voice) => voice.toString())
//           .toList();
//     } catch (e) {
//       print('Error getting voices: $e');
//       return [];
//     }
//   }

//   int _calculateCurrentWordIndex(Duration position) {
//     const int wordsPerMinute = 150;
//     int wordsToSkip = ((position.inSeconds / 60) * wordsPerMinute).toInt();
//     return wordsToSkip;
//   }

//   Future<void> _onStop(Stop event, Emitter<TextToSpeechState> emit) async {
//     await _flutterTts.stop();
//     emit(state.copyWith(
//       isPlaying: false,
//       currentPosition: Duration.zero,
//     ));
//     _progressTimer?.cancel();
//   }

//   void _onPause(Pause event, Emitter<TextToSpeechState> emit) async {
//     await _flutterTts.stop();
//     emit(state.copyWith(isPlaying: false, isPaused: true));
//     _progressTimer?.cancel();
//   }

//   void _onTogglePlayPause(
//       TogglePlayPause event, Emitter<TextToSpeechState> emit) {
//     if (state.isPlaying) {
//       add(Pause());
//     } else if (state.isPaused) {
//       add(Speak(startFrom: state.currentPosition));
//     } else {
//       add(Speak());
//     }
//   }

//   void _onReset(Reset event, Emitter<TextToSpeechState> emit) {
//     emit(TextToSpeechState.initial());
//     _progressTimer?.cancel();
//     _flutterTts.stop();
//   }

//   void _onChangeSpeechRate(
//       ChangeSpeechRate event, Emitter<TextToSpeechState> emit) {
//     final newSpeechRate = event.rate;

//     final newDuration = _estimateDuration(state.text, newSpeechRate);

//     emit(state.copyWith(
//       speechRate: newSpeechRate,
//       originalAudioDuration: newDuration,
//     ));
//     emit(state.copyWith(speechRate: event.rate));
//     if (state.isPlaying) {
//       add(Stop());
//       add(Speak(startFrom: state.currentPosition));
//     }
//     if (state.isPlaying) {
//       add(Stop());
//       add(Speak(startFrom: state.currentPosition));
//     }
//   }

//   Duration _estimateDuration(String text, double speechRate) {
//     const double baseWordsPerMinute = 150.0;

//     final String cleanText = text.trim();
//     if (cleanText.isEmpty) return Duration.zero;

//     final List<String> words = cleanText.split(RegExp(r'\s+'));
//     final int wordCount = words.length;

//     final double adjustedWordsPerMinute = baseWordsPerMinute * speechRate;
//     final double minutes = wordCount / adjustedWordsPerMinute;
//     final int milliseconds = (minutes * 60 * 850).round();

//     final int minDuration = 850;

//     return Duration(milliseconds: math.max(milliseconds, minDuration));
//   }

//   // sound pitch
//   void _onSliderValueChanged(
//       PitchValueChange event, Emitter<TextToSpeechState> emit) async {
//     await _flutterTts.stop();

//     await _flutterTts.stop();
//     _progressTimer?.cancel();

//     emit(state.copyWith(
//       isPlaying: false,
//       isPaused: false,
//     ));
//     emit(state.copyWith(setPitch: event.value));
//   }

//   // change volume
//   void _onSlidersetVolumeValueChange(
//       setVolumeValueChange event, Emitter<TextToSpeechState> emit) async {
//     await _flutterTts.stop();

//     _progressTimer?.cancel();

//     emit(state.copyWith(
//       isPlaying: false,
//       isPaused: false,
//     ));
//     emit(state.copyWith(setValume: event.volumeValue));
//   }
// //  increase and decrease text size
// //  on<IncreaseTextSize>((event, emit) {
// //       emit(state.copyWith(textSize: state.textSize + 2));
// //     });

// //     on<DecreaseTextSize>((event, emit) {
// //       emit(state.copyWith(textSize: state.textSize - 2));
// //     });
//   void _onIncreaseTextSize(
//       IncreaseTextSize event, Emitter<TextToSpeechState> emit) async {
//     await _flutterTts.stop();

//     _progressTimer?.cancel();
//     emit(state.copyWith(textSize: state.textSize + 1));
//     emit(state.copyWith(
//       isPlaying: false,
//       isPaused: false,
//     ));
//   }

//   void _onDecreaseTextSize(
//       DecreaseTextSize event, Emitter<TextToSpeechState> emit) async {
//     await _flutterTts.stop();

//     _progressTimer?.cancel();
//     emit(state.copyWith(textSize: state.textSize - 1));
//     emit(state.copyWith(
//       isPlaying: false,
//       isPaused: false,
//     ));
//   }

//   Future<void> _onSeekTo(SeekTo event, Emitter<TextToSpeechState> emit) async {
//     final Duration newPosition = event.position;

//     await _flutterTts.stop();
//     _progressTimer?.cancel();

//     _currentChunkIndex = _calculateStartChunk(newPosition);
//     int wordIndex = _findWordIndexAtPosition(newPosition);

//     emit(state.copyWith(
//       currentPosition: newPosition,
//       currentWordIndex: wordIndex,
//       isPlaying: true,
//       isPaused: false,
//     ));

//     _speakCurrentChunk(startWordIndex: wordIndex - _getGlobalWordIndex(0));
//     _startTimer(state.wordTimings, state.speechRate);
//   }

//   String _getTextAtPosition(Duration position) {
//     Duration cumulativeDuration = Duration.zero;
//     List<String> words = state.text.split(' ');

//     for (int i = 0; i < state.wordTimings.length; i++) {
//       cumulativeDuration += state.wordTimings[i];
//       if (position < cumulativeDuration) {
//         return words.sublist(i).join(' ');
//       }
//     }

//     return state.text;
//   }

//   void showLanguageSelectionBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       isScrollControlled: true,
//       context: context,
//       isDismissible: false,
//       builder: (BuildContext context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.5,
//           minChildSize: 0.5,
//           maxChildSize: 1.0,
//           expand: false,
//           builder: (context, scrollController) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Text(
//                           'Select Language',
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ],
//                   ),
//                   LanguageSelectionWidget(),
//                   SizedBox(height: 10),
//                   const Divider(),
//                   // SizedBox(height: 10),
//                   if (state.languageHistory.isNotEmpty)
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: CommonText(
//                         title: "Recently",
//                         color: Colors.black,
//                         size: 0.02,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   SizedBox(height: 20),
//                   CountryHistoryWidget(
//                     countryHistory: state.countryHistory,
//                     onDelete: (country) {
//                       final updatedHistory =
//                           List<String>.from(state.countryHistory);
//                       updatedHistory.remove(country);
//                       context
//                           .read<TextToSpeechBloc>()
//                           .emit(state.copyWith(countryHistory: updatedHistory));
//                     },
//                   ),
//                   state.ToggleSubCategory || state.isLanguageSelectOn
//                       ? SubCategoryWidget()
//                       : Expanded(
//                           child: ListView.builder(
//                             controller:
//                                 scrollController, // Attach scroll controller
//                             itemCount: defaultLanguages.length,
//                             itemBuilder: (context, index) {
//                               final language = defaultLanguages[index];
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 8.0),
//                                     child: Text(
//                                       language.name,
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   ...language.countries.map((country) {
//                                     return ListTile(
//                                       leading: CircleAvatar(
//                                         child: Text(country.code),
//                                       ),
//                                       title: Text(country.voiceName),
//                                       subtitle: Text(country.name),
//                                       onTap: () {
//                                         selectLang = language.code;
//                                         selectCountriesCode = country.code;
//                                         context
//                                             .read<TextToSpeechBloc>()
//                                             .add(SelectLanguage(language));
//                                         context
//                                             .read<TextToSpeechBloc>()
//                                             .add(SelectCountry(country.name));
//                                         print(
//                                             "Qaiser farooq: ${selectLang} country code: ${selectCountriesCode}");
//                                         Navigator.pop(context);
//                                       },
//                                     );
//                                   }).toList(),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

// /*
//   List<TextSpan> buildHighlightedTextSpans({
//     required String text,
//     required int currentWordIndex,
//     required BuildContext context,
//   }) {
//     List<String> words = text.split(' ');

//     return words.asMap().entries.map((entry) {
//       final int index = entry.key;
//       final String word = entry.value;
//       final bool isHighlighted = index == currentWordIndex;

//       return TextSpan(
//         text: '$word ',
//         style: TextStyle(
//           fontSize: state.textSize.toDouble(),
//           color: isHighlighted ? Colors.white : Colors.black54,
//           fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
//           backgroundColor: isHighlighted ? Colors.blue : null,
//         ),
//         recognizer: TapGestureRecognizer()
//           ..onTap = () {
//             context.read<TextToSpeechBloc>().add(WordSelected(index));
//           },
//       );
//     }).toList();
//   }
// */

// /*
//   Widget buildHighlightedTextSpans(
//       BuildContext context, String text, int currentWordIndex) {
//     if (text.isEmpty || state.wordKeys.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final List<String> words = text.split(' ');
//     if (currentWordIndex >= words.length) {
//       currentWordIndex = words.length - 1;
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Wrap(
//         spacing: 4.0,
//         runSpacing: 8.0,
//         children: words.asMap().entries.map((entry) {
//           final int index = entry.key;
//           final String word = entry.value;
//           final bool isHighlighted = index == currentWordIndex;
          
//           // Make sure we don't exceed the wordKeys list length
//           final GlobalKey key = index < state.wordKeys.length 
//               ? state.wordKeys[index]
//               : GlobalKey();

//           return Container(
//             key: key,
//             decoration: BoxDecoration(
//               color: isHighlighted ? Colors.blue.withOpacity(0.2) : null,
//               borderRadius: BorderRadius.circular(4.0),
//             ),
//             child: GestureDetector(
//               onTap: () => add(WordSelected(index)),
//               child: Text(
//                 word,
//                 style: TextStyle(
//                   fontSize: MediaQuery.of(context).size.height * 0.02,
//                   color: isHighlighted ? Colors.blue : Colors.black,
//                   fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   void scrollToHighlightedWord(BuildContext context, int wordIndex) {
//     if (state.wordKeys.isEmpty || wordIndex >= state.wordKeys.length) {
//       return;
//     }

//     final key = state.wordKeys[wordIndex];
//     if (key.currentContext != null) {
//       Scrollable.ensureVisible(
//         key.currentContext!,
//         alignment: 0.5,
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
 
//  */
//   Widget buildHighlightedTextSpans(
//       BuildContext context, String text, int currentWordIndex) {
//     if (text.isEmpty || state.wordKeys.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final List<String> words = text.split(' ');
//     if (currentWordIndex >= words.length) {
//       currentWordIndex = words.length - 1;
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Wrap(
//         spacing: 4.0,
//         runSpacing: 8.0,
//         children: words.asMap().entries.map((entry) {
//           final int index = entry.key;
//           final String word = entry.value;
//           final bool isHighlighted = index == currentWordIndex;

//           final GlobalKey key = index < state.wordKeys.length
//               ? state.wordKeys[index]
//               : GlobalKey();

//           return AnimatedContainer(
//             key: key,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             decoration: BoxDecoration(
//               color: isHighlighted
//                   ? Colors.blue.withOpacity(0.2)
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(4.0),
//               boxShadow: isHighlighted
//                   ? [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.1),
//                         blurRadius: 4.0,
//                         spreadRadius: 1.0,
//                       )
//                     ]
//                   : [],
//             ),
//             padding: const EdgeInsets.symmetric(
//               horizontal: 4.0,
//               vertical: 2.0,
//             ),
//             child: TweenAnimationBuilder<double>(
//               duration: const Duration(milliseconds: 300),
//               tween: Tween<double>(
//                 begin: isHighlighted ? 0.0 : 1.0,
//                 end: isHighlighted ? 1.0 : 0.0,
//               ),
//               builder: (context, value, child) {
//                 return Text(
//                   word,
//                   style: TextStyle(
//                     fontSize: MediaQuery.of(context).size.height * 0.02,
//                     color: Color.lerp(
//                       Colors.black,
//                       Colors.blue,
//                       value,
//                     ),
//                     fontWeight:
//                         isHighlighted ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 );
//               },
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

// // Update the scrollToHighlightedWord method to include smooth scrolling
//   void scrollToHighlightedWord(BuildContext context, int wordIndex) {
//     if (state.wordKeys.isEmpty || wordIndex >= state.wordKeys.length) {
//       return;
//     }

//     final key = state.wordKeys[wordIndex];
//     if (key.currentContext != null) {
//       Scrollable.ensureVisible(
//         key.currentContext!,
//         alignment: 0.5,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   Duration _calculateCumulativeDuration(
//       List<String> words, BuildContext context) {
//     final speechRate = context.read<TextToSpeechBloc>().state.speechRate;
//     Duration totalDuration = Duration.zero;

//     for (var word in words) {
//       Duration wordDuration = Duration(
//           milliseconds: ((word.length / 8) * (600 / speechRate)).toInt());
//       totalDuration += wordDuration;
//     }
//     return totalDuration;
//   }

//   void _onSeekBy(SeekBy event, Emitter<TextToSpeechState> emit) async {
//     final Duration newPosition = state.currentPosition + event.offset;

//     if (newPosition >= Duration.zero &&
//         newPosition <= state.originalAudioDuration) {
//       await _flutterTts.stop();
//       _progressTimer?.cancel();
//       _currentChunkIndex = _calculateStartChunk(newPosition);
//       int wordIndex = _findWordIndexAtPosition(newPosition);

//       emit(state.copyWith(
//         currentPosition: newPosition,
//         currentWordIndex: wordIndex,
//         isPlaying: true,
//         isPaused: false,
//       ));

//       _speakCurrentChunk(startWordIndex: wordIndex - _getGlobalWordIndex(0));
//       _startTimer(state.wordTimings, state.speechRate);
//     }
//   }

//   Duration _calculateAdjustedAudioDuration() {
//     return Duration(
//         seconds: (_estimateDuration(state.text, state.speechRate).inSeconds));
//   }

//   Duration _adjustedAudioDuration() {
//     return Duration(
//         seconds:
//             (state.originalAudioDuration.inSeconds / state.speechRate).round());
//   }

//   int _calculateWordsToSkip(Duration duration) {
//     const int wordsPerMinute = 150;
//     int wordsToSkip = ((duration.inSeconds / 60) * wordsPerMinute).toInt();
//     return wordsToSkip;
//   }

//   @override
//   Future<void> close() {
//     _flutterTts.stop();
//     _progressTimer?.cancel();
//     return super.close();
//   }
// }
