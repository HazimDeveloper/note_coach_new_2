// lib/main.dart - Complete NoteCoach Application with Singing Practice
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:note_coach_new_2/pitch_lesson_step2.dart';
import 'package:note_coach_new_2/pitch_lesson_step3.dart';
import 'package:note_coach_new_2/singing_practice_screen.dart';
import 'package:note_coach_new_2/singing_practice_screens.dart';
import 'package:note_coach_new_2/vocal_range_detector_screen.dart';

void main() {
  runApp(NoteCoachApp());
}

class NoteCoachApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'NoteCoach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2196F3),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    LearningScreen(),
    SingScreen(), // New singing screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Sing',
          ),
        ],
      ),
    );
  }
}

// New Sing Screen - Main singing hub
class SingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.music_note, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('NOTECOACH'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3).withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF2196F3).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.mic, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Practice Singing',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Real-time pitch feedback & accuracy tracking',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Choose from our curated song collection and practice with professional-grade pitch detection technology.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Song Practice Button
            _buildActionCard(
              context,
              'Song Practice',
              'Practice with popular songs',
              'Real-time feedback & accuracy scoring',
              Icons.library_music,
              Color(0xFF4CAF50),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatedSongSelectionScreen()),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Free Practice Button
            _buildActionCard(
              context,
              'Free Practice',
              'Practice any melody you like',
              'Open pitch detection mode',
              Icons.keyboard_voice,
              Color(0xFFFF9800),
              () => _showComingSoonDialog(context, 'Free Practice'),
            ),
            
            SizedBox(height: 12),
            
            // Vocal Warm-up Button
            _buildActionCard(
              context,
              'Vocal Warm-up',
              'Prepare your voice for singing',
              'Guided vocal exercises',
              Icons.self_improvement,
              Color(0xFF9C27B0),
              () => _showComingSoonDialog(context, 'Vocal Warm-up'),
            ),
            
            SizedBox(height: 24),
            
            // Featured Songs Preview
            Text(
              'Featured Songs',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Song Cards
            Container(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: SimpleSongDatabase.getSongs().map((song) {
                  final voiceColor = SimpleSongDatabase.getVoiceTypeColor(song.voiceType);
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [voiceColor.withOpacity(0.1), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: voiceColor.withOpacity(0.3)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnhancedSongPreviewScreen(song: song),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [voiceColor, voiceColor.withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.music_note, color: Colors.white, size: 28),
                              ),
                              SizedBox(height: 16),
                              Text(
                                song.title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: voiceColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: voiceColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  song.voiceType,
                                  style: TextStyle(
                                    color: voiceColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.construction, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: Text('$feature feature is currently under development and will be available in a future update.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2196F3)),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Original Home Screen - White Theme (kept as is)
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.music_note, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('NOTECOACH'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF2196F3),
                    child: Text(
                      'AH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        Text(
                          'Amir Hakim !',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Free User',
                          style: TextStyle(color: Color(0xFF2196F3), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Start Learning Section
            Row(
              children: [
                Text(
                  'Start/Continue Learning Course',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward, color: Colors.grey[600], size: 20),
              ],
            ),
            SizedBox(height: 12),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LearningScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.headset, color: Color(0xFF2196F3), size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Get the perfect pitch by practicing with your sweet voice',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Browse Section
            Text(
              'Browse Version',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            // Browse Cards
            Row(
              children: [
                // Expanded(
                //   child: _buildBrowseCard(
                //     context,
                //     'SONG PRACTICE',
                //     'Practice with real songs',
                //     () => Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => UpdatedSongSelectionScreen()),
                //     ),
                //   ),
                // ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildBrowseCard(
                    context,
                    'VOCAL RANGE',
                    'Test your vocal range',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImprovedVocalRangeDetector()),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Recently Played Section
            Text(
              'Recently Played',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No recent sessions',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseCard(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(Icons.music_note, color: Color(0xFF2196F3), size: 30),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 9,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Learning Screen - List of lessons with White Theme (kept as is)
class LearningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Course'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildLearningCard(
            context,
            'Pitching',
            'Learn about pitch and frequency',
            Icons.graphic_eq,
            Color(0xFF2196F3),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PitchLessonStep1()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard(BuildContext context, String title, String subtitle, 
      IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: Color(0xFFF5F5F5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 25,
          child: Icon(icon, color: Colors.white, size: 25),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
        onTap: onTap,
      ),
    );
  }
}

// Keep all the existing lesson classes as they were
class PitchLessonStep1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.music_note, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('NOTECOACH'),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Header with Progress
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pitch Lesson',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lightbulb, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Step 1 of 4',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.25, // 25% progress (step 1 of 4)
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Welcome Section
            Text(
              'Welcome to Pitch Training!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            Text(
              'In this lesson, you\'ll learn about pitch and how it affects your singing. We\'ll guide you through understanding what pitch is and how to recognize different pitches.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 24),
            
            // What You'll Learn Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What You\'ll Learn:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildLearningPoint('What is pitch and frequency'),
                  _buildLearningPoint('How to recognize different pitches'),
                  _buildLearningPoint('Practice listening to various tones'),
                  _buildLearningPoint('Test your vocal range'),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Fun Fact Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Fun Fact!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'The human ear can detect pitch differences as small as 1 Hz! This amazing ability helps us enjoy music and communicate effectively.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Navigation Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PitchLessonStep2()),
                ),
                icon: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                label: Text('Start Learning', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}