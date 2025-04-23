// ignore_for_file: prefer_const_constructors_in_immutables, unused_element, unused_local_variable, unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_state.dart';
import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
import 'package:new_wall_paper_app/audio-to-text/page/show-history.dart';
import 'package:new_wall_paper_app/utils/app-color.dart';
import 'package:new_wall_paper_app/utils/app-icon.dart';
import 'package:new_wall_paper_app/widget/common-text.dart';
import 'package:new_wall_paper_app/widget/common_bottomsheet.dart';

import 'package:new_wall_paper_app/widget/height-widget.dart';
import 'package:new_wall_paper_app/widget/sqlite-helper.dart';
import 'package:new_wall_paper_app/widget/time_duration_formate.dart';

class WriteAndTextPage extends StatefulWidget {
  final String? text;
  final bool isText;

  WriteAndTextPage({Key? key, this.text, required this.isText})
      : super(key: key);

  @override
  State<WriteAndTextPage> createState() => _WriteAndTextPageState();
}

class _WriteAndTextPageState extends State<WriteAndTextPage> {
  late TextEditingController _controller;
  Timer? _debounce;

  late ScrollController _scrollController;

  List<GlobalKey> _wordKeys = [];
  String textfieldText = '';

  void _initializeWordKeys(String text) {
    _wordKeys = text.split(' ').map((_) => GlobalKey()).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    context.read<TextToSpeechBloc>().add(Stop());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.text ?? '');
    _scrollController = ScrollController();
    if (widget.text != null) {
      context.read<TextToSpeechBloc>().add(InitializeWordKeys(widget.text!));
    }
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        textfieldText = value;
        context.read<TextToSpeechBloc>().add(InitializeWordKeys(value));
      });
      context.read<TextToSpeechBloc>().add(TextChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TextToSpeechBloc, TextToSpeechState>(
      listener: (context, state) {
        if (state.downloadedFilePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Audio saved to ${state.downloadedFilePath}')),
          );
        }

        if (state.isDownloading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloading...')),
          );
        }
      },
      child: BlocConsumer<TextToSpeechBloc, TextToSpeechState>(
        listener: (context, state) {
          if (state.isPlaying && state.wordKeys.isNotEmpty) {
            context
                .read<TextToSpeechBloc>()
                .scrollToHighlightedWord(context, state.currentWordIndex);
          }
        },
        builder: (context, state) {
          if (widget.text != null && widget.text!.isNotEmpty) {
            context.read<TextToSpeechBloc>().add(TextChanged(widget.text!));
          }
          final totalWords = state.text.split(' ').length;
          final wordsRead = state.currentWordIndex;
          final wordsRemaining = totalWords - wordsRead;
          final currentWordPosition = state.currentWordIndex + 1;
          final progress = totalWords > 0
              ? (currentWordPosition / totalWords).clamp(0.0, 1.0)
              : 0.0;
          return GestureDetector(
            onTap: () {
              context.read<TextToSpeechBloc>().add(ScreenTouched());
            },
            child: WillPopScope(
              onWillPop: () async {
                context.read<TextToSpeechBloc>().add(Reset());

                return true;
              },
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: state.themeData,
                home: Scaffold(
                  appBar: AppBar(
                    backgroundColor: const Color(0xffEEF2FD),
                    elevation: 0,
                    title: const Text(
                      'Text to Speech',
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      /*
                      ElevatedButton(
                        onPressed: () {
                          var da =
                              "Ensure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the evenEnsure the text is correctly passed from the UI when dispatching the even";
                          if (state.text.isNotEmpty) {
                            context
                                .read<TextToSpeechBloc>()
                                .add(DownloadAudio(da));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter some text')),
                            );
                          }
                        },
                        child: state.isDownloading
                            ? CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(' Save'),
                      ),
                     */
                    
                      IconButton(
                        onPressed: () {
                         Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OpenedPdfsPage()));
                        
                        },
                        icon: SvgPicture.asset("assets/icons/sound.svg"),
                      ),   IconButton(
                        onPressed: () {
                         Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OpenedPdfsPage()));
                        
                        },
                        icon: SvgPicture.asset("assets/icons/history.svg"),
                      ), IconButton(
                        onPressed: () {
                        //  Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => OpenedPdfsPage()));
                             VoiceBottomSheetWidget.show(context);
                        },
                        icon: SvgPicture.asset("assets/icons/bx_file.svg"),
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     VoiceBottomSheetWidget.show(context);
                      //       // FontSelectionBottomSheetWidget.show(context);
                      //   },
                      //   icon: const Icon(
                      //     Icons.volume_down,
                      //     color: Colors.black,
                      //   ),
                      // ),
                     
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          textfieldText == ""
                              ? widget.isText
                                  ? TextField(
                                      maxLines: null,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        wordSpacing: 1.2,
                                        color: Colors.black54,
                                      ),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        border: InputBorder.none,
                                        hintText: "Enter something ....",
                                      ),
                                      onChanged: _onTextChanged,
                                    )
                                  :
                                  //                         HighlightedText(
                                  //   text: state.text,
                                  //   currentWordIndex: state.currentWordIndex,
                                  //   fontSize: 18.0,
                                  // )

                                  state.summarizedText.isNotEmpty
                                      ?
                                      
                                      // summerize text
                                      RichText(
                                          text: TextSpan(
                                            children: context
                                                .read<TextToSpeechBloc>()
                                                .buildHighlightedTextSpans(
                                                  context: context,
                                                  text: state.summarizedText,
                                                  currentWordIndex:
                                                      state.currentWordIndex,
                                                ),
                                          ),
                                        )
                                      :
                                      // any docs or pdf text
                                      RichText(
                                          text: TextSpan(
                                            children: context
                                                .read<TextToSpeechBloc>()
                                                .buildHighlightedTextSpans(
                                                  context: context,
                                                  text:
                                                      state.editText.isNotEmpty
                                                          ? state.editText
                                                          : state.text,
                                                  currentWordIndex:
                                                      state.currentWordIndex,
                                                ),
                                          ),
                                        )
                              // type text
                              : RichText(
                                  text: TextSpan(
                                    children: context
                                        .read<TextToSpeechBloc>()
                                        .buildHighlightedTextSpans(
                                          context: context,
                                          text: state.editText.isNotEmpty
                                              ? state.editText
                                              : state.text,
                                          currentWordIndex:
                                              state.currentWordIndex,
                                        ),
                                  ),
                                ),

                          //                     : HighlightedText(
                          //   text: state.text,
                          //   currentWordIndex: state.currentWordIndex,
                          //   fontSize: 18.0,
                          // ),
                          const SizedBox(height: 20),
                          if (state.isLoading && state.isPlaying)
                            const CircularProgressIndicator(),

                          /*
                          if (textfieldText.isEmpty && widget.isText)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: _controller,
                                maxLines: null,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.02,
                                  wordSpacing: 1.2,
                                  color: Colors.black54,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height * 0.02,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "Enter something....",
                                ),
                                onChanged: _onTextChanged,
                              ),
                            )
                          else if (state.text.isNotEmpty && state.wordKeys.isNotEmpty)
                            context
                                .read<TextToSpeechBloc>()
                                .buildHighlightedTextSpans(
                                  context,
                                  state.text,
                                  state.currentWordIndex,
                                ),
              */
                          if (state.isLoading && state.isPlaying)
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: state.isSwitchedToHideShowPlayer
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                           SliderTheme(
                            
  data: SliderTheme.of(context).copyWith(
    activeTrackColor: AppColor.primaryColor2,
    inactiveTrackColor: AppColor.primaryColor2, 
    trackHeight: 4.0, 
    thumbColor: AppColor.primaryColor2, 
    thumbShape: const RoundSliderThumbShape(
      
      enabledThumbRadius: 10.0, 
      elevation: 4.0, 
    ),
    overlayColor:AppColor.primaryColor2, 
    overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0), 
  ),
  child: Slider(
    
    value: state.currentPosition.inMilliseconds
        .toDouble()
        .clamp(
          0.0,
          state.originalAudioDuration.inMilliseconds.toDouble(),
        ),
    min: 0,
    max: state.originalAudioDuration.inMilliseconds.toDouble(),
    onChanged: (double value) {
      final newPosition = Duration(milliseconds: value.toInt());
      context.read<TextToSpeechBloc>().add(SeekTo(newPosition));
    },
  ),
),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.04),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDuration(state.currentPosition),
                                    style: TextStyle(
                                        color: state.isChangeColor
                                            ? Colors.white
                                            : Colors.grey),
                                  ),
                                  // count word
                                  /*
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(Colors.blue),
                                            strokeWidth: 8,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$currentWordPosition',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'of $totalWords',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: state.isChangeColor
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  */

                                  Text(
                                    formatDuration(state.originalAudioDuration),
                                    style: TextStyle(
                                        color: state.isChangeColor
                                            ? Colors.white
                                            : Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: SvgPicture.asset(AppImage.skipback),
                                  onPressed: () => context
                                      .read<TextToSpeechBloc>()
                                      .add(
                                          SeekBy(const Duration(seconds: -10))),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.035,
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  child: IconButton(
                                    icon: state.isPlaying
                                        ? Icon(
                                            Icons.pause_circle,
                                            color: state.isChangeColor
                                                ? Colors.white
                                                : AppColor.primaryColor2,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                          )
                                        : Icon(
                                            Icons.play_circle_fill,
                                            color: state.isChangeColor
                                                ? Colors.white
                                                : AppColor.primaryColor2,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                          ),
                                    onPressed: () async {
                                      if (state.isPlaying) {
                                        context
                                            .read<TextToSpeechBloc>()
                                            .add(Pause());
                                      } else if (state.isPaused) {
                                        // udpate sqlite data
                                        final document = Document(
                                          name: "",
                                          pdfContent: state.editText.isNotEmpty
                                              ? state.editText
                                              : state.text,
                                          description:
                                              DateTime.now().toIso8601String(),
                                          contentType: "DOCX",
                                        );

                                        final dbHelper = DatabaseHelper();
                                        await dbHelper.insertDocument(document);
                                        context.read<TextToSpeechBloc>().add(
                                            Speak(
                                                startFrom:
                                                    state.currentPosition));
                                      } else {
                                        context
                                            .read<TextToSpeechBloc>()
                                            .add(Speak());
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: SvgPicture.asset(AppImage.skipforward),
                                  onPressed: () => context
                                      .read<TextToSpeechBloc>()
                                      .add(SeekBy(const Duration(seconds: 10))),
                                ),
                              ],
                            ),
                            height(size: 0.02),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right:10,  bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: InkWell(
                                        onTap: () {
                                          context
                                              .read<TextToSpeechBloc>()
                                              .showLanguageSelectionBottomSheet(
                                                  context);
                                         },
                                        child: Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            Container(
                                              
                                              child: CircleAvatar(
                                                // radius: MediaQuery.of(context).size.height * 0.03,
                                                backgroundImage:
                                                   state.countryFlat.isEmpty?const NetworkImage("https://images.pexels.com/photos/15652226/pexels-photo-15652226/free-photo-of-the-national-flag-of-united-states.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"): NetworkImage(state.countryFlat),
                                              ),
                                            ),
                                            Positioned(
                                              right: -20,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.black,
                                                size: MediaQuery.of(context).size.height * 0.05,
                                              ),
                                        
                                            ),
                                          ],
                                        )),
                                  ),
                                
                                
                                  Row(
                                    children: [
                                      SvgPicture.asset(AppImage.speedWatch),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      CommonText(
                                          title: "Speed ",
                                          color: Colors.grey,
                                          size: 0.017),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<double>(
                                          
                                          icon: Container(),
                                          style: TextStyle(
                                              color: state.isChangeColor
                                                  ? Colors.white
                                                  : Colors.grey),
                                          value: state.speechRate,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 0.5, child: Text("0.5x")),
                                            DropdownMenuItem(
                                                value: 1.0, child: Text("1x")),
                                            DropdownMenuItem(
                                                value: 1.5, child: Text("1.5x")),
                                            DropdownMenuItem(
                                                value: 2.0, child: Text("2x")),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              context
                                                  .read<TextToSpeechBloc>()
                                                  .add(ChangeSpeechRate(value));
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                              
                              
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////
class DropdownWithTap extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double?> onChanged;

  const DropdownWithTap({
    required this.initialValue,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _DropdownWithTapState createState() => _DropdownWithTapState();
}

class _DropdownWithTapState extends State<DropdownWithTap> {
  late GlobalKey _dropdownKey;
  late double _selectedValue;

  @override
  void initState() {
    super.initState();
    _dropdownKey = GlobalKey();
    _selectedValue = widget.initialValue;
  }

  void _openDropdown() {
    GestureDetector? gesture = _dropdownKey.currentContext?.findAncestorWidgetOfExactType<GestureDetector>();
    if (gesture != null) {
      gesture.onTap!(); // Trigger the dropdown open event
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDropdown, // Handle row tap to open dropdown
      child: Row(
        children: [
          SvgPicture.asset(AppImage.speedWatch),
          const SizedBox(width: 4),
          CommonText(
            title: "Speed ",
            color: Colors.black,
            size: 0.017,
          ),
          DropdownButton<double>(
            key: _dropdownKey, // Assign the key to the dropdown
            value: _selectedValue,
            style: TextStyle(color: Colors.black),
            items: const [
              DropdownMenuItem(value: 0.5, child: Text("0.5x")),
              DropdownMenuItem(value: 1.0, child: Text("1x")),
              DropdownMenuItem(value: 1.5, child: Text("1.5x")),
              DropdownMenuItem(value: 2.0, child: Text("2x")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedValue = value;
                });
                widget.onChanged(value); // Notify parent widget
              }
            },
          ),
        ],
      ),
    );
  }
}
