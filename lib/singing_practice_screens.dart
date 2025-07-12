// lib/singing_practice_screens.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:note_coach_new_2/singing_practice_screen.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';

// Song Data Model with actual accompaniment files
class Note {
  final String note;
  final String lyric;
  final double frequency;

  Note({required this.note, required this.lyric, required this.frequency});
}

class SongData {
  final String title;
  final String artist;
  final String voiceType;
  final String lyrics;
  final String accompanimentPath; // Path to actual MP3 file
  final Duration estimatedDuration;
  final List<Note> notes;

  SongData({
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.lyrics,
    required this.accompanimentPath,
    required this.notes,
    this.estimatedDuration = const Duration(minutes: 3),
  });
}

// Song Database with actual accompaniment files
class SongDatabase {
  static List<SongData> getSongs() {
    return [
      // AMIR JAHARI – HASRAT (BARITONE)
      SongData(
        title: "Hasrat",
        artist: "Amir Jahari",
        voiceType: "BARITONE",
        lyrics: "Teriaklah sekuat mana pun aku suara ini tidak mendengar...",
        accompanimentPath: "song/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE-Accompaniment.mp3",
        notes: [
          Note(note: "C3", lyric: "Te", frequency: 130.81),
          Note(note: "D3", lyric: "ri", frequency: 146.83),
          Note(note: "E3", lyric: "ak", frequency: 164.81),
          Note(note: "F3", lyric: "lah", frequency: 174.61),
        ],
        estimatedDuration: Duration(minutes: 3, seconds: 30),
      ),

      // ANDMESH KAMALENG – CINTA LUAR BIASA (TENOR MALE)
      SongData(
        title: "Cinta Luar Biasa",
        artist: "Andmesh Kamaleng",
        voiceType: "TENOR MALE",
        lyrics: "Rasa ini tak tertahan hati ini selalu untukmu...",
        accompanimentPath: "song/Andmesh - Cinta Luar Biasa - TENOR MALE-Accompaniment.mp3",
        notes: [
          Note(note: "G3", lyric: "Ra", frequency: 196.00),
          Note(note: "A3", lyric: "sa", frequency: 220.00),
          Note(note: "B3", lyric: "in", frequency: 246.94),
          Note(note: "C4", lyric: "i", frequency: 261.63),
        ],
        estimatedDuration: Duration(minutes: 4, seconds: 15),
      ),

      // DATO' SITI NURHALIZA – BUKAN CINTA BIASA (TENOR FEMALE)
      SongData(
        title: "Bukan Cinta Biasa",
        artist: "Dato' Siti Nurhaliza",
        voiceType: "TENOR FEMALE",
        lyrics: "Mengapa mereka selalu bertanya cinta ku bukan di atas kertas...",
        accompanimentPath: "song/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE-Accompaniment.mp3",
        notes: [
          Note(note: "D4", lyric: "Me", frequency: 293.66),
          Note(note: "E4", lyric: "nga", frequency: 329.63),
          Note(note: "F4", lyric: "pa", frequency: 349.23),
          Note(note: "G4", lyric: "me", frequency: 392.00),
        ],
        estimatedDuration: Duration(minutes: 3, seconds: 45),
      ),

      // AINA ABDUL – JANGAN MATI RASA ITU (ALTO)
      SongData(
        title: "Jangan Mati Rasa Itu",
        artist: "Aina Abdul",
        voiceType: "ALTO",
        lyrics: "Kasihmu terus hidup jangan mati rasa itu...",
        accompanimentPath: "song/Aina Abdul - Jangan Mati Rasa Itu - ALTO-Accompaniment.mp3",
        notes: [
          Note(note: "A3", lyric: "Ka", frequency: 220.00),
          Note(note: "B3", lyric: "sih", frequency: 246.94),
          Note(note: "C4", lyric: "mu", frequency: 261.63),
          Note(note: "D4", lyric: "te", frequency: 293.66),
        ],
        estimatedDuration: Duration(minutes: 3, seconds: 20),
      ),
    ];
  }

  static Color getVoiceTypeColor(String voiceType) {
    switch (voiceType.toUpperCase()) {
      case 'BARITONE':
        return Color(0xFF4169E1); // Royal Blue
      case 'TENOR MALE':
      case 'TENOR':
        return Color(0xFF32CD32); // Lime Green
      case 'TENOR FEMALE':
        return Color(0xFF20B2AA); // Light Sea Green
      case 'ALTO':
        return Color(0xFFFF6347); // Tomato
      default:
        return Color(0xFF2196F3); // Default Blue
    }
  }
}

// Song Selection Screen
class SongSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final songs = SongDatabase.getSongs();

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
          // Header Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8F9FA), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
                      child: Icon(Icons.library_music, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Song',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Choose a song and practice singing',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_note, color: Color(0xFF4CAF50), size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${songs.length} Songs Available',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
                      ),
                      child: Text(
                        'Real-time Feedback',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Songs List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final voiceColor = SongDatabase.getVoiceTypeColor(song.voiceType);

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongPreviewScreen(song: song),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Album Art Placeholder
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
                              child: Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            
                            // Song Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    song.artist,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: voiceColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: voiceColor.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          song.voiceType,
                                          style: TextStyle(
                                            color: voiceColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${song.estimatedDuration.inMinutes}:${(song.estimatedDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Play Icon
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: voiceColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: voiceColor,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Song Preview Screen
class SongPreviewScreen extends StatelessWidget {
  final SongData song;

  const SongPreviewScreen({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final voiceColor = SongDatabase.getVoiceTypeColor(song.voiceType);

    return Scaffold(
      appBar: AppBar(
        title: Text('Song Preview'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Song Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [voiceColor.withOpacity(0.1), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Album Art
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [voiceColor, voiceColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: voiceColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                SizedBox(height: 20),
                
                // Song Title & Artist
                Text(
                  song.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  song.artist,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                
                // Voice Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: voiceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: voiceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    song.voiceType,
                    style: TextStyle(
                      color: voiceColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Song Info
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This Song',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Song Stats
                  Row(
                    children: [
                      _buildStatCard(
                        'Duration',
                        '${song.estimatedDuration.inMinutes}:${(song.estimatedDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                        Icons.timer,
                        Color(0xFF2196F3),
                      ),
                      SizedBox(width: 12),
                      _buildStatCard(
                        'Voice Type',
                        song.voiceType.split(' ').first,
                        Icons.person,
                        Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 12),
                      _buildStatCard(
                        'Difficulty',
                        'Medium',
                        Icons.bar_chart,
                        Color(0xFFFF9800),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Lyrics Preview
                  Text(
                    'Lyrics Preview',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      song.lyrics,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Practice Features
                  Text(
                    'Practice Features',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.mic, 'Real-time pitch detection', voiceColor),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.headset, 'Full song accompaniment', voiceColor),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.analytics, 'Accuracy scoring & feedback', voiceColor),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.track_changes, 'Progress tracking', voiceColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Start Singing Button
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingingPracticeScreen(song: song),
                    ),
                  );
                },
                icon: Icon(Icons.mic, color: Colors.white),
                label: Text(
                  'Start Singing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: voiceColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}