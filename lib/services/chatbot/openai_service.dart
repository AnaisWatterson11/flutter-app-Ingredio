import 'dart:convert';

import 'package:flutter_application_1/services/chatbot/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();

/*class OpenAIService {
  final List<Map<String, String>> messages = [];

Future<String> isArtPromptAPI(String prompt) async {
  try {
    print('🗣️ Message vocal reçu : $prompt');

    final res = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1:free",
        "messages": [
          {
            'role': 'user',
            'content':
                'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
          }
        ],
      }),
    );

    print('🧠 Réponse API brute : ${utf8.decode(res.bodyBytes)}');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      String content = decoded['choices'][0]['message']['content'];
      content = content.trim();

      switch (content.toLowerCase().replaceAll('.', '')) {
        case 'yes':
          final res = await dallEAPI(prompt);
          return res;
        default:
          final res = await chatGPTAPI(prompt);
          return res;
      }
    }

    return 'An internal error occurred';
  } catch (e) {
    print('❌ Erreur : $e');
    return e.toString();
  }
}


 Future<String> chatGPTAPI(String prompt) async {
  messages.add({
    'role': 'user',
    'content': prompt,
  });
  try {
    final res = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1:free",
        "messages": messages,
      }),
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      String content = decoded['choices'][0]['message']['content'];
      content = content.trim();

      messages.add({
        'role': 'assistant',
        'content': content,
      });
      return content;
    }
    return 'An internal error occurred';
  } catch (e) {
    return e.toString();
  }
}

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}*/

class OpenAIService {
  final List<Map<String, String>> messages = [];

  // Fonction pour nettoyer le texte des caractères indésirables
  String nettoyerMessage(String content) {
    // Remplacer les caractères spéciaux comme #, ##, *, etc.
    content = content.replaceAll(RegExp(r'[#\*]{2,}'), ''); // Retirer #, ##, *
    return content;
  }

  /*Future<String> isArtPromptAPI(String prompt) async {
    try {
      print('🗣️ Message vocal reçu : $prompt');
      
      // S'assurer que l'encodage est correct
      String encodedPrompt = utf8.encode(prompt).toString();

      final res = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'), 
        //Uri.parse('https://openrouter.ai/api/v1'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          //"model": "deepseek/deepseek-r1:free",
          //"model": "deepseek/deepseek-v3-base:free",
          "model": "google/gemini-2.0-flash-exp:free",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $encodedPrompt . Simply answer with a yes or no.',
            }
          ],
        }),
      );

      print('🧠 Réponse API brute : ${utf8.decode(res.bodyBytes)}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        String content = decoded['choices'][0]['message']['content'];
        content = content.trim();

        // Nettoyer le texte
        content = nettoyerMessage(content);

        switch (content.toLowerCase().replaceAll('.', '')) {
          case 'yes':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }

      return 'Une erreur interne est survenue';  // Message en français
    } catch (e) {
      print('❌ Erreur : $e');
      return 'Erreur: ${e.toString()}';  // Message d'erreur en français
    }
  }*/

Future<String> isArtPromptAPI(String prompt) async {
  try {
    print('🗣️ Message vocal reçu : $prompt');

    final res = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: jsonEncode({
        "model": "google/gemini-2.0-flash-exp:free",
        "messages": [
          {
            'role': 'user',
            'content':
                'Does this message want to generate an AI picture, image, art or anything similar? "$prompt". Simply answer with a yes or no.',
          }
        ],
      }),
    );

    final responseBody = utf8.decode(res.bodyBytes);
    print('🧠 Réponse API brute : $responseBody');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      String content = decoded['choices'][0]['message']['content'] ?? '';
      content = content.trim();

      // Nettoyer le texte
      content = nettoyerMessage(content);

      print("🧪 Réponse filtrée : $content");

      final answer = content.toLowerCase().replaceAll('.', '');
      if (answer == 'yes') {
        final res = await dallEAPI(prompt);
        return res;
      } else if (answer == 'no') {
        final res = await chatGPTAPI(prompt);
        return res;
      } else {
        return 'Réponse inattendue de l’API : $content';
      }
    }

    return 'Une erreur interne est survenue';
  } catch (e) {
    print('❌ Erreur : $e');
    return 'Erreur: ${e.toString()}';
  }
}


/*
  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        //Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          //"model": "deepseek/deepseek-r1:free",
          "model": "google/gemini-2.0-flash-exp:free",
          //"model": "deepseek/deepseek-v3-base:free",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        String content = decoded['choices'][0]['message']['content'];
        content = content.trim();

        // Nettoyer le texte
        content = nettoyerMessage(content);

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'Une erreur interne est survenue';  // Message en français
    } catch (e) {
      return 'Erreur: ${e.toString()}';  // Message d'erreur en français
    }
  }*/


  Future<String> chatGPTAPI(String prompt) async {
  messages.add({
    'role': 'user',
    'content': prompt,
  });

  try {
    final res = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: jsonEncode({
        "model": "google/gemini-2.0-flash-exp:free",
        "messages": messages,
      }),
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      String content = decoded['choices'][0]['message']['content'];
      content = nettoyerMessage(content);

      messages.add({
        'role': 'assistant',
        'content': content,
      });

      // Text-to-Speech
      await flutterTts.setLanguage("fr-FR");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(content);

      return content;
    }

    return 'Une erreur interne est survenue';
  } catch (e) {
    return 'Erreur: ${e.toString()}';
  }
}


  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'Une erreur interne est survenue';  // Message en français
    } catch (e) {
      return 'Erreur: ${e.toString()}';  // Message d'erreur en français
    }
  }
}

/*
class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
  try {
    String correctedPrompt = prompt.trim();
    
    print('🗣️ Message vocal reçu : $correctedPrompt');
    
    if (correctedPrompt.isEmpty || correctedPrompt.length < 5) {
      return 'La phrase semble incomplète. Pouvez-vous répéter ?';
    }

    final res = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1:free",
        "messages": [
          {
            'role': 'user',
            'content': "Ce message veut-il générer une image, une œuvre d’art ou quelque chose de similaire ? $correctedPrompt. Répondez simplement par oui ou non.",
          }
        ],
      }),
    );

    print('🧠 Réponse API brute : ${res.body}');

    if (res.statusCode == 200) {
      // Proper UTF-8 decoding
      // Au lieu de juste utf8.decode, essayez de décoder la réponse proprement
      final decoded = jsonDecode(utf8.decode(res.bodyBytes, allowMalformed: true));
      String content = decoded['choices'][0]['message']['content'];
      content = content.trim();


      print('🧠 Réponse traitée : $content');

      // Handle both image and text responses
      if (content.toLowerCase() == 'oui') {
        final imageResponse = await dallEAPI(correctedPrompt);
        return imageResponse;
      } else if (content.toLowerCase() == 'non') {
        // Detect that this is a recipe request
        if (correctedPrompt.toLowerCase().contains("recette") || correctedPrompt.toLowerCase().contains("couscous")) {
          return "Bien sûr ! Voici une recette de couscous :\n\n1. Préparez la semoule de couscous.\n2. Faites cuire la viande et les légumes.\n3. Mélangez et servez.";
        } else {
          return "Il semble que vous demandez quelque chose qui ne concerne pas une image. Pouvez-vous clarifier votre demande ?";
        }
      } else {
        return "Désolé, je n'ai pas compris la demande.";
      }
    } else if (res.statusCode == 429) {
      return 'Limite de requêtes atteinte. Veuillez réessayer plus tard.';
    } else {
      return 'Une erreur interne est survenue';
    }
  } catch (e) {
    print('❌ Erreur : $e');
    return 'Une erreur est survenue : ${e.toString()}';
  }
}

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'Une erreur interne est survenue';
    } catch (e) {
      return e.toString();
    }
  }
}*/