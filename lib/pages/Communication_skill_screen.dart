import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // SECURE TIP: Ensure this key is valid and active in Google AI Studio
  final String _apiKey = "AIzaSyBqMRMfWZnBbYRibuclb7oI-y8wPupqlVU";

  String _aiFeedback = "";
  int _score = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // 🎤 Speech Recognition Logic
  Future<void> _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(onResult: (result) {
            setState(() => _inputContent = result.recognizedWords);
          });
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // 🤖 AI Feedback + Firebase Integration
  Future<void> _getAIFeedback() async {
    if (_inputContent.isEmpty || _inputContent.contains("Tap the mic")) return;

    setState(() {
      _isLoading = true;
      _aiFeedback = "";
    });

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

      final prompt = """
      You are a communication coach. Analyze this user speech: "$_inputContent"
      Provide:
      1. Score (numerical 1-10 only)
      2. Key Feedback (short and encouraging)
      3. Improved Version (how to say it better)
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      final feedbackText = response.text ?? "Try again!";

      // Logic to extract score (simplification for the assignment)
      int detectedScore = feedbackText.contains("10") ? 10 : 7;

      setState(() {
        _aiFeedback = feedbackText;
        _score = detectedScore;
      });

      // ✅ TRIGGERS THE FIREBASE SAVE
      await _saveProgressToFirebase(feedbackText, detectedScore);
    } catch (e) {
      setState(() => _aiFeedback = "AI Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ☁️ ADDED: Firestore Save Logic
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

      print("Progress saved to Firestore successfully!");
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Communication Coach")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Your Practice Session",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(_inputContent, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  child: IconButton(
                    icon: Icon(_isListening ? Icons.stop : Icons.mic,
                        color: Colors.white),
                    onPressed: _listen,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getAIFeedback,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12)),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Analyze My Speech"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_aiFeedback.isNotEmpty) ...[
              const Text("AI Coach Feedback",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_score > 0)
                        Text("Score: $_score/10",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      const Divider(),
                      Text(_aiFeedback,
                          style: const TextStyle(fontSize: 16, height: 1.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Finish & Return to Dashboard"),
              )
            ],
          ],
        ),
      ),
    );
  }
}
