import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class SpeakingPracticeScreen extends StatefulWidget {
  final SkillNotifier? skillNotifier;
  final String skillTitle;

  const SpeakingPracticeScreen({
    super.key,
    this.skillNotifier,
    this.skillTitle = 'Speaking Practice',
  });

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusText = 'Press Mic to start speaking';
  
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  
  String _transcribedText = '';
  String _feedbackText = '';
  double _sessionSpeechScore = 0.0;
  int _sentencesAttempted = 0;

  final List<String> _practiceSentences = [
    "I am learning how to speak clearly and confidently.",
    "Technology is transforming the way we live and work.",
    "A journey of a thousand miles begins with a single step.",
  ];
  int _currentSentenceIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
             _isRecording = false;
             _isProcessing = false;
             if (_transcribedText.isNotEmpty) {
               _evaluateSpeech(_transcribedText);
             }
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isRecording = false;
          _isProcessing = false;
          _statusText = 'Error: ${errorNotification.errorMsg}';
        });
      },
    );
    setState(() {});
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

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false, // Turn off for camera to prevent mic conflict
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      print('DEBUG: Camera crash: $e');
      String errorMsg = e.toString();
      // On Web, accessing camera via HTTP on a local IP causes a JSOBJECT/TypeError
      if (kIsWeb && (errorMsg.toLowerCase().contains('jsobject') || errorMsg.toLowerCase().contains('typeerror'))) {
        errorMsg = 'Camera requires a secure connection (HTTPS) on mobile browsers. '
                   'Please use a secure tunnel (like ngrok) or test on localhost.';
      }
      setState(() => _statusText = 'Camera error: $errorMsg');
    }
  }

  Future<void> _toggleRecording() async {
    if (!_speechEnabled) {
      setState(() => _statusText = 'Speech recognition not available on this device');
      return;
    }

    if (_isRecording) {
      // Stop listening manually
      await _speechToText.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _statusText = 'Evaluating your speech...';
      });
    } else {
      // Start listening
      setState(() {
        _isRecording = true;
        _transcribedText = '';
        _feedbackText = '';
        _statusText = 'Listening... read the sentence below';
      });

      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
          // When speech recognition produces final result
          if (result.finalResult) {
             setState(() {
                _isRecording = false;
                _isProcessing = false;
                _evaluateSpeech(_transcribedText);
             });
          }
        },
      );
    }
  }

  void _evaluateSpeech(String transcribed) {
    final target = _practiceSentences[_currentSentenceIndex].toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final actual = transcribed.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    
    double score;
    if (target == actual) {
      _feedbackText = 'Excellent! You pronounced it perfectly.';
      _statusText = 'Perfect Pronunciation ✅';
      score = 10.0;
    } else if (actual.contains(target) || target.contains(actual)) {
      _feedbackText = 'Very close! Keep practicing your pacing.';
      _statusText = 'Good effort! 👍';
      score = 7.0;
    } else {
      _feedbackText = 'Some words were missed. Try speaking slower and more clearly.';
      _statusText = 'Needs Improvement ⚠️';
      score = 4.0;
    }
    
    _sentencesAttempted++;
    _sessionSpeechScore = ((_sessionSpeechScore * (_sentencesAttempted - 1)) + score) / _sentencesAttempted;
  }

  void _nextSentence() {
    setState(() {
      _currentSentenceIndex = (_currentSentenceIndex + 1) % _practiceSentences.length;
      _transcribedText = '';
      _feedbackText = '';
      _statusText = 'Press Mic to start speaking';
    });
  }

  Future<void> _finishPractice() async {
    await _speechToText.cancel();

    // Save results to Firebase
    if (widget.skillNotifier != null && _sentencesAttempted > 0) {
      try {
        await widget.skillNotifier!.addPracticeResults(
          PracticeResults(
            date: DateTime.now(),
            postureScore: 0.0,
            speechScore: _sessionSpeechScore,
            facialScore: 0.0,
            aiFeedback: 'Speaking score: ${_sessionSpeechScore.toStringAsFixed(1)}/10 — Practiced $_sentencesAttempted sentence(s). $_feedbackText',
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
    _speechToText.cancel();
    _controller?.dispose();
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
            child: Container(color: Colors.black54),
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
                        Icon(
                          _isRecording ? Icons.mic : Icons.mic_none, 
                          color: _isRecording ? Colors.red : Colors.green, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sentence to Read
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Read this sentence aloud:",
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _practiceSentences[_currentSentenceIndex],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mic Button
                  GestureDetector(
                    onTap: _isProcessing ? null : _toggleRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : const Color.fromARGB(255, 71, 172, 200),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: _isProcessing
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 40,
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feedback Display
                  if (_transcribedText.isNotEmpty)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "What AI Heard:",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"$_transcribedText"',
                                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                              const Divider(height: 24),
                              const Text(
                                "Feedback:",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _feedbackText,
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: _statusText.contains('Perfect') ? Colors.green : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  // Bottom Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _finishPractice,
                        child: const Text('Finish'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 71, 172, 200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _isRecording || _isProcessing ? null : _nextSentence,
                        child: const Text('Next Sentence ➡️'),
                      ),
                    ],
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
