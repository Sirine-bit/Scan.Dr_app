import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // API Hugging Face (gratuite avec création de compte)
  static const String token = '';
  static const String endpoint = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2';
  
  static List<Map<String, String>> conversationHistory = [
    {"role": "system", "content": "You are a medical assistant who helps patients understand their medical analyses. Provide concise, accurate information and explain medical terms in simple language."}
  ];

  static Future<String> sendMessage(String message) async {
    try {
      // Préparer le format de conversation pour Hugging Face
      String conversationText = "";
      for (var msg in conversationHistory) {
        if (msg["role"] == "system") {
          conversationText += "<s>[INST] ${msg["content"]} [/INST]</s>\n";
        } else if (msg["role"] == "user") {
          conversationText += "<s>[INST] ${msg["content"]} [/INST]</s>\n";
        } else if (msg["role"] == "assistant") {
          conversationText += "<s>${msg["content"]}</s>\n";
        }
      }
      
      // Ajouter le nouveau message
      conversationText += "<s>[INST] $message [/INST]</s>";
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "inputs": conversationText,
          "parameters": {
            "max_new_tokens": 500,
            "temperature": 0.7,
            "return_full_text": false
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data[0]["generated_text"];
        
        // Ajouter à l'historique
        conversationHistory.add({"role": "user", "content": message});
        conversationHistory.add({"role": "assistant", "content": reply.trim()});
        
        return reply.trim();
      } else {
        print('API error: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        if (response.statusCode == 401) {
          return 'Erreur d\'authentification. Veuillez vérifier la clé API.';
        } else if (response.statusCode == 429) {
          return 'Limite de requêtes atteinte. Veuillez réessayer plus tard.';
        } else {
          return 'Erreur de communication avec le chatbot (${response.statusCode}).';
        }
      }
    } catch (e) {
      print('Exception during API call: $e');
      return 'Erreur de réseau. Veuillez vérifier votre connexion internet.';
    }
  }
  
  static void resetConversation() {
    conversationHistory = [
      {"role": "system", "content": "You are a medical assistant who helps patients understand their medical analyses. Provide concise, accurate information and explain medical terms in simple language."}
    ];
  }
}