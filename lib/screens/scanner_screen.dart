import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
void main() {
  runApp(MaterialApp(home: ScannerScreen()));
}
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _image;
  String? _analysisResult;
  bool _isLoading = false;
  bool _isAnalysisComplete = false;
  
  // Base de données médicale locale
  final Map<String, List<String>> _medicalConditionsDatabase = {
    "anémie": ["fatigue", "pâleur", "essoufflement", "hémoglobine basse", "fer bas"],
    "diabète": ["glycémie élevée", "soif", "miction fréquente", "glucose", "HbA1c élevée"],
    "hypothyroïdie": ["tsh élevée", "t4 basse", "fatigue", "prise de poids", "frilosité"],
    "hyperthyroïdie": ["tsh basse", "t4 élevée", "perte de poids", "nervosité", "tachycardie"],
    "cholestérol élevé": ["ldl élevé", "cholestérol total élevé", "triglycérides"],
    "infection urinaire": ["leucocytes", "nitrites", "bactéries", "sang dans les urines"],
    // Ajoutez d'autres conditions selon vos besoins
  };

  // Liste de termes médicaux pour la reconnaissance
  final Map<String, String> _medicalTerms = {
    "hémoglobine": "Protéine des globules rouges qui transporte l'oxygène",
    "leucocytes": "Globules blancs, cellules du système immunitaire",
    "glycémie": "Taux de glucose (sucre) dans le sang",
    "cholestérol": "Lipide sanguin, existe en forme HDL (bon) et LDL (mauvais)",
    "créatinine": "Déchet musculaire filtré par les reins",
    "tsh": "Hormone stimulant la thyroïde",
    // Ajoutez d'autres termes selon vos besoins
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _analysisResult = null;
          _isLoading = true;
          _isAnalysisComplete = false;
        });
        await _analyzeImage(_image!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _analysisResult = "Erreur: Impossible de charger l'image. ${e.toString()}";
      });
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    try {
      setState(() {
        _analysisResult = "Extraction du texte en cours...";
      });

      // Utiliser ML Kit pour la reconnaissance de texte
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Libérer les ressources après utilisation
      textRecognizer.close();
      
      // Extraire le texte reconnu
      String extractedText = recognizedText.text;
      
      if (extractedText.isEmpty) {
        setState(() {
          _isLoading = false;
          _analysisResult = "Aucun texte détecté dans l'image. Veuillez réessayer avec une image plus claire.";
        });
        return;
      }

      await _interpretResult(extractedText);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _analysisResult = "Erreur lors de l'analyse: ${e.toString()}";
      });
    }
  }

  Future<void> _interpretResult(String extractedText) async {
    setState(() {
      _analysisResult = "Texte extrait :\n$extractedText\n\nAnalyse des entités en cours...";
    });

    try {
      // Analyse locale des termes médicaux
      final medicalEntities = _analyzeTextLocally(extractedText);
      
      // Analyse locale des conditions potentielles
      final medicalConditions = _analyzeConditionsLocally(extractedText);

      // Mise à jour des résultats
      setState(() {
        _analysisResult = "Texte extrait :\n$extractedText\n\n" +
                        "🔍 Termes médicaux détectés:\n$medicalEntities\n\n" +
                        "🩺 Conditions potentielles:\n$medicalConditions";
        _isLoading = false;
        _isAnalysisComplete = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _analysisResult = "${_analysisResult ?? ''}\n\nErreur lors de l'analyse: ${e.toString()}";
      });
    }
  }

  // Méthodes d'analyse locale (identiques à celles dans la version précédente)
  String _analyzeTextLocally(String text) {
    final lowerText = text.toLowerCase();
    List<String> foundTerms = [];

    _medicalTerms.forEach((term, description) {
      if (lowerText.contains(term.toLowerCase())) {
        foundTerms.add("📌 $term: $description");
      }
    });

    if (foundTerms.isEmpty) {
      return "Aucun terme médical reconnu.";
    }

    return foundTerms.join("\n");
  }

  String _analyzeConditionsLocally(String text) {
    final lowerText = text.toLowerCase();
    Map<String, int> conditionScores = {};
    
    _medicalConditionsDatabase.forEach((condition, symptoms) {
      int score = 0;
      
      for (String symptom in symptoms) {
        if (lowerText.contains(symptom.toLowerCase())) {
          score += 1;
        }
      }
      
      if (score > 0) {
        conditionScores[condition] = score;
      }
    });
    
    var sortedConditions = conditionScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedConditions.isEmpty) {
      return "Aucune condition médicale reconnue avec les termes présents.";
    }
    
    final topConditions = sortedConditions.take(3).toList();
    
    return topConditions.map((entry) {
      final condition = entry.key;
      final matchCount = entry.value;
      final totalSymptoms = _medicalConditionsDatabase[condition]!.length;
      final percentage = (matchCount / totalSymptoms * 100).toStringAsFixed(0);
      
      final matchedSymptoms = _medicalConditionsDatabase[condition]!
          .where((symptom) => lowerText.contains(symptom.toLowerCase()))
          .toList();
          
      return "🦠 $condition (correspondance: $percentage%)\n" +
            "📝 Éléments identifiés: ${matchedSymptoms.join(', ')}";
    }).join("\n\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Analyse Médicale', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Scanner une analyse médicale',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prenez une photo claire de vos résultats d\'analyse pour obtenir une interprétation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Appareil photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galerie'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (_image != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.contain,
                            height: 250,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _isLoading
                              ? Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  _analysisResult ?? 'Analyse en cours...',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )
                              : _analysisResult != null
                              ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Résultats de l\'analyse:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _analysisResult!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                if (_isAnalysisComplete) ...[
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _image = null;
                        _analysisResult = null;
                        _isAnalysisComplete = false;
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Nouvelle analyse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
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