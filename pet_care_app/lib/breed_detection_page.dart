import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_v2/tflite_v2.dart';
import 'nutritional_tips_page.dart';
import 'disease_checker_page.dart';
import 'reminder_page.dart'; // Import the new reminder page

class BreedDetectionPage extends StatefulWidget {
  @override
  _BreedDetectionPageState createState() => _BreedDetectionPageState();
}

class _BreedDetectionPageState extends State<BreedDetectionPage> {
  File? _image;
  List? _output;
  final picker = ImagePicker();
  String? _selectedPet;
  bool _loading = false;
  final TextEditingController _breedController = TextEditingController();

  Future<void> classifyImage(File image) async {
    setState(() {
      _loading = true;
    });

    var output = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 12,
      threshold: 0.2,
      asynch: true,
    );

    setState(() {
      _loading = false;
      _output = output;
      if (_output != null && _output!.isNotEmpty) {
        _breedController.text = _output![0]['label'];
      }
    });
  }

  Future<void> loadModel(String modelPath, String labelPath) async {
    await Tflite.loadModel(
      model: modelPath,
      labels: labelPath,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });

    classifyImage(_image!);
  }

  Future<void> _detectBreed() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.pets),
              title: Text('Dog'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPet = 'Dog';
                });
                loadModel('assets/model_2.tflite', 'assets/label_2.txt')
                    .then((_) {
                  _showImageSourceSelection();
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.pets),
              title: Text('Cat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPet = 'Cat';
                });
                loadModel('assets/model_1.tflite', 'assets/label_1.txt')
                    .then((_) {
                  _showImageSourceSelection();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    Tflite.close();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PawPal Care',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.orange.shade200,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade200, Colors.orange.shade500],
          ),
        ),
        child: Center(
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: [
              _image != null
                  ? Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _image!,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _output != null
                            ? Text(
                                'Breed: ${_output![0]['label']}',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600),
                              )
                            : Container(),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            cursorColor: Colors.grey.shade800,
                            controller: _breedController,
                            decoration: InputDecoration(
                              labelText: 'Enter or correct breed',
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade800),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade800),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade800),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: 25,
              ),
              ElevatedButton(
                onPressed: _detectBreed,
                child: Text(
                  'Detect Breed',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_output != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NutritionalTipsPage(
                          breed: _breedController.text.isNotEmpty
                              ? _breedController.text
                              : _output![0]['label'],
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.orange.shade100,
                        title: Text('Breed not detected'),
                        titleTextStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                        content: Text('Please detect a breed first.'),
                        contentTextStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade800),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  'Get Nutritional Tips',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_output != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseaseChecker(
                          breed: _breedController.text.isNotEmpty
                              ? _breedController.text
                              : _output![0]['label'],
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.orange.shade100,
                        title: Text('Breed not detected'),
                        titleTextStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                        content: Text('Please detect a breed first.'),
                        contentTextStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade800),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  'Disease Checker',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 13,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReminderPage(),
                    ),
                  );
                },
                child: Text(
                  'Vet Reminder',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 13,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
