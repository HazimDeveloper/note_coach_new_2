// lib/singing_practice_screen.dart - SIMPLIFIED but FUNCTIONAL Version
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// SIMPLE Song Data Structure
class SimpleSongData {
  final String title;
  final String artist;
  final String voiceType;
  final Duration duration;
  final List<LyricSegment> lyrics;
  final String previewPath; // <-- add this line

  SimpleSongData({
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.duration,
    required this.lyrics,
    required this.previewPath, // <-- add this line
  });
}

class LyricSegment {
  final String text;
  final double startTime;
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

// SIMPLE Song Database
class SimpleSongDatabase {
  static List<SimpleSongData> getSongs() {
    return [
      SimpleSongData(
        title: "Test Song",
        artist: "Test Artist",
        voiceType: "TENOR",
        duration: Duration(seconds: 20),
        lyrics: [
          LyricSegment(
            text: "Hello world",
            startTime: 2.0,
            endTime: 4.0,
            targetFrequency: 220.0, // A3
            targetNote: "A3",
          ),
          LyricSegment(
            text: "This is a test",
            startTime: 5.0,
            endTime: 7.0,
            targetFrequency: 246.94, // B3
            targetNote: "B3",
          ),
          LyricSegment(
            text: "Singing practice",
            startTime: 8.0,
            endTime: 10.0,
            targetFrequency: 261.63, // C4
            targetNote: "C4",
          ),
          LyricSegment(
            text: "Real time feedback",
            startTime: 12.0,
            endTime: 15.0,
            targetFrequency: 293.66, // D4
            targetNote: "D4",
          ),
          LyricSegment(
            text: "End of song",
            startTime: 16.0,
            endTime: 18.0,
            targetFrequency: 220.0, // A3
            targetNote: "A3",
          ),
        ],
        previewPath: "song/preview/Test Song.mp3", // <-- add this line
      ),
    ];
  }

  static Color getVoiceTypeColor(String voiceType) {
    switch (voiceType.toUpperCase()) {
      case 'TENOR':
        return Color(0xFF32CD32);
      case 'ALTO':
        return Color(0xFFFF6347);
      case 'BARITONE':
        return Color(0xFF4169E1);
      default:
        return Color(0xFF2196F3);
    }
  }
}

// SIMPLE Real-time Pitch Detection
class SimplePitchDetector {
  static double detectPitch(List<double> samples, int sampleRate) {
    if (samples.length < 1024) return 0.0;
    
    // Simple autocorrelation
    List<double> autocorr = List.filled(samples.length ~/ 2, 0.0);
    
    for (int lag = 0; lag < samples.length ~/ 2; lag++) {
      double sum = 0.0;
      for (int i = 0; i < samples.length - lag; i++) {
        sum += samples[i] * samples[i + lag];
      }
      autocorr[lag] = sum;
    }
    
    // Find first peak
    double maxVal = autocorr[0];
    int bestLag = 0;
    
    for (int lag = sampleRate ~/ 800; lag < sampleRate ~/ 80; lag++) {
      if (lag < autocorr.length && autocorr[lag] > maxVal * 0.5) {
        maxVal = autocorr[lag];
        bestLag = lag;
        break;
      }
    }
    
    if (bestLag == 0) return 0.0;
    return sampleRate / bestLag;
  }

  static double calculateAccuracy(double detected, double target) {
    if (target == 0 || detected == 0) return 0.0;
    
    double ratio = detected / target;
    double cents = 1200 * log(ratio) / ln2;
    double accuracy = max(0.0, 1.0 - (cents.abs() / 50.0));
    return accuracy.clamp(0.0, 1.0);
  }

  static String frequencyToNote(double frequency) {
    if (frequency <= 0) return "---";
    
    const Map<String, double> notes = {
      'A3': 220.00,
      'A#3': 233.08,
      'B3': 246.94,
      'C4': 261.63,
      'C#4': 277.18,
      'D4': 293.66,
      'D#4': 311.13,
      'E4': 329.63,
      'F4': 349.23,
      'F#4': 369.99,
      'G4': 392.00,
      'G#4': 415.30,
    };
    
    String closestNote = '---';
    double minDiff = double.infinity;
    
    notes.forEach((note, freq) {
      double diff = (frequency - freq).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestNote = note;
      }
    });
    
    return minDiff < 25.0 ? closestNote : '---';
  }
}

// MAIN SIMPLIFIED SINGING PRACTICE SCREEN
class SimplifiedSingingPracticeScreen extends StatefulWidget {
  final SimpleSongData song;

  const SimplifiedSingingPracticeScreen({Key? key, required this.song}) : super(key: key);

  @override
  _SimplifiedSingingPracticeScreenState createState() => _SimplifiedSingingPracticeScreenState();
}

class _SimplifiedSingingPracticeScreenState extends State<SimplifiedSingingPracticeScreen> {
  
  // Audio components
  final AudioRecorder _recorder = AudioRecorder();
  
  // State variables
  bool isRecording = false;
  bool isPlaying = false;
  
  // Real-time detection
  double currentTime = 0.0;
  String currentLyric = 'Ready to start...';
  String targetNote = '';
  double targetFrequency = 0.0;
  double detectedFrequency = 0.0;
  String detectedNote = '';
  double accuracy = 0.0;
  bool isOnPitch = false;
  
  // Audio data
  String? audioFilePath;
  static const int sampleRate = 44100;
  
  // Timers
  Timer? progressTimer;
  Timer? pitchTimer;
  
  // Current segment tracking
  LyricSegment? currentSegment;
  int currentSegmentIndex = -1;
  
  // Performance data
  List<double> accuracyHistory = [];
  int correctNotes = 0;
  int totalNotes = 0;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    _stopPractice();
    progressTimer?.cancel();
    pitchTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    await Permission.microphone.request();
  }

  Future<void> _startPractice() async {
    try {
      setState(() {
        isRecording = true;
        isPlaying = true;
        currentTime = 0.0;
        currentLyric = 'Starting...';
        accuracyHistory.clear();
        correctNotes = 0;
        totalNotes = 0;
      });

      // Setup audio file
      final directory = await getTemporaryDirectory();
      audioFilePath = '${directory.path}/practice_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: sampleRate,
          numChannels: 1,
        ),
        path: audioFilePath!,
      );

      // Start timers
      _startProgressTimer();
      _startPitchAnalysis();

    } catch (e) {
      print('Error starting practice: $e');
      _showError('Failed to start practice');
    }
  }

  void _startProgressTimer() {
    progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        currentTime += 0.1;
      });

      // Check if song finished
      if (currentTime >= widget.song.duration.inSeconds) {
        _stopPractice();
        _showResults();
        return;
      }

      // Update current lyric segment
      _updateCurrentSegment();
    });
  }

  void _updateCurrentSegment() {
    LyricSegment? newSegment;
    int newIndex = -1;

    for (int i = 0; i < widget.song.lyrics.length; i++) {
      final segment = widget.song.lyrics[i];
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
        
        if (newSegment != null) {
          currentLyric = newSegment.text;
          targetNote = newSegment.targetNote;
          targetFrequency = newSegment.targetFrequency;
        } else {
          currentLyric = '♪ Instrumental ♪';
          targetNote = '';
          targetFrequency = 0.0;
        }
      });
    }
  }

  void _startPitchAnalysis() {
    pitchTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!isRecording) {
        timer.cancel();
        return;
      }

      _analyzePitch();
    });
  }

  Future<void> _analyzePitch() async {
    if (audioFilePath == null || !File(audioFilePath!).existsSync()) {
      return;
    }

    try {
      final audioFile = File(audioFilePath!);
      final fileSize = await audioFile.length();
      
      if (fileSize < 8000) return;
      
      final audioBytes = await audioFile.readAsBytes();
      List<double> samples = _convertBytesToSamples(audioBytes);
      
      if (samples.length < 1000) return;

      // Get recent samples
      int startIndex = samples.length > sampleRate ? samples.length - sampleRate : 0;
      List<double> recentSamples = samples.sublist(startIndex);
      
      // Detect pitch
      double frequency = SimplePitchDetector.detectPitch(recentSamples, sampleRate);
      
      if (frequency > 80 && frequency < 600) {
        _updateDetection(frequency);
      } else {
        _clearDetection();
      }
    } catch (e) {
      print('Error analyzing pitch: $e');
    }
  }

  List<double> _convertBytesToSamples(Uint8List bytes) {
    List<double> samples = [];
    int startIndex = min(44, bytes.length);
    
    for (int i = startIndex; i < bytes.length - 1; i += 2) {
      if (i + 1 < bytes.length) {
        int sample16 = bytes[i] | (bytes[i + 1] << 8);
        if (sample16 > 32767) sample16 -= 65536;
        double normalizedSample = sample16 / 32768.0;
        samples.add(normalizedSample);
      }
    }
    
    return samples;
  }

  void _updateDetection(double frequency) {
    setState(() {
      detectedFrequency = frequency;
      detectedNote = SimplePitchDetector.frequencyToNote(frequency);
    });

    if (currentSegment != null && targetFrequency > 0) {
      accuracy = SimplePitchDetector.calculateAccuracy(frequency, targetFrequency);
      isOnPitch = accuracy > 0.7;
      
      // Track performance
      accuracyHistory.add(accuracy);
      totalNotes++;
      if (isOnPitch) correctNotes++;
      
      setState(() {});
    }
  }

  void _clearDetection() {
    setState(() {
      detectedFrequency = 0.0;
      detectedNote = '';
      accuracy = 0.0;
      isOnPitch = false;
    });
  }

  void _stopPractice() {
    setState(() {
      isRecording = false;
      isPlaying = false;
    });
    
    progressTimer?.cancel();
    pitchTimer?.cancel();
    _recorder.stop();
    
    // Clean up audio file
    if (audioFilePath != null && File(audioFilePath!).existsSync()) {
      File(audioFilePath!).delete().catchError((_) {});
    }
  }

  void _showResults() {
    double overallAccuracy = accuracyHistory.isNotEmpty 
        ? accuracyHistory.reduce((a, b) => a + b) / accuracyHistory.length 
        : 0.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Practice Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Overall Accuracy: ${(overallAccuracy * 100).toInt()}%'),
            Text('Correct Notes: $correctNotes / $totalNotes'),
            Text('Success Rate: ${totalNotes > 0 ? (correctNotes / totalNotes * 100).toInt() : 0}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startPractice();
            },
            child: Text('Practice Again'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Color _getFeedbackColor() {
    if (targetFrequency == 0) return Colors.grey;
    if (accuracy > 0.8) return Colors.green;
    if (accuracy > 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getFeedbackText() {
    if (targetFrequency == 0) return 'No target note';
    if (accuracy > 0.8) return 'Perfect!';
    if (accuracy > 0.6) return 'Good!';
    if (accuracy > 0.4) return 'Adjust pitch';
    return 'Off pitch';
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.song.duration.inSeconds > 0 
        ? currentTime / widget.song.duration.inSeconds 
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.song.title} - Practice'),
        actions: [
          if (isPlaying)
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _stopPractice,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Song Info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.song.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.song.artist),
                    Text(widget.song.voiceType),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Progress Bar
            if (isPlaying) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${currentTime.toStringAsFixed(1)}s'),
                  Text('${widget.song.duration.inSeconds}s'),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),
            ],
            
            // Current Lyric
            Card(
              color: _getFeedbackColor().withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Current Lyric',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentLyric,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getFeedbackColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (targetNote.isNotEmpty)
                      Text(
                        'Target: $targetNote',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Detection Results
            if (isPlaying) ...[
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Your Voice'),
                            Text(
                              detectedNote.isNotEmpty ? detectedNote : '---',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text('${detectedFrequency.toStringAsFixed(1)} Hz'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      color: _getFeedbackColor().withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Accuracy'),
                            Text(
                              '${(accuracy * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                color: _getFeedbackColor(),
                              ),
                            ),
                            Text(_getFeedbackText()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Real-time Stats
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Correct Notes'),
                          Text(
                            '$correctNotes / $totalNotes',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Success Rate'),
                          Text(
                            '${totalNotes > 0 ? (correctNotes / totalNotes * 100).toInt() : 0}%',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            Spacer(),
            
            // Control Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: isPlaying ? _stopPractice : _startPractice,
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(
                  isPlaying ? 'Stop Practice' : 'Start Practice',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}