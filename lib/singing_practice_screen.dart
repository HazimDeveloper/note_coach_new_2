// lib/singing_practice_screen.dart - REAL Voice Detection for Karaoke
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_coach_new_2/realtime_voice_detector.dart' show PreciseVoiceFrequencies;

// Enhanced Song Data with ACCURATE timing and full lyrics
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
  final String previewPath; // NEW: Preview path
  final Duration duration;
  final List<LyricSegment> lyricSegments;

  EnhancedSongData({
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.accompanimentPath,
    required this.previewPath,
    required this.duration,
    required this.lyricSegments,
  });
}

// Song database with ACCURATE timing from user
class EnhancedSongDatabase {
  static List<EnhancedSongData> getSongs() {
    return [
      // AMIR JAHARI – HASRAT (BARITONE) - 28 seconds
      EnhancedSongData(
        title: "Hasrat",
        artist: "Amir Jahari",
        voiceType: "BARITONE",
        accompanimentPath: "song/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE-Accompaniment.mp3",
        previewPath: "song/preview/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE.mp3",
        duration: Duration(seconds: 28),
        lyricSegments: [
          LyricSegment(text: "Teriaklah", startTime: 0.02, endTime: 0.06, targetFrequency: 130.81, targetNote: "C3"),
          LyricSegment(text: "Sekuat mana pun aku", startTime: 0.06, endTime: 0.10, targetFrequency: 146.83, targetNote: "D3"),
          LyricSegment(text: "Suara ini", startTime: 0.10, endTime: 0.12, targetFrequency: 164.81, targetNote: "E3"),
          LyricSegment(text: "Tiada mendengar", startTime: 0.12, endTime: 0.17, targetFrequency: 174.61, targetNote: "F3"),
          LyricSegment(text: "Teriaklah", startTime: 0.17, endTime: 0.18, targetFrequency: 130.81, targetNote: "C3"),
          LyricSegment(text: "Berhentilah berharap", startTime: 0.18, endTime: 0.22, targetFrequency: 146.83, targetNote: "D3"),
        ],
      ),

      // ANDMESH KAMALENG – CINTA LUAR BIASA (TENOR MALE) - 29 seconds
      EnhancedSongData(
        title: "Cinta Luar Biasa",
        artist: "Andmesh Kamaleng", 
        voiceType: "TENOR MALE",
        accompanimentPath: "song/Andmesh - Cinta Luar Biasa - TENOR MALE-Accompaniment.mp3",
        previewPath: "song/preview/Andmesh - Cinta Luar Biasa - TENOR MALE.mp3",
        duration: Duration(seconds: 29),
        lyricSegments: [
          LyricSegment(text: "Rasa ini", startTime: 0.01, endTime: 0.04, targetFrequency: 196.00, targetNote: "G3"),
          LyricSegment(text: "Tak tertahan", startTime: 0.04, endTime: 0.08, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Hati ini", startTime: 0.08, endTime: 0.10, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Selalu untukmu", startTime: 0.10, endTime: 0.15, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Terimalah lagu ini", startTime: 0.15, endTime: 0.18, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Dari orang biasa", startTime: 0.18, endTime: 0.22, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Tapi cintaku padamu luar biasa", startTime: 0.22, endTime: 0.29, targetFrequency: 261.63, targetNote: "C4"),
        ],
      ),

      // DATO' SITI NURHALIZA – BUKAN CINTA BIASA (TENOR FEMALE) - 25 seconds
      EnhancedSongData(
        title: "Bukan Cinta Biasa", 
        artist: "Dato' Siti Nurhaliza",
        voiceType: "TENOR FEMALE",
        accompanimentPath: "song/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE-Accompaniment.mp3",
        previewPath: "song/preview/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE.mp3",
        duration: Duration(seconds: 25),
        lyricSegments: [
          LyricSegment(text: "Mengapa mereka selalu bertanya", startTime: 0.00, endTime: 0.07, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Cintaku bukan di atas kertas", startTime: 0.07, endTime: 0.11, targetFrequency: 329.63, targetNote: "E4"),
          LyricSegment(text: "Cintaku getaran yang sama", startTime: 0.11, endTime: 0.15, targetFrequency: 349.23, targetNote: "F4"),
          LyricSegment(text: "Tak perlu dipaksa", startTime: 0.15, endTime: 0.17, targetFrequency: 392.00, targetNote: "G4"),
          LyricSegment(text: "Tak perlu dicari", startTime: 0.17, endTime: 0.19, targetFrequency: 329.63, targetNote: "E4"),
          LyricSegment(text: "Kerna ku yakin ada jawabnya", startTime: 0.19, endTime: 0.25, targetFrequency: 349.23, targetNote: "F4"),
        ],
      ),

      // AINA ABDUL – JANGAN MATI RASA ITU (ALTO) - 32 seconds
      EnhancedSongData(
        title: "Jangan Mati Rasa Itu",
        artist: "Aina Abdul",
        voiceType: "ALTO", 
        accompanimentPath: "song/Aina Abdul - Jangan Mati Rasa Itu - ALTO-Accompaniment.mp3",
        previewPath: "song/preview/Aina Abdul - Jangan Mati Rasa Itu - ALTO.mp3",
        duration: Duration(seconds: 32),
        lyricSegments: [
          LyricSegment(text: "Kasihmu", startTime: 0.01, endTime: 0.04, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Terus hidup", startTime: 0.04, endTime: 0.07, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Jangan mati rasa", startTime: 0.07, endTime: 0.12, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Itu", startTime: 0.12, endTime: 0.17, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Bagaimana", startTime: 0.17, endTime: 0.24, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Harus ku", startTime: 0.24, endTime: 0.27, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Jalani", startTime: 0.27, endTime: 0.29, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Tanpa kamu", startTime: 0.29, endTime: 0.32, targetFrequency: 220.00, targetNote: "A3"),
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

// REAL Performance tracking data
class PerformanceData {
  final double accuracy;
  final bool wasOnPitch;
  final double detectedFrequency;
  final String detectedNote;
  final LyricSegment segment;
  final DateTime timestamp;
  
  PerformanceData({
    required this.accuracy,
    required this.wasOnPitch,
    required this.detectedFrequency,
    required this.detectedNote,
    required this.segment,
    required this.timestamp,
  });
}

// REAL Voice Detection Utils
class RealVoiceDetection {
  static double detectPitchFromSamples(List<double> samples, int sampleRate) {
    if (samples.length < 1024) return 0.0;
    
    // Apply Hann window
    List<double> windowed = _applyHannWindow(samples);
    
    // Autocorrelation pitch detection
    return _autocorrelationPitchDetection(windowed, sampleRate);
  }

  static List<double> _applyHannWindow(List<double> samples) {
    List<double> windowed = [];
    int length = samples.length;
    
    for (int i = 0; i < length; i++) {
      double window = 0.5 * (1 - cos(2 * pi * i / (length - 1)));
      windowed.add(samples[i] * window);
    }
    return windowed;
  }

  static double _autocorrelationPitchDetection(List<double> samples, int sampleRate) {
    int length = samples.length;
    List<double> autocorr = List.filled(length ~/ 2, 0.0);
    
    // Calculate autocorrelation
    for (int lag = 0; lag < length ~/ 2; lag++) {
      double sum = 0.0;
      for (int i = 0; i < length - lag; i++) {
        sum += samples[i] * samples[i + lag];
      }
      autocorr[lag] = sum;
    }
    
    // Find peak
    double maxVal = autocorr[0];
    int bestLag = 0;
    
    for (int lag = sampleRate ~/ 800; lag < sampleRate ~/ 80; lag++) {
      if (lag < autocorr.length && autocorr[lag] > maxVal * 0.5 && 
          autocorr[lag] > autocorr[lag - 1] && 
          lag + 1 < autocorr.length && autocorr[lag] > autocorr[lag + 1]) {
        maxVal = autocorr[lag];
        bestLag = lag;
        break;
      }
    }
    
    if (bestLag == 0) return 0.0;
    return sampleRate / bestLag;
  }

  static double calculateAccuracy(double detectedFreq, double targetFreq) {
    if (targetFreq == 0 || detectedFreq == 0) return 0.0;
    
    double ratio = detectedFreq / targetFreq;
    double cents = 1200 * log(ratio) / ln2;
    
    double accuracy = max(0.0, 1.0 - (cents.abs() / 50.0));
    return accuracy.clamp(0.0, 1.0);
  }

  static String frequencyToNote(double frequency) {
    if (frequency <= 0) return "---";
    
    // Find closest note
    String closestNote = '';
    double minDifference = double.infinity;
    
    PreciseVoiceFrequencies.getAllNotes().forEach((note, noteFreq) {
      double difference = (frequency - noteFreq).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestNote = note;
      }
    });
    
    return minDifference < 25.0 ? closestNote : "---";
  }
}

// Main Enhanced Karaoke Singing Practice Screen with REAL voice detection
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
  
  // REAL voice detection
  String? audioFilePath;
  List<double> audioSamples = [];
  static const int sampleRate = 44100;
  
  // Timing and progress
  double currentTime = 0.0;
  Timer? progressTimer;
  LyricSegment? currentSegment;
  int currentSegmentIndex = -1;
  
  // REAL Performance tracking
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
    
    // Clean up audio file
    if (audioFilePath != null && File(audioFilePath!).existsSync()) {
      File(audioFilePath!).delete().catchError((_) {});
    }
    
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
    lyricAnimController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    lyricAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: lyricAnimController!, curve: Curves.easeInOut),
    );

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
        audioSamples.clear();
      });

      // Setup audio file path
      final directory = await getTemporaryDirectory();
      audioFilePath = '${directory.path}/karaoke_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start accompaniment playback
      await _accompanimentPlayer.play(AssetSource(widget.song.accompanimentPath));
      
      // Start REAL voice recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: sampleRate,
          numChannels: 1,
        ), 
        path: audioFilePath!,
      );

      _startProgressTracking();
      _startRealVoicePitchDetection(); // REAL detection now!
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

      if (sessionStartTime != null) {
        totalPracticeTime = DateTime.now().difference(sessionStartTime!);
      }

      _updateCurrentSegment();
    });
  }

  // 1. Lirik keluar ikut masa
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
    // Fallback: kekalkan lirik terakhir jika currentTime > endTime terakhir
    if (newSegment == null && widget.song.lyricSegments.isNotEmpty) {
      final last = widget.song.lyricSegments.last;
      if (currentTime > last.endTime) {
        newSegment = last;
        newIndex = widget.song.lyricSegments.length - 1;
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

  // REAL Voice Detection Implementation
  void _startRealVoicePitchDetection() {
    pitchAnalysisTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!isPlaying || !isRecording) {
        timer.cancel();
        return;
      }

      _analyzeRealVoice();
    });
  }

  Future<void> _analyzeRealVoice() async {
    if (audioFilePath == null || !File(audioFilePath!).existsSync()) {
      return;
    }

    try {
      // Read current audio file
      final audioFile = File(audioFilePath!);
      final fileSize = await audioFile.length();
      
      if (fileSize < 8000) return; // Need minimum data
      
      final audioBytes = await audioFile.readAsBytes();
      List<double> samples = _convertBytesToSamples(audioBytes);
      
      if (samples.length < 1000) return;

      // Get recent samples for analysis
      int startIndex = samples.length > sampleRate ? samples.length - sampleRate : 0;
      List<double> recentSamples = samples.sublist(startIndex);
      
      // REAL pitch detection (no dummy, no fallback)
      double detectedFreq = RealVoiceDetection.detectPitchFromSamples(recentSamples, sampleRate);
      
      if (detectedFreq > 80 && detectedFreq < 600) { // Valid vocal range
        _processRealDetectedFrequency(detectedFreq);
      } else {
        // Clear detection if no valid frequency
        setState(() {
          currentDetectedFrequency = 0.0;
          currentDetectedNote = '';
          currentAccuracy = 0.0;
          isCurrentlyOnPitch = false;
        });
      }
    } catch (e) {
      print('Error analyzing real voice: $e');
    }
  }

  List<double> _convertBytesToSamples(Uint8List bytes) {
    List<double> samples = [];
    
    // Skip WAV header (44 bytes)
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

  // 2. Accuracy sentiasa update ikut suara user
  void _processRealDetectedFrequency(double frequency) {
    setState(() {
      currentDetectedFrequency = frequency;
      currentDetectedNote = RealVoiceDetection.frequencyToNote(frequency);
    });

    if (currentSegment != null) {
      // Calculate REAL accuracy (no dummy)
      currentAccuracy = RealVoiceDetection.calculateAccuracy(frequency, currentSegment!.targetFrequency);
      
      // Determine if on pitch (within tolerance)
      double frequencyDiff = (frequency - currentSegment!.targetFrequency).abs();
      isCurrentlyOnPitch = frequencyDiff < 30.0 && currentAccuracy > 0.6;
      
      // Update visual feedback based on REAL accuracy
      _updateRealTimeFeedback();
      
      // Store REAL performance data
      _recordRealPerformanceData();
    }
    
    setState(() {});
  }

  void _updateRealTimeFeedback() {
    if (isCurrentlyOnPitch && currentAccuracy > 0.8) {
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

  void _recordRealPerformanceData() {
    if (currentSegment == null) return;
    
    performanceHistory.add(PerformanceData(
      accuracy: currentAccuracy,
      wasOnPitch: isCurrentlyOnPitch,
      detectedFrequency: currentDetectedFrequency,
      detectedNote: currentDetectedNote,
      segment: currentSegment!,
      timestamp: DateTime.now(),
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
        if (currentDetectedFrequency > 0) {
          // Active singing waveform based on REAL detection
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
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
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
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [currentFeedbackColor.withOpacity(0.18), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: currentFeedbackColor.withOpacity(0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: currentFeedbackColor.withOpacity(0.08),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Current Lyrics',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  currentSegment!.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: currentFeedbackColor,
                    height: 1.3,
                    shadows: [Shadow(blurRadius: 8, color: currentFeedbackColor.withOpacity(0.18))],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Target: ${currentSegment!.targetNote} (${currentSegment!.targetFrequency.toStringAsFixed(1)} Hz)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
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
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                'Accuracy: ${(currentAccuracy * 100).toInt()}%',
                style: TextStyle(
                  color: currentFeedbackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatDuration(widget.song.duration)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  // Paparan pitch/note user secara live
  Widget _buildPitchDisplay() {
    if (!isPlaying || currentDetectedNote.isEmpty || currentSegment == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Text('Your Voice', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          SizedBox(height: 4),
          Text(
            currentDetectedNote,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: currentFeedbackColor,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${currentDetectedFrequency.toStringAsFixed(1)} Hz',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(
              value: currentAccuracy,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
              minHeight: 8,
            ),
          ),
          Text(
            'Accuracy: ${(currentAccuracy * 100).toInt()}%',
            style: TextStyle(
              color: currentFeedbackColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voiceColor = EnhancedSongDatabase.getVoiceTypeColor(widget.song.voiceType);
    
    return WillPopScope(
      onWillPop: () async {
        _stopPractice();
        return true;
      },
      child: Scaffold(
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

            // REAL detected pitch display
            if (isPlaying && currentDetectedNote.isNotEmpty && currentSegment != null)
              _buildPitchDisplay(),

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
                              'Real Voice Karaoke',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '• REAL voice detection & pitch analysis\n'
                              '• Live accuracy feedback based on your voice\n'
                              '• Green = perfect pitch, Red = adjust\n'
                              '• Professional analysis after completion',
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
                          'Start Real Voice Karaoke',
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
      ),
    );
  }
}

// Analysis Screen remains the same but now shows REAL data
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
    
    // Calculate REAL statistics
    Map<LyricSegment, List<PerformanceData>> segmentPerformance = {};
    for (var performance in performanceHistory) {
      if (!segmentPerformance.containsKey(performance.segment)) {
        segmentPerformance[performance.segment] = [];
      }
      segmentPerformance[performance.segment]!.add(performance);
    }

    List<Widget> analysisCards = [];
    
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
                  '💡 Practice tip: Focus on matching this pitch more precisely',
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
        title: Text('REAL Voice Analysis'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              'REAL Voice Analysis Complete',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Based on your actual voice detection',
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
                          'Real Score',
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
            
            Text(
              'Real Voice Analysis by Lyric',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Based on actual voice detection. Red sections need more practice.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 16),
            
            ...analysisCards,
            
            SizedBox(height: 24),
            
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