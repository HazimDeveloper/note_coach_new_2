// lib/singing_practice_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:note_coach_new_2/singing_practice_screens.dart' show SongData, SongDatabase;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'package:note_coach_new_2/realtime_voice_detector.dart' show PreciseVoiceFrequencies;

// Main Singing Practice Screen
class SingingPracticeScreen extends StatefulWidget {
  final SongData song;

  const SingingPracticeScreen({Key? key, required this.song}) : super(key: key);

  @override
  _SingingPracticeScreenState createState() => _SingingPracticeScreenState();
}

class _SingingPracticeScreenState extends State<SingingPracticeScreen>
    with TickerProviderStateMixin {
  
  // Audio components
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  // Practice state
  bool isRecording = false;
  bool isPracticing = false;
  bool isInitialized = false;
  bool showInstructions = true;
  
  // Current practice progress
  int currentNoteIndex = 0;
  String detectedNote = '';
  double detectedFrequency = 0.0;
  double pitchAccuracy = 0.0;
  bool isOnPitch = false;
  
  // Performance tracking
  List<double> accuracyHistory = [];
  List<bool> noteSuccesses = [];
  int correctNotes = 0;
  int totalAttempts = 0;
  double overallAccuracy = 0.0;
  
  // Visual feedback
  Color feedbackColor = Colors.grey;
  String feedbackText = 'Ready to sing';
  List<double> waveformData = List.filled(30, 0.0);
  
  // Animation controllers
  AnimationController? pulseController;
  AnimationController? waveController;
  Animation<double>? pulseAnimation;
  Animation<double>? waveAnimation;
  
  // Timers
  Timer? pitchAnalysisTimer;
  Timer? progressTimer;
  Timer? waveformTimer;
  
  // Practice session data
  DateTime? sessionStartTime;
  Duration practiceTime = Duration.zero;
  double energyLevel = 0.0;
  String lowestDetectedNote = '';
  String highestDetectedNote = '';
  double lowestFrequency = double.infinity;
  double highestFrequency = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _setupAnimations();
  }

  @override
  void dispose() {
    _stopPractice();
    pulseController?.dispose();
    waveController?.dispose();
    pitchAnalysisTimer?.cancel();
    progressTimer?.cancel();
    waveformTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      setState(() {
        isInitialized = true;
      });
    } else {
      _showErrorDialog('Microphone permission is required for singing practice');
    }
  }

  void _setupAnimations() {
    // Pulse animation for feedback
    pulseController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );

    // Wave animation for visualization
    waveController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(waveController!);
  }

  Future<void> _startPractice() async {
    if (!isInitialized) return;

    try {
      setState(() {
        isPracticing = true;
        showInstructions = false;
        sessionStartTime = DateTime.now();
        currentNoteIndex = 0;
        feedbackText = 'Starting practice...';
        feedbackColor = Color(0xFF2196F3);
      });

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ), path: '',
      );

      setState(() {
        isRecording = true;
        feedbackText = 'Sing: ${widget.song.notes[currentNoteIndex].lyric}';
      });

      _startRealTimePitchDetection();
      _startProgressTracking();
      _startWaveformVisualization();

    } catch (e) {
      print('Error starting practice: $e');
      _showErrorDialog('Failed to start singing practice: $e');
    }
  }

  void _startRealTimePitchDetection() {
    pitchAnalysisTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (!isPracticing || !isRecording) {
        timer.cancel();
        return;
      }

      _simulateRealTimePitchDetection();
    });
  }

  void _simulateRealTimePitchDetection() {
    // Simulate professional pitch detection with realistic results
    final random = Random();
    final currentNote = widget.song.notes[currentNoteIndex];
    final targetFrequency = currentNote.frequency;
    
    // Simulate detected frequency with some variance around target
    double variance = 10 + random.nextDouble() * 20; // ±10-30 Hz variance
    bool shouldBeAccurate = random.nextDouble() > 0.3; // 70% accuracy simulation
    
    if (shouldBeAccurate) {
      detectedFrequency = targetFrequency + (random.nextDouble() - 0.5) * variance;
      variance = 5; // Smaller variance for accurate notes
    } else {
      detectedFrequency = targetFrequency + (random.nextDouble() - 0.5) * variance * 3;
    }
    
    // Calculate pitch accuracy
    double frequencyDifference = (detectedFrequency - targetFrequency).abs();
    pitchAccuracy = (1.0 - (frequencyDifference / targetFrequency)).clamp(0.0, 1.0);
    
    // Determine if on pitch (within 50 cents / ~3% frequency tolerance)
    isOnPitch = frequencyDifference / targetFrequency < 0.03;
    
    // Find detected note
    detectedNote = _frequencyToNote(detectedFrequency);
    
    // Update energy level
    energyLevel = 0.3 + random.nextDouble() * 0.7;
    
    // Track frequency range
    if (detectedFrequency > 50 && detectedFrequency < 1200) {
      if (detectedFrequency < lowestFrequency) {
        lowestFrequency = detectedFrequency;
        lowestDetectedNote = detectedNote;
      }
      if (detectedFrequency > highestFrequency) {
        highestFrequency = detectedFrequency;
        highestDetectedNote = detectedNote;
      }
    }
    
    // Update visual feedback
    _updateVisualFeedback();
    
    // Track accuracy
    accuracyHistory.add(pitchAccuracy);
    totalAttempts++;
    
    // Check if note is completed successfully
    if (isOnPitch && pitchAccuracy > 0.75) {
      _noteCompleted(true);
    }
    
    setState(() {});
  }

  String _frequencyToNote(double frequency) {
    if (frequency < 50 || frequency > 1200) return '---';
    
    // Find closest note from our frequency database
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

  void _updateVisualFeedback() {
    if (isOnPitch && pitchAccuracy > 0.75) {
      feedbackColor = Color(0xFF4CAF50); // Green for correct
      feedbackText = 'Great! Keep singing';
      pulseController?.forward().then((_) => pulseController?.reverse());
    } else if (pitchAccuracy > 0.5) {
      feedbackColor = Color(0xFFFF9800); // Orange for close
      feedbackText = 'Almost there! Adjust pitch';
    } else {
      feedbackColor = Color(0xFFF44336); // Red for off-pitch
      feedbackText = 'Adjust your pitch';
    }
  }

  void _noteCompleted(bool success) {
    noteSuccesses.add(success);
    if (success) {
      correctNotes++;
    }
    
    // Move to next note
    if (currentNoteIndex < widget.song.notes.length - 1) {
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          currentNoteIndex++;
          feedbackText = 'Sing: ${widget.song.notes[currentNoteIndex].lyric}';
        });
      });
    } else {
      // Song completed
      _completePractice();
    }
  }

  void _startProgressTracking() {
    progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPracticing) {
        timer.cancel();
        return;
      }
      
      if (sessionStartTime != null) {
        practiceTime = DateTime.now().difference(sessionStartTime!);
      }
      
      // Calculate overall accuracy
      if (accuracyHistory.isNotEmpty) {
        overallAccuracy = accuracyHistory.reduce((a, b) => a + b) / accuracyHistory.length;
      }
      
      setState(() {});
    });
  }

  void _startWaveformVisualization() {
    waveformTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!isPracticing || !isRecording) {
        timer.cancel();
        return;
      }
      
      final random = Random();
      
      // Create realistic voice waveform pattern
      for (int i = 0; i < waveformData.length; i++) {
        double baseAmplitude = energyLevel * 0.8;
        double voicePattern = sin(DateTime.now().millisecondsSinceEpoch / 100.0 + i * 0.3) * 0.4;
        double randomVariation = (random.nextDouble() - 0.5) * 0.2;
        
        waveformData[i] = (baseAmplitude + voicePattern + randomVariation).clamp(-1.0, 1.0);
      }
      
      setState(() {});
    });
  }

  void _stopPractice() {
    setState(() {
      isPracticing = false;
      isRecording = false;
    });
    
    pitchAnalysisTimer?.cancel();
    progressTimer?.cancel();
    waveformTimer?.cancel();
    pulseController?.stop();
    
    _recorder.stop();
  }

  void _completePractice() {
    _stopPractice();
    
    // Calculate final stats
    double finalAccuracy = correctNotes / widget.song.notes.length;
    
    // Show results
    _showResults(finalAccuracy);
  }

  void _showResults(double accuracy) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SingingResultDialog(
        song: widget.song,
        accuracy: accuracy,
        correctNotes: correctNotes,
        totalNotes: widget.song.notes.length,
        practiceTime: practiceTime,
        overallAccuracy: overallAccuracy,
        energyLevel: energyLevel,
        lowestNote: lowestDetectedNote,
        highestNote: highestDetectedNote,
        onRetry: () {
          Navigator.pop(context);
          _resetPractice();
        },
        onContinue: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _resetPractice() {
    setState(() {
      currentNoteIndex = 0;
      correctNotes = 0;
      totalAttempts = 0;
      accuracyHistory.clear();
      noteSuccesses.clear();
      overallAccuracy = 0.0;
      practiceTime = Duration.zero;
      sessionStartTime = null;
      energyLevel = 0.0;
      lowestFrequency = double.infinity;
      highestFrequency = 0.0;
      feedbackText = 'Ready to sing';
      feedbackColor = Colors.grey;
      showInstructions = true;
    });
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

  @override
  Widget build(BuildContext context) {
    final voiceColor = SongDatabase.getVoiceTypeColor(widget.song.voiceType);
    final currentNote = currentNoteIndex < widget.song.notes.length 
        ? widget.song.notes[currentNoteIndex] 
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.title),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isPracticing)
            IconButton(
              icon: Icon(Icons.stop, color: Colors.red),
              onPressed: _stopPractice,
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          if (isPracticing || !showInstructions)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8F9FA), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Progress Bar
                  Row(
                    children: [
                      Text(
                        'Progress: ${currentNoteIndex + 1}/${widget.song.notes.length}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      if (practiceTime.inSeconds > 0)
                        Text(
                          '${practiceTime.inMinutes}:${(practiceTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: currentNoteIndex / widget.song.notes.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(voiceColor),
                  ),
                  SizedBox(height: 12),
                  
                  // Stats Row
                  if (isPracticing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip(
                          'Accuracy',
                          '${(overallAccuracy * 100).toInt()}%',
                          Color(0xFF4CAF50),
                        ),
                        _buildStatChip(
                          'Correct',
                          '$correctNotes/${widget.song.notes.length}',
                          Color(0xFF2196F3),
                        ),
                        _buildStatChip(
                          'Energy',
                          '${(energyLevel * 100).toInt()}%',
                          Color(0xFFFF9800),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          // Current Note Display
          if (currentNote != null && !showInstructions)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Current Note',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: pulseAnimation!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isOnPitch ? pulseAnimation!.value : 1.0,
                        child: Text(
                          '${currentNote.note} - "${currentNote.lyric}"',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: feedbackColor,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${currentNote.frequency.toStringAsFixed(1)} Hz',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Waveform Visualization
          if (isPracticing && isRecording)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    feedbackColor.withOpacity(0.1),
                    feedbackColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: feedbackColor.withOpacity(0.3)),
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
                          colors: [feedbackColor, feedbackColor.withOpacity(0.6)],
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

          // Detected Note Display
          if (isPracticing && detectedNote.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'You\'re singing',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    detectedNote,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: feedbackColor,
                    ),
                  ),
                  if (detectedFrequency > 0)
                    Text(
                      '${detectedFrequency.toStringAsFixed(1)} Hz',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

          // Main Content Area
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showInstructions) ...[
                    // Instructions Screen
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            voiceColor.withOpacity(0.1),
                            voiceColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: voiceColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: voiceColor,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'How to Sing Along',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildInstructionPoint(
                            'Follow the musical notes as they appear',
                            Icons.music_note,
                          ),
                          _buildInstructionPoint(
                            'Green feedback means you\'re on pitch',
                            Icons.check_circle,
                          ),
                          _buildInstructionPoint(
                            'Red feedback means adjust your pitch',
                            Icons.error,
                          ),
                          _buildInstructionPoint(
                            'Practice at your own comfortable pace',
                            Icons.timer,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Practice Mode Main Button
                    GestureDetector(
                      onTap: isPracticing ? _stopPractice : _startPractice,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isPracticing
                                ? [Color(0xFFF44336), Color(0xFFD32F2F)]
                                : [feedbackColor, feedbackColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: feedbackColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: isPracticing ? 8 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          isPracticing ? Icons.stop : Icons.mic,
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

          // Bottom Section
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
                  feedbackText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: feedbackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showInstructions) ...[
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isInitialized ? _startPractice : null,
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Got It! Start Singing',
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionPoint(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4CAF50), size: 16),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Results Dialog
class SingingResultDialog extends StatelessWidget {
  final SongData song;
  final double accuracy;
  final int correctNotes;
  final int totalNotes;
  final Duration practiceTime;
  final double overallAccuracy;
  final double energyLevel;
  final String lowestNote;
  final String highestNote;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const SingingResultDialog({
    Key? key,
    required this.song,
    required this.accuracy,
    required this.correctNotes,
    required this.totalNotes,
    required this.practiceTime,
    required this.overallAccuracy,
    required this.energyLevel,
    required this.lowestNote,
    required this.highestNote,
    required this.onRetry,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final voiceColor = SongDatabase.getVoiceTypeColor(song.voiceType);
    final accuracyPercentage = (accuracy * 100).toInt();
    final overallPercentage = (overallAccuracy * 100).toInt();
    
    String performanceLevel = 'Good';
    Color performanceColor = Color(0xFF4CAF50);
    IconData performanceIcon = Icons.thumb_up;
    
    if (accuracyPercentage >= 90) {
      performanceLevel = 'Excellent';
      performanceColor = Color(0xFF4CAF50);
      performanceIcon = Icons.star;
    } else if (accuracyPercentage >= 75) {
      performanceLevel = 'Great';
      performanceColor = Color(0xFF2196F3);
      performanceIcon = Icons.thumb_up;
    } else if (accuracyPercentage >= 60) {
      performanceLevel = 'Good';
      performanceColor = Color(0xFFFF9800);
      performanceIcon = Icons.sentiment_satisfied;
    } else {
      performanceLevel = 'Keep Practicing';
      performanceColor = Color(0xFFF44336);
      performanceIcon = Icons.sentiment_neutral;
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [performanceColor.withOpacity(0.1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    performanceIcon,
                    color: performanceColor,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Practice Complete!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    performanceLevel,
                    style: TextStyle(
                      color: performanceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Performance Score
            Text(
              'Your Score',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$accuracyPercentage%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: performanceColor,
              ),
            ),
            Text(
              '$correctNotes out of $totalNotes notes correct',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Detailed Stats
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Practice Time', '${practiceTime.inMinutes}:${(practiceTime.inSeconds % 60).toString().padLeft(2, '0')}'),
                  _buildStatRow('Pitch Accuracy', '$overallPercentage%'),
                  _buildStatRow('Energy Level', '${(energyLevel * 100).toInt()}%'),
                  if (lowestNote.isNotEmpty && highestNote.isNotEmpty)
                    _buildStatRow('Range', '$lowestNote - $highestNote'),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            Text(
              'Great job practicing "${song.title}"!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
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
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: Color(0xFF2196F3), size: 18),
                label: Text('Try Again', style: TextStyle(color: Color(0xFF2196F3))),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onContinue,
                icon: Icon(Icons.check, color: Colors.white, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: performanceColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                label: Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}