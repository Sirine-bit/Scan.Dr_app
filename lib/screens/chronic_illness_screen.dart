import 'package:flutter/material.dart';

class ChronicIllnessScreen extends StatefulWidget {
  @override
  _ChronicIllnessScreenState createState() => _ChronicIllnessScreenState();
}

class _ChronicIllnessScreenState extends State<ChronicIllnessScreen> {
  String? chronicIllness;
  bool? hasChronicIllness;
  GlobalKey _dropdownKey = GlobalKey();

  List<String> illnesses = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'Kidney Disease',
    'Other'
  ];

  void _navigateToNextPage() {
    if (hasChronicIllness != null) {
      Navigator.pushNamed(context, '/health_profile');
    }
  }

  void _showOtherIllnessDialog() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your illness'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Type your illness here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  chronicIllness = _controller.text;
                });
                Navigator.of(context).pop();
                _navigateToNextPage();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chronic Illness'),
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
                  'Do you have a chronic illness?',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hasChronicIllness = true;
                          chronicIllness = null;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final dynamic dropdown = _dropdownKey.currentState;
                          dropdown?.openDropdown();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.lightBlue, backgroundColor: hasChronicIllness == true ? Color.fromARGB(255, 255, 246, 161) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'YES',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hasChronicIllness = false;
                          chronicIllness = null;
                        });
                        _navigateToNextPage();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.lightBlue, backgroundColor: hasChronicIllness == false ? Color.fromARGB(255, 255, 246, 161) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'NO',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                if (hasChronicIllness == true) ...[
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    key: _dropdownKey,
                    value: chronicIllness,
                    hint: Text('Select Illness', style: TextStyle(color: Colors.white)),
                    dropdownColor: Colors.lightBlue,
                    items: illnesses.map((String illness) {
                      return DropdownMenuItem<String>(
                        value: illness,
                        child: Text(illness, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        chronicIllness = newValue;
                        if (newValue == 'Other') {
                          _showOtherIllnessDialog();
                        } else {
                          _navigateToNextPage();
                        }
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
