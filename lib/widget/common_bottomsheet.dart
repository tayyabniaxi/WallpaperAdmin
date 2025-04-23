// ignore_for_file: use_key_in_widget_constructors, camel_case_types, avoid_print, library_private_types_in_public_api, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/write_past_text_to_speed_listen_bloc/write_past_text_to_speed_listen_bloc_state.dart';
import 'package:new_wall_paper_app/audio-to-text/model/country_model.dart';
import 'package:new_wall_paper_app/audio-to-text/page/audio-download-file.dart';
import 'package:new_wall_paper_app/widget/height-widget.dart';

class LanguageSelectionWidget extends StatefulWidget {
  @override
  _LanguageSelectionWidgetState createState() =>
      _LanguageSelectionWidgetState();
}

class _LanguageSelectionWidgetState extends State<LanguageSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
          builder: (context, state) {
            if (state.selectedLanguage != null) {
              return Column(children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TextToSpeechBloc>()
                                  .add(ToggleLanguageOn(state.selectLang));
                              state.ToggleSubCategory
                                  ? context.read<TextToSpeechBloc>().add(
                                      ToggleSubCategory(
                                          state.selectCountriesCode,
                                          state.countryFlat))
                                  : null;
                            },
                            child: const Text('Language'),
                          );
                        },
                      ),
                      Text(
                        'Voice for ${state.selectedLanguage.name}:',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (state.isLanguageSelectOn) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Row(
                        children: defaultLanguages.map((language) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: MaterialButton(
                              color: Colors.grey[200],
                              onPressed: () {
                                context
                                    .read<TextToSpeechBloc>()
                                    .add(SelectLanguage(language));
                                context
                                    .read<TextToSpeechBloc>()
                                    .add(ToggleLanguageOn(state.selectLang));
                                context.read<TextToSpeechBloc>().add(
                                    ToggleSubCategory(state.selectCountriesCode,
                                        state.countryFlat));
                                state.selectLang = language.code;

                                print(
                                    "Qaiser farooq: country code: ${language.code}");
                              },
                              child: Text(language.name),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ]);
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }
}

class SubCategoryWidget extends StatefulWidget {
  @override
  _SubCategoryWidgetState createState() => _SubCategoryWidgetState();
}

class _SubCategoryWidgetState extends State<SubCategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
          builder: (context, state) {
            return Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                scrollDirection: Axis.vertical,
                itemCount: state.selectedLanguage.countries.length,
                itemBuilder: (context, index) {
                  final country = state.selectedLanguage.countries[index];
                  return GestureDetector(
                    onTap: () {
                      state.countryCode = country.code;
                      context
                          .read<TextToSpeechBloc>()
                          .add(SelectCountry(country.code));

                      context.read<TextToSpeechBloc>().add(ToggleSubCategory(
                          state.countryCode, state.countryFlat));
                      Navigator.pop(context);

                      state.countryFlat = country.countryPic;
                      print(
                          "Qaiser farooq: ${state.selectLang} country code: ${state.selectCountriesCode}");
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(country.countryPic),
                      ),
                      title: Text(country.voiceName),
                      subtitle: Text(country.name),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// allcountry list
class allCountryListBottomSheet extends StatelessWidget {
  late ScrollController scrollController;
  allCountryListBottomSheet({required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
      builder: (context, state) {
        return Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: defaultLanguages.length,
            itemBuilder: (context, index) {
              final language = defaultLanguages[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      language.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...language.countries.map((country) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(country.profilePic),
                      ),
                      title: Text(country.voiceName),
                      subtitle: Text(country.name),
                      onTap: () {
                        state.selectLang = language.code;
                        state.countryCode = country.code;
                        state.countryFlat = country.countryPic;
                        print(
                            "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj:${state.countryFlat}");

                        context
                            .read<TextToSpeechBloc>()
                            .add(SelectLanguage(language));
                        context
                            .read<TextToSpeechBloc>()
                            .add(SelectCountry(country.name));

                        context
                            .read<TextToSpeechBloc>()
                            .add(SelectCountry(country.code));
                        context
                            .read<TextToSpeechBloc>()
                            .add(SelectCountryPic(country.countryPic));
                        print(
                            "Qaiser farooq: ${state.selectedLanguage.code}-${state.selectedCountry} country code: ${country.code}");
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// voice pitch volumn change

class VoiceBottomSheetWidget extends StatelessWidget {
  static void show(BuildContext context) {
    // Method to show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content
                children: [
                  Text(
                    "Pitch: ${state.setPitch}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Slider(
                    value: state.setPitch,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      context
                          .read<TextToSpeechBloc>()
                          .add(PitchValueChange(value));
                    },
                  ),
                  height(size: 0.01),
                  Text(
                    "Volume: ${state.setValume}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Slider(
                    value: state.setValume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      context
                          .read<TextToSpeechBloc>()
                          .add(setVolumeValueChange(value));
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(DecreaseTextSize());
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 10),
                      Text("${state.textSize}"),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(IncreaseTextSize());
                        },
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (state.text.isNotEmpty) {
                  //       context
                  //           .read<TextToSpeechBloc>()
                  //           .add(DownloadAudio(state.text));
                  //     }
                  //   },
                  //   child: state.isDownloading
                  //       ? const CircularProgressIndicator(color: Colors.white)
                  //       : const Icon(Icons.download),
                  // ),

                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AudioDownloadFileList()));
                      },
                      child: const Text("Download File List")),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeBackgroundColor(
                                Colors.indigo,
                              ));
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeColorToggle());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(10)),
                          height: 60,
                          width: 60,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeBackgroundColor(
                                Colors.deepOrange,
                              ));
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeColorToggle());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(10)),
                          height: 60,
                          width: 60,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeBackgroundColor(
                                Colors.yellow,
                              ));
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeColorToggle());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(10)),
                          height: 60,
                          width: 60,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeBackgroundColor(
                                Colors.blueAccent,
                              ));
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeColorToggle());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10)),
                          height: 60,
                          width: 60,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeBackgroundColor(Colors.brown));
                          context
                              .read<TextToSpeechBloc>()
                              .add(ChangeColorToggle());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.circular(10)),
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // String text = _textController.text.trim();
                      if (state.text.isNotEmpty) {
                        context
                            .read<TextToSpeechBloc>()
                            .add(SummarizeText(state.text));
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hide Player'),
                      Switch(
                        value: state.isSwitchedToHideShowPlayer,
                        onChanged: (_) {
                          context
                              .read<TextToSpeechBloc>()
                              .add(HideShowPlayerToggle());
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        editTextBottomSheet(context, state);
                      },
                      child: Text("Edit Text")),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<dynamic> editTextBottomSheet(
      BuildContext context, TextToSpeechState state) {
    final TextEditingController textController = TextEditingController();

    // Assign the text value to the controller
    textController.text =
        state.editText.isNotEmpty ? state.editText : state.text;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Text(state.text),
                              ),
                              Divider(
                                color: Colors.red,
                                thickness: 3,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: TextFormField(
                                  controller: textController,
                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("        "),
                    Text("Edit Text"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        state.editText = textController.text;
                        context
                            .read<TextToSpeechBloc>()
                            .add(UpdateText(textController.text));

                        // context.read<TextToSpeechBloc>().add(Reset());
                      },
                      child: Text("Save"),
                    )
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class FontSelectionBottomSheetWidget extends StatelessWidget {
  static void show(BuildContext context) {
    // Method to show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) {
            final fonts = [
              'AvenirNextLTPro',
              'DejaVuSerCondensed',
              'OpenDyslexicAlta',
              'Roboto',
              'Roboto'
            ];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content
                children: [
                  const Text(
                    'Select Font',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: fonts.length,
                      itemBuilder: (context, index) {
                        final fontName = fonts[index];
                        return ListTile(
                          title: Text(
                            fontName,
                            style: TextStyle(fontFamily: fontName),
                          ),
                          onTap: () {
                            context
                                .read<TextToSpeechBloc>()
                                .add(SelectFont(fontName));
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
