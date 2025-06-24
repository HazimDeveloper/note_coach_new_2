import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:note_coach_new_2/pitch_lesson_step3.dart';

// Pitch Lesson Step 2 - Listen to Different Pitches (White Theme)
class PitchLessonStep2 extends StatefulWidget {
  @override
  _PitchLessonStep2State createState() => _PitchLessonStep2State();
}

class _PitchLessonStep2State extends State<PitchLessonStep2> {
  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Audio files mapping
  final Map<String, String> audioTones = {
    'A3': 'audio/tones/A3_220Hz.mp3',  // Remove 'assets/' prefix for audioplayers
    'C4': 'audio/tones/C4_262Hz.mp3', 
    'E4': 'audio/tones/E4_330Hz.mp3',
    'A4': 'audio/tones/A4_440Hz.mp3',
  };
  
  final Map<String, String> frequencies = {
    'A3': '220 Hz',
    'C4': '262 Hz',
    'E4': '330 Hz', 
    'A4': '440 Hz',
  };

  String? currentlyPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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

  Future<void> _playTone(String note) async {
    try {
      if (currentlyPlaying == note) {
        // Stop current tone
        await _audioPlayer.stop();
        setState(() {
          currentlyPlaying = null;
        });
      } else {
        // Stop any currently playing audio
        await _audioPlayer.stop();
        
        // Play new tone
        setState(() {
          currentlyPlaying = note;
        });
        
        // Play audio from assets
        await _audioPlayer.play(AssetSource(audioTones[note]!));
        
        // Listen for completion
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              currentlyPlaying = null;
            });
          }
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      // If file not found, show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio file not found: ${audioTones[note]}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        currentlyPlaying = null;
      });
    }
  }
}