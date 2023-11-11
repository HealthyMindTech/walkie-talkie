import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CustomButton extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.children,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
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
    // Pre-load the sound file (replace with your asset)
    await _audioPlayer.setSource(AssetSource('tap.mp3'));
  }

  void _playSound() async {
    await _audioPlayer.resume(); // Play the loaded sound
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _playSound(); // Play sound on button press
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
      onTapDown: _onTapDown,
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
                ? [
                    Color(0xFFfc8c3e),
                    Color(0xFFf8c85c),
                  ]
                : [
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
