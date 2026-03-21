import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:newskilloapp/pages/pose_camera_screen.dart';
import 'package:newskilloapp/pages/reading_practice_screen.dart';
import 'package:newskilloapp/services/firestore_service.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';

class SkillLessonPage extends StatefulWidget {
  final Map<String, dynamic>? initialSkill;
  final SkillNotifier? skillNotifier;

  const SkillLessonPage({super.key, this.initialSkill, this.skillNotifier});

  @override
  State<SkillLessonPage> createState() => _SkillLessonPageState();
}

class _SkillLessonPageState extends State<SkillLessonPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? selectedSkill;
  List<Map<String, dynamic>> _lessons = [];
  int _currentLessonIndex = 0;
  bool _loading = true;

  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _canGoNext = false;

  String _getVideoForSkill(String? title) {
    if (title == null) return 'assets/videos/communication.mp4';
    final t = title.toLowerCase();

    if (t.contains('speaking')) {
      return 'assets/videos/speaking.mp4';
    } else if (t.contains('facial') || t.contains('expression')) {
      return 'assets/videos/facial expressions.mp4';
    } else if (t.contains('posture') || t.contains('walking') || t.contains('pose') || t.contains('raise')) {
      return 'assets/videos/posture.mp4';
    } else if (t.contains('writing') || t.contains('reading')) {
      return 'assets/videos/writing.mp4';
    }

    return 'assets/videos/communication.mp4';
  }

  void _initializeVideo() {
    if (_lessons.isEmpty) return;

    final String skillTitle = selectedSkill?['title']?.toString() ?? '';
    final String videoSource = _getVideoForSkill(skillTitle);

    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();

    _videoController = VideoPlayerController.asset(videoSource)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isVideoReady = true;
          _videoController?.play();
          _videoController?.setLooping(true);
        });
      })
      ..addListener(_videoListener);
  }

  void _videoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }
    // For now, we enable the next button immediately after video is ready.
    // Later, we might add logic for video completion or specific interaction.
    if (_videoController!.value.isInitialized && !_canGoNext) {
      setState(() {
        _canGoNext = true;
      });
    }
  }

  Future<void> _fetchLessons() async {
    setState(() {
      _loading = true;
    });

    try {
      if (selectedSkill != null && selectedSkill!['id'] != null) {
        final fetchedLessons = await _firestoreService.getLessonsForSkill(selectedSkill!['id']);
        if (fetchedLessons.isNotEmpty) {
          _lessons = fetchedLessons;
        }
      }

      if (_lessons.isEmpty) {
        // Create a dummy lesson if none exist in Firestore
        _lessons = [
          {
            'title': 'Introduction',
            'description': selectedSkill?['description'] ?? 'Learn the basics of this skill.',
            'isAsset': true,
          }
        ];
      }
    } catch (e) {
      print('Error fetching lessons: $e');
      // Fallback to a dummy lesson if there's an error
      _lessons = [
        {
          'title': 'Introduction',
          'description': selectedSkill?['description'] ?? 'Learn the basics of this skill.',
          'isAsset': true,
        }
      ];
    } finally {
      _initializeVideo(); // Initialize video after lessons are fetched
      setState(() {
        _loading = false;
      });
    }
  }

  void _nextLesson() {
    if (_currentLessonIndex < _lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
        _isVideoReady = false; // Reset video ready state for new video
        _canGoNext = false; // Disable button until new video is ready
      });
      _initializeVideo(); // Initialize video for the next lesson
    } else {
      // All lessons completed, navigate to AI practice
      final title = (selectedSkill?['title'] ?? 'Skill').toString().toLowerCase();
      final isReadingSkill = title.contains('communication') || 
                             title.contains('reading') || 
                             title.contains('speaking') ||
                             title.contains('listening') ||
                             title.contains('thanking') ||
                             title.contains('greeting');

      if (isReadingSkill) {
        // Go to Reading/Grammar Practice
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadingPracticeScreen(
              skillNotifier: widget.skillNotifier,
              skillTitle: selectedSkill?['title'] ?? 'Skill',
            ),
          ),
        );
      } else {
        // Last lesson completed, go to AI Pose Practice
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PoseCameraScreen(
              skillNotifier: widget.skillNotifier,
              skillTitle: selectedSkill?['title'] ?? 'Skill',
            ),
          ),
        );
      }
    }
  }

  final List<Map<String, dynamic>> fallbackSkills = [
    {
      'title': 'Improve Communication',
      'description':
          'Learn how to express your ideas clearly and confidently in daily conversations.',
    },
    {
      'title': 'Public Speaking',
      'description':
          'Practice speaking with confidence, better posture, and a stronger presence in front of others.',
    },
    {
      'title': 'Facial Expressions',
      'description':
          'Improve your expressions so you look more friendly, confident, and engaging while speaking.',
    },
    {
      'title': 'Active Listning',
      'description':
          'Practice showing that you are listening by nodding, maintaining eye contact, and reacting appropriately during conversations.',
    },
    {
      'title': 'Confident Walking',
      'description':
          'Learn how to walk confidently with upright posture, steady pace, and relaxed body language.',
    },
    {
      'title': 'Thanking Someone Properly',
      'description':
          'Practice expressing gratitude sincerely using words, tone, and facial expression.',
    },
    {
      'title': 'Simple Yoga Pose (Tree Pose)',
      'description':
          'Stand on one leg and place the other foot on your inner thigh. AI checks balance and body posture.',
    },
    {
      'title': 'Hand Raise Detection',
      'description':
          'Practice raising your hand straight above your head. AI can detect the position of the arm and shoulder alignment.',
    },
    {
      'title': 'Greeting Someone Politely',
      'description':
          'Learn how to greet people politely using friendly words, tone, and body language.',
    },
    {
      'title': 'Time Management',
      'description':
          'Build better habits to organize your tasks, stay focused, and use your time effectively.',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedSkill = widget.initialSkill ?? fallbackSkills[Random().nextInt(fallbackSkills.length)];
    _fetchLessons();
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Today\'s Skill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentLesson = _lessons.isNotEmpty ? _lessons[_currentLessonIndex] : {};

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSkill?['title'] ?? 'Skill Lesson'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress tracker
            Row(
              children: [
                Text(
                  'Lesson ${_currentLessonIndex + 1} of ${_lessons.length}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 71, 172, 200),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentLessonIndex + 1) / _lessons.length,
                    backgroundColor: Colors.grey[200],
                    color: const Color.fromARGB(255, 71, 172, 200),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black12,
              ),
              child: _isVideoReady
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: VideoPlayer(_videoController!),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
            Text(
              currentLesson['title'] ?? selectedSkill?['title'] ?? 'Skill Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentLesson['description'] ??
                  selectedSkill?['description'] ??
                  'No description available.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canGoNext
                      ? const Color.fromARGB(255, 71, 172, 200)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                onPressed: _canGoNext ? _nextLesson : null,
                child: Text(
                  _currentLessonIndex < _lessons.length - 1
                      ? 'Next Lesson'
                      : 'Start AI Practice',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
