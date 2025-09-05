import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 50,
        ),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Hello User!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              DateFormat.yMMMMEEEEd().format(DateTime.now()),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome back, I hope you are well.',
              style: TextStyle(fontSize: 20, color: Colors.blueGrey),
            ),
            const Text(
              'How can I help you?',
              style: TextStyle(fontSize: 20, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),

            // Latest Results
            const SectionHeader(title: 'Latest Results'),
            const SizedBox(height: 10),
            const ResultCard(
              title: 'Glucose',
              value: '90 mg/dL',
            ),
            const SizedBox(height: 10),
            const ResultCard(
              title: 'Blood Pressure',
              value: '120/80 mmHg',
            ),
            const SizedBox(height: 20),

            // Card Carousel
            const SectionHeader(title: 'Services'),
            const SizedBox(height: 10),
            CardCarousel(),
          ],
        ),
      ),
    );
  }
}

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }
}

// Result Card Widget
class ResultCard extends StatelessWidget {
  final String title;
  final String value;

  const ResultCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue.shade100,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blueGrey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card Carousel Widget
class CardCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselCard(
          title: 'Diagnostic',
          description: 'Get a diagnosis based on your symptoms.',
          emoji: '🩺',
          onTap: () {
            // Logique pour le diagnostic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigate to Diagnostic')),
            );
          },
        ),
        const SizedBox(height: 20),
        CarouselCard(
          title: 'Tests',
          description: 'Access various medical tests.',
          emoji: '🧪',
          onTap: () {
            // Logique pour les tests
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigate to Tests')),
            );
          },
        ),
      ],
    );
  }
}

// Carousel Card Widget
class CarouselCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final VoidCallback onTap;

  const CarouselCard({
    required this.title,
    required this.description,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue.shade100,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}