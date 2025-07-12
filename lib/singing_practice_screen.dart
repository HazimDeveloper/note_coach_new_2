// lib/enhanced_singing_practice_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'package:note_coach_new_2/realtime_voice_detector.dart' show PreciseVoiceFrequencies;

// Enhanced Song Data with timing and full lyrics
class LyricSegment {
  final String text;
  final double startTime; // in seconds
  final double endTime;
  final double targetFrequency;
  final String targetNote;
  
  LyricSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.targetFrequency,
    required this.targetNote,
  });
}

class EnhancedSongData {
  final String title;
  final String artist;
  final String voiceType;
  final String accompanimentPath;
  final Duration duration;
  final List<LyricSegment> lyricSegments;

  EnhancedSongData({
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.accompanimentPath,
    required this.duration,
    required this.lyricSegments,
  });
}

// Song database with full timing
class EnhancedSongDatabase {
  static List<EnhancedSongData> getSongs() {
    return [
      // AMIR JAHARI – HASRAT (BARITONE)
      EnhancedSongData(
        title: "Hasrat",
        artist: "Amir Jahari",
        voiceType: "BARITONE",
        accompanimentPath: "song/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE-Accompaniment.mp3",
        duration: Duration(minutes: 3, seconds: 30),
        lyricSegments: [
          LyricSegment(text: "Teriaklah sekuat mana pun aku", startTime: 10.0, endTime: 15.0, targetFrequency: 130.81, targetNote: "C3"),
          LyricSegment(text: "Suara ini tidak mendengar", startTime: 15.5, endTime: 20.0, targetFrequency: 146.83, targetNote: "D3"),
          LyricSegment(text: "Menangislah sesedih mana pun aku", startTime: 25.0, endTime: 30.0, targetFrequency: 164.81, targetNote: "E3"),
          LyricSegment(text: "Mata ini tidak melihat", startTime: 30.5, endTime: 35.0, targetFrequency: 174.61, targetNote: "F3"),
          LyricSegment(text: "Kau yang selama ini ku tunggu", startTime: 40.0, endTime: 45.0, targetFrequency: 130.81, targetNote: "C3"),
          LyricSegment(text: "Dimana dirimu kini berada", startTime: 45.5, endTime: 50.0, targetFrequency: 146.83, targetNote: "D3"),
        ],
      ),

      // ANDMESH KAMALENG – CINTA LUAR BIASA (TENOR MALE)
      EnhancedSongData(
        title: "Cinta Luar Biasa",
        artist: "Andmesh Kamaleng", 
        voiceType: "TENOR MALE",
        accompanimentPath: "song/Andmesh - Cinta Luar Biasa - TENOR MALE-Accompaniment.mp3",
        duration: Duration(minutes: 4, seconds: 15),
        lyricSegments: [
          LyricSegment(text: "Rasa ini tak tertahan", startTime: 8.0, endTime: 12.0, targetFrequency: 196.00, targetNote: "G3"),
          LyricSegment(text: "Hati ini selalu untukmu", startTime: 12.5, endTime: 17.0, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Cinta yang luar biasa", startTime: 22.0, endTime: 26.0, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Terlahir dari dalam jiwa", startTime: 26.5, endTime: 30.0, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Tak pernah ku rasakan", startTime: 35.0, endTime: 39.0, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Seindah cinta yang kau beri", startTime: 39.5, endTime: 44.0, targetFrequency: 246.94, targetNote: "B3"),
        ],
      ),

      // DATO' SITI NURHALIZA – BUKAN CINTA BIASA (TENOR FEMALE)
      EnhancedSongData(
        title: "Bukan Cinta Biasa", 
        artist: "Dato' Siti Nurhaliza",
        voiceType: "TENOR FEMALE",
        accompanimentPath: "song/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE-Accompaniment.mp3",
        duration: Duration(minutes: 3, seconds: 45),
        lyricSegments: [
          LyricSegment(text: "Mengapa mereka selalu bertanya", startTime: 12.0, endTime: 17.0, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Cinta ku bukan di atas kertas", startTime: 17.5, endTime: 22.0, targetFrequency: 329.63, targetNote: "E4"),
          LyricSegment(text: "Bukan cinta biasa", startTime: 27.0, endTime: 30.0, targetFrequency: 349.23, targetNote: "F4"),
          LyricSegment(text: "Yang mudah tergoda", startTime: 30.5, endTime: 34.0, targetFrequency: 392.00, targetNote: "G4"),
          LyricSegment(text: "Ini cinta yang membara", startTime: 39.0, endTime: 43.0, targetFrequency: 329.63, targetNote: "E4"),
          LyricSegment(text: "Sampai nafas terakhir", startTime: 43.5, endTime: 47.0, targetFrequency: 349.23, targetNote: "F4"),
        ],
      ),

      // AINA ABDUL – JANGAN MATI RASA ITU (ALTO)
      EnhancedSongData(
        title: "Jangan Mati Rasa Itu",
        artist: "Aina Abdul",
        voiceType: "ALTO", 
        accompanimentPath: "song/Aina Abdul - Jangan Mati Rasa Itu - ALTO-Accompaniment.mp3",
        duration: Duration(minutes: 3, seconds: 20),
        lyricSegments: [
          LyricSegment(text: "Kasihmu terus hidup", startTime: 15.0, endTime: 19.0, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Jangan mati rasa itu", startTime: 19.5, endTime: 24.0, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Walau dunia meninggalkan kita", startTime: 29.0, endTime: 34.0, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Jangan pernah berputus asa", startTime: 34.5, endTime: 39.0, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Kerana cinta yang sejati", startTime: 44.0, endTime: 48.0, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Akan kekal selamanya", startTime: 48.5, endTime: 52.0, targetFrequency: 261.63, targetNote: "C4"),
        ],
      ),
    ];
  }

  static Color getVoiceTypeColor(String voiceType) {
    switch (voiceType.toUpperCase()) {
      case 'BARITONE':
        return Color(0xFF4169E1);
      case 'TENOR MALE':
      case 'TENOR':
        return Color(0xFF32CD32);
      case 'TENOR FEMALE':
        return Color(0xFF20B2AA);
      case 'ALTO':
        return Color(0xFFFF6347);
      default:
        return Color(0xFF2196F3);
    }
  }
}

// Performance tracking data
class PerformanceData {
  final double accuracy;
  final bool wasOnPitch;
  final double detectedFrequency;
  final String detectedNote;
  final LyricSegment segment;
  
  PerformanceData({
    required this.accuracy,
    required this.wasOnPitch,
    required this.detectedFrequency,
    required this.detectedNote,
    required this.segment,
  });
}

// Main Enhanced Karaoke Singing Practice Screen
class EnhancedSingingPracticeScreen extends StatefulWidget {
  final EnhancedSongData song;

  const EnhancedSingingPracticeScreen({Key? key, required this.song}) : super(key: key);

  @override
  _EnhancedSingingPracticeScreenState createState() => _EnhancedSingingPracticeScreenState();
}

class _EnhancedSingingPracticeScreenState extends State<EnhancedSingingPracticeScreen>
    with TickerProviderStateMixin {
  
  // Audio components
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _accompanimentPlayer = AudioPlayer();
  
  // Practice state
  bool isPlaying = false;
  bool isRecording = false;
  bool isInitialized = false;
  bool showInstructions = true;
  
  // Timing and progress
  double currentTime = 0.0;
  Timer? progressTimer;
  LyricSegment? currentSegment;
  int currentSegmentIndex = -1;
  
  // Performance tracking
  List<PerformanceData> performanceHistory = [];
  double currentDetectedFrequency = 0.0;
  String currentDetectedNote = '';
  bool isCurrentlyOnPitch = false;
  double currentAccuracy = 0.0;
  
  // Visual feedback
  Color currentFeedbackColor = Colors.grey;
  String currentFeedbackText = 'Ready to sing';
  List<double> waveformData = List.filled(40, 0.0);
  
  // Animation controllers
  AnimationController? lyricAnimController;
  AnimationController? accuracyAnimController;
  Animation<double>? lyricAnimation;
  Animation<double>? accuracyAnimation;
  
  // Timers
  Timer? pitchAnalysisTimer;
  Timer? waveformTimer;
  
  // Session data
  DateTime? sessionStartTime;
  Duration totalPracticeTime = Duration.zero;
  int totalCorrectSegments = 0;
  double overallAccuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _setupAnimations();
  }

  @override
  void dispose() {
    _stopPractice();
    lyricAnimController?.dispose();
    accuracyAnimController?.dispose();
    progressTimer?.cancel();
    pitchAnalysisTimer?.cancel();
    waveformTimer?.cancel();
    _recorder.dispose();
    _accompanimentPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      setState(() {
        isInitialized = true;
      });
    } else {
      _showErrorDialog('Microphone permission required for karaoke practice');
    }
  }

  void _setupAnimations() {
    // Lyric highlight animation
    lyricAnimController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    lyricAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: lyricAnimController!, curve: Curves.easeInOut),
    );

    // Accuracy feedback animation
    accuracyAnimController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    accuracyAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: accuracyAnimController!, curve: Curves.easeOutBack),
    );
  }

  Future<void> _startKaraokePractice() async {
    if (!isInitialized) return;

    try {
      setState(() {
        isPlaying = true;
        isRecording = true;
        showInstructions = false;
        sessionStartTime = DateTime.now();
        currentTime = 0.0;
        currentSegmentIndex = -1;
        performanceHistory.clear();
        totalCorrectSegments = 0;
        currentFeedbackText = 'Karaoke starting...';
        currentFeedbackColor = Color(0xFF2196F3);
      });

      // Start accompaniment playback
      await _accompanimentPlayer.play(AssetSource(widget.song.accompanimentPath));
      
      // Start voice recording for analysis
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ), path: '',
      );

      _startProgressTracking();
      _startRealTimePitchDetection();
      _startWaveformVisualization();

      // Listen for song completion
      _accompanimentPlayer.onPlayerComplete.listen((_) {
        _completePractice();
      });

    } catch (e) {
      print('Error starting karaoke: $e');
      _showErrorDialog('Failed to start karaoke practice: $e');
    }
  }

  void _startProgressTracking() {
    progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        currentTime += 0.1;
      });

      // Update total practice time
      if (sessionStartTime != null) {
        totalPracticeTime = DateTime.now().difference(sessionStartTime!);
      }

      // Check for current lyric segment
      _updateCurrentSegment();
    });
  }

  void _updateCurrentSegment() {
    LyricSegment? newSegment;
    int newIndex = -1;

    for (int i = 0; i < widget.song.lyricSegments.length; i++) {
      final segment = widget.song.lyricSegments[i];
      if (currentTime >= segment.startTime && currentTime <= segment.endTime) {
        newSegment = segment;
        newIndex = i;
        break;
      }
    }

    if (newSegment != currentSegment) {
      setState(() {
        currentSegment = newSegment;
        currentSegmentIndex = newIndex;
      });

      if (newSegment != null) {
        lyricAnimController?.forward().then((_) => lyricAnimController?.reverse());
        setState(() {
          currentFeedbackText = 'Sing: ${newSegment?.text}';
        });
      } else {
        setState(() {
          currentFeedbackText = 'Keep singing along...';
        });
      }
    }
  }

  void _startRealTimePitchDetection() {
    pitchAnalysisTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!isPlaying || !isRecording) {
        timer.cancel();
        return;
      }

      _simulateRealTimePitchDetection();
    });
  }

  void _simulateRealTimePitchDetection() {
    final random = Random();
    
    if (currentSegment != null) {
      final targetFreq = currentSegment!.targetFrequency;
      
      // Simulate realistic pitch detection with accuracy variation
      bool shouldBeAccurate = random.nextDouble() > 0.25; // 75% accuracy simulation
      
      if (shouldBeAccurate) {
        // Simulate good singing (within ±15 Hz)
        currentDetectedFrequency = targetFreq + (random.nextDouble() - 0.5) * 30;
        currentAccuracy = 0.75 + random.nextDouble() * 0.25; // 75-100% accuracy
      } else {
        // Simulate off-pitch singing
        currentDetectedFrequency = targetFreq + (random.nextDouble() - 0.5) * 80;
        currentAccuracy = 0.3 + random.nextDouble() * 0.4; // 30-70% accuracy
      }
      
      // Determine if on pitch (within 25 Hz tolerance)
      double frequencyDiff = (currentDetectedFrequency - targetFreq).abs();
      isCurrentlyOnPitch = frequencyDiff < 25.0 && currentAccuracy > 0.7;
      
      // Find detected note
      currentDetectedNote = _frequencyToNote(currentDetectedFrequency);
      
      // Update visual feedback
      _updateRealTimeFeedback();
      
      // Store performance data for analysis
      _recordPerformanceData();
      
    } else {
      // Not in a singing segment
      currentDetectedFrequency = 0.0;
      currentAccuracy = 0.0;
      isCurrentlyOnPitch = false;
      currentDetectedNote = '';
      currentFeedbackColor = Colors.grey;
      currentFeedbackText = 'Instrumental section...';
    }
    
    setState(() {});
  }

  String _frequencyToNote(double frequency) {
    if (frequency < 50 || frequency > 1200) return '---';
    
    String closestNote = '';
    double minDifference = double.infinity;
    
    PreciseVoiceFrequencies.getAllNotes().forEach((note, noteFreq) {
      double difference = (frequency - noteFreq).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestNote = note;
      }
    });
    
    return closestNote;
  }

  void _updateRealTimeFeedback() {
    if (isCurrentlyOnPitch && currentAccuracy > 0.75) {
      currentFeedbackColor = Color(0xFF4CAF50); // Green for excellent
      currentFeedbackText = 'Perfect! Keep it up!';
      accuracyAnimController?.forward().then((_) => accuracyAnimController?.reverse());
    } else if (currentAccuracy > 0.6) {
      currentFeedbackColor = Color(0xFFFF9800); // Orange for good
      currentFeedbackText = 'Good! Adjust pitch slightly';
    } else if (currentAccuracy > 0.4) {
      currentFeedbackColor = Color(0xFFFF5722); // Red-orange for needs work
      currentFeedbackText = 'Adjust your pitch';
    } else {
      currentFeedbackColor = Color(0xFFF44336); // Red for off-pitch
      currentFeedbackText = 'Listen and match the pitch';
    }
  }

  void _recordPerformanceData() {
    if (currentSegment == null) return;
    
    performanceHistory.add(PerformanceData(
      accuracy: currentAccuracy,
      wasOnPitch: isCurrentlyOnPitch,
      detectedFrequency: currentDetectedFrequency,
      detectedNote: currentDetectedNote,
      segment: currentSegment!,
    ));
    
    if (isCurrentlyOnPitch) {
      totalCorrectSegments++;
    }
  }

  void _startWaveformVisualization() {
    waveformTimer = Timer.periodic(Duration(milliseconds: 80), (timer) {
      if (!isPlaying || !isRecording) {
        timer.cancel();
        return;
      }
      
      final random = Random();
      
      for (int i = 0; i < waveformData.length; i++) {
        if (currentSegment != null && currentDetectedFrequency > 0) {
          // Active singing waveform
          double baseAmplitude = 0.4 + (currentAccuracy * 0.5);
          double voicePattern = sin(DateTime.now().millisecondsSinceEpoch / 150.0 + i * 0.3) * 0.4;
          double randomVariation = (random.nextDouble() - 0.5) * 0.15;
          waveformData[i] = (baseAmplitude + voicePattern + randomVariation).clamp(-1.0, 1.0);
        } else {
          // Minimal background waveform
          waveformData[i] = (random.nextDouble() - 0.5) * 0.1;
        }
      }
      
      setState(() {});
    });
  }

  void _stopPractice() {
    setState(() {
      isPlaying = false;
      isRecording = false;
    });
    
    progressTimer?.cancel();
    pitchAnalysisTimer?.cancel();
    waveformTimer?.cancel();
    lyricAnimController?.stop();
    accuracyAnimController?.stop();
    
    _accompanimentPlayer.stop();
    _recorder.stop();
  }

  void _completePractice() {
    _stopPractice();
    
    // Calculate final statistics
    if (performanceHistory.isNotEmpty) {
      overallAccuracy = performanceHistory
          .map((p) => p.accuracy)
          .reduce((a, b) => a + b) / performanceHistory.length;
    }
    
    // Show comprehensive analysis
    _showDetailedAnalysis();
  }

  void _showDetailedAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KaraokeAnalysisScreen(
          song: widget.song,
          performanceHistory: performanceHistory,
          totalPracticeTime: totalPracticeTime,
          overallAccuracy: overallAccuracy,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsDisplay() {
    if (currentSegment == null) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            '♪ Instrumental ♪',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: lyricAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: lyricAnimation!.value,
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentFeedbackColor.withOpacity(0.1),
                  currentFeedbackColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: currentFeedbackColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Current Lyrics',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  currentSegment!.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: currentFeedbackColor,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Target: ${currentSegment!.targetNote} (${currentSegment!.targetFrequency.toStringAsFixed(1)} Hz)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    double progress = widget.song.duration.inSeconds > 0 
        ? currentTime / widget.song.duration.inSeconds 
        : 0.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDuration(Duration(seconds: currentTime.toInt()))}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Overall Accuracy: ${(overallAccuracy * 100).toInt()}%',
                style: TextStyle(
                  color: currentFeedbackColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatDuration(widget.song.duration)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final voiceColor = EnhancedSongDatabase.getVoiceTypeColor(widget.song.voiceType);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.song.title} - Karaoke'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isPlaying)
            IconButton(
              icon: Icon(Icons.stop, color: Colors.red),
              onPressed: _stopPractice,
            ),
        ],
      ),
      body: Column(
        children: [
          // Header with song info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8F9FA), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [voiceColor, voiceColor.withOpacity(0.7)],
                    ),
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
                        widget.song.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${widget.song.artist} • ${widget.song.voiceType}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlaying 
                        ? Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPlaying ? 'LIVE' : 'READY',
                    style: TextStyle(
                      color: isPlaying ? Color(0xFF4CAF50) : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator
          if (isPlaying) ...[
            SizedBox(height: 16),
            _buildProgressIndicator(),
          ],

          // Current lyrics display
          SizedBox(height: 20),
          if (isPlaying && !showInstructions)
            _buildLyricsDisplay(),

          // Waveform visualization
          if (isPlaying && isRecording)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentFeedbackColor.withOpacity(0.1),
                    currentFeedbackColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: currentFeedbackColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(waveformData.length, (index) {
                    final height = (waveformData[index].abs() * 40) + 8;
                    return Container(
                      width: 3,
                      height: height,
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [currentFeedbackColor, currentFeedbackColor.withOpacity(0.6)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Detected pitch display
          if (isPlaying && currentDetectedNote.isNotEmpty && currentSegment != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Your Voice',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    currentDetectedNote,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: currentFeedbackColor,
                    ),
                  ),
                  Text(
                    '${currentDetectedFrequency.toStringAsFixed(1)} Hz',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  SizedBox(height: 8),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: currentAccuracy,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
                    ),
                  ),
                  Text(
                    'Accuracy: ${(currentAccuracy * 100).toInt()}%',
                    style: TextStyle(
                      color: currentFeedbackColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Main control area
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showInstructions) ...[
                    // Instructions
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            voiceColor.withOpacity(0.1),
                            voiceColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: voiceColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.queue_music, color: voiceColor, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Karaoke Mode',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '• Full lyrics will appear with timing\n'
                            '• Sing along with the music\n'
                            '• Green = perfect pitch, Red = adjust\n'
                            '• Detailed analysis after completion',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Main karaoke button
                    GestureDetector(
                      onTap: isPlaying ? _stopPractice : null,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isPlaying
                                ? [Color(0xFFF44336), Color(0xFFD32F2F)]
                                : [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isPlaying ? Color(0xFFF44336) : Color(0xFF4CAF50)).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: isPlaying ? 8 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom feedback and controls
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Text(
                  currentFeedbackText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: currentFeedbackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showInstructions) ...[
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isInitialized ? _startKaraokePractice : null,
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Start Karaoke',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: voiceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Comprehensive Analysis Screen
class KaraokeAnalysisScreen extends StatelessWidget {
  final EnhancedSongData song;
  final List<PerformanceData> performanceHistory;
  final Duration totalPracticeTime;
  final double overallAccuracy;

  const KaraokeAnalysisScreen({
    Key? key,
    required this.song,
    required this.performanceHistory,
    required this.totalPracticeTime,
    required this.overallAccuracy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final voiceColor = EnhancedSongDatabase.getVoiceTypeColor(song.voiceType);
    
    // Calculate statistics
    Map<LyricSegment, List<PerformanceData>> segmentPerformance = {};
    for (var performance in performanceHistory) {
      if (!segmentPerformance.containsKey(performance.segment)) {
        segmentPerformance[performance.segment] = [];
      }
      segmentPerformance[performance.segment]!.add(performance);
    }

    List<Widget> analysisCards = [];
    
    // Build analysis for each segment
    segmentPerformance.forEach((segment, performances) {
      double avgAccuracy = performances.map((p) => p.accuracy).reduce((a, b) => a + b) / performances.length;
      bool needsImprovement = avgAccuracy < 0.7;
      
      analysisCards.add(
        Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: needsImprovement 
                ? Color(0xFFFFEBEE) 
                : Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: needsImprovement 
                  ? Color(0xFFE57373) 
                  : Color(0xFF81C784),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    needsImprovement ? Icons.warning : Icons.check_circle,
                    color: needsImprovement ? Color(0xFFE57373) : Color(0xFF4CAF50),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      segment.text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '${(avgAccuracy * 100).toInt()}%',
                    style: TextStyle(
                      color: needsImprovement ? Color(0xFFE57373) : Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Target: ${segment.targetNote} (${segment.targetFrequency.toStringAsFixed(1)} Hz)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (needsImprovement) ...[
                SizedBox(height: 8),
                Text(
                  '💡 Practice tip: Listen carefully to this part and try to match the pitch more precisely',
                  style: TextStyle(
                    color: Color(0xFFD84315),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Analysis'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Results Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [voiceColor.withOpacity(0.1), Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: voiceColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: voiceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.analytics, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Karaoke Analysis Complete',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Detailed breakdown of your performance',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Overall Score',
                          '${(overallAccuracy * 100).toInt()}%',
                          overallAccuracy > 0.8 ? Color(0xFF4CAF50) : 
                          overallAccuracy > 0.6 ? Color(0xFFFF9800) : Color(0xFFF44336),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Practice Time',
                          '${totalPracticeTime.inMinutes}:${(totalPracticeTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          Color(0xFF2196F3),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Segments',
                          '${segmentPerformance.length}',
                          Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Section-by-section analysis
            Text(
              'Lyric-by-Lyric Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Each section shows your pitch accuracy. Focus on red sections for improvement.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 16),
            
            ...analysisCards,
            
            SizedBox(height: 24),
            
            // Improvement suggestions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF9C27B0).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Color(0xFF9C27B0)),
                      SizedBox(width: 8),
                      Text(
                        'Improvement Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (overallAccuracy < 0.5)
                    Text('🎯 Focus on pitch matching - practice humming along first\n'
                         '📻 Listen to the original song more to internalize the melody\n'
                         '🎵 Start with slower songs to build accuracy',
                         style: TextStyle(color: Colors.grey[700], height: 1.4))
                  else if (overallAccuracy < 0.8)
                    Text('🎯 You\'re doing well! Focus on the red sections above\n'
                         '🎵 Practice difficult parts slowly and repeat\n'
                         '📈 Try more challenging songs to improve further',
                         style: TextStyle(color: Colors.grey[700], height: 1.4))
                  else
                    Text('🌟 Excellent performance! You have great pitch control\n'
                         '🎭 Try adding expression and dynamics to your singing\n'
                         '🎤 Challenge yourself with more complex songs',
                         style: TextStyle(color: Colors.grey[700], height: 1.4)),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.refresh, color: voiceColor),
                    label: Text('Practice Again', style: TextStyle(color: voiceColor)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: voiceColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.home, color: Colors.white),
                    label: Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: voiceColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}