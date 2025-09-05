import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MainScreen.dart';

class HealthProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? savedProfileData;

  const HealthProfileScreen({Key? key, this.savedProfileData}) : super(key: key);

  @override
  _HealthProfileScreenState createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _gender = 'Male';
  double _height = 0.0;
  double _weight = 0.0;
  String _bloodType = 'A+';
  String? _chronicIllness;
  bool? _hasChronicIllness;
  File? _profileImage;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _initializeProfile();

  }
  Future<void> _initializeProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          _fullName = profileSnapshot['fullName'] ?? '';
          _gender = profileSnapshot['gender'] ?? 'Male';
          _height = profileSnapshot['height'] ?? 0.0;
          _weight = profileSnapshot['weight'] ?? 0.0;
          _bloodType = profileSnapshot['bloodType'] ?? 'A+';
          _chronicIllness = profileSnapshot['chronicIllness'];
          _hasChronicIllness = _chronicIllness != null && _chronicIllness!.isNotEmpty;
          _profileImage = profileSnapshot['profileImage'] != null
              ? File(profileSnapshot['profileImage'])
              : null;
          _birthDate = profileSnapshot['birthDate'] != null
              ? DateTime.parse(profileSnapshot['birthDate'])
              : null;
        });
      }
    }
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _birthDate) {
      setState(() {
        _birthDate = pickedDate;
      });
    }
  }

  Future<void> _saveProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profileData = {
        'fullName': _fullName,
        'gender': _gender,
        'height': _height,
        'weight': _weight,
        'bloodType': _bloodType,
        'chronicIllness': _chronicIllness,
        'profileImage': _profileImage?.path,
        'birthDate': _birthDate?.toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .set(profileData);
    }
  }

  Future<void> _checkIfProfileExists() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/sela.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : AssetImage('assets/default_profile.png') as ImageProvider,
          backgroundColor: Colors.grey.shade200,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.teal),
            onPressed: () {
              _showImagePickerDialog();
            },
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Text(
      'Please fill out your health profile',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.teal,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildTextField(
              label: 'Full Name',
              icon: Icons.person,
              initialValue: _fullName,
              onSaved: (value) => _fullName = value!,
              validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
            ),
            const SizedBox(height: 15),
            _buildGenderField(),
            const SizedBox(height: 15),
            _buildDateOfBirthField(),
            const SizedBox(height: 15),
            _buildTextField(
              label: 'Height (cm)',
              icon: Icons.height,
              initialValue: _height.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _height = double.parse(value!),
              validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Please enter a valid height' : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: 'Weight (kg)',
              icon: Icons.fitness_center,
              initialValue: _weight.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _weight = double.parse(value!),
              validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Please enter a valid weight' : null,
            ),
            const SizedBox(height: 15),
            _buildBloodTypeField(),
            const SizedBox(height: 15),
            _buildChronicIllnessField(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    String? initialValue,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          keyboardType: keyboardType,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.transgender, color: Colors.teal),
        title: DropdownButtonFormField<String>(
          value: _gender,
          decoration: InputDecoration(
            labelText: 'Gender',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onChanged: (value) {
            setState(() {
              _gender = value!;
            });
          },
          items: ['Male', 'Female']
              .map((gender) => DropdownMenuItem(
            child: Text(gender),
            value: gender,
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Colors.teal),
        title: TextFormField(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          controller: TextEditingController(
            text: _birthDate != null ? '${_birthDate!.toLocal()}'.split(' ')[0] : '',
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
      ),
    );
  }

  Widget _buildBloodTypeField() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.bloodtype, color: Colors.teal),
        title: DropdownButtonFormField<String>(
          value: _bloodType,
          decoration: InputDecoration(
            labelText: 'Blood Type',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onChanged: (value) {
            setState(() {
              _bloodType = value!;
            });
          },
          items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
              .map((bloodType) => DropdownMenuItem(
            child: Text(bloodType),
            value: bloodType,
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildChronicIllnessField() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.health_and_safety, color: Colors.teal),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<bool>(
              value: _hasChronicIllness,
              decoration: InputDecoration(
                labelText: 'Do you have any chronic illness?',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _hasChronicIllness = value;
                  if (!value!) {
                    _chronicIllness = null;
                  }
                });
              },
              items: [
                DropdownMenuItem(child: Text('Yes'), value: true),
                DropdownMenuItem(child: Text('No'), value: false),
              ],
            ),
            if (_hasChronicIllness == true)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Specify Chronic Illness (if any)',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  initialValue: _chronicIllness,
                  onChanged: (value) {
                    setState(() {
                      _chronicIllness = value;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          _formKey.currentState?.save();
          _saveProfile().then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          });
        }
      },
      child: const Text('Save Profile'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
