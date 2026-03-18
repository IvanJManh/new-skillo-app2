import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:newskilloapp/pages/pose_camera_screen.dart';

class SkillLessonPage extends StatefulWidget {
  const SkillLessonPage({super.key});

  @override
  State<SkillLessonPage> createState() => _SkillLessonPageState();
}

class _SkillLessonPageState extends State<SkillLessonPage> {
  late final Map<String, String> selectedSkill;

  late VideoPlayerController _videoController;
  bool _isVideoReady = false;

  final List<Map<String, String>> skills = [
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
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Skill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isVideoReady
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: VideoPlayer(_videoController),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
            Text(
              selectedSkill['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              selectedSkill['description']!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
