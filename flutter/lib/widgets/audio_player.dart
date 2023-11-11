import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({super.key});

  @override
  State<AudioPlayer> createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioPlayer> {
  List<String> urls = [];
  int currentUrlIndex = -1;

  void addUrl(String url) {
    setState(() {
      urls.add(url);
      if (currentUrlIndex == -1) {
        currentUrlIndex = 0;
      }
    });
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
