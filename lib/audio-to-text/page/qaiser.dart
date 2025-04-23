// // import 'dart:async';

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc.dart';
// // import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
// // import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_state.dart';
// // import 'package:new_wall_paper_app/audio-to-text/model/country_model.dart';
// // import 'package:new_wall_paper_app/audio-to-text/page/testing.dart';
// // import 'package:new_wall_paper_app/widget/common_bottomsheet.dart';
// // // import 'package:new_wall_paper_app/widget/country_bottomsheet.dart';
// // import 'package:new_wall_paper_app/widget/height-widget.dart';
// // import 'package:new_wall_paper_app/widget/time_duration_formate.dart';
// // import 'package:flutter/gestures.dart';

// // class WriteAndTextPage extends StatefulWidget {
// //   final String? text;
// //   final bool isText;

// //   WriteAndTextPage({Key? key, this.text, required this.isText})
// //       : super(key: key);

// //   @override
// //   State<WriteAndTextPage> createState() => _WriteAndTextPageState();
// // }

// // class _WriteAndTextPageState extends State<WriteAndTextPage> {
// //   late TextEditingController _controller;
// //   late ScrollController _scrollController;
// //   Timer? _debounce;
// //   List<GlobalKey> _wordKeys = [];
// //   String textfieldText = '';

// //   void _initializeWordKeys(String text) {
// //     _wordKeys = text.split(' ').map((_) => GlobalKey()).toList();
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     _scrollController.dispose();
// //     _debounce?.cancel();
// //     context.read<TextToSpeechBloc>().add(Stop());
// //     super.dispose();
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = TextEditingController(text: widget.text ?? '');
// //     _scrollController = ScrollController();
// //     if (widget.text != null) {
// //       context.read<TextToSpeechBloc>().add(InitializeWordKeys(widget.text!));
// //     }
// //   }

// //   void _onTextChanged(String value) {
// //     _debounce?.cancel();
// //     _debounce = Timer(const Duration(milliseconds: 300), () {
// //       setState(() {
// //         textfieldText = value;
// //         context.read<TextToSpeechBloc>().add(InitializeWordKeys(value));
// //       });
// //       context.read<TextToSpeechBloc>().add(TextChanged(value));
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocConsumer<TextToSpeechBloc, TextToSpeechState>(
// //       listener: (context, state) {
// //         if (state.isPlaying && state.wordKeys.isNotEmpty) {
// //           context
// //               .read<TextToSpeechBloc>()
// //               .scrollToHighlightedWord(context, state.currentWordIndex);
// //         }
// //       },
// //       builder: (context, state) {
// //         if (widget.text != null && widget.text!.isNotEmpty) {
// //           context.read<TextToSpeechBloc>().add(TextChanged(widget.text!));
// //         }
// //         final totalWords = state.text.split(' ').length;
// //         final wordsRead = state.currentWordIndex;
// //         final wordsRemaining = totalWords - wordsRead;
// //         final currentWordPosition = state.currentWordIndex + 1;
// //         final progress = totalWords > 0
// //             ? (currentWordPosition / totalWords).clamp(0.0, 1.0)
// //             : 0.0;
// //         return WillPopScope(
// //           onWillPop: () async {
// //             context.read<TextToSpeechBloc>().add(Reset());
// //             return true;
// //           },
// //           child: Scaffold(
// //             appBar: AppBar(
// //               title: const Text('Text to Speech'),
// //               actions: [
// //                 IconButton(
// //                   onPressed: () {
// //                     VoiceBottomSheetWidget.show(
// //                         context); // Call the show method to open the bottom sheet
// //                   },
// //                   icon: const Icon(Icons.volume_down),
// //                 )
// //               ],
// //             ),
// //             body: Column(children: [
// //               Expanded(
// //                 child: SingleChildScrollView(
// //                   controller: _scrollController,
// //                   child: Column(
// //                     children: [
// //                       if (textfieldText.isEmpty && widget.isText)
// //                         Padding(
// //                           padding: const EdgeInsets.all(16.0),
// //                           child: TextField(
// //                             controller: _controller,
// //                             maxLines: null,
// //                             style: TextStyle(
// //                               fontSize:
// //                                   MediaQuery.of(context).size.height * 0.02,
// //                               wordSpacing: 1.2,
// //                               color: Colors.black54,
// //                             ),
// //                             decoration: InputDecoration(
// //                               hintStyle: TextStyle(
// //                                 fontSize:
// //                                     MediaQuery.of(context).size.height * 0.02,
// //                               ),
// //                               border: InputBorder.none,
// //                               hintText: "Enter something....",
// //                             ),
// //                             onChanged: _onTextChanged,
// //                           ),
// //                         )
// //                       else if (state.text.isNotEmpty &&
// //                           state.wordKeys.isNotEmpty)
// //                         context
// //                             .read<TextToSpeechBloc>()
// //                             .buildHighlightedTextSpans(
// //                               context,
// //                               state.text,
// //                               state.currentWordIndex,
// //                             ),
// //                       if (state.isLoading && state.isPlaying)
// //                         const Center(child: CircularProgressIndicator()),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ]),
// //             bottomNavigationBar: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Slider(
// //                   value: state.currentPosition.inSeconds.toDouble().clamp(
// //                       0, state.originalAudioDuration.inSeconds.toDouble()),
// //                   min: 0,
// //                   max: state.originalAudioDuration.inSeconds.toDouble(),
// //                   onChanged: (value) {
// //                     // Only seek if the position has changed, and automatically resume playback
// //                     context
// //                         .read<TextToSpeechBloc>()
// //                         .add(SeekTo(Duration(seconds: value.toInt())));
// //                   },
// //                 ),
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(
// //                       horizontal: MediaQuery.of(context).size.width * 0.04),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         formatDuration(state.currentPosition),
// //                         style: const TextStyle(color: Colors.black),
// //                       ),
// //                         Expanded(
// //                         child: Stack(
// //                           alignment: Alignment.center,
// //                           children: [
// //                             SizedBox(
// //                               width: 60,
// //                               height: 60,
// //                               child: CircularProgressIndicator(
// //                                 value: progress,
// //                                 backgroundColor: Colors.grey[300],
// //                                 valueColor: const AlwaysStoppedAnimation<Color>(
// //                                     Colors.blue),
// //                                 strokeWidth: 8,
// //                               ),
// //                             ),
// //                             Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Text(
// //                                   '$currentWordPosition',
// //                                   style: const TextStyle(
// //                                     fontSize: 15,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   'of $totalWords',
// //                                   style: const TextStyle(
// //                                     fontSize: 13,
// //                                     color: Colors.grey,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Text(
// //                         formatDuration(state.originalAudioDuration),
// //                         style: const TextStyle(color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 height(size: 0.02),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                   children: [
// //                     InkWell(
// //                         onTap: () => context
// //                             .read<TextToSpeechBloc>()
// //                             .showLanguageSelectionBottomSheet(context),
// //                         child: CircleAvatar(
// //                           child: Text(state.selectedCountry),
// //                         )),
// //                     IconButton(
// //                       icon: const Icon(Icons.replay_10),
// //                       onPressed: () => context
// //                           .read<TextToSpeechBloc>()
// //                           .add(SeekBy(const Duration(seconds: -10))),
// //                     ),
// //                     IconButton(
// //                       icon: state.isPlaying
// //                           ? const Icon(Icons.pause)
// //                           : const Icon(Icons.play_arrow),
// //                       onPressed: () {
// //                         if (state.isPlaying) {
// //                           context.read<TextToSpeechBloc>().add(Pause());
// //                         } else if (state.isPaused) {
// //                           context
// //                               .read<TextToSpeechBloc>()
// //                               .add(Speak(startFrom: state.currentPosition));
// //                         } else {
// //                           context.read<TextToSpeechBloc>().add(Speak());
// //                         }
// //                       },
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.forward_10),
// //                       onPressed: () => context
// //                           .read<TextToSpeechBloc>()
// //                           .add(SeekBy(const Duration(seconds: 10))),
// //                     ),
// //                     DropdownButton<double>(
// //                       value: state.speechRate,
// //                       items: const [
// //                         DropdownMenuItem(value: 0.5, child: Text("0.5x")),
// //                         DropdownMenuItem(value: 1.0, child: Text("1x")),
// //                         DropdownMenuItem(value: 1.5, child: Text("1.5x")),
// //                         DropdownMenuItem(value: 2.0, child: Text("2x")),
// //                       ],
// //                       onChanged: (value) {
// //                         if (value != null) {
// //                           context
// //                               .read<TextToSpeechBloc>()
// //                               .add(ChangeSpeechRate(value));
// //                         }
// //                       },
// //                     )
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

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
//   BuildContext? context;
//   final AudioPlayer audioPlayer = AudioPlayer();
//   Duration totalDuration = Duration.zero;
//   Duration currentPosition = Duration.zero;
//   String selectedCountry = '';
//   String CountryFlat = '';
//   String selectLang = '';
//   String selectCountriesCode = '';
//   SeekTo? seekTo;
//   static const int _maxChunkSize = 100;
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

//     // testing
//     // on<AddOpenedPdf>(_onAddOpenedPdf);
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

// /*
//   _onWordSelected(WordSelected event, Emitter<TextToSpeechState> emit) async {
//     if (state.text.isEmpty) return;

//     final List<String> words = state.text.split(' ');

//     if (event.wordIndex < 0 || event.wordIndex >= words.length) return;

//     // Stop current playback
//     await _flutterTts.stop();
//     _progressTimer?.cancel();
//     _speakCurrentChunk(startWordIndex: _getGlobalWordIndex(0));

//     Duration position = _calculatePositionForWord(event.wordIndex);
//     int newChunkIndex = _calculateStartChunk(position);

//     emit(state.copyWith(
//       currentWordIndex: event.wordIndex,
//       currentPosition: position,
//       isPlaying: true,
//       isPaused: false,
//       currentChunkIndex: newChunkIndex,
//     ));

//     _currentChunkIndex = newChunkIndex;

//     // Scroll to the clicked word
//     scrollToHighlightedWord(context!, event.wordIndex);

//     // Start speaking from the clicked word
//     await _speakCurrentChunk(
//       startWordIndex: event.wordIndex - _getGlobalWordIndex(0),
//     );
//   }
// */
// // SeekTo event
//   _onWordSelected(WordSelected event, Emitter emit) async {
//     if (state.text.isEmpty) return;

//     final List words = state.text.split(' ');
//     if (event.wordIndex < 0 || event.wordIndex >= words.length) return;

//     // Stop current playback
//     await _flutterTts.stop();
//     _progressTimer?.cancel();

//     // Calculate the position based on word timings
//     Duration position = Duration.zero;
//     for (int i = 0; i < event.wordIndex && i < state.wordTimings.length; i++) {
//       position += state.wordTimings[i];
//     }

//     // Dispatch the SeekTo event with the calculated position
//     add(SeekTo(position));

//     // Calculate which chunk contains the selected word
//     int totalWords = 0;
//     int targetChunkIndex = 0;

//     for (int i = 0; i < _textChunks.length; i++) {
//       int chunkWordCount = _textChunks[i].split(' ').length;
//       if (totalWords + chunkWordCount > event.wordIndex) {
//         targetChunkIndex = i;
//         break;
//       }
//       totalWords += chunkWordCount;
//     }

//     // Calculate the word index within the chunk
//     int wordIndexInChunk = event.wordIndex - totalWords;

//     _currentChunkIndex = targetChunkIndex;

//     // Update state with new values
//     emit(state.copyWith(
//       currentWordIndex: event.wordIndex,
//       currentPosition: position,
//       isPlaying: true,
//       isPaused: false,
//     ));

//     // Scroll to the clicked word
//     scrollToHighlightedWord(context!, event.wordIndex);

//     // Start speaking from the clicked word
//     await _speakCurrentChunk(startWordIndex: wordIndexInChunk);
//     _startTimer(state.wordTimings, state.speechRate);
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
//         selectCountriesCode: selectLang,
//         countryFlat: state.countryFlat));
//   }

//   void ToggleSubCategries(
//       ToggleSubCategory event, Emitter<TextToSpeechState> emit) {
//     selectCountriesCode = event.selectCountriesCode;
//     CountryFlat = event.CountryFlag;
//     emit(state.copyWith(
//         ToggleSubCategory: !state.ToggleSubCategory,
//         selectLang: selectCountriesCode,
//         countryFlat: CountryFlat));
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

//     emit(state.copyWith(
//         selectedCountry: newSelectedCountry, countryFlat: selectedCountry));

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
//       countryFlat: "",
//       isPlaying: false,
//       currentPosition: Duration.zero,
//     ));
//   }

//   Future<void> _speakCurrentChunk({int startWordIndex = 0}) async {
//     if (_currentChunkIndex >= _textChunks.length) return;

//     String chunk = _textChunks[_currentChunkIndex];
//     List<String> words = chunk.split(' ');

//     // Ensure startWordIndex is within bounds
//     startWordIndex = startWordIndex.clamp(0, words.length - 1);

//     // Get the text to speak from the starting word
//     String adjustedChunk = words.sublist(startWordIndex).join(' ');

//     // Configure TTS settings
//     await _flutterTts
//         .setLanguage("${state.selectedLanguage.code}-${state.selectedCountry}");
//     await _flutterTts.setPitch(state.setPitch);
//     await _flutterTts.setSpeechRate(state.speechRate.clamp(0.5, 2.0));
//     await _flutterTts.setVolume(state.setValume);

//     // Calculate global word index for the current chunk
//     int globalWordIndexStart = 0;
//     for (int i = 0; i < _currentChunkIndex; i++) {
//       globalWordIndexStart += _textChunks[i].split(' ').length;
//     }

//     // Speak the chunk
//     await _flutterTts.speak(adjustedChunk);

//     // Set up progress handler for word highlighting
//     _flutterTts.setProgressHandler(
//         (String text, int startOffset, int endOffset, String word) {
//       final int localWordIndex = _getWordIndexByOffset(startOffset, words);
//       final int globalWordIndex =
//           globalWordIndexStart + localWordIndex + startWordIndex;

//       emit(state.copyWith(currentWordIndex: globalWordIndex));
//       scrollToHighlightedWord(context!, globalWordIndex);
//     });

//     // Set up completion handler for chunk transitions
//     _flutterTts.setCompletionHandler(() async {
//       if (_currentChunkIndex < _textChunks.length - 1) {
//         _currentChunkIndex++;
//         await Future.delayed(const Duration(milliseconds: 100));
//         await _speakCurrentChunk();
//       } else {
//         add(Stop());
//       }
//     });
//   }

//   void _onInitializeWordKeys(
//       InitializeWordKeys event, Emitter<TextToSpeechState> emit) {
//     final List<GlobalKey> wordKeys =
//         event.text.split(' ').map((_) => GlobalKey()).toList();
//     emit(state.copyWith(wordKeys: wordKeys, text: event.text));
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

//   int _findWordIndexForTime(Duration elapsedTime, List<Duration> wordTimings) {
//     Duration cumulativeDuration = Duration.zero;

//     for (int i = 0; i < wordTimings.length; i++) {
//       cumulativeDuration += wordTimings[i];
//       if (elapsedTime < cumulativeDuration) {
//         return i;
//       }
//     }

//     return wordTimings.length - 1;
//   }

//   void _startTimer(List<Duration> wordTimings, double speechRate) {
//     _progressTimer?.cancel();

//     const int baseInterval = 50; // Base timer interval
//     int lastWordIndex = -1; // Tracks the last highlighted word index
//     Duration elapsedTime =
//         state.currentPosition; // Tracks elapsed playback time

//     _progressTimer =
//         Timer.periodic(Duration(milliseconds: baseInterval), (timer) {
//       if (!state.isPlaying) {
//         timer.cancel();
//         return;
//       }

//       // Update elapsed time
//       elapsedTime += Duration(milliseconds: baseInterval);

//       // Stop playback when reaching the end
//       if (elapsedTime >= state.originalAudioDuration) {
//         add(Stop());
//         timer.cancel();
//         return;
//       }

//       // Find the word index based on elapsed time
//       int currentWordIndex = _findWordIndexForTime(elapsedTime, wordTimings);

//       // Ensure no backward movement in word highlighting
//       if (currentWordIndex < lastWordIndex) {
//         currentWordIndex = lastWordIndex;
//       }

//       // Emit state changes only if necessary
//       if (currentWordIndex < lastWordIndex) {
//         currentWordIndex = lastWordIndex;
//         emit(state.copyWith(
//           currentPosition: elapsedTime,
//           currentWordIndex: currentWordIndex,
//         ));
//       } else {
//         emit(state.copyWith(currentPosition: elapsedTime));
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
//     return state.wordTimings.length - 1;
//   }

//   int _calculateStartChunk(Duration position) {
//     Duration cumulativeDuration = Duration.zero;

//     for (int i = 0; i < _textChunks.length; i++) {
//       String chunk = _textChunks[i];
//       List<String> words = chunk.split(' ');

//       Duration chunkDuration = Duration.zero;

//       for (String word in words) {
//         chunkDuration += Duration(
//             milliseconds:
//                 ((word.length / 8) * (600 / state.speechRate)).toInt());
//       }

//       cumulativeDuration += chunkDuration;

//       if (position < cumulativeDuration) {
//         return i;
//       }
//     }

//     return _textChunks.length - 1;
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
//     scrollToHighlightedWord(context!, wordIndex);
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
//                             controller: scrollController,
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
//                                         backgroundImage:
//                                             NetworkImage(country.profilePic),
//                                       ),
//                                       title: Text(country.voiceName),
//                                       subtitle: Text(country.name),
//                                       onTap: () {
//                                         selectLang = language.code;
//                                         selectCountriesCode = country.code;
//                                         CountryFlat = country.countryPic;
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

//   Widget buildHighlightedTextSpans(
//       BuildContext context, String text, int currentWordIndex) {
//     if (text.isEmpty || state.wordKeys.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final List<String> words = text.split(' ');
//     if (currentWordIndex >= words.length) {
//       currentWordIndex = words.length - 1;
//     }

//     return RichText(
//       text: TextSpan(
//         children: words.asMap().entries.map((entry) {
//           final int index = entry.key;
//           final String word = entry.value;
//           final bool isHighlighted = index == currentWordIndex;
//           final GlobalKey key = index < state.wordKeys.length
//               ? state.wordKeys[index]
//               : GlobalKey();

//           return WidgetSpan(
//             child: GestureDetector(
//               onTap: () {
//                 context.read<TextToSpeechBloc>().add(WordSelected(index));
//               },
//               child: AnimatedContainer(
//                 key: key,
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 decoration: BoxDecoration(
//                   color: isHighlighted
//                       ? Colors.blue.withOpacity(0.2)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(4.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 2.0,
//                   vertical: 0.0,
//                 ),
//                 child: TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 300),
//                   tween: Tween<double>(
//                     begin: isHighlighted ? 0.0 : 0.0,
//                     end: isHighlighted ? 1.0 : 0.0,
//                   ),
//                   builder: (context, value, child) {
//                     return Text(
//                       '${word} ', // Added space after each word
//                       style: TextStyle(
//                         fontSize: state.textSize.toDouble(),
//                         color: Color.lerp(
//                           Colors.black,
//                           Colors.blue,
//                           value,
//                         ),
//                         fontWeight: FontWeight.normal,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   void scrollToHighlightedWord(BuildContext context, int wordIndex) {
//     if (state.wordKeys.isEmpty ||
//         wordIndex < 0 ||
//         wordIndex >= state.wordKeys.length) {
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
//       await _flutterTts.startHandler;
//       _currentChunkIndex = _calculateStartChunk(newPosition);
//       int wordIndex = _findWordIndexAtPosition(newPosition);

//       emit(state.copyWith(
//         currentPosition: newPosition,
//         currentWordIndex: wordIndex,
//         isPlaying: true,
//         isPaused: false,
//       ));
//       _speakCurrentChunk(startWordIndex: wordIndex - _getGlobalWordIndex(0));
//       scrollToHighlightedWord(context!, wordIndex); // Scroll to the new word
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


