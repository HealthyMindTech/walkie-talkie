import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CustomButton extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.children,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSound();
  }

  Future<void> _loadSound() async {
    try {
      await _audioPlayer.setAsset('assets/tap.mp3');
      // Set a flag here to indicate the sound is ready
    } catch (e) {
      debugPrint('Error loading sound: $e');
      // Optionally reinitialize the AudioPlayer here
    }
  }

  Future<void> _playSound() async {
    if (_audioPlayer.playing) {
      await _audioPlayer
          .stop(); // Ensure the player is stopped before playing again
    }
    try {
      await _audioPlayer.play(); // Play the loaded sound
    } catch (e) {
      debugPrint('Error playing sound: $e');
      // Handle the error, possibly reinitialize the AudioPlayer
    }
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    setState(() {
      _isPressed = true;
    });
    await _audioPlayer.seek(const Duration()); // Restart the sound
    await _playSound(); // Play sound on button press
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  void dispose() {
    // Release the AudioPlayer resources
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async => await _onTapDown(details),
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPressed
                ? const [
                    Color(0xFFfc8c3e),
                    Color(0xFFf8c85c),
                  ]
                : const [
                    Color(0xFFf8c85c),
                    Color(0xFFfc8c3e),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4.0,
                  ),
                ],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color(0xFFae3d0b),
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.children,
        ),
      ),
    );
  }
}
