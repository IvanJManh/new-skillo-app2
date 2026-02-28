import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'skill_notifier.dart';

class ProgressPage extends StatelessWidget {
  final SkillNotifier skillNotifier;
  final int totalSkills;

  const ProgressPage({
    super.key,
    required this.skillNotifier,
    required this.totalSkills,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: skillNotifier, 
      builder: (context, skills, child){
    final completed = skillNotifier.completedDays;
    final streak = skillNotifier.streak;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Text(
              'Track progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          child: Column(
            children: [
              _topProgressCard(completed, streak),
              SizedBox(height: 20),
              _middleCards(skillNotifier),
              SizedBox(height: 20),
              _learningProgressChart(),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _topProgressCard(int completed, int streak) {
    return Container(
      padding: EdgeInsets.all(20),
      constraints: BoxConstraints(minHeight: 170),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/images/background.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills\nCompleted\n$completed/$totalSkills',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Current\nStreak\n$streak Days',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'My\nPROGRESS\nTODAY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.play_arrow,
                    color: Color.fromARGB(255, 71, 172, 200)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _middleCards(SkillNotifier skillNotifier) {
    return Row(
      children: [
        Expanded(child: _weeklyBarChart(skillNotifier)),
        SizedBox(width: 15),
        Expanded(child: _performanceCard()),
      ],
    );
  }

  Widget _weeklyBarChart(SkillNotifier skillNotifier) {
    final scores = skillNotifier.weeklyScores;
    return Container(
      padding: EdgeInsets.all(15),
      height: 170,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 71, 172, 200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: scores.isEmpty
                ? Center(child: Text('No data available'))
                : BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      barGroups: scores.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              width: 8,
                              color: Color.fromARGB(255, 71, 172, 200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }).toList(),
                      maxY: scores.isEmpty ? 0 : scores.max * 1.1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _performanceCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      height: 170,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 71, 172, 200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Feedback',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Body Posture Good'),
          Text('Speech Good'),
          Text('Facial Expression Good'),
        ],
      ),
    );
  }

  Widget _learningProgressChart() {
    return Container(
      padding: EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 71, 172, 200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: [
                      FlSpot(0, 1),
                      FlSpot(1, 2),
                      FlSpot(2, 1.5),
                      FlSpot(3, 3),
                      FlSpot(4, 2.5),
                      FlSpot(5, 3.8),
                    ],
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true),
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

extension ListExtension on List<double> {
  double get max => isEmpty ? 0 : reduce((a, b) => a > b ? a : b);
}


