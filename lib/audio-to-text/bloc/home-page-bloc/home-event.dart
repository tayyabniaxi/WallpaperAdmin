abstract class HomePageEvent {}

class LoadItemsEvent extends HomePageEvent {}

class SliderValueChange extends HomePageEvent {
  final double value;
  SliderValueChange(this.value);
}
 
class InitializeSpeech extends HomePageEvent {}
class PlayAudioEvent extends HomePageEvent {}
class PauseAudioEvent extends HomePageEvent {}

class SeekAudioEvent extends HomePageEvent {
  final Duration position;
  SeekAudioEvent(this.position);
}

class ChangeSpeedEvent extends HomePageEvent {
  final double speed;
  ChangeSpeedEvent(this.speed);
}

class AudioDurationLoaded extends HomePageEvent {
  final Duration duration;
  AudioDurationLoaded(this.duration);
}

class UpdateTranscription extends HomePageEvent {
  final String transcription;
  UpdateTranscription(this.transcription);
}

// New Event for Country Selection
class ChangeCountryEvent extends HomePageEvent {
  final String country;
  ChangeCountryEvent(this.country);
}
