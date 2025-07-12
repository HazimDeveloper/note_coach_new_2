// lib/updated_singing_practice_screens.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:note_coach_new_2/singing_practice_screen.dart';

// Enhanced Song Preview Screen
class EnhancedSongPreviewScreen extends StatefulWidget {
  final SimpleSongData song;

  const EnhancedSongPreviewScreen({Key? key, required this.song}) : super(key: key);

  @override
  _EnhancedSongPreviewScreenState createState() => _EnhancedSongPreviewScreenState();
}

class _EnhancedSongPreviewScreenState extends State<EnhancedSongPreviewScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initializeAudio() {
    _player.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    _player.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });
  }

  Future<void> _togglePreview() async {
    try {
      if (isPlaying) {
        await _player.stop();
        setState(() {
          isPlaying = false;
          currentPosition = Duration.zero;
        });
      } else {
        // Guna previewPath untuk preview
        await _player.play(AssetSource(widget.song.previewPath));
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      print('Error playing preview: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preview not available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceColor = SimpleSongDatabase.getVoiceTypeColor(widget.song.voiceType);

    return Scaffold(
      appBar: AppBar(
        title: Text('Song Preview'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Enhanced Song Header
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
                // Enhanced Album Art with Animation
                Hero(
                  tag: 'song_${widget.song.title}',
                  child: Container(
                    width: 140,
                    height: 140,
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
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        if (isPlaying)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // Song Title & Artist
                Text(
                  widget.song.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  widget.song.artist,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                
                // Enhanced Voice Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [voiceColor.withOpacity(0.2), voiceColor.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: voiceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.song.voiceType,
                    style: TextStyle(
                      color: voiceColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Preview Control
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _togglePreview,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: voiceColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: voiceColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isPlaying || totalDuration.inSeconds > 0) ...[
                  SizedBox(height: 16),
                  Text(
                    'Preview: ${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Enhanced Song Info
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
                  
                  // Enhanced Song Stats
                  Row(
                    children: [
                      _buildStatCard(
                        'Duration',
                        '${widget.song.duration.inMinutes}:${(widget.song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        Icons.timer,
                        Color(0xFF2196F3),
                      ),
                      SizedBox(width: 12),
                      _buildStatCard(
                        'Voice Type',
                        widget.song.voiceType.split(' ').first,
                        Icons.person,
                        Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 12),
                      _buildStatCard(
                        'Segments',
                        '${widget.song.lyrics.length}',
                        Icons.list,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.song.lyrics.take(4).map((segment) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: voiceColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  segment.text,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Enhanced Karaoke Features
                  Text(
                    'Karaoke Features',
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
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CAF50).withOpacity(0.1), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.queue_music, 'Full song karaoke with timing', Color(0xFF4CAF50)),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.mic, 'Real-time pitch detection & feedback', Color(0xFF2196F3)),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.analytics, 'Comprehensive lyric-by-lyric analysis', Color(0xFFFF9800)),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.track_changes, 'Visual accuracy indicators', Color(0xFF9C27B0)),
                        SizedBox(height: 8),
                        _buildFeatureRow(Icons.school, 'Personalized improvement tips', Color(0xFFE91E63)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced Start Button
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isPlaying) {
                    _player.stop();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SimplifiedSingingPracticeScreen(song: widget.song),
                    ),
                  );
                },
                icon: Icon(Icons.queue_music, color: Colors.white, size: 24),
                label: Text(
                  'Start Karaoke Practice',
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
                  elevation: 4,
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
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}

// Add UpdatedSongSelectionScreen here, using SimpleSongData from singing_practice_screen.dart
class UpdatedSongSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final songs = SimpleSongDatabase.getSongs();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Song - Simplified Version'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: SimpleSongDatabase.getVoiceTypeColor(song.voiceType),
                child: Icon(Icons.music_note, color: Colors.white),
              ),
              title: Text(song.title),
              subtitle: Text('${song.artist} • ${song.voiceType} • ${song.duration.inSeconds}s'),
              trailing: Icon(Icons.play_arrow),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnhancedSongPreviewScreen(song: song),
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