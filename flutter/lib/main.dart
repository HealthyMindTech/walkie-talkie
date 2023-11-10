import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:logging/logging.dart';

import 'config.dart';
import 'screens/explore_page.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/social_page.dart';

final log = Logger('main');

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  setPathUrlStrategy();

  await Supabase.initialize(
      url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonkey);

  runApp(const MyApp());
}

Widget ensureLoggedIn({required Widget child}) {
  if (Supabase.instance.client.auth.currentUser == null) {
    return const LoginPage();
  } else {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walkie Talkie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => ensureLoggedIn(child: const HomePage()),
        '/explore': (context) =>
            ensureLoggedIn(child: const ExplorePage(title: 'Walkie Talkie')),
        '/adventure': (context) => ensureLoggedIn(child: const HomePage()),
        '/config': (context) => ensureLoggedIn(child: const ProfilePage()),
        '/social': (context) => ensureLoggedIn(child: const SocialPage()),
      },
    );
  }
}
