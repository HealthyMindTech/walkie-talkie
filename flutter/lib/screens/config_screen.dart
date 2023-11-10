import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  String userTheme = "fantasy";

  @override
  void initState() {
    super.initState();
    _getThemeFromDatabase(Supabase.instance.client.auth.currentUser!.id);
  }

  void _getThemeFromDatabase(String userId) async {
    final userProfile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (userProfile != null) {
      final theme = userProfile['theme'];
      setState(() {
        userTheme = theme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: const Text('Select a theme for the story'),
            trailing: DropdownButton<String>(
              value: userTheme,
              onChanged: (String? newValue) async {
                await Supabase.instance.client.from('profiles').upsert({
                  'id': Supabase.instance.client.auth.currentUser!.id,
                  'theme': newValue,
                });
                setState(() {
                  userTheme = newValue!;
                });
              },
              items: <String>[
                'fantasy',
                'sci-fi',
                'pirates',
                'western',
                'cute animals'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
