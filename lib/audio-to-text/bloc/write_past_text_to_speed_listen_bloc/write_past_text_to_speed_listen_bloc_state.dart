// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_const_literals_to_create_immutables

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/audio-to-text/model/country_model.dart';

class TextToSpeechState extends Equatable {
  final List<String> openedPdfs;
  String text;
  final Duration originalAudioDuration;
  final Duration currentPosition;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final double speechRate;
  final int currentWordIndex;
  List<Duration> wordTimings;
  final List<Language> availableLanguages;
  final Language selectedLanguage;
  final String selectedCountry;
  final List<String> countryHistory;
  final bool isLanguageSelectOn;
  final bool ToggleSubCategory;
  String selectLang;
  String selectCountriesCode;
  final double setPitch;
  final double setValume;
  final List<String> languageHistory;
  final int textSize;
  final GlobalKey? highlightedWordKey;
  final int lastPausedWordIndex;
  final List<GlobalKey> wordKeys;
  final bool isUserScrolling;
  final int currentChunkIndex;
  String countryFlat;
  String languageCode;
  String countryCode;
  final String selectedFont;
  final String savedFilePath;
  final ThemeData themeData;
  final bool isChangeColor;
  final String summarizedText;
  final bool isPermissionGranted;
  final bool isDownloading;
  final String? downloadedFilePath;
  final bool isSwitchedToHideShowPlayer;
  String editText;

 final int totalScheduledTime; // Total time scheduled in seconds
  final int totalPlayedTime;
  TextToSpeechState({
    required this.openedPdfs,
    required this.wordKeys,
    this.highlightedWordKey,
    required this.text,
    required this.originalAudioDuration,
    required this.currentPosition,
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    required this.speechRate,
    required this.currentWordIndex,
    required this.wordTimings,
    required this.availableLanguages,
    required this.selectedLanguage,
    required this.selectedCountry,
    required this.languageHistory,
    required this.countryHistory,
    required this.isLanguageSelectOn,
    required this.ToggleSubCategory,
    required this.selectLang,
    required this.setPitch,
    required this.setValume,
    required this.textSize,
    required this.lastPausedWordIndex,
    required this.selectCountriesCode,
    required this.isUserScrolling,
    required this.currentChunkIndex,
    required this.countryFlat,
    required this.languageCode,
    required this.countryCode,
    required this.selectedFont,
    required this.savedFilePath,
    this.isDownloading = false,
    this.isChangeColor = false,
    required this.themeData,
    this.isPermissionGranted = false,
    this.isSwitchedToHideShowPlayer = false,
    this.downloadedFilePath,
    this.summarizedText = '',
    this.editText = '',
     required this.totalScheduledTime,
    required this.totalPlayedTime,
  });

  factory TextToSpeechState.initial() {
    return TextToSpeechState(
        openedPdfs: [],
        wordKeys: [],
        highlightedWordKey: null,
        text: '',
        originalAudioDuration: Duration.zero,
        currentPosition: Duration.zero,
        isPlaying: false,
        isPaused: false,
        isLoading: false,
        speechRate: 0.5,
        currentWordIndex: 0,
        wordTimings: [],
        availableLanguages: defaultLanguages,
        selectedLanguage: defaultLanguages.first,
        selectedCountry: '',
        languageHistory: [],
        countryHistory: [],
        isLanguageSelectOn: false,
        ToggleSubCategory: false,
        selectLang: "",
        setPitch: 0.5,
        setValume: 0.5,
        textSize: 16,
        lastPausedWordIndex: 0,
        currentChunkIndex: 0,
        isUserScrolling: false,
        countryFlat: '',
        selectCountriesCode: '',
        languageCode: '',
        countryCode: '',
        selectedFont: 'AvenirNextLTPro',
        savedFilePath: "",
        downloadedFilePath: "",
        summarizedText: "",
        editText: "",
        isDownloading: false,
        isChangeColor: false,
        isPermissionGranted: false,
        isSwitchedToHideShowPlayer: false,
         totalScheduledTime: 0,
      totalPlayedTime: 0,
        themeData: ThemeData.light());
  }

  TextToSpeechState copyWith({
    List<String>? openedPdfs,
    List<GlobalKey>? wordKeys,
    GlobalKey? highlightedWordKey,
    String? text,
    Duration? originalAudioDuration,
    Duration? currentPosition,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    double? speechRate,
    int? currentWordIndex,
    List<Duration>? wordTimings,
    List<Language>? availableLanguages,
    Language? selectedLanguage,
    String? selectedCountry,
    List<String>? languageHistory,
    List<String>? countryHistory,
    bool? isLanguageSelectOn,
    bool? ToggleSubCategory,
    String? selectLang,
    double? setPitch,
    double? setValume,
    String? selectCountriesCode,
    int? textSize,
    int? lastPausedWordIndex,
    int? currentChunkIndex,
    bool? isUserScrolling,
    String? countryFlat,
    String? languageCode,
    String? countryCode,
    String? selectedFont,
    String? savedFilePath,
    bool? isDownloading,
    bool? isChangeColor,
    ThemeData? themeData,
    bool? isPermissionGranted,
    bool? isSwitchedToHideShowPlayer,
    String? downloadedFilePath,
    String? summarizedText,
    String? editText,
     int? totalScheduledTime,
    int? totalPlayedTime,
  }) {
    return TextToSpeechState(
      openedPdfs: openedPdfs ?? this.openedPdfs,
      wordKeys: wordKeys ?? this.wordKeys,
      highlightedWordKey: highlightedWordKey ?? this.highlightedWordKey,
      text: text ?? this.text,
      originalAudioDuration:
          originalAudioDuration ?? this.originalAudioDuration,
      currentPosition: currentPosition ?? this.currentPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      speechRate: speechRate ?? this.speechRate,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      wordTimings: wordTimings ?? this.wordTimings,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      languageHistory: languageHistory ?? this.languageHistory,
      countryHistory: countryHistory ?? this.countryHistory,
      isLanguageSelectOn: isLanguageSelectOn ?? this.isLanguageSelectOn,
      ToggleSubCategory: ToggleSubCategory ?? this.ToggleSubCategory,
      selectLang: selectLang ?? this.selectLang,
      setPitch: setPitch ?? this.setPitch,
      setValume: setValume ?? this.setValume,
      textSize: textSize ?? this.textSize,
      lastPausedWordIndex: lastPausedWordIndex ?? this.lastPausedWordIndex,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      selectCountriesCode: selectCountriesCode ?? this.selectCountriesCode,
      isUserScrolling: isUserScrolling ?? this.isUserScrolling,
      countryFlat: countryFlat ?? this.countryFlat,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      selectedFont: selectedFont ?? this.selectedFont,
      savedFilePath: savedFilePath ?? this.savedFilePath,
      isDownloading: isDownloading ?? this.isDownloading,
      themeData: themeData ?? this.themeData,
      isChangeColor: isChangeColor ?? this.isChangeColor,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      summarizedText: summarizedText ?? this.summarizedText,
      editText: editText ?? this.editText,
      isSwitchedToHideShowPlayer:
          isSwitchedToHideShowPlayer ?? this.isSwitchedToHideShowPlayer,
           totalScheduledTime: totalScheduledTime ?? this.totalScheduledTime,
      totalPlayedTime: totalPlayedTime ?? this.totalPlayedTime,
    );
  }

  @override
  List<Object?> get props => [
        openedPdfs,
        wordKeys,
        highlightedWordKey,
        text,
        originalAudioDuration,
        currentPosition,
        isPlaying,
        isPaused,
        isLoading,
        speechRate,
        currentWordIndex,
        wordTimings,
        availableLanguages,
        selectedLanguage,
        selectedCountry,
        countryHistory,
        isLanguageSelectOn,
        ToggleSubCategory,
        selectLang,
        selectCountriesCode,
        setPitch,
        setValume,
        languageHistory,
        textSize,
        isUserScrolling,
        currentChunkIndex,
        countryFlat,
        selectedFont,
        savedFilePath,
        isDownloading,
        themeData,
        isChangeColor,
        isPermissionGranted,
        isSwitchedToHideShowPlayer,
        editText
      ];
}
