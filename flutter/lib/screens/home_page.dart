import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CharacterWidget(), // This will be the full background
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Align children to both ends
              children: [
                Spacer(flex: 1), // Takes all available space
                GoExploreButton(), // 'Go Explore!' button with margin
                StatsWidget(), // Stats widget at the bottom
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(), // Bottom navigation bar
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

// ... Other widget classes remain unchanged ...

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(
                  icon: Icons.favorite,
                  value: '38',
                  maxValue: '100',
                  color: Colors.red,
                ),
                StatItem(
                  icon: Icons.flash_on,
                  value: '30',
                  maxValue: '100',
                  color: Colors.yellow,
                ),
                StatItem(
                  icon: Icons.local_dining,
                  value: '55',
                  maxValue: '100',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
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
