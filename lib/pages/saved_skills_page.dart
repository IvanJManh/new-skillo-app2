import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';


class SavedSkillsPage extends StatefulWidget {
  final SkillNotifier skillNotifier;

  final List<String> skillsList = [
    'Improve Communication',
    'Facial Expressions',
    'Public Speaking',
    'Time Management',
  ];

  double calculateProgress(int completed, int total) {
  if (total == 0) return 0;
  return completed / total;
}

  SavedSkillsPage(
    {
    required this.skillNotifier,
    }
  );
  

  @override
  _SavedSkillsPageState createState() => _SavedSkillsPageState(); 

}

class _SavedSkillsPageState extends State<SavedSkillsPage>{

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 210,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('lib/images/background.png'),
                fit: BoxFit.cover,
                ),
              ),
            ),

            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0.5, 1),
                      )
                    ]
                  ),


                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },

                    decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                ),
                  ),
                ),
              ),
            ),
            ),

            Positioned(
              bottom: 10,
              left: 16,
              child: Text(
              'Previous Skills',
              style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  ),
),

      body: ValueListenableBuilder(
        valueListenable: widget.skillNotifier,
        builder: (context, skills, child) {
          
          final filteredSkills = widget.skillsList.where((skill){
              return skill.toLowerCase().contains(searchQuery);
          }).toList();
            
          return Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: filteredSkills.length,
              itemBuilder: (context, index) {
                final skill = filteredSkills[index];
                return Card(
                  elevation: 0.7,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    side: BorderSide(
                      color: Color.fromARGB(255, 71, 172, 200),
                      width: 1,
                    )
                  ),
                  child: Container(
                    height: 150,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (index% 2 == 0)
                        Image.asset('lib/images/man.png',
                        width: 155,
                        ),
                        SizedBox(width: 10),
                        Expanded(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              skill,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Practice and improve this skill',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          ],
                        ),
                        ),
                        SizedBox(width: 10),
                        if (index% 2 != 0)
                        Image.asset('lib/images/man.png',
                        width: 155,
                        ),
            
                        Center(
                          child: SizedBox(width: 30,
                            child: IconButton(
                              icon: Icon(
                              widget.skillNotifier.value.contains(skill)
                            ? Icons.bookmark : Icons.bookmark_border,  
                            ),
                            onPressed: (){
                              if (widget.skillNotifier.value.contains(skill)){
                              widget.skillNotifier.removeSkill(skill);
                            } else {
                              widget.skillNotifier.addSkill(skill);
                            }
                            },
                            style: IconButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
                      
