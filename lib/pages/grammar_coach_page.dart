import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http; // New import for free API
import 'dart:convert';

class GrammarCoachPage extends StatefulWidget {
  final String? skillTitle;
  const GrammarCoachPage({super.key, this.skillTitle});

  @override
  State<GrammarCoachPage> createState() => _GrammarCoachPageState();
}

class _GrammarCoachPageState extends State<GrammarCoachPage> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _speechText = '';
  String _correctedText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _correctedText = ''; // Clear old correction
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _speechText = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);

    // Trigger the correction as soon as you stop speaking
    if (_speechText.isNotEmpty) {
      _getFreeGrammarCorrection(_speechText);
    }
  }

  // FIXED: Using LanguageTool (Free, no API key needed for basic usage)
  Future<void> _getFreeGrammarCorrection(String text) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.languagetool.org/v2/check'),
        body: {
          'text': text,
          'language': 'en-US',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List matches = data['matches'];

        if (matches.isEmpty) {
          setState(() => _correctedText = text); // No errors found
        } else {
          // Apply corrections automatically
          String tempText = text;
          // Apply matches in reverse order so character offsets don't break
          for (var match in matches.reversed) {
            final replacements = match['replacements'];
            if (replacements.isNotEmpty) {
              final String bestFix = replacements[0]['value'];
              final int offset = match['offset'];
              final int length = match['length'];

              // We wrap the fix in ** ** so your existing _buildCorrectionDisplay highlighs it!
              tempText = tempText.replaceRange(
                  offset, offset + length, "**$bestFix**");
            }
          }
          setState(() => _correctedText = tempText);
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // This is your original logic to highlight the **words** - it still works!
  Widget _buildCorrectionDisplay() {
    if (_correctedText.isEmpty) {
      return const Center(
          child: Text('Corrections will appear here',
              style:
                  TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
    }

    List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    regex.allMatches(_correctedText).forEach((match) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
            text: _correctedText.substring(lastIndex, match.start),
            style: const TextStyle(color: Colors.black87)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
            color: Colors.white,
            backgroundColor: Colors.green,
            fontWeight: FontWeight.bold),
      ));
      lastIndex = match.end;
    });

    if (lastIndex < _correctedText.length) {
      spans.add(TextSpan(
          text: _correctedText.substring(lastIndex),
          style: const TextStyle(color: Colors.black87)));
    }

    return RichText(
        text: TextSpan(children: spans, style: const TextStyle(fontSize: 16)));
  }

  @override
  Widget build(BuildContext context) {
    // ... Keeping your existing UI exactly the same ...
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillTitle ?? 'Grammar Coach'),
        backgroundColor: const Color.fromARGB(255, 71, 172, 200),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mic Button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: _isListening
                    ? Colors.red
                    : const Color.fromARGB(255, 71, 172, 200),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 30),
            // Block 1: Your Speech
            _buildTextBlock("Your Speech", _speechText,
                const Color.fromARGB(255, 71, 172, 200)),
            const SizedBox(height: 20),
            // Block 2: Correction
            _buildCorrectionBlock(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBlock(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(10)),
          child: Text(content.isEmpty ? "Speak to see text..." : content),
        ),
      ],
    );
  }

  Widget _buildCorrectionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Suggested Correction",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(10)),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCorrectionDisplay(),
        ),
      ],
    );
  }
}
