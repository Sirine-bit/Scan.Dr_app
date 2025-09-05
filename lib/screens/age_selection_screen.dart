import 'package:flutter/material.dart';
class AgeSelectionScreen extends StatefulWidget {
  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  double _currentAge = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Age'),
        backgroundColor: Color.fromARGB(255, 100, 191, 251),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade200, Color.fromARGB(255, 198, 162, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select your age',
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                Slider(
                  value: _currentAge,
                  min: 1,
                  max: 150,
                  divisions: 149,
                  label: _currentAge.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentAge = value;
                    });
                  },
                ),
                Text(
                  '${_currentAge.round()}',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  // ignore: unnecessary_null_comparison
                  onPressed: _currentAge != null
                      ? () {
                          Navigator.pushNamed(context, '/chronic_illness');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.lightBlue, backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
