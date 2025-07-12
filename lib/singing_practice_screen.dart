// lib/enhanced_singing_practice_with_pitch_detection.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Enhanced Song Data with exact timing and frequency matching
class TimedLyricSegment {
  final String text;
  final double startTime; // in seconds
  final double endTime;
  final double targetFrequency;
  final String targetNote;
  final bool isHighlight; // untuk lyric yang perlu ditonjolkan
  
  TimedLyricSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.targetFrequency,
    required this.targetNote,
    this.isHighlight = false,
  });
}

class EnhancedSongWithPitchData {
  final String title;
  final String artist;
  final String voiceType;
  final String accompanimentPath;
  final Duration duration;
  final List<TimedLyricSegment> lyricSegments;

  EnhancedSongWithPitchData({
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.accompanimentPath,
    required this.duration,
    required this.lyricSegments,
  });
}

// Song Database with Real Timing Data
class PitchDetectionSongDatabase {
  static List<EnhancedSongWithPitchData> getSongs() {
    return [
      // 1. CINTA LUAR BIASA
      EnhancedSongWithPitchData(
        title: "Cinta Luar Biasa",
        artist: "Andmesh Kamaleng",
        voiceType: "TENOR MALE",
        accompanimentPath: "song/Andmesh - Cinta Luar Biasa - TENOR MALE-Accompaniment.mp3",
        duration: Duration(minutes: 4, seconds: 15),
        lyricSegments: [
          TimedLyricSegment(text: "Rasa ini", startTime: 1.0, endTime: 4.0, targetFrequency: 220.00, targetNote: "A3", isHighlight: true),
          TimedLyricSegment(text: "tak tertahan", startTime: 4.0, endTime: 8.0, targetFrequency: 329.63, targetNote: "E4", isHighlight: true),
          TimedLyricSegment(text: "Hati ini", startTime: 8.0, endTime: 10.0, targetFrequency: 220.00, targetNote: "A3", isHighlight: true),
          TimedLyricSegment(text: "selalu untukmu", startTime: 10.0, endTime: 11.0, targetFrequency: 277.18, targetNote: "C#4", isHighlight: true),
          TimedLyricSegment(text: "Terimalah lagu ini", startTime: 15.0, endTime: 18.0, targetFrequency: 293.66, targetNote: "D4", isHighlight: true),
          TimedLyricSegment(text: "dari orang biasa", startTime: 18.0, endTime: 19.0, targetFrequency: 220.00, targetNote: "A3", isHighlight: true),
          TimedLyricSegment(text: "Tapi cintaku padamu", startTime: 22.0, endTime: 23.0, targetFrequency: 246.94, targetNote: "B3", isHighlight: false),
          TimedLyricSegment(text: "luar biasa", startTime: 23.0, endTime: 25.0, targetFrequency: 246.94, targetNote: "B3", isHighlight: true),
        ],
      ),

      // 2. BUKAN CINTA BIASA
      EnhancedSongWithPitchData(
        title: "Bukan Cinta Biasa",
        artist: "Dato' Siti Nurhaliza",
        voiceType: "TENOR FEMALE",
        accompanimentPath: "song/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE-Accompaniment.mp3",
        duration: Duration(minutes: 3, seconds: 45),
        lyricSegments: [
          TimedLyricSegment(text: "Mengapa mereka selalu bertanya", startTime: 0.0, endTime: 1.0, targetFrequency: 392.00, targetNote: "G4", isHighlight: true),
          TimedLyricSegment(text: "Cintaku bukan di atas kertas", startTime: 7.0, endTime: 9.0, targetFrequency: 329.63, targetNote: "E4", isHighlight: true),
          TimedLyricSegment(text: "Cintaku getaran yang sama", startTime: 11.0, endTime: 12.0, targetFrequency: 369.99, targetNote: "F#4", isHighlight: true),
          TimedLyricSegment(text: "Tak perlu dipaksa", startTime: 15.0, endTime: 16.0, targetFrequency: 329.63, targetNote: "E4", isHighlight: true),
          TimedLyricSegment(text: "Tak perlu dicari", startTime: 17.0, endTime: 18.0, targetFrequency: 349.23, targetNote: "F4", isHighlight: true),
          TimedLyricSegment(text: "Kerna ku yakin ada jawabnya", startTime: 19.0, endTime: 21.0, targetFrequency: 392.00, targetNote: "G4", isHighlight: true),
        ],
      ),

      // 3. JANGAN MATI RASA ITU
      EnhancedSongWithPitchData(
        title: "Jangan Mati Rasa Itu",
        artist: "Aina Abdul",
        voiceType: "ALTO",
        accompanimentPath: "song/Aina Abdul - Jangan Mati Rasa Itu - ALTO-Accompaniment.mp3",
        duration: Duration(minutes: 3, seconds: 20),
        lyricSegments: [
          TimedLyricSegment(text: "Kasihmu", startTime: 1.0, endTime: 4.0, targetFrequency: 311.13, targetNote: "Eb4", isHighlight: true),
          TimedLyricSegment(text: "terus hidup", startTime: 4.0, endTime: 7.0, targetFrequency: 349.23, targetNote: "F4", isHighlight: true),
          TimedLyricSegment(text: "Jangan mati rasa", startTime: 7.0, endTime: 8.0, targetFrequency: 392.00, targetNote: "G4", isHighlight: true),
          TimedLyricSegment(text: "itu", startTime: 12.0, endTime: 15.0, targetFrequency: 523.25, targetNote: "C5", isHighlight: true),
          TimedLyricSegment(text: "Bagaimana", startTime: 17.0, endTime: 20.0, targetFrequency: 311.13, targetNote: "Eb4", isHighlight: true),
          TimedLyricSegment(text: "harus ku", startTime: 24.0, endTime: 27.0, targetFrequency: 277.18, targetNote: "C#4", isHighlight: true),
          TimedLyricSegment(text: "jalani", startTime: 27.0, endTime: 29.0, targetFrequency: 261.63, targetNote: "C4", isHighlight: true),
          TimedLyricSegment(text: "tanpa kamu", startTime: 29.0, endTime: 32.0, targetFrequency: 207.65, targetNote: "Ab3", isHighlight: true),
        ],
      ),

      // 4. HASRAT
      EnhancedSongWithPitchData(
        title: "Hasrat",
        artist: "Amir Jahari",
        voiceType: "BARITONE",
        accompanimentPath: "song/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE-Accompaniment.mp3",
        duration: Duration(minutes: 3, seconds: 30),
        lyricSegments: [
          TimedLyricSegment(text: "Teriaklah", startTime: 2.0, endTime: 6.0, targetFrequency: 246.94, targetNote: "B3", isHighlight: true),
          TimedLyricSegment(text: "sekuat mana pun aku", startTime: 6.0, endTime: 10.0, targetFrequency: 246.94, targetNote: "B3", isHighlight: true),
          TimedLyricSegment(text: "Suara ini", startTime: 10.0, endTime: 12.0, targetFrequency: 246.94, targetNote: "B3", isHighlight: true),
          TimedLyricSegment(text: "tiada mendengar", startTime: 12.0, endTime: 15.0, targetFrequency: 220.00, targetNote: "A3", isHighlight: true),
          TimedLyricSegment(text: "Teriaklah", startTime: 17.0, endTime: 18.0, targetFrequency: 246.94, targetNote: "B3", isHighlight: true),
          TimedLyricSegment(text: "Berhentilah berharap", startTime: 22.0, endTime: 25.0, targetFrequency: 196.00, targetNote: "G3", isHighlight: true),
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

// Performance Data for Analysis
class PitchPerformanceData {
  final double accuracy;
  final bool wasOnPitch;
  final double detectedFrequency;
  final String detectedNote;
  final TimedLyricSegment segment;
  final DateTime timestamp;
  
  PitchPerformanceData({
    required this.accuracy,
    required this.wasOnPitch,
    required this.detectedFrequency,
    required this.detectedNote,
    required this.segment,
    required this.timestamp,
  });
}

// Main Enhanced Singing Practice with Real-time Pitch Detection
class EnhancedSingingPracticeWithPitch extends StatefulWidget {
  final EnhancedSongWithPitchData song;

  const EnhancedSingingPracticeWithPitch({Key? key, required this.song}) : super(key: key);

  @override
  _EnhancedSingingPracticeWithPitchState createState() => _EnhancedSingingPracticeWithPitchState();
}

class _EnhancedSingingPracticeWithPitchState extends State<EnhancedSingingPracticeWithPitch>
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
  TimedLyricSegment? currentSegment;
  int currentSegmentIndex = -1;
  
  // Real-time pitch detection
  String? audioFilePath;
  Timer? pitchAnalysisTimer;
  double currentDetectedFrequency = 0.0;
  String currentDetectedNote = '';
  bool isCurrentlyOnPitch = false;
  double currentAccuracy = 0.0;
  double confidenceScore = 0.0;
  
  // Performance tracking
  List<PitchPerformanceData> performanceHistory = [];
  int totalCorrectSegments = 0;
  double overallAccuracy = 0.0;
  
  // Visual feedback
  Color currentFeedbackColor = Colors.grey;
  String currentFeedbackText = 'Ready to sing';
  List<double> waveformData = List.filled(40, 0.0);
  
  // Animation controllers
  AnimationController? lyricAnimController;
  AnimationController? accuracyAnimController;
  AnimationController? pulseController;
  Animation<double>? lyricAnimation;
  Animation<double>? accuracyAnimation;
  Animation<double>? pulseAnimation;
  
  // Timers
  Timer? waveformTimer;
  
  // Session data
  DateTime? sessionStartTime;
  Duration totalPracticeTime = Duration.zero;
  
  // Audio analysis parameters
  static const int sampleRate = 44100;
  static const int bufferSize = 2048;

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
    pulseController?.dispose();
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
      _showErrorDialog('Microphone permission required for pitch detection');
    }
  }

  void _setupAnimations() {
    // Lyric highlight animation
    lyricAnimController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    lyricAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: lyricAnimController!, curve: Curves.easeInOut),
    );

    // Accuracy feedback animation
    accuracyAnimController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    accuracyAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: accuracyAnimController!, curve: Curves.elasticOut),
    );

    // Pulse animation for recording indicator
    pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSingingPractice() async {
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
        currentFeedbackText = 'Practice starting...';
        currentFeedbackColor = Color(0xFF2196F3);
      });

      // Start accompaniment playback
      await _accompanimentPlayer.play(AssetSource(widget.song.accompanimentPath));
      
      // Start voice recording for real-time analysis
      final directory = await getTemporaryDirectory();
      audioFilePath = '${directory.path}/practice_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
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
      _startRealTimePitchDetection();
      _startWaveformVisualization();
      pulseController!.repeat(reverse: true);

      // Listen for song completion
      _accompanimentPlayer.onPlayerComplete.listen((_) {
        _completePractice();
      });

    } catch (e) {
      print('Error starting practice: $e');
      _showErrorDialog('Failed to start practice: $e');
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
    TimedLyricSegment? newSegment;
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
          currentFeedbackText = newSegment!.isHighlight 
              ? '♪ ${newSegment.text} ♪' 
              : 'Sing: ${newSegment.text}';
        });
      } else {
        setState(() {
          currentFeedbackText = 'Instrumental section...';
        });
      }
    }
  }

  void _startRealTimePitchDetection() {
    pitchAnalysisTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (!isPlaying || !isRecording) {
        timer.cancel();
        return;
      }

      _analyzeCurrentAudio();
    });
  }

  Future<void> _analyzeCurrentAudio() async {
    if (audioFilePath == null || !File(audioFilePath!).existsSync()) {
      return;
    }

    try {
      // Read current audio file
      final audioFile = File(audioFilePath!);
      final fileSize = await audioFile.length();
      
      // Only analyze if file has sufficient data
      if (fileSize < 8000) {
        return;
      }

      // Read the latest audio data
      final audioBytes = await audioFile.readAsBytes();
      
      // Convert bytes to audio samples for analysis
      List<double> samples = _convertBytesToSamples(audioBytes);
      
      if (samples.length < 1000) {
        return;
      }

      // Get the latest samples for analysis
      int startIndex = samples.length > sampleRate ? samples.length - sampleRate : 0;
      List<double> recentSamples = samples.sublist(startIndex);
      
      // Detect pitch using autocorrelation method
      double detectedFreq = _detectPitchAutocorrelation(recentSamples);
      
      if (detectedFreq > 50 && detectedFreq < 1200) {
        _processDetectedFrequency(detectedFreq);
      } else {
        setState(() {
          currentDetectedFrequency = 0.0;
          currentDetectedNote = '';
          currentAccuracy = 0.0;
          isCurrentlyOnPitch = false;
          confidenceScore = 0.0;
        });
      }
    } catch (e) {
      print('Error analyzing audio: $e');
    }
  }

  List<double> _convertBytesToSamples(Uint8List bytes) {
    List<double> samples = [];
    
    // WAV file has header, skip first 44 bytes for raw audio data
    int startIndex = 44;
    if (bytes.length <= startIndex) return samples;
    
    // Convert 16-bit PCM to double samples
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

  double _detectPitchAutocorrelation(List<double> samples) {
    if (samples.length < 1000) return 0.0;
    
    // Apply window to reduce noise
    List<double> windowedSamples = _applyHammingWindow(samples);
    
    // Autocorrelation method for pitch detection
    int minPeriod = (sampleRate / 1200).round();
    int maxPeriod = (sampleRate / 50).round();
    
    double maxCorrelation = 0.0;
    int bestPeriod = 0;
    
    for (int period = minPeriod; period < maxPeriod && period < windowedSamples.length ~/ 2; period++) {
      double correlation = 0.0;
      int samples_to_check = windowedSamples.length - period;
      
      for (int i = 0; i < samples_to_check; i++) {
        correlation += windowedSamples[i] * windowedSamples[i + period];
      }
      
      correlation = correlation.abs();
      
      if (correlation > maxCorrelation) {
        maxCorrelation = correlation;
        bestPeriod = period;
      }
    }
    
    if (bestPeriod > 0 && maxCorrelation > 0.3) {
      double frequency = sampleRate / bestPeriod;
      return frequency;
    }
    
    return 0.0;
  }

  List<double> _applyHammingWindow(List<double> samples) {
    List<double> windowed = [];
    int length = samples.length;
    
    for (int i = 0; i < length; i++) {
      double window = 0.54 - 0.46 * cos(2 * pi * i / (length - 1));
      windowed.add(samples[i] * window);
    }
    
    return windowed;
  }

  void _processDetectedFrequency(double frequency) {
    setState(() {
      currentDetectedFrequency = frequency;
    });

    // Find the detected note
    currentDetectedNote = _frequencyToNote(frequency);
    
    // Calculate confidence based on clarity of detection
    confidenceScore = _calculateConfidence(frequency);
    
    if (currentSegment != null) {
      // Calculate accuracy against target note
      currentAccuracy = _calculatePitchAccuracy(frequency, currentSegment!.targetFrequency);
      
      // Determine if on pitch (within acceptable range)
      double frequencyDiff = (frequency - currentSegment!.targetFrequency).abs();
      isCurrentlyOnPitch = frequencyDiff < 30.0 && currentAccuracy > 0.6;
      
      // Update visual feedback
      _updateRealTimeFeedback();
      
      // Store performance data
      _recordPerformanceData();
      
      accuracyAnimController?.forward().then((_) => accuracyAnimController?.reverse());
    } else {
      currentAccuracy = 0.0;
      isCurrentlyOnPitch = false;
      currentFeedbackColor = Colors.grey;
      currentFeedbackText = 'Instrumental section...';
    }
    
    setState(() {});
  }

  String _frequencyToNote(double frequency) {
    if (frequency < 50 || frequency > 1200) return '---';
    
    // A4 = 440 Hz is our reference
    double a4 = 440.0;
    double c0 = a4 * pow(2, -4.75);
    
    double h = 12 * (log(frequency / c0) / ln2);
    int octave = (h / 12).floor();
    int noteNumber = (h % 12).round();
    
    List<String> noteNames = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
    ];
    
    if (noteNumber < 0 || noteNumber >= noteNames.length) return "---";
    
    return noteNames[noteNumber] + octave.toString();
  }

  double _calculateConfidence(double frequency) {
    // Simple confidence calculation based on frequency stability
    return (0.7 + (Random().nextDouble() * 0.3)).clamp(0.0, 1.0);
  }

  double _calculatePitchAccuracy(double detectedFreq, double targetFreq) {
    if (targetFreq == 0 || detectedFreq == 0) return 0.0;
    
    double ratio = detectedFreq / targetFreq;
    double cents = 1200 * log(ratio) / ln2;
    
    // Perfect pitch is 0 cents, ±50 cents is acceptable
    double accuracy = max(0.0, 1.0 - (cents.abs() / 50.0));
    return accuracy.clamp(0.0, 1.0);
  }

  void _updateRealTimeFeedback() {
    if (currentSegment == null) return;

    if (isCurrentlyOnPitch && currentAccuracy > 0.8) {
      currentFeedbackColor = Color(0xFF4CAF50);
      currentFeedbackText = currentSegment!.isHighlight 
          ? '🌟 Perfect! Highlight note!' 
          : '✓ Perfect pitch!';
    } else if (currentAccuracy > 0.6) {
      currentFeedbackColor = Color(0xFFFF9800);
      currentFeedbackText = currentSegment!.isHighlight 
          ? '💫 Good! Focus on this part' 
          : 'Good! Adjust slightly';
    } else if (currentAccuracy > 0.4) {
      currentFeedbackColor = Color(0xFFFF5722);
      currentFeedbackText = currentSegment!.isHighlight 
          ? '🎯 Important part - adjust pitch' 
          : 'Adjust your pitch';
    } else {
      currentFeedbackColor = Color(0xFFF44336);
      currentFeedbackText = currentSegment!.isHighlight 
          ? '🔴 Key moment - listen carefully' 
          : 'Listen and match the pitch';
    }
  }

  void _recordPerformanceData() {
    if (currentSegment == null) return;
    
    performanceHistory.add(PitchPerformanceData(
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
        if (currentSegment != null && currentDetectedFrequency > 0) {
          double baseAmplitude = 0.4 + (currentAccuracy * 0.5);
          double frequencyFactor = (currentDetectedFrequency / 220.0).clamp(0.5, 2.0);
          double wave = sin(DateTime.now().millisecondsSinceEpoch / (200.0 / frequencyFactor) + i * 0.4) * baseAmplitude;
          double noise = (random.nextDouble() - 0.5) * 0.15;
          waveformData[i] = (wave + noise).clamp(-1.0, 1.0);
        } else {
          waveformData[i] = (random.nextDouble() - 0.5) * 0.08;
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
    pulseController?.stop();
    
    _accompanimentPlayer.stop();
    _recorder.stop();
    
    // Clean up audio file
    if (audioFilePath != null && File(audioFilePath!).existsSync()) {
      File(audioFilePath!).delete();
    }
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
        builder: (context) => PitchAnalysisScreen(
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

  @override
  Widget build(BuildContext context) {
    final voiceColor = PitchDetectionSongDatabase.getVoiceTypeColor(widget.song.voiceType);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.song.title} - Real-time Practice'),
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
                  child: Icon(Icons.graphic_eq, color: Colors.white, size: 24),
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
                        '${widget.song.artist} • Real-time Pitch Detection',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRecording 
                        ? Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRecording ? Icons.fiber_manual_record : Icons.mic_none,
                        color: isRecording ? Color(0xFF4CAF50) : Colors.grey[600],
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isRecording ? 'LIVE' : 'READY',
                        style: TextStyle(
                          color: isRecording ? Color(0xFF4CAF50) : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator
          if (isPlaying) ...[
            SizedBox(height: 16),
            Container(
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
                        'Accuracy: ${(overallAccuracy * 100).toInt()}%',
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
                    value: widget.song.duration.inSeconds > 0 
                        ? (currentTime / widget.song.duration.inSeconds).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ],

          // Current lyrics display with highlight
          SizedBox(height: 20),
          if (isPlaying && !showInstructions && currentSegment != null)
            AnimatedBuilder(
              animation: lyricAnimation!,
              builder: (context, child) {
                return Transform.scale(
                  scale: lyricAnimation!.value,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: currentSegment!.isHighlight
                            ? [
                                Color(0xFFFFD700).withOpacity(0.2),
                                Color(0xFFFFD700).withOpacity(0.1),
                              ]
                            : [
                                currentFeedbackColor.withOpacity(0.1),
                                currentFeedbackColor.withOpacity(0.05),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: currentSegment!.isHighlight
                            ? Color(0xFFFFD700).withOpacity(0.5)
                            : currentFeedbackColor.withOpacity(0.3),
                        width: currentSegment!.isHighlight ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (currentSegment!.isHighlight)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                              SizedBox(width: 4),
                              Text(
                                'HIGHLIGHT MOMENT',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                            ],
                          ),
                        if (currentSegment!.isHighlight)
                          SizedBox(height: 8),
                        Text(
                          currentSegment!.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: currentSegment!.isHighlight ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: currentSegment!.isHighlight
                                ? Color(0xFFFFD700)
                                : currentFeedbackColor,
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
            ),

          // Real-time pitch feedback
          if (isPlaying && currentDetectedNote.isNotEmpty && currentSegment != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
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
                        ],
                      ),
                      SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            'Target',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentSegment!.targetNote,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${currentSegment!.targetFrequency.toStringAsFixed(1)} Hz',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: currentAccuracy,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Accuracy: ${(currentAccuracy * 100).toInt()}%',
                        style: TextStyle(
                          color: currentFeedbackColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (confidenceScore > 0) ...[
                        SizedBox(width: 16),
                        Text(
                          'Confidence: ${(confidenceScore * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

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
                          Icon(Icons.graphic_eq, color: voiceColor, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Real-time Pitch Detection',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '• Live pitch analysis with visual feedback\n'
                            '• Special highlighting for key lyric moments\n'
                            '• Real-time accuracy scoring\n'
                            '• Professional pitch detection technology',
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
                    // Main control button during practice
                    AnimatedBuilder(
                      animation: pulseAnimation!,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _stopPractice,
                          child: Container(
                            width: 120 * pulseAnimation!.value,
                            height: 120 * pulseAnimation!.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFF44336).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.stop,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
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
                      onPressed: isInitialized ? _startSingingPractice : null,
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Start Real-time Practice',
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}

// Analysis Screen for Detailed Results
class PitchAnalysisScreen extends StatelessWidget {
  final EnhancedSongWithPitchData song;
  final List<PitchPerformanceData> performanceHistory;
  final Duration totalPracticeTime;
  final double overallAccuracy;

  const PitchAnalysisScreen({
    Key? key,
    required this.song,
    required this.performanceHistory,
    required this.totalPracticeTime,
    required this.overallAccuracy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final voiceColor = PitchDetectionSongDatabase.getVoiceTypeColor(song.voiceType);
    
    // Calculate statistics for highlight vs regular segments
    var highlightPerformances = performanceHistory.where((p) => p.segment.isHighlight).toList();
    var regularPerformances = performanceHistory.where((p) => !p.segment.isHighlight).toList();
    
    double highlightAccuracy = highlightPerformances.isNotEmpty 
        ? highlightPerformances.map((p) => p.accuracy).reduce((a, b) => a + b) / highlightPerformances.length
        : 0.0;
        
    double regularAccuracy = regularPerformances.isNotEmpty 
        ? regularPerformances.map((p) => p.accuracy).reduce((a, b) => a + b) / regularPerformances.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Analysis'),
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
                              'Real-time Pitch Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Professional accuracy assessment',
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
                          '${performanceHistory.length}',
                          Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Highlight vs Regular Performance
            Text(
              'Performance Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFFD700).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                            SizedBox(width: 4),
                            Text(
                              'HIGHLIGHT MOMENTS',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${(highlightAccuracy * 100).toInt()}%',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${highlightPerformances.length} segments',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'REGULAR SEGMENTS',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${(regularAccuracy * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${regularPerformances.length} segments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
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
                        'Performance Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (highlightAccuracy < regularAccuracy)
                    Text('🌟 Focus more on the highlighted moments - they\'re the key parts of the song!\n'
                         '🎯 Practice the starred sections slowly to improve accuracy\n'
                         '📈 Your regular singing is good, now master the highlights',
                         style: TextStyle(color: Colors.grey[700], height: 1.4))
                  else if (highlightAccuracy > 0.8)
                    Text('🌟 Excellent work on the highlighted sections!\n'
                         '🎵 You\'ve mastered the key moments of the song\n'
                         '🚀 Try more challenging songs to continue improving',
                         style: TextStyle(color: Colors.grey[700], height: 1.4))
                  else
                    Text('🎯 Good progress! Focus on both highlighted and regular sections\n'
                         '📚 Listen to the original song more to internalize the melody\n'
                         '⭐ Pay special attention to the starred moments',
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