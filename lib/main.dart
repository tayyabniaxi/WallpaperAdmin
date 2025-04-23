// // // ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/bottom-nav-bloc/bottom-nav-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/docsReader-bloc/docs-reader-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/gDrive-bloc/gDrive-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/imageReader-bloc/imgReader-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/link_reader_bloc/link_reader_bloc.dart';
// import 'package:new_wall_paper_app/audio-to-text/bloc/link_reader_bloc/bloc/link_reader_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/pdf-to-text-bloc/pdf-to-text-bloc-class.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/readEmail-message/read_email_message_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/bottom-nav.dart/bottom-nav-page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ImageReaderBloc>(
          create: (context) => ImageReaderBloc(),
        ),
        BlocProvider<DocsReaderBloc>(
          create: (context) => DocsReaderBloc(),
        ),
        BlocProvider<HomePageBloc>(
          create: (context) => HomePageBloc(),
        ),
        BlocProvider<LinkReaderBloc>(
          create: (context) => LinkReaderBloc(),
        ),
        BlocProvider<PDFReaderBloc>(
          create: (context) => PDFReaderBloc(),
        ),
        BlocProvider<GmailBloc>(
          create: (context) => GmailBloc(),
        ),
        BlocProvider<BottomNavigationBloc>(
          create: (context) => BottomNavigationBloc(),
        ),
        BlocProvider<TextToSpeechBloc>(
          create: (context) => TextToSpeechBloc(),
        ),
        BlocProvider<DriveBloc>(
          create: (context) => DriveBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Text To Voice',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: SpeechToTextScreen(),
        // home: HomeScreen(),
        home: BottomNavigationPage(),
        // home: TextToSpeechScreen(),
      ),
    );
  }
}


// summerize text
/*
class TextToSpeechScreen extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Summarization')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        context
                            .read<TextToSpeechBloc>()
                            .add(SummarizeText(text));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please enter some text to summarize'),
                          ),
                        );
                      }
                    },
                    child: const Text('Summarize'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
                builder: (context, state) {
                  if (state.summarizedText.isNotEmpty) {
                    return Text(
                      'Summarized Text:\n${state.summarizedText}',
                      style: const TextStyle(fontSize: 16),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Speech Demo',
      home: const TextToSpeechToFile(),
    );
  }
}

class TextToSpeechToFile extends StatefulWidget {
  const TextToSpeechToFile({Key? key}) : super(key: key);

  @override
  _TextToSpeechToFileState createState() => _TextToSpeechToFileState();
}

class _TextToSpeechToFileState extends State<TextToSpeechToFile> {
  final TextEditingController _textController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  bool isProcessing = false;

  Future<void> _convertAndSaveAudio() async {
    String text = _textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Request storage permission
      if (!await _requestPermission()) {
        setState(() {
          isProcessing = false;
        });
        return;
      }

      // Create folder in public storage
      Directory directory = Directory('/storage/emulated/0/QaiserF');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Generate audio file path
      String filePath = '${directory.path}/converted_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      // Convert text to speech and save directly to the file
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);

      // Save file using synthesizeToFile
      await _flutterTts.synthesizeToFile(text, filePath);

      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio saved to $filePath')),
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

Future<bool> _requestPermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted) {
      return true;
    }

    if (await Permission.storage.request().isGranted) {
      return true;
    }

    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // For Android 11+ (MANAGE_EXTERNAL_STORAGE)
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }

    if (await Permission.storage.isPermanentlyDenied ||
        await Permission.manageExternalStorage.isPermanentlyDenied) {
      // Redirect to app settings if permanently denied
      bool openSettings = await _showPermissionDialog(
        context,
        'Storage permission is required to save audio files. Open settings to enable it.',
        'Open Settings',
      );
      if (openSettings) {
        await openAppSettings();
      }
    }
  }
  return false;
}
Future<bool> _showPermissionDialog(BuildContext context, String message, String buttonText) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Speech to File'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _convertAndSaveAudio,
                    child: const Text('Convert and Save'),
                  ),
          ],
        ),
      ),
    );
  }
}


*/
