import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/profile_page.dart';
import 'package:newskilloapp/pages/progress_page.dart';
import 'package:newskilloapp/pages/saved_skills_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';



class HomePage extends StatefulWidget {
  final SkillNotifier skillNotifier;
  final String userName;
  final String userEmail;
  
  const HomePage({
    super.key,
    required this.skillNotifier, 
    required this.userName, 
    required this.userEmail,
    }
    );

    @override
    State<HomePage> createState() => _HomePageState();

}

  class _HomePageState extends State<HomePage>{
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
                        backgroundImage: AssetImage('lib/images/user-6.png'),
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
            onPressed: (){
              setState(() {
                _currentIndex = 3;
                _pageController.jumpToPage(3);
              });(
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
        onPageChanged: (index){
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
          child: Theme(data: ThemeData(
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

    class HomeContent extends StatelessWidget{
      final SkillNotifier skillNotifier;

      HomeContent({required this.skillNotifier});

      @override
      Widget build(BuildContext context){
        return ValueListenableBuilder(
          valueListenable: skillNotifier,
          builder: (context, skills, child){
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
                      if (index == 1) {
                        final homeState = context.findAncestorStateOfType<_HomePageState>();
                        homeState?._pageController.jumpToPage(2);
                      } else {
                        final homeState = context.findAncestorStateOfType<_HomePageState>();
                        homeState?._pageController.jumpToPage(0);
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
                        image: AssetImage(index == 0? 'lib/images/background.png' : 'lib/images/background.png'),
                        fit: BoxFit.cover,
                        ),
                    ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8), // FIXED
                        child: Image.asset(
                          index == 0? 'lib/images/IMG_2238.PNG' : 'lib/images/IMG_2239.PNG',
                          height: 100,
                        ),
                        ),
                        Text(
                          index == 0? " Today's 2 minute Skill" : " Current Streak",
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
            child: skills.isEmpty ? Center(
              child: Card(
                elevation: 0.3,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Color.fromARGB(255, 71, 172, 200),
                    width: 1,
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 90,
                    child: Center(
                      child: Text(
                        'No skills saved yet',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
            )

            : ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: skills.length,
              itemBuilder: (context, index){
                final skill = skills[index];
                return Container(
                      width: 140,
                      child: Container(
                        width: 140,
                        margin: EdgeInsets.only(right: 5),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Color.fromARGB(255, 71, 172, 200),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10), // FIXED
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/images/IMG_2258.PNG',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                        
                                SizedBox(
                                  height: 12,
                                ),
                        
                                Text(
                                  skill,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            ),
                        ),
                      ),
                );
              }
                      
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


