import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'package:stroke_text/stroke_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'John the Muffin Man');
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    // Always remember to dispose of the controllers when the widget is removed from the widget tree.
    _nameController.dispose();
    _classController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Corrected code inside the build method of _HomePageState
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromRGBO(36, 58, 47, 1), // Dark green background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              // This should wrap the ListView
              child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: ListView(
                    children: [
                      CustomInput(
                        controller: _nameController,
                        label: 'Name',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) {
                          },
                      ),
                    ],
                  )),
            ),
            Expanded(
              flex: 4, // Adjust the flex factor as needed
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16), // Horizontal margin
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFfc8c3e),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8), // Apply the same rounded corners to the clipper
                  child: Image.asset('assets/background.png',
                    width: MediaQuery.of(context).size.width, // Force the image to take full width of the screen
                    fit: BoxFit.fitHeight, // Fit the width of the image to the container
                    // alignment: Alignment
                    //     .topCenter, // Align the image to the top of the container
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              // Center aligned
              alignment: Alignment.center,
              child: CustomButton(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10.0),
                    child: StrokeText(
                      text: "Go Explore!",
                      textStyle: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      // strokeColor: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                ],
                onPressed: () {
                  Navigator.pushNamed(context, '/explore', arguments: {
                      'name': _nameController.text,
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.75, // Mock progress value
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.orange, // Orange progress bar
                    ),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3.2 km walked - 4.1 km to next level',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
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

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  const CustomInput({
    Key? key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical padding
      child: Row(
        children: [
          Expanded(
            flex:
                1, // Adjust the ratio of label width to text field width as needed
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white, // Label color
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          // SizedBox(width: 16), // Space between label and text field
          Expanded(
            flex: 5, // Increase the flex of text field to give it more space
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onFieldSubmitted: onFieldSubmitted,
              style: const TextStyle(
                color: Colors.black, // Text color
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 10), // Vertical padding inside the text field
                filled: true,
                fillColor: const Color(0xFFfbfcf4), // Field fill color
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFae3d0b), // Border color
                    width: 2,
                  ),
                  borderRadius:
                      BorderRadius.circular(8.0), // Field border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFae3d0b), // Focused border color
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                counterText: "", // Hide character count
              ),
              maxLength: 25, // Limit characters to 20
            ),
          ),
          const SizedBox(width: 16), // Space between label and text field
          CustomButton(
              children: const [Icon(Icons.casino, color: Colors.white, size: 32)],
              onPressed: () {
                controller.text = getRandomNameProfession();
              })
        ],
      ),
    );
  }
}

List<String> names = [
  'Aeliana',
  'Braden',
  'Caius',
  'Delilah',
  'Emeric',
  'Freya',
  'Gavriel',
  'Hester',
  'Idris',
  'Jovita',
  'Kael',
  'Lysandra',
  'Myron',
  'Nyx',
  'Orion',
  'Persephone',
  'Quinlan',
  'Rhea',
  'Soren',
  'Thalia',
  'Ulysses',
  'Vesper',
  'Wynter',
  'Xanthe',
  'Yara',
  'Zephyr',
];

List<String> fantasyClasses = [
  'Paladin',
  'Sorcerer',
  'Druid',
  'Necromancer',
  'Bard',
  'Ranger',
  'Monk',
  'Alchemist',
  'Illusionist',
  'Enchanter',
];

List<String> realLifeProfessions = [
  'Engineer',
  'Scientist',
  'Architect',
  'Teacher',
  'Chef',
  'Muffin Man',
  'Artist',
  'Nurse',
  'Farmer',
  'Pilot',
  'Detective',
];

List<String> sciFiOptions = [
  'Cyborg',
  'Android Mechanic',
  'Starship Captain',
  'Quantum Physicist',
  'Holo-programmer',
  'Terraformer',
  'Alien Anthropologist',
  'Laser Surgeon',
  'Galactic Trader',
  'Warp Drive Engineer',
];

// Utility function to get a random element from a list
T getRandomElement<T>(List<T> list) {
  final random = Random();
  var i = random.nextInt(list.length);
  return list[i];
}

// Function to generate a random name with profession
String getRandomNameProfession() {
  String name = getRandomElement(names);
  // Combine lists of professions
  List<String> professions = []
    ..addAll(fantasyClasses)
    ..addAll(realLifeProfessions)
    ..addAll(sciFiOptions);
  String profession = getRandomElement(professions);

  return '$name the $profession';
}
