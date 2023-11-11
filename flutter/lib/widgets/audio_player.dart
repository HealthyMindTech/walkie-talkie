import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logging/logging.dart';
import '../widgets/custom_button.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  static final log = Logger('AudioPlayerWidgetState');
  List<String> urls = [];
  int currentUrlIndex = -1;
  late AudioPlayer audioPlayer;
  bool isPaused = true;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    if (urls.isNotEmpty) {
      _playNextFile();
    }
  }

  void _playNextFile() {
    if (currentUrlIndex < urls.length - 1) {
      currentUrlIndex++;
      _play();
    }
  }

  void _play() {
    audioPlayer.play(UrlSource(urls[currentUrlIndex]));
  }

  void addUrl(String url) {
    log.info('Adding url: $url');
    urls.add(url);
    if (currentUrlIndex == -1) {
      _playNextFile();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white),
            const Text(
              'Audio Player',
              style: TextStyle(color: Colors.white),
            ),
            CustomButton(
              children: [
                Text(
                  'Pause',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
              onPressed: () {
                // Your button press action
              },
            ),
            const Icon(Icons.stop, color: Colors.white),
          ],
        ));
  }
}
