// // ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_tts/flutter_tts.dart';

// import 'package:audioplayers/audioplayers.dart';
// import 'dart:async';

// import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc.dart';
// import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
// import 'package:new_wall_paper_app/audio-to-text/model/country_model.dart';

// class TextToSpeechAndListen extends StatefulWidget {
//   @override
//   _TextToSpeechAndListenState createState() => _TextToSpeechAndListenState();
// }

// class _TextToSpeechAndListenState extends State<TextToSpeechAndListen> {
//   final FlutterTts _flutterTts = FlutterTts();

//   String _text =
//       "With this implementation, changing the slider will seek the audio to the specified position instead of restarting it from the beginning. If you have any further questions or adjustments needed, feel free to ask!";
//   Duration _originalAudioDuration = Duration.zero;
//   Duration _currentPosition = Duration.zero;
//   bool _isPlaying = false;
//   bool _isPaused = false;
//   bool _isLoading = false;
//   double _speechRate = 0.5; // Default speed (1x)
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _speak([Duration startFrom = Duration.zero]) async {
//     if (_text.isNotEmpty) {
//       setState(() {
//         _isLoading = true;
//       });

//       await _flutterTts.setLanguage("en-US");
//       await _flutterTts.setPitch(1.0);
//       await _flutterTts
//           .setSpeechRate(_speechRate); // Set speech rate based on dropdown

//       String skippedText = _text;
//       int startWordIndex = _calculateWordsToSkip(startFrom);

//       if (startWordIndex > 0) {
//         List<String> words = _text.split(' ');
//         skippedText = words.skip(startWordIndex).join(' ');
//       }

//       await _flutterTts.speak(skippedText).then((_) {
//         _originalAudioDuration = _estimateDuration(_text);
//         setState(() {
//           _isLoading = false;
//           _isPlaying = true;
//           _isPaused = false;
//           _currentPosition = startFrom;
//         });
//         _startTimer();
//       }).catchError((error) {
//         print("Error speaking: $error");
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_isPlaying) {
//         if (_currentPosition < _adjustedAudioDuration()) {
//           setState(() {
//             _currentPosition += Duration(seconds: 1);
//           });
//         } else {
//           _stop();
//         }
//       }
//     });
//   }

//   Duration _adjustedAudioDuration() {
//     return Duration(
//         seconds: (_originalAudioDuration.inSeconds / _speechRate).round());
//   }

//   int _calculateWordsToSkip(Duration duration) {
//     const int wordsPerMinute = 150;
//     int wordsToSkip = ((duration.inSeconds / 60) * wordsPerMinute).toInt();
//     return wordsToSkip;
//   }

//   void _stop() async {
//     await _flutterTts.stop();
//     setState(() {
//       _isPlaying = false;
//       _isPaused = false;
//       _currentPosition = Duration.zero;
//     });
//     _timer?.cancel();
//   }

//   void _pause() async {
//     await _flutterTts.stop();
//     setState(() {
//       _isPlaying = false;
//       _isPaused = true;
//     });
//     _timer?.cancel();
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _pause();
//     } else {
//       _speak(_currentPosition);
//     }
//   }

//   Duration _estimateDuration(String text) {
//     const int wordsPerMinute = 150;
//     const double secondsPerMinute = 60.0;
//     int wordCount = text.split(' ').length;
//     double durationInSeconds = (wordCount / wordsPerMinute) * secondsPerMinute;
//     return Duration(seconds: durationInSeconds.toInt());
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$twoDigitMinutes:$twoDigitSeconds";
//   }

//   void _seekBy(Duration offset) {
//     final newPosition = _currentPosition + offset;
//     if (newPosition >= Duration.zero &&
//         newPosition <= _adjustedAudioDuration()) {
//       _stop();
//       _speak(newPosition);
//     }
//   }

//   @override
//   void dispose() {
//     _flutterTts.stop();
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Text to Speech')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Enter text'),
//               onChanged: (value) {
//                 setState(() {
//                   _text = value;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _speak(),
//               child: Text('Convert to Speech'),
//             ),
//             SizedBox(height: 20),
//             DropdownButton<double>(
//               value: _speechRate,
//               items: [
//                 DropdownMenuItem(value: 0.5, child: Text("1x")),
//                 DropdownMenuItem(value: 1.5, child: Text("1.5x")),
//                 DropdownMenuItem(value: 2.0, child: Text("2x")),
//                 DropdownMenuItem(value: 2.5, child: Text("2.5x")),
//                 DropdownMenuItem(value: 3.0, child: Text("3x")),
//                 DropdownMenuItem(value: 3.5, child: Text("3.5x")),
//                 DropdownMenuItem(value: 4.0, child: Text("4x")),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _speechRate = value!;
//                   if (_isPlaying) {
//                     _stop();
//                     _speak(_currentPosition);
//                   }
//                 });
//               },
//               hint: Text("Select Speed"),
//             ),
//             if (_originalAudioDuration != Duration.zero) ...[
//               Text(
//                   'Adjusted Audio Length: ${_formatDuration(_adjustedAudioDuration())}'),
//               Slider(
//                 value: _currentPosition.inSeconds.toDouble(),
//                 min: 0,
//                 max: _adjustedAudioDuration().inSeconds.toDouble(),
//                 onChanged: (value) {
//                   setState(() {
//                     _currentPosition = Duration(seconds: value.toInt());
//                   });
//                 },
//                 onChangeEnd: (value) {
//                   _stop();
//                   _speak(Duration(seconds: value.toInt()));
//                 },
//               ),
//               Text('Current Position: ${_formatDuration(_currentPosition)}'),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.replay_10),
//                     onPressed: () => _seekBy(Duration(seconds: -10)),
//                   ),
//                   IconButton(
//                     icon:
//                         _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
//                     onPressed: _togglePlayPause,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.forward_10),
//                     onPressed: () => _seekBy(Duration(seconds: 10)),
//                   ),
//                 ],
//               ),
//             ],
//             if (_isLoading) CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /////////////////////////////////////////////////////////////////////////////////////////
// ///
// ///
// ///

// class HighlightedText extends StatelessWidget {
//   final String text;
//   final int currentWordIndex;
//   final double fontSize;
//   final Color highlightColor;
//   final Color textColor;

//   const HighlightedText({
//     Key? key,
//     required this.text,
//     required this.currentWordIndex,
//     this.fontSize = 16.0,
//     this.highlightColor = Colors.blue,
//     this.textColor = Colors.black87,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final words = text.split(' ');
//     final spans = <TextSpan>[];

//     for (int i = 0; i < words.length; i++) {
//       final isHighlighted = i == currentWordIndex;
//       spans.add(
//         TextSpan(
//           text: '${words[i]}${i < words.length - 1 ? ' ' : ''}',
//           style: TextStyle(
//             fontSize: fontSize,
//             backgroundColor: isHighlighted ? highlightColor : Colors.transparent,
//             color: textColor,
//             height: 1.5,
//           ),
//             recognizer: TapGestureRecognizer()
//           ..onTap = () {
//             final position =
//                 _calculateCumulativeDuration(words.sublist(0, i), context);
//             context.read<TextToSpeechBloc>().add(SeekTo(position,));
//           },
//         ),
//       );
//     }

//     return SelectableText.rich(
//       TextSpan(children: spans),
//       textAlign: TextAlign.justify,
//     );
//   }
// }

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



////////////////////////
///
///
///
///
///
///
///

// second 

// import android.media.Medcom.example.flutter_node_authiaScannerConnection;
// import android.os.Bundle;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.flutter_node_auth/media_scanner";

//     @Override
//     public void configureFlutterEngine(FlutterEngine flutterEngine) {
//         super.configureFlutterEngine(flutterEngine);
//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .setMethodCallHandler((call, result) -> {
//                 if (call.method.equals("scanFile")) {
//                     String filePath = call.argument("filePath");
//                     scanMedia(filePath);
//                     result.success(null);
//                 } else {
//                     result.notImplemented();
//                 }
//             });
//     }

//     private void scanMedia(String filePath) {
//         MediaScannerConnection.scanFile(
//             getApplicationContext(),
//             new String[]{filePath},
//             null,
//             (path, uri) -> System.out.println("Scanned " + path + " -> URI: " + uri)
//         );
//     }
// }
