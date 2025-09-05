import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'health_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore.collection('profiles').doc(user!.uid).get();
      setState(() {
        userProfile = snapshot.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
      ),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${userProfile!['fullName'] ?? ''}'),
            SizedBox(height: 10),
            Text('Date de naissance: ${userProfile!['birthDate'] ?? ''}'),
            SizedBox(height: 10),
            Text('Maladies chroniques: ${userProfile!['chronicIllness'] ?? 'Aucune'}'),
            SizedBox(height: 10),
            Text('Groupe sanguin: ${userProfile!['bloodType'] ?? ''}'),
            SizedBox(height: 10),
            Text('Gender: ${userProfile!['gender'] ?? ''}'),
            SizedBox(height: 10),
            Text('Height: ${userProfile!['height'] ?? ''}'),
            SizedBox(height: 10),
            Text('Weight: ${userProfile!['weight'] ?? ''}'),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Navigation vers la page pour modifier le profil
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthProfileScreen()),
                );
              },
              child: Text('Modifier le Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
