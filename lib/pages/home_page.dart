import 'dart:math';
import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/profile_page.dart';
import 'package:newskilloapp/pages/progress_page.dart';
import 'package:newskilloapp/pages/saved_skills_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/pages/pose_camera_screen.dart';
import 'package:newskilloapp/pages/skill_lesson_page.dart';
import 'package:newskilloapp/screens/practice_facial_expression_screen.dart';

class HomePage extends StatefulWidget {
  final SkillNotifier skillNotifier;
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.skillNotifier,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              toolbarHeight: 90,
              flexibleSpace: Container(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage:
                                  AssetImage('lib/images/user-6.png'),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Icon',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                widget.userName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, right: 15),
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    color: Colors.black,
                    onPressed: () {
                      setState(() {
                        _currentIndex = 3;
                        _pageController.jumpToPage(3);
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userName: widget.userName,
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : null,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeContent(skillNotifier: widget.skillNotifier),
          SavedSkillsPage(skillNotifier: widget.skillNotifier),
          ProgressPage(skillNotifier: widget.skillNotifier, totalSkills: 4),
          ProfilePage(userName: widget.userName, userEmail: widget.userEmail),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Color.fromARGB(255, 71, 172, 200),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // FIXED
          child: Theme(
            data: ThemeData(
              canvasColor: Colors.white,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '',
                ),
              ],
              selectedItemColor: Color.fromARGB(255, 71, 172, 200),
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final SkillNotifier skillNotifier;

  HomeContent({required this.skillNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: skillNotifier,
      builder: (context, skills, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 2,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (index == 0) {
                          final List<String> dailySkills = [
                            'Writing Skills',
                            'Postures and Gestures',
                            'Speaking',
                            'Facial Expression',
                          ];
                          final randomSkill = dailySkills[Random().nextInt(dailySkills.length)];

                          if (randomSkill == 'Facial Expression') {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PracticeFacialExpressionScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SkillLessonPage(
                                  initialSkill: {'title': randomSkill},
                                  skillNotifier: skillNotifier,
                                ),
                              ),
                            );
                          }
                        } else {
                          final homeState =
                              context.findAncestorStateOfType<_HomePageState>();
                          homeState?._pageController.jumpToPage(2);
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(index == 0
                                  ? 'lib/images/background.png'
                                  : 'lib/images/background.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8), // FIXED
                                child: Image.asset(
                                  index == 0
                                      ? 'lib/images/IMG_2238.PNG'
                                      : 'lib/images/IMG_2239.PNG',
                                  height: 100,
                                ),
                              ),
                              Text(
                                index == 0
                                    ? " Today's 2 minute Skill"
                                    : " Current Streak: ${skillNotifier.streak} Days",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Text(
                      'Saved Skills',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: skills.isEmpty
                      ? InkWell(
                          onTap: () {
                            final homeState =
                                context.findAncestorStateOfType<_HomePageState>();
                            if (homeState != null) {
                              homeState._pageController.animateToPage(
                                1,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color.fromARGB(255, 71, 172, 200),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0.5, 0.5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bookmark_add_outlined,
                                      color: Color.fromARGB(255, 71, 172, 200),
                                      size: 30),
                                  SizedBox(height: 8),
                                  Text(
                                    'No skills saved yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Tap here to browse and save skills!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemCount: skills.length,
                          itemBuilder: (context, index) {
                            final skill = skills[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SkillLessonPage(
                                      initialSkill: {'title': skill},
                                      skillNotifier: skillNotifier,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140,
                                margin: EdgeInsets.only(
                                    right: 12, bottom: 10, top: 4, left: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 71, 172, 200),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0.5, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'lib/images/IMG_2258.PNG',
                                        height: 100,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        skill,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
