import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void signIn() async {
    await Supabase.instance.client.auth.signInWithOAuth(Provider.google,
        redirectTo: AppConfig.loginRedirect,
        authScreenLaunchMode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              'Welcome to Walkie Talkie',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: 250.0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    signIn();
                  },
                  child: const Text("Sign in with Google"),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
