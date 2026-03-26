import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'skill_notifier.dart';
import 'practice_results.dart';

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
    final results = skillNotifier.practiceResults;
    final practicedToday = results.any((r) {
      final now = DateTime.now();
      return r.date.year == now.year && r.date.month == now.month && r.date.day == now.day;
    });

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
              'Track Progress',
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
              _topProgressCard(completed, streak, practicedToday),
              SizedBox(height: 20),
              _middleCards(skillNotifier),
              SizedBox(height: 20),
              _learningProgressChart(skillNotifier),
              SizedBox(height: 20),
              _practiceHistorySection(results),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _topProgressCard(int completed, int streak, bool practicedToday) {
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
                'Sessions\nCompleted\n$completed',
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
                backgroundColor: practicedToday ? Colors.green : Colors.white,
                child: Icon(
                  practicedToday ? Icons.check : Icons.play_arrow,
                  color: practicedToday ? Colors.white : Color.fromARGB(255, 71, 172, 200),
                ),
              ),
              SizedBox(height: 6),
              Text(
                practicedToday ? 'Done today!' : 'Not yet',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
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
        Expanded(child: _performanceCard(skillNotifier)),
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
                ? Center(child: Text('No data yet', style: TextStyle(color: Colors.grey)))
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
                      maxY: scores.isEmpty ? 10 : (scores.max * 1.1).clamp(1, 10),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _performanceCard(SkillNotifier skillNotifier) {
    final latestResult = skillNotifier.latestPracticeResult;

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
            'Latest Feedback',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: latestResult?.aiFeedback != null && latestResult!.aiFeedback!.isNotEmpty
                ? SingleChildScrollView(
                    child: Text(
                      latestResult!.aiFeedback!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  )
                : Center(
                    child: Text(
                      'No AI feedback yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _learningProgressChart(SkillNotifier skillNotifier) {
    final scores = skillNotifier.weeklyScores.reversed.toList();
    
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
            'Learning Progress (Last 7 sessions)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: scores.isEmpty
                ? Center(
                    child: Text(
                      'Start practicing to see progress',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Color.fromARGB(255, 71, 172, 200),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Color.fromARGB(255, 71, 172, 200).withOpacity(0.2),
                          ),
                          spots: scores.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value);
                          }).toList(),
                        ),
                      ],
                      minY: 0,
                      maxY: 10, // Assuming score is out of 10
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _practiceHistorySection(List<PracticeResults> results) {
    return Container(
      height: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [ //////////////////////////////////
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
            'Practice History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          results.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No sessions recorded yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    final date = r.date;
                    final dateStr = '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
                    
                    // Determine which score to show (whichever is non-zero)
                    double displayScore;
                    String scoreLabel;
                    if (r.postureScore > 0) {
                      displayScore = r.postureScore;
                      scoreLabel = 'Posture';
                    } else if (r.facialScore > 0) {
                      displayScore = r.facialScore;
                      scoreLabel = 'Expression';
                    } else {
                      displayScore = r.speechScore;
                      scoreLabel = 'Speech/Writing';
                    }

                    final scoreColor = displayScore >= 7
                        ? Colors.green
                        : displayScore >= 4
                            ? Colors.orange
                            : Colors.red;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: scoreColor.withOpacity(0.15),
                            child: Text(
                              '${displayScore.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$scoreLabel Practice',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      dateStr,
                                      style: TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                if (r.aiFeedback != null && r.aiFeedback!.isNotEmpty)
                                  Text(
                                    r.aiFeedback!,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

extension ListExtension on List<double> {
  double get max => isEmpty ? 0 : reduce((a, b) => a > b ? a : b);
}
