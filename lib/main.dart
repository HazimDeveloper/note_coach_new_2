// lib/main.dart - Complete NoteCoach Application
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

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
        ],
      ),
    );
  }
}

// Home Screen - White Theme
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
                Expanded(
                  child: _buildBrowseCard(
                    'VOCAL WARM UP',
                    'Voice Resonance',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildBrowseCard(
                    'BREATHING CONTROL',
                    'Learn and master your voice',
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

  Widget _buildBrowseCard(String title, String subtitle) {
    return Container(
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
    );
  }
}

// Learning Screen - List of lessons with White Theme
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

// Pitch Lesson Step 1 - Introduction
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

// Pitch Lesson Step 2 - Listen to Different Pitches (White Theme)
class PitchLessonStep2 extends StatefulWidget {
  @override
  _PitchLessonStep2State createState() => _PitchLessonStep2State();
}

class _PitchLessonStep2State extends State<PitchLessonStep2> {
  // Audio files mapping
  final Map<String, String> audioTones = {
    'A3': 'assets/audio/tones/A3_220Hz.mp3',
    'C4': 'assets/audio/tones/C4_262Hz.mp3', 
    'E4': 'assets/audio/tones/E4_330Hz.mp3',
    'A4': 'assets/audio/tones/A4_440Hz.mp3',
  };
  
  final Map<String, String> frequencies = {
    'A3': '220 Hz',
    'C4': '262 Hz',
    'E4': '330 Hz', 
    'A4': '440 Hz',
  };

  String? currentlyPlaying;
  
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
                    'Step 2 of 4',
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
                widthFactor: 0.5, // 50% progress (step 2 of 4)
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Title
            Text(
              'Listen to Different Pitches',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Description
            Text(
              'Let\'s hear different pitch levels. Pay attention to how they sound different.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Audio Instructions
            Text(
              'Tap to hear different pitches:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Audio Buttons Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: audioTones.keys.map((note) => _buildAudioButton(note)).toList(),
            ),
            
            SizedBox(height: 40),
            
            // What is Pitch Section
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
                    'What is Pitch?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Pitch refers to the highness or lowness of a sound, determined by its frequency. Matching pitch is essential for singing in tune.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Did You Know Section
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
                        'Did you know?',
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
                    'Pitch is just frequency.\nA higher frequency means a higher pitch.\nHigher pitch = faster vibrations.\nLower pitch = slower vibrations.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 16),
                    label: Text('Previous', style: TextStyle(color: Colors.grey[700])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PitchLessonStep3()),
                    ),
                    icon: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    label: Text('Next', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioButton(String note) {
    final isPlaying = currentlyPlaying == note;
    
    return GestureDetector(
      onTap: () => _playTone(note),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying ? Color(0xFF2196F3) : Colors.grey[400]!,
            width: isPlaying ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: isPlaying ? Color(0xFF2196F3) : Colors.grey[700],
              size: 32,
            ),
            SizedBox(height: 12),
            Text(
              note,
              style: TextStyle(
                color: isPlaying ? Color(0xFF2196F3) : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              frequencies[note]!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playTone(String note) {
    setState(() {
      if (currentlyPlaying == note) {
        // Stop current tone
        currentlyPlaying = null;
        _stopAudio();
      } else {
        // Play new tone
        currentlyPlaying = note;
        _playAudioFile(audioTones[note]!);
      }
    });
  }

  void _playAudioFile(String assetPath) {
    // TODO: Implement audio playback with audioplayers package
    print('Playing: $assetPath');
    
    // Auto-stop after 3 seconds (simulate tone duration)
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          currentlyPlaying = null;
        });
      }
    });
  }

  void _stopAudio() {
    // TODO: Implement audio stop
    print('Stopping audio');
  }
}

// Pitch Lesson Step 3 - Practice Recognition
class PitchLessonStep3 extends StatelessWidget {
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
                    'Step 3 of 4',
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
                widthFactor: 0.75, // 75% progress (step 3 of 4)
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Title
            Text(
              'Understanding Pitch Recognition',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            Text(
              'Now that you\'ve heard different pitches, let\'s understand how our ears and voice work together to recognize and match pitch.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Key Concepts
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
                    'Key Concepts:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildConceptItem(
                    '🎵',
                    'Pitch Matching',
                    'Your goal is to match the pitch you hear with your voice',
                  ),
                  _buildConceptItem(
                    '👂',
                    'Active Listening',
                    'Train your ear to recognize subtle pitch differences',
                  ),
                  _buildConceptItem(
                    '🎯',
                    'Practice Makes Perfect',
                    'Regular practice improves your pitch accuracy over time',
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Tips Section
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
                      Icon(Icons.tips_and_updates, color: Color(0xFF2196F3), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pro Tips for Pitch Training:',
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
                    '• Start with humming - it\'s easier than singing words\n'
                    '• Focus on one pitch at a time\n'
                    '• Practice regularly, even just 5 minutes daily\n'
                    '• Don\'t worry about being perfect immediately',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Ready for Test Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology, color: Color(0xFF2196F3), size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Ready for Your First Test?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Next, we\'ll help you discover your unique vocal range!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 16),
                    label: Text('Previous', style: TextStyle(color: Colors.grey[700])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PitchLessonStep4()),
                    ),
                    icon: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    label: Text('Next', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptItem(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pitch Lesson Step 4 - Ready for Vocal Range Test
class PitchLessonStep4 extends StatelessWidget {
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
                        child: Icon(Icons.check_circle, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Step 4 of 4 - Complete!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Progress Bar (100%)
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Completion Message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    color: Color(0xFF4CAF50),
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ve completed the Pitch Lesson',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // What You Learned
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
                    'What You\'ve Learned:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildLearningPoint('✓ Understanding what pitch is'),
                  _buildLearningPoint('✓ Hearing different pitch levels'),
                  _buildLearningPoint('✓ Pitch recognition techniques'),
                  _buildLearningPoint('✓ Ready for vocal range testing'),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Next Step
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.mic, color: Color(0xFF4CAF50), size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Ready for Vocal Range Test?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Now that you understand pitch, let\'s discover your unique vocal range!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 16),
                    label: Text('Previous', style: TextStyle(color: Colors.grey[700])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Vocal Range Test
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VocalRangeIntroScreen()),
                      );
                    },
                    icon: Icon(Icons.mic, color: Colors.white, size: 16),
                    label: Text('Test Vocal Range', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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

// Individual Notes Lesson Screen - White Theme
class NotesLessonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Course'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF2196F3),
                  child: Text('AH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12),
                Text(
                  'Learning Course',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Title with icon
            Row(
              children: [
                Icon(Icons.music_note, color: Color(0xFF4CAF50), size: 28),
                SizedBox(width: 12),
                Text(
                  'Notes in Singing',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            Text(
              'What Are Notes?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 12),
            
            Text(
              'Notes are the building blocks of music. Each note represents a specific pitch, forming the basis of melodies.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Did You Know Section
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
                        'Did you know?',
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
                    'All the music you hear. Only 12 unique notes in music exist that are just repeated in different octaves.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Next Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VocalRangeIntroScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vocal Range Introduction Screen (separate) - White Theme
class VocalRangeIntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Course'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF2196F3),
                  child: Text('AH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12),
                Text(
                  'Learning Course',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Title with icon
            Row(
              children: [
                Icon(Icons.record_voice_over, color: Color(0xFFFF9800), size: 28),
                SizedBox(width: 12),
                Text(
                  'Vocal Range',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Find your vocal range',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Vocal Range Chart (as shown in report)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // First row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['F2', 'F#2', 'G2', 'G#2', 'A2', 'A#2'].map((note) =>
                      Container(
                        width: 35,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(note, style: TextStyle(color: Colors.black, fontSize: 9)),
                        ),
                      )
                    ).toList(),
                  ),
                  SizedBox(height: 4),
                  // Second row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['B2', 'C3', 'C#3', 'D3', 'D#3', 'E3'].map((note) =>
                      Container(
                        width: 35,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(note, style: TextStyle(color: Colors.black, fontSize: 9)),
                        ),
                      )
                    ).toList(),
                  ),
                  SizedBox(height: 4),
                  // Third row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['F3', 'F#3', 'G3', 'G#3', 'A3', 'A#3'].map((note) =>
                      Container(
                        width: 35,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(note, style: TextStyle(color: Colors.black, fontSize: 9)),
                        ),
                      )
                    ).toList(),
                  ),
                  SizedBox(height: 4),
                  // Fourth row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['B3', 'C4', 'C#4', 'D4', 'D#4', 'E4'].map((note) =>
                      Container(
                        width: 35,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(note, style: TextStyle(color: Colors.black, fontSize: 9)),
                        ),
                      )
                    ).toList(),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Explanation text (exact from report)
            Text(
              'We\'ll play a series of notes until you\'ll match them by humming or singing. The app will detect your highest and lowest notes. This determines your vocal range.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 32),
            
            // Start Button (as shown in report)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to VocalRangeDetectorScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VocalRangeDetectorScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'START VOCAL RANGE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vocal Range Detector Screen - White Theme  
class VocalRangeDetectorScreen extends StatefulWidget {
  @override
  _VocalRangeDetectorScreenState createState() => _VocalRangeDetectorScreenState();
}

class _VocalRangeDetectorScreenState extends State<VocalRangeDetectorScreen>
    with TickerProviderStateMixin {

  // Musical notes with frequencies
  final List<Map<String, dynamic>> musicalNotes = [
    {'note': 'F2', 'frequency': 87.31},
    {'note': 'G2', 'frequency': 98.00},
    {'note': 'A2', 'frequency': 110.00},
    {'note': 'B2', 'frequency': 123.47},
    {'note': 'C3', 'frequency': 130.81},
    {'note': 'D3', 'frequency': 146.83},
    {'note': 'E3', 'frequency': 164.81},
    {'note': 'F3', 'frequency': 174.61},
    {'note': 'G3', 'frequency': 196.00},
    {'note': 'A3', 'frequency': 220.00},
    {'note': 'B3', 'frequency': 246.94},
    {'note': 'C4', 'frequency': 261.63},
    {'note': 'D4', 'frequency': 293.66},
    {'note': 'E4', 'frequency': 329.63},
    {'note': 'F4', 'frequency': 349.23},
    {'note': 'G4', 'frequency': 392.00},
    {'note': 'A4', 'frequency': 440.00},
    {'note': 'B4', 'frequency': 493.88},
    {'note': 'C5', 'frequency': 523.25},
  ];

  // Test states
  String currentStep = 'start';
  bool isRecording = false;
  String detectedNote = '';
  double detectedFrequency = 0.0;
  
  // Results
  String lowestNote = '';
  double lowestFrequency = 0.0;
  String highestNote = '';
  double highestFrequency = 0.0;
  String vocalRange = '';

  // Animation
  AnimationController? pulseController;
  Animation<double>? pulseAnimation;
  Timer? recordingTimer;
  Timer? simulationTimer;

  // Waveform data
  List<double> waveformData = List.filled(30, 0.0);

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController?.dispose();
    recordingTimer?.cancel();
    simulationTimer?.cancel();
    super.dispose();
  }

  void startLowestTest() {
    setState(() {
      currentStep = 'lowest';
      isRecording = true;
      detectedNote = '';
      detectedFrequency = 0.0;
    });
    
    pulseController!.repeat(reverse: true);
    startFrequencySimulation();
    
    recordingTimer = Timer(Duration(seconds: 5), () {
      stopRecording();
    });
  }

  void startHighestTest() {
    setState(() {
      currentStep = 'highest';
      isRecording = true;
      detectedNote = '';
      detectedFrequency = 0.0;
    });
    
    pulseController!.repeat(reverse: true);
    startFrequencySimulation();
    
    recordingTimer = Timer(Duration(seconds: 5), () {
      stopRecording();
    });
  }

  void startFrequencySimulation() {
    final random = Random();
    
    simulationTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (!isRecording) {
        timer.cancel();
        return;
      }

      double simulatedFreq;
      if (currentStep == 'lowest') {
        simulatedFreq = 100 + random.nextDouble() * 150;
      } else {
        simulatedFreq = 250 + random.nextDouble() * 200;
      }

      for (int i = 0; i < waveformData.length; i++) {
        waveformData[i] = random.nextDouble() * 2 - 1;
      }

      String closestNote = '';
      double closestDiff = double.infinity;
      
      for (var noteData in musicalNotes) {
        double diff = (simulatedFreq - noteData['frequency']).abs();
        if (diff < closestDiff) {
          closestDiff = diff;
          closestNote = noteData['note'];
        }
      }

      setState(() {
        detectedFrequency = simulatedFreq;
        detectedNote = closestNote;
      });
    });
  }

  void stopRecording() {
    setState(() {
      isRecording = false;
    });
    
    pulseController!.stop();
    pulseController!.reset();
    recordingTimer?.cancel();
    simulationTimer?.cancel();

    if (detectedNote.isNotEmpty) {
      if (currentStep == 'lowest') {
        lowestNote = detectedNote;
        lowestFrequency = detectedFrequency;
        
        Timer(Duration(seconds: 1), () {
          startHighestTest();
        });
      } else {
        highestNote = detectedNote;
        highestFrequency = detectedFrequency;
        calculateVocalRange();
        showResults();
      }
    }
  }

  void calculateVocalRange() {
    if (lowestFrequency <= 130 && highestFrequency <= 260) {
      vocalRange = 'BASS';
    } else if (lowestFrequency <= 130 && highestFrequency <= 349) {
      vocalRange = 'BARITONE';
    } else if (lowestFrequency <= 174 && highestFrequency <= 440) {
      vocalRange = 'TENOR';
    } else if (lowestFrequency >= 130 && highestFrequency >= 260 && highestFrequency <= 440) {
      vocalRange = 'ALTO';
    } else if (lowestFrequency >= 174 && highestFrequency >= 349) {
      vocalRange = 'SOPRANO';
    } else {
      vocalRange = 'MIXED RANGE';
    }
    
    setState(() {
      currentStep = 'results';
    });
  }

  void showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF2196F3),
                    child: Text('AH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Learning Course',
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.summarize, color: Colors.black, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Summary',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                'Results',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              
              SizedBox(height: 12),
              
              // Waveform
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(15, (index) {
                      final random = Random();
                      final height = random.nextDouble() * 40 + 10;
                      return Container(
                        width: 6,
                        height: height,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                'YOUR VOCAL RANGE',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                vocalRange,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              
              SizedBox(height: 16),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lowest:', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        Text(lowestNote, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Highest:', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        Text(highestNote, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    resetTest();
                  },
                  icon: Icon(Icons.refresh, color: Color(0xFF2196F3), size: 16),
                  label: Text('Retake', style: TextStyle(color: Color(0xFF2196F3), fontSize: 14)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Finish', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void resetTest() {
    setState(() {
      currentStep = 'start';
      detectedNote = '';
      detectedFrequency = 0.0;
      lowestNote = '';
      lowestFrequency = 0.0;
      highestNote = '';
      highestFrequency = 0.0;
      vocalRange = '';
    });
  }

  String getInstructionText() {
    switch (currentStep) {
      case 'start':
        return 'Let\'s help you find your comfortable vocal range. Tap the microphone when ready.';
      case 'lowest':
        return 'Hum or sing your LOWEST comfortable note.';
      case 'highest':
        return 'Now hum or sing your HIGHEST comfortable note.';
      default:
        return '';
    }
  }

  String getActivityTitle() {
    switch (currentStep) {
      case 'lowest':
        return 'Activity:\nFind your LOWEST comfortable note by humming.';
      case 'highest':
        return 'Activity:\nFind your HIGHEST comfortable note by humming.';
      default:
        return 'Activity:\nLet\'s discover your vocal range!';
    }
  }

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
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF2196F3),
                  child: Text('AH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12),
                Text(
                  'Learning Course',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Activity Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getActivityTitle(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Humming/Singing',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Waveform Visualization
          if (isRecording)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(waveformData.length, (index) {
                    final height = (waveformData[index].abs() * 50) + 8;
                    return Container(
                      width: 4,
                      height: height,
                      margin: EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Detected Note Display
          if (detectedNote.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Detected Note',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    detectedNote,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Text(
                    '${detectedFrequency.toStringAsFixed(1)} Hz',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

          // Microphone Button
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (currentStep == 'start') {
                        startLowestTest();
                      } else if (isRecording) {
                        stopRecording();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: pulseAnimation!,
                      builder: (context, child) {
                        return Container(
                          width: isRecording ? 100 * pulseAnimation!.value : 100,
                          height: isRecording ? 100 * pulseAnimation!.value : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording ? Color(0xFF2196F3) : Color(0xFFF5F5F5),
                            border: Border.all(
                              color: Color(0xFF2196F3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.mic,
                            color: isRecording ? Colors.white : Color(0xFF2196F3),
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    currentStep == 'start' 
                        ? 'Tap to Start Test' 
                        : isRecording 
                            ? 'Recording...' 
                            : 'Tap to Stop',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Instruction Text
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              getInstructionText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}