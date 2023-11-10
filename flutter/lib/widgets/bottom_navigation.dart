import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BottomNavigationBar for navigation
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.amber[800],
      onTap: (value) {
        // Handle navigation
        switch (value) {
          case 0:
            Navigator.pushNamed(context, '/adventure');
            break;
          case 1:
            Navigator.pushNamed(context, '/social');
            break;
          case 2:
            Navigator.pushNamed(context, '/config');
            break;
        }
      },
    );
  }
}
