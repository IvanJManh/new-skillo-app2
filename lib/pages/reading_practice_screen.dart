import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class ReadingPracticeScreen extends StatefulWidget {
  final SkillNotifier? skillNotifier;
  final String skillTitle;

  const ReadingPracticeScreen({
    super.key,
    this.skillNotifier,
    this.skillTitle = 'Skill',
  });

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  CameraController? _controller;
  final TextEditingController _textController = TextEditingController();

  bool _isChecking = false;
  String _statusText = 'Type your sentence and check grammar';
  List<dynamic> _grammarErrors = [];
  double _grammarScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _statusText = 'No cameras found');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // We enable audio here to turn on the microphone as requested by user
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusText = 'Camera error: $e');
    }
  }

  Future<void> _checkGrammar() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a sentence first')),
      );
      return;
    }

    setState(() {
      _isChecking = true;
      _statusText = 'Checking grammar with AI...';
      _grammarErrors = [];
    });

    try {
      // Using LanguageTool API as a free alternative to Grammarly
      final response = await http.post(
        Uri.parse('https://api.languagetool.org/v2/check'),
        body: {
          'text': text,
          'language': 'en-US',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final matches = data['matches'] as List<dynamic>;

        setState(() {
          _grammarErrors = matches;
          // Score = 10 for 0 errors, reduce by 2 per error down to 0
          _grammarScore = (10.0 - matches.length * 2).clamp(0.0, 10.0);
          if (matches.isEmpty) {
            _statusText = 'Perfect! No errors found ✅';
          } else {
            _statusText = 'Found ${matches.length} issue(s) 👇';
          }
        });
      } else {
        setState(() => _statusText = 'AI Check failed. Try again.');
      }
    } catch (e) {
      setState(() => _statusText = 'Network Error');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _finishPractice() async {
    // Save results to Firebase
    if (widget.skillNotifier != null && _grammarScore > 0) {
      try {
        final errorSummary = _grammarErrors.isEmpty
            ? 'No grammar errors found.'
            : '${_grammarErrors.length} grammar error(s) found.';
        await widget.skillNotifier!.addPracticeResults(
          PracticeResults(
            date: DateTime.now(),
            postureScore: 0.0,
            speechScore: _grammarScore,
            facialScore: 0.0,
            aiFeedback: 'Writing score: ${_grammarScore.toStringAsFixed(1)}/10 — $errorSummary',
          ),
        );
      } catch (_) {}
    }
    await _controller?.dispose();
    _controller = null;
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillTitle),
      ),
      body: Stack(
        children: [
          // Background Camera View
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Semi-transparent overlay to make text readable
          Positioned.fill(
            child: Container(color: Colors.black45),
          ),

          // Main Interactive Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Speak clearly and type your sentence here...",
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  // Check Grammar Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 71, 172, 200),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isChecking ? null : _checkGrammar,
                      icon: _isChecking
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isChecking ? 'Checking...' : 'Check Grammar (AI)'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Display Error Cards
                  Expanded(
                    child: ListView.builder(
                      itemCount: _grammarErrors.length,
                      itemBuilder: (context, index) {
                        final error = _grammarErrors[index];
                        final message = error['message'];
                        final replacements = error['replacements'] as List;
                        
                        return Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "⚠️ $message",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (replacements.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    "Suggestion: ${replacements.first['value']}",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Finish Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _finishPractice,
                    child: const Text('Finish Practice', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
