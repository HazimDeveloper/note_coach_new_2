

// Pitch Lesson Step 4 - Ready for Vocal Range Test
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:note_coach_new_2/main.dart';
import 'package:note_coach_new_2/vocal_range_detector_screen.dart' show EnhancedVocalRangeDetector, ImprovedVocalRangeDetector;

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
                        MaterialPageRoute(builder: (context) => ImprovedVocalRangeDetector()),
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