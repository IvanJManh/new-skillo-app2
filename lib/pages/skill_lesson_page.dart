import 'dart:math';
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:newskilloapp/pages/pose_camera_screen.dart';
import 'package:newskilloapp/services/firestore_service.dart';

class SkillLessonPage extends StatefulWidget {
  final Map<String, dynamic>? initialSkill;

  const SkillLessonPage({super.key, this.initialSkill});
=======

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:newskilloapp/pages/pose_camera_screen.dart';

class SkillLessonPage extends StatefulWidget {
  const SkillLessonPage({super.key});
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013

  @override
  State<SkillLessonPage> createState() => _SkillLessonPageState();
}

class _SkillLessonPageState extends State<SkillLessonPage> {
<<<<<<< HEAD
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? selectedSkill;
  List<Map<String, dynamic>> _lessons = [];
  int _currentLessonIndex = 0;
  bool _loading = true;

  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _canGoNext = false;

  final List<Map<String, dynamic>> fallbackSkills = [
=======
  late final Map<String, String> selectedSkill;

  late VideoPlayerController _videoController;
  bool _isVideoReady = false;

  final List<Map<String, String>> skills = [
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
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
<<<<<<< HEAD
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    Map<String, dynamic>? skill = widget.initialSkill;

    // Fetch all skills to find the full data if needed or to pick a random one
    final allSkills = await _firestoreService.getSkills();

    if (skill == null || skill?['id'] == null || skill?['description'] == null) {
      if (skill != null && skill?['title'] != null) {
        // Find by title in our fetched list
        final searchTitle = skill?['title'].toString().trim().toLowerCase();
        try {
          skill = allSkills.firstWhere(
            (s) => s['title'].toString().trim().toLowerCase() == searchTitle,
          );
        } catch (e) {
          // Fallback to separate query if not in allSkills
          skill = await _firestoreService.getSkillByTitle(skill?['title']);
        }
      }

      if (skill == null) {
        if (allSkills.isNotEmpty) {
          skill = allSkills[Random().nextInt(allSkills.length)];
        } else {
          skill = fallbackSkills[Random().nextInt(fallbackSkills.length)];
        }
      }
    }

    selectedSkill = skill;

    if (selectedSkill != null && selectedSkill!['id'] != null) {
      _lessons = await _firestoreService.getLessons(selectedSkill!['id']);
    }

    if (_lessons.isEmpty) {
      // Create a dummy lesson if none exist in Firestore
      _lessons = [
        {
          'title': 'Introduction',
          'description': selectedSkill?['description'] ?? 'Learn the basics of this skill.',
          'videoUrl': 'assets/videos/communication.mp4', // Default asset
          'isAsset': true,
        }
      ];
    }

    if (mounted) {
      setState(() => _loading = false);
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    if (_lessons.isEmpty) return;

    final lesson = _lessons[_currentLessonIndex];
    final String videoSource =
        lesson['videoUrl'] ?? 'assets/videos/communication.mp4';
    final bool isAsset = lesson['isAsset'] ?? videoSource.startsWith('assets/');

    _isVideoReady = false;
    _canGoNext = false;

    if (_videoController != null) {
      _videoController!.removeListener(_videoListener);
      _videoController!.dispose();
    }

    if (isAsset) {
      _videoController = VideoPlayerController.asset(videoSource);
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoSource));
    }

    _videoController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isVideoReady = true;
      });
      _videoController!.addListener(_videoListener);
      _videoController!.play();
    });
  }

  void _videoListener() {
    if (_videoController != null &&
        _videoController!.value.position >= _videoController!.value.duration &&
        _videoController!.value.duration > Duration.zero) {
      if (!_canGoNext) {
        setState(() {
          _canGoNext = true;
        });
      }
    }
  }

  void _nextLesson() {
    if (_currentLessonIndex < _lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
      _initializeVideo();
    } else {
      // Last lesson completed, go to AI Practice
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PoseCameraScreen(),
        ),
      );
    }
=======
    selectedSkill = skills[Random().nextInt(skills.length)];

    _videoController = VideoPlayerController.asset(
      'assets/videos/communication.mp4',
    )
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isVideoReady = true;
        });
      });
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
=======
    _videoController.dispose();
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Today\'s Skill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentLesson = _lessons[_currentLessonIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSkill?['title'] ?? 'Skill Lesson'),
=======
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Skill'),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
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
=======
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
<<<<<<< HEAD
                color: Colors.black12,
=======
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
              ),
              child: _isVideoReady
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
<<<<<<< HEAD
                      child: VideoPlayer(_videoController!),
=======
                      child: VideoPlayer(_videoController),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
            Text(
<<<<<<< HEAD
              currentLesson['title'] ?? selectedSkill?['title'] ?? 'Skill Title',
=======
              selectedSkill['title']!,
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
<<<<<<< HEAD
              currentLesson['description'] ??
                  selectedSkill?['description'] ??
                  'No description available.',
=======
              selectedSkill['description']!,
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
<<<<<<< HEAD
=======
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 248, 250),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 71, 172, 200),
                ),
              ),
              child: const Text(
                'Video lesson area\n\nYou can add the actual lesson video here next.',
                style: TextStyle(fontSize: 15),
              ),
            ),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
<<<<<<< HEAD
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
=======
                  backgroundColor: const Color.fromARGB(255, 71, 172, 200),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PoseCameraScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Start AI Practice',
                  style: TextStyle(fontSize: 16),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
