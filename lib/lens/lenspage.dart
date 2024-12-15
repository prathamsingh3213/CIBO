import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class LensPage extends StatefulWidget {
  const LensPage({super.key});

  @override
  LensPageState createState() => LensPageState();
}

class LensPageState extends State<LensPage> {
  File? _image;
  List<dynamic> _recommendedDishes = []; // Changed to dynamic to handle JSON
  bool _isLoading = false; // To show loading indicator
  String _errorMessage = ''; // To display error messages

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true; // Start loading
        _errorMessage = ''; // Clear any previous error message
      });

      _sendImageToBackend(_image!);
    }
  }

  Future<void> _sendImageToBackend(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Replace with your actual backend API endpoint
      var url = Uri.parse('http://192.168.0.197:5000/clarifai_recognition');
      var response = await http.post(
        url,
        body: json.encode({'image': base64Image}),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _isLoading = false; // Stop loading
      });

      if (response.statusCode == 200) {
        setState(() {
          _recommendedDishes = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Error fetching recommendations';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading
        _errorMessage = 'An error occurred';
      });
      debugPrint("Error sending image to backend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Food Item Recognition"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading indicator
            : _image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 100,
                        onPressed: _getImage,
                        icon: const Icon(Icons.photo_library),
                      ),
                      const Text(
                        "Select an Image",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage) // Show error message
                    : Column(
                        children: [
                          Image.file(_image!),
                          const SizedBox(height: 20),
                          const Text(
                            "Recommended dishes:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _recommendedDishes.length,
                              itemBuilder: (context, index) {
                                // Assuming each dish is a map with a 'name' key
                                return ListTile(
                                  title:
                                      Text(_recommendedDishes[index]['name']),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
