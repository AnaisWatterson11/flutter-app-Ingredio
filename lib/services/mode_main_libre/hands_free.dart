import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechAssistant extends StatefulWidget {
  final List<String> contenu;

  const SpeechAssistant({Key? key, required this.contenu}) : super(key: key);

  @override
  State<SpeechAssistant> createState() => _SpeechAssistantState();
}

class _SpeechAssistantState extends State<SpeechAssistant> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isPaused = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    speech = stt.SpeechToText();
    _initTTS();
    _initSpeech();
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.45);
  }

  Future<void> _initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (val) => print('Status: $val'),
      onError: (val) => print('Error: $val'),
    );
    if (!available) {
      print("Speech not available");
    }
  }

  void _startListening() async {
    if (!isListening) {
      bool available = await speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            _handleCommand(val.recognizedWords.toLowerCase());
          }
        },
      );
      if (available) {
        setState(() {
          isListening = true;
        });
      }
    }
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {
      isListening = false;
    });
  }

  Future<void> _handleCommand(String command) async {
    if (command.contains("lis")) {
      currentIndex = 0;
      await flutterTts.speak("Je commence la lecture.");
      _readCurrent();
    } else if (command.contains("suivant")) {
      _next();
    } else if (command.contains("précédent")) {
      _previous();
    } else if (command.contains("pause")) {
      isPaused = true;
      await flutterTts.stop();
    } else if (command.contains("reprends")) {
      if (isPaused) {
        isPaused = false;
        _readCurrent();
      }
    } else if (command.contains("stop")) {
      await flutterTts.stop();
    }
  }

  Future<void> _readCurrent() async {
    if (currentIndex >= 0 && currentIndex < widget.contenu.length) {
      await flutterTts.speak(widget.contenu[currentIndex]);
    }
  }

  void _next() async {
    if (currentIndex < widget.contenu.length - 1 && !isPaused) {
      currentIndex++;
      await _readCurrent();
    } else {
      await flutterTts.speak("Fin du contenu.");
    }
  }

  void _previous() async {
    if (currentIndex > 0 && !isPaused) {
      currentIndex--;
      await _readCurrent();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isListening ? Icons.mic_off : Icons.mic,
        size: 40,
        color: isListening ? Colors.red : Colors.green,
      ),
      onPressed: () {
        if (isListening) {
          _stopListening();
        } else {
          _startListening();
        }
      },
    );
  }
}
