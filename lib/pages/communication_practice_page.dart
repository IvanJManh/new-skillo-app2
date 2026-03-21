import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class CommunicationPracticePage extends StatefulWidget {
  final String skillTitle;

  const CommunicationPracticePage({super.key, required this.skillTitle});

  @override
  State<CommunicationPracticePage> createState() => _CommunicationPracticePageState();
}

class _CommunicationPracticePageState extends State<CommunicationPracticePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking...';
  String _correctedText = '';
  bool _isLoading = false;
  List<dynamic> _matches = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _correctGrammar(_text);
    }
  }

  Future<void> _correctGrammar(String text) async {
    if (text.isEmpty || text == 'Press the button and start speaking...') return;

    setState(() => _isLoading = true);

    try {
      // Using LanguageTool free API
      final response = await http.post(
        Uri.parse('https://api.languagetoolplus.com/v2/check'),
        body: {
          'text': text,
          'language': 'en-US',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _matches = data['matches'] as List;
        
        String corrected = text;
        // Simple correction: apply matches from back to front to maintain indices
        List sortedMatches = List.from(_matches);
        sortedMatches.sort((a, b) => b['offset'].compareTo(a['offset']));

        for (var match in sortedMatches) {
          final replacements = match['replacements'] as List;
          if (replacements.isNotEmpty) {
            final replacement = replacements[0]['value'];
            final offset = match['offset'] as int;
            final length = match['length'] as int;
            corrected = corrected.replaceRange(offset, offset + length, replacement);
          }
        }

        setState(() {
          _correctedText = corrected;
          _isLoading = false;
        });
      } else {
        setState(() {
          _correctedText = 'Failed to get corrections.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _correctedText = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color.fromARGB(255, 71, 172, 200);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.skillTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: tealColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Speech',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _text,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Suggested Correction',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : RichText(
                          text: _buildHighlightedText(_text, _correctedText),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: InkWell(
              onTap: _listen,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: tealColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildHighlightedText(String original, String corrected) {
    if (_correctedText.isEmpty) {
      return const TextSpan(
        text: 'Waiting for speech...',
        style: TextStyle(color: Colors.grey, fontSize: 15),
      );
    }

    if (_matches.isEmpty) {
      return TextSpan(
        text: corrected,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      );
    }

    final List<InlineSpan> spans = [];
    final sortedMatches = List.from(_matches);
    sortedMatches.sort((a, b) => a['offset'].compareTo(b['offset']));

    int currentOriginalPos = 0;
    for (var match in sortedMatches) {
      final offset = match['offset'] as int;
      final length = match['length'] as int;
      final replacements = match['replacements'] as List;

      if (replacements.isEmpty) continue;

      // Unchanged text before match
      if (offset > currentOriginalPos) {
        spans.add(TextSpan(
          text: original.substring(currentOriginalPos, offset),
          style: const TextStyle(color: Colors.black87, fontSize: 15),
        ));
      }

      // Highlighted replacement (as a badge/background like in the image)
      final replacement = replacements[0]['value'];
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            replacement,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 15,
            ),
          ),
        ),
      ));

      currentOriginalPos = offset + length;
    }

    // Remaining text
    if (currentOriginalPos < original.length) {
      spans.add(TextSpan(
        text: original.substring(currentOriginalPos),
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      ));
    }

    return TextSpan(children: spans);
  }
}
