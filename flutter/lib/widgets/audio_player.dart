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
  }

  void startAudio() async {
    setState(() {
      isPaused = false;
    });

    if (urls.isNotEmpty && currentUrlIndex == -1) {
      currentUrlIndex = urls.length - 1;
      await audioPlayer.setUrl(urls[currentUrlIndex]);
      await audioPlayer.play();
    } else {
      _playChimes();
    }
  }

  void _onAudioPlayerListener(PlayerState event) async {
    if (event.processingState == ProcessingState.completed) {
      log.info("Got event: $event");

      if (!isPlayingChimes) {
        widget.onEndOfAudio();
      }
      _playChimes();
    }
  }

  void _playChimes() async {
    isPlayingChimes = true;
    await audioPlayer.setAsset('assets/chimes.mp3');
    await audioPlayer.play();
    debugPrint('Playing chimes');
  }

  void _playOrPause() async {
    if (isPaused) {
      await audioPlayer.play();

      isPaused = false;
      setState(() {});
    } else {
      await audioPlayer.pause();
      isPaused = true;
      setState(() {});
    }
  }

  void addUrl(String url) async {
    log.info('Adding url: $url');
    urls.add(url);

    // Stop chimes and play the new file immediately
    isPlayingChimes = false;
    if (!isPaused) {
      currentUrlIndex = urls.length - 1; // Set the index to the new file
      await audioPlayer.setUrl(urls[currentUrlIndex]);
      await audioPlayer.play();
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
              if (urls.isEmpty) ...[
                // Spinner
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Generating,",
                        style: TextStyle(color: Colors.white)),
                    Text("prlease wait... ",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ))
              ] else
                IconButton(
                    onPressed: _playOrPause,
                    icon: isPaused
                        ? const Icon(Icons.play_arrow, color: Colors.white)
                        : const Icon(Icons.pause, color: Colors.white)),
              const Text(
                'Audio Player',
                style: TextStyle(color: Colors.white),
              ),
              // IconButton(
              //   onPressed: () {
              //     _playChimes();
              //     widget.onEndOfAudio();
              //   },
              //   icon: const Icon(Icons.forward, color: Colors.white),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
