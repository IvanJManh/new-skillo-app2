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
