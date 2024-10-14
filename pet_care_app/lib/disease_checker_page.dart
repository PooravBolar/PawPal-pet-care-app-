import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class DiseaseChecker extends StatefulWidget {
  final String breed;
  const DiseaseChecker({Key? key, required this.breed}) : super(key: key);

  @override
  _DiseaseCheckerState createState() => _DiseaseCheckerState();
}

class _DiseaseCheckerState extends State<DiseaseChecker> {
  final TextEditingController _symptomsController = TextEditingController();
  String? _diseasePrediction;
  bool _loading = false;

  Future<void> _checkDisease() async {
    setState(() {
      _loading = true;
    });

    try {
      final gemini = Gemini.instance;
      final response = await gemini.text(
          'You are a highly experienced doctor specialized in veterinary medicine. Based on the symptoms of a breed ${widget.breed} provided: "${_symptomsController.text}", please diagnose and suggest probable diseases, along with treatment recommendations and any additional advice for the pet owner. Please be careful of your advice as a wrong advice may cause the life of the pet.');
      setState(() {
        _diseasePrediction = response?.output;
      });
    } catch (e) {
      setState(() {
        _diseasePrediction = 'Error fetching disease prediction: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<Widget> _buildNutritionalTips(String tips) {
    List<String> sections = tips.split('\n\n');
    return sections.map((section) {
      List<String> lines = section.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.startsWith('**')) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                line.replaceAll('**', ''),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            );
          } else if (line.startsWith('*')) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                line.replaceFirst('*', '‣'),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                line,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            );
          }
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disease Checker',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                cursorColor: Colors.grey.shade800,
                controller: _symptomsController,
                decoration: InputDecoration(
                  labelText: 'Enter symptoms',
                  labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade800),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade800),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade800),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkDisease,
                child: Text(
                  'Check Disease',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  backgroundColor: Colors.orange.shade100,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Diagnosing symptoms...",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              _loading
                  ? Container()
                  : _diseasePrediction != null
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  _buildNutritionalTips(_diseasePrediction!),
                            ),
                          ),
                        )
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
