import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final void Function() onEndOfAudio;

  const AudioPlayerWidget({super.key, required this.onEndOfAudio});

  @override
  State<AudioPlayerWidget> createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  static final log = Logger('AudioPlayerWidgetState');
  List<String> urls = [];
  int currentUrlIndex = -1;
  late AudioPlayer audioPlayer;
  bool isPaused = true;
  bool isPlayingChimes = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.playerStateStream.listen(_onAudioPlayerListener);

    // Play chimes initially
    //r_playChimes();
  }

  void startAudio() {
    if (urls.isNotEmpty) {
      currentUrlIndex = 0; // Start from the first file
      _play();
    } else {
      // If no files are present, start chimes or handle accordingly
      _playChimes();
    }
  }


  void _onAudioPlayerListener(PlayerState event) async {
    if (event.processingState == ProcessingState.completed) {
      if (!isPlayingChimes) {
        _playChimes();
      }
    }
  }

  void _playChimes() async {
    isPlayingChimes = true;
    await audioPlayer.setAsset('assets/chimes.mp3');
    await audioPlayer.play();
    debugPrint('Playing chimes');
  }

  void _handleEndOfChimes() {
    // Handle what should happen after chimes have played.
    // For example, move to next file or something else.
  }

  void _nextFile() {
    if (currentUrlIndex < urls.length - 1) {
      currentUrlIndex++;
    }
  }

  void _play() async {
    if (currentUrlIndex == -1 || currentUrlIndex >= urls.length) {
      return;
    }
    isPlayingChimes = false; // Ensure chimes are not considered playing
    await audioPlayer.setUrl(urls[currentUrlIndex]);
    await audioPlayer.play();
  }

  void _playOrPause() async {
    if (isPaused) {
      if (currentUrlIndex == -1) {
        _nextFile();
      }
      _play();
      setState(() {
        isPaused = false;
      });
    } else {
      await audioPlayer.pause();
      setState(() {
        isPaused = true;
      });
    }
  }

  void addUrl(String url) {
    log.info('Adding url: $url');
    urls.add(url);

    // Stop chimes and play the new file immediately
    if (isPlayingChimes) {
      isPlayingChimes = false;
      currentUrlIndex = urls.length - 1; // Set the index to the new file
      _play(); // Play the new file
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Existing player UI
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.black.withOpacity(0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (urls.isNotEmpty)
                IconButton(
                    onPressed: _playOrPause,
                    icon: isPaused
                        ? const Icon(Icons.play_arrow, color: Colors.white)
                        : const Icon(Icons.pause, color: Colors.white)),
              const Text(
                'Audio Player',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
