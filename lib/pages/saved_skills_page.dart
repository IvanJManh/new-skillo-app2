import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/pages/skill_details_page.dart';
import 'package:newskilloapp/features/content/content.dart';

class SavedSkillsPage extends StatefulWidget {
  final SkillNotifier skillNotifier;

  const SavedSkillsPage({
    super.key,
    required this.skillNotifier,
  });

  @override
  State<SavedSkillsPage> createState() => _SavedSkillsPageState();
}

class _SavedSkillsPageState extends State<SavedSkillsPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentService = ContentService();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 210,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/background.png'),
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
                        offset: const Offset(0.5, 1),
                      )
                    ],
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
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
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

      body: StreamBuilder<List<Skill>>(
        stream: contentService.watchSkills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final skills = snapshot.data ?? [];

          final filteredSkills = skills.where((s) {
            return s.title.toLowerCase().contains(searchQuery);
          }).toList();

          if (filteredSkills.isEmpty) {
            return const Center(child: Text("No skills found"));
          }

          return Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: filteredSkills.length,
              itemBuilder: (context, index) {
                final s = filteredSkills[index];
                final isSaved = widget.skillNotifier.value.contains(s.title);

                return Card(
                  elevation: 0.7,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 71, 172, 200),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkillDetailsPage(
                            skillId: s.id,
                            skillTitle: s.title,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          if (index % 2 == 0)
                            Image.asset('lib/images/man.png', width: 155),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  s.description.isNotEmpty
                                      ? s.description
                                      : 'Practice and improve this skill',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          if (index % 2 != 0)
                            Image.asset('lib/images/man.png', width: 155),

                          SizedBox(
                            width: 30,
                            child: IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              onPressed: () {
                                if (isSaved) {
                                  widget.skillNotifier.removeSkill(s.title);
                                } else {
                                  widget.skillNotifier.addSkill(s.title);
                                }
                              },
                              style: IconButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                            ),
                          ),
                        ],
                      ),
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
