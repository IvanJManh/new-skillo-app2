import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // 🎤 Microphone Logic
  Future<void> _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(onResult: (result) {
            setState(() {
              _inputContent = result.recognizedWords;
              if (result.finalResult) _isListening = false;
            });
          });
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
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
      final prompt =
          "Coach analysis for: '$_inputContent'. Provide Score: X/10 and feedback.";
      final response = await model.generateContent([Content.text(prompt)]);

      final feedbackText = response.text ?? "AI error.";
      final scoreMatch = RegExp(r'(\d+)/10').firstMatch(feedbackText);
      int detectedScore = int.tryParse(scoreMatch?.group(1) ?? "7") ?? 7;

      setState(() {
        _aiFeedback = feedbackText;
        _score = detectedScore;
      });
      await _saveProgressToFirebase(feedbackText, detectedScore);
    } catch (e) {
      setState(() => _aiFeedback = "Connection error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ☁️ Firebase Logic
  Future<void> _saveProgressToFirebase(String feedback, int score) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'skillType': 'Communication',
        'content': _inputContent,
        'aiFeedback': feedback,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firebase Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("AI Coach",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Improve your speaking skills",
                style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.blueGrey)),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5)
                  ]),
              child: Text(_inputContent),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _listen,
                  backgroundColor:
                      _isListening ? Colors.red : Colors.blueAccent,
                  child: Icon(_isListening ? Icons.stop : Icons.mic),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _getAIFeedback,
                  child: Text(_isLoading ? "Analyzing..." : "GET FEEDBACK"),
                ),
              ],
            ),
            if (_aiFeedback.isNotEmpty) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(color: Colors.blueAccent.withOpacity(0.2))),
                child: Column(
                  children: [
                    Text("Coach Analysis",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text(_aiFeedback),
                    const SizedBox(height: 10),
                    Text("Score: $_score/10",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
