import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunicationSkillScreen extends StatefulWidget {
  const CommunicationSkillScreen({super.key});

  @override
  State<CommunicationSkillScreen> createState() =>
      _CommunicationSkillScreenState();
}

class _CommunicationSkillScreenState extends State<CommunicationSkillScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _inputContent = "Tap the mic and start speaking your response...";

  final String _apiKey = "AIzaSyBqMRMfWZnBbYRibuclb7oI-y8wPupqlVU";

  String _aiFeedback = "";
  int _score = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Coach")),
      body: Center(child: Text(_inputContent)),
    );
  }
}

// 🤖 AI Feedback Logic
Future<void> _getAIFeedback() async {
  if (_inputContent.isEmpty || _inputContent.contains("Tap the mic")) return;

  setState(() {
    _isLoading = true;
    _aiFeedback = "";
  });

  try {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

    final prompt = """
      You are a communication coach. Analyze this speech: "$_inputContent"
      Provide the following:
      1. Score: (A number from 1 to 10)
      2. Feedback: (A 2-sentence encouraging analysis)
      3. Better Version: (How to say it more professionally)
      """;

    final response = await model.generateContent([Content.text(prompt)]);
    final feedbackText = response.text ?? "AI could not generate feedback.";

    final scoreRegExp = RegExp(r'Score:\s*(\d+)');
    final match = scoreRegExp.firstMatch(feedbackText);
    int detectedScore = int.tryParse(match?.group(1) ?? "7") ?? 7;

    setState(() {
      _aiFeedback = feedbackText;
      _score = detectedScore;
    });

    await _saveProgressToFirebase(feedbackText, detectedScore);
  } catch (e) {
    setState(() => _aiFeedback = "Error connecting to AI: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}
