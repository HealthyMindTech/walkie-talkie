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
      TextEditingController(text: 'John the Chef');
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
                  padding: EdgeInsets.fromLTRB(12, 12, 148, 16),
                  child: ListView(
                    children: [
                      CustomInput(
                        controller: _nameController,
                        label: 'Name',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (value) {
                          // Handle the input submission if needed
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
                    color: Color(0xFFfc8c3e),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(
                      10), // Rounded corners for the container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // Apply the same rounded corners to the clipper
                  child: Image.asset(
                    'assets/character.png',
                    width: MediaQuery.of(context)
                        .size
                        .width, // Force the image to take full width of the screen
                    fit: BoxFit
                        .fitWidth, // Fit the width of the image to the container
                    alignment: Alignment
                        .topCenter, // Align the image to the top of the container
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
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
                  // Navigate to the explore page
                },
              ),
            ),
            SizedBox(height: 16),
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
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.75, // Mock progress value
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange, // Orange progress bar
                    ),
                    minHeight: 10,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '3.2 km walked - 4.1 km to next level',
                    style: TextStyle(
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
          SizedBox(width: 16), // Space between label and text field
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
                fontSize: 18,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 10), // Vertical padding inside the text field
                filled: true,
                fillColor: const Color(0xFFfbfcf4), // Field fill color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFae3d0b), // Border color
                    width: 2,
                  ),
                  borderRadius:
                      BorderRadius.circular(8.0), // Field border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFae3d0b), // Focused border color
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                counterText: "", // Hide character count
              ),
              maxLength: 20, // Limit characters to 20
            ),
          ),
        ],
      ),
    );
  }
}
