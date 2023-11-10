import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const CharacterWidget(), // Full background character image
            Column(
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Stretch the column across the screen width
              children: [
                const SizedBox(height: 16), // Add some spacing at the top
                FittedBox(
                  // Ensures the text fits within the available space
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'John ',
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'the ',
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Chef',
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(), // Pushes all children towards the ends
                GoExploreButton(), // 'Go Explore!' button
                StatsWidget(), // Stats widget
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class CharacterStatsWidget extends StatelessWidget {
  const CharacterStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Use min to wrap content in the column
      children: [
        // Wrap StatsWidget with a container that has a semi-transparent background
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Semi-transparent black
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: const StatsWidget(),
        ),
      ],
    );
  }
}

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget now acts as a full background
    return Positioned.fill(
      child: Image.asset(
        'assets/character.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock level and experience percentage
    const int level = 5;
    const double experience = 0.75; // 75% towards the next level
    const int xpNeeded = 100; // Mock value for XP needed for the next level
    final int xpRemaining = ((1 - experience) * xpNeeded).toInt(); // Calculate remaining XP

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level and XP remaining row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lvl $level', // Level display
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '$xpRemaining XP to next lvl', // XP remaining for next level
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4), // Spacing between text and bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // Fully rounded corners
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[800], // Background color of the bar
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: experience, // Fraction of the bar filled with experience
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.orange[700]!, // Start color of the gradient
                            Colors.orange[900]!, // End color of the gradient
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String maxValue;
  final Color color;

  const StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.maxValue,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              width: 50,
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 50 * (int.parse(value) / int.parse(maxValue)),
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GoExploreButton extends StatelessWidget {
  const GoExploreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 50.0, vertical: 20.0), // Add margin around the button
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 4), // changes position of shadow
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[700]!, // Top-left color
              Colors.orange[900]!, // Bottom-right color
            ],
          ),
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        child: ElevatedButton(
          onPressed: () {
            // Action when button is pressed
            Navigator.pushNamed(context, '/explore');
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent, // Text color
            shadowColor: Colors.transparent, // Remove shadow from button itself
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'GO EXPLORE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
