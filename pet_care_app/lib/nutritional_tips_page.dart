import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class NutritionalTipsPage extends StatefulWidget {
  final String breed;

  const NutritionalTipsPage({Key? key, required this.breed}) : super(key: key);

  @override
  _NutritionalTipsPageState createState() => _NutritionalTipsPageState();
}

class _NutritionalTipsPageState extends State<NutritionalTipsPage> {
  String? _nutritionalTips;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchNutritionalTips();
  }

  Future<void> _fetchNutritionalTips() async {
    setState(() {
      _loading = true;
    });

    try {
      final gemini = Gemini.instance;
      final response = await gemini.text(
          "You are a highly experienced veterinary doctor specializing in canine nutrition. The breed of the dog or cat detected is ${widget.breed}. Please provide comprehensive and detailed nutritional tips specifically tailored for this breed, including daily caloric intake, essential nutrients, recommended food types, portion sizes, and any breed-specific dietary considerations or restrictions. Additionally, highlight any common health issues related to diet that this breed may encounter and provide preventive dietary advice. Be very careful and make sure your advice is very accurate as a silly mistake can cause the life of a pet animal.");
      setState(() {
        _nutritionalTips = response?.output;
      });
    } catch (e) {
      setState(() {
        _nutritionalTips = 'Error fetching nutritional tips: $e';
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
                  color: Colors.orange,
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
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
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
      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        title: Text(
          'Nutritional Tips',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade800),
      ),
      body: Container(
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.grey.shade800,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Generating Tips...",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _nutritionalTips != null
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildNutritionalTips(_nutritionalTips!),
                        ),
                      )
                    : Center(
                        child: Text(
                          'No nutritional tips available.',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ),
              ),
      ),
    );
  }
}
