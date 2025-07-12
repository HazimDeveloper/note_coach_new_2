// lib/singing_practice_screen.dart - FIXED Professional Karaoke with Real Voice Detection
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

// FIXED Lyric Segment with ACCURATE timing from user
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

// FIXED Song Data with ACCURATE timing provided by user
class EnhancedSongData {
  final String title;
  final String artist;
  final String voiceType;
  final String accompanimentPath;
  final String previewPath;
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

// FIXED Song Database with EXACT timing from user
class EnhancedSongDatabase {
  static List<EnhancedSongData> getSongs() {
    return [
      // AMIR JAHARI – HASRAT (BARITONE) - FIXED TIMING
      EnhancedSongData(
        title: "Hasrat",
        artist: "Amir Jahari",
        voiceType: "BARITONE",
        accompanimentPath: "song/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE-Accompaniment.mp3",
        previewPath: "song/preview/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE.mp3",
        duration: Duration(seconds: 28),
        lyricSegments: [
          LyricSegment(text: "Teriaklah", startTime: 2.0, endTime: 4.5, targetFrequency: 130.81, targetNote: "C3"),
          LyricSegment(text: "Sekuat mana pun aku", startTime: 6.0, endTime: 8.5, targetFrequency: 146.83, targetNote: "D3"),
          LyricSegment(text: "Suara ini", startTime: 10.0, endTime: 11.5, targetFrequency: 164.81, targetNote: "E3"),
          LyricSegment(text: "Tiada mendengar", startTime: 12.0, endTime: 15.0, targetFrequency: 174.61, targetNote: "F3"),
          LyricSegment(text: "Teriaklah", startTime: 17.0, endTime: 18.5, targetFrequency: 130.81, targetNote: "C3"),
          LyricSegment(text: "Berhentilah berharap", startTime: 22.0, endTime: 26.0, targetFrequency: 146.83, targetNote: "D3"),
        ],
      ),

      // ANDMESH KAMALENG – CINTA LUAR BIASA (TENOR MALE) - FIXED TIMING  
      EnhancedSongData(
        title: "Cinta Luar Biasa",
        artist: "Andmesh Kamaleng", 
        voiceType: "TENOR MALE",
        accompanimentPath: "song/Andmesh - Cinta Luar Biasa - TENOR MALE-Accompaniment.mp3",
        previewPath: "song/preview/Andmesh - Cinta Luar Biasa - TENOR MALE.mp3",
        duration: Duration(seconds: 29),
        lyricSegments: [
          LyricSegment(text: "Rasa ini", startTime: 1.0, endTime: 3.5, targetFrequency: 196.00, targetNote: "G3"),
          LyricSegment(text: "Tak tertahan", startTime: 4.0, endTime: 6.5, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Hati ini", startTime: 8.0, endTime: 9.5, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Selalu untukmu", startTime: 10.0, endTime: 13.0, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Terimalah lagu ini", startTime: 15.0, endTime: 17.5, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Dari orang biasa", startTime: 18.0, endTime: 21.0, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Tapi cintaku padamu luar biasa", startTime: 22.0, endTime: 27.0, targetFrequency: 261.63, targetNote: "C4"),
        ],
      ),

      // DATO' SITI NURHALIZA – BUKAN CINTA BIASA (TENOR FEMALE) - FIXED TIMING
      EnhancedSongData(
        title: "Bukan Cinta Biasa", 
        artist: "Dato' Siti Nurhaliza",
        voiceType: "TENOR FEMALE",
        accompanimentPath: "song/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE-Accompaniment.mp3",
        previewPath: "song/preview/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE.mp3",
        duration: Duration(seconds: 25),
        lyricSegments: [
          LyricSegment(text: "Mengapa mereka selalu bertanya", startTime: 0.5, endTime: 4.0, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Cintaku bukan di atas kertas", startTime: 7.0, endTime: 10.0, targetFrequency: 329.63, targetNote: "E4"),
          LyricSegment(text: "Cintaku getaran yang sama", startTime: 11.0, endTime: 14.0, targetFrequency: 349.23, targetNote: "F4"),
          LyricSegment(text: "Tak perlu dipaksa", startTime: 15.0, endTime: 16.5, targetFrequency: 392.00, targetNote: "G4"),
          LyricSegment(text: "Tak perlu dicari", startTime: 17.0, endTime: 18.5, targetFrequency: 329.63, targetNote: "E4"),
          LyricSegment(text: "Kerna ku yakin ada jawabnya", startTime: 19.0, endTime: 23.0, targetFrequency: 349.23, targetNote: "F4"),
        ],
      ),

      // AINA ABDUL – JANGAN MATI RASA ITU (ALTO) - FIXED TIMING
      EnhancedSongData(
        title: "Jangan Mati Rasa Itu",
        artist: "Aina Abdul",
        voiceType: "ALTO", 
        accompanimentPath: "song/Aina Abdul - Jangan Mati Rasa Itu - ALTO-Accompaniment.mp3",
        previewPath: "song/preview/Aina Abdul - Jangan Mati Rasa Itu - ALTO.mp3",
        duration: Duration(seconds: 32),
        lyricSegments: [
          LyricSegment(text: "Kasihmu", startTime: 1.0, endTime: 3.0, targetFrequency: 220.00, targetNote: "A3"),
          LyricSegment(text: "Terus hidup", startTime: 4.0, endTime: 6.0, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Jangan mati rasa", startTime: 7.0, endTime: 10.0, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Itu", startTime: 12.0, endTime: 15.0, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Bagaimana", startTime: 17.0, endTime: 22.0, targetFrequency: 246.94, targetNote: "B3"),
          LyricSegment(text: "Harus ku", startTime: 24.0, endTime: 26.0, targetFrequency: 261.63, targetNote: "C4"),
          LyricSegment(text: "Jalani", startTime: 27.0, endTime: 28.5, targetFrequency: 293.66, targetNote: "D4"),
          LyricSegment(text: "Tanpa kamu", startTime: 29.0, endTime: 31.0, targetFrequency: 220.00, targetNote: "A3"),
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

// FIXED Performance tracking data
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

// ENHANCED Real Voice Detection Utils
class RealVoiceDetection {
  static double detectPitchFromSamples(List<double> samples, int sampleRate) {
    if (samples.length < 2048) return 0.0;
    
    // Apply Hann window for better frequency resolution
    List<double> windowed = _applyHannWindow(samples);
    
    // Enhanced autocorrelation pitch detection
    return _enhancedAutocorrelationPitchDetection(windowed, sampleRate);
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

  static double _enhancedAutocorrelationPitchDetection(List<double> samples, int sampleRate) {
    int length = samples.length;
    List<double> autocorr = List.filled(length ~/ 2, 0.0);
    
    // Calculate autocorrelation with normalization
    for (int lag = 0; lag < length ~/ 2; lag++) {
      double sum = 0.0;
      int count = length - lag;
      for (int i = 0; i < count; i++) {
        sum += samples[i] * samples[i + lag];
      }
      autocorr[lag] = sum / count; // Normalize
    }
    
    // Find the best lag with confidence checking
    double maxVal = 0.0;
    int bestLag = 0;
    
    // Search in vocal frequency range (80Hz to 800Hz)
    int minLag = (sampleRate / 800).round();
    int maxLag = (sampleRate / 80).round();
    
    for (int lag = minLag; lag < maxLag && lag < autocorr.length; lag++) {
      if (autocorr[lag] > maxVal && autocorr[lag] > autocorr[0] * 0.3) {
        // Check for peak (higher than neighbors)
        bool isPeak = true;
        if (lag > 0 && autocorr[lag] <= autocorr[lag - 1]) isPeak = false;
        if (lag < autocorr.length - 1 && autocorr[lag] <= autocorr[lag + 1]) isPeak = false;
        
        if (isPeak) {
          maxVal = autocorr[lag];
          bestLag = lag;
        }
      }
    }
    
    if (bestLag == 0 || maxVal < autocorr[0] * 0.4) return 0.0;
    
    // Parabolic interpolation for better accuracy
    double refinedLag = _parabolicInterpolation(autocorr, bestLag);
    return sampleRate / refinedLag;
  }

  static double _parabolicInterpolation(List<double> array, int peakIndex) {
    if (peakIndex <= 0 || peakIndex >= array.length - 1) {
      return peakIndex.toDouble();
    }
    
    double y1 = array[peakIndex - 1];
    double y2 = array[peakIndex];
    double y3 = array[peakIndex + 1];
    
    double a = (y1 - 2 * y2 + y3) / 2;
    double b = (y3 - y1) / 2;
    
    if (a == 0) return peakIndex.toDouble();
    
    double xOffset = -b / (2 * a);
    return peakIndex + xOffset;
  }

  static double calculateAccuracy(double detectedFreq, double targetFreq) {
    if (targetFreq == 0 || detectedFreq == 0) return 0.0;
    
    double ratio = detectedFreq / targetFreq;
    double cents = 1200 * log(ratio) / ln2;
    
    // More forgiving accuracy calculation
    double accuracy = max(0.0, 1.0 - (cents.abs() / 100.0)); // ±100 cents = 50% accuracy
    return accuracy.clamp(0.0, 1.0);
  }

  static String frequencyToNote(double frequency) {
    if (frequency <= 0) return "---";
    
    // Find closest note with better tolerance
    String closestNote = '';
    double minDifference = double.infinity;
    
    PreciseVoiceFrequencies.getAllNotes().forEach((note, noteFreq) {
      double difference = (frequency - noteFreq).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestNote = note;
      }
    });
    
    return minDifference < 50.0 ? closestNote : "---"; // Increased tolerance
  }
}

// ENHANCED Karaoke Singing Practice Screen with FIXED voice detection
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
  
  // ENHANCED voice detection
  String? audioFilePath;
  List<double> audioSamples = [];
  static const int sampleRate = 44100;
  
  // FIXED Timing and progress
  double currentTime = 0.0;
  Timer? progressTimer;
  LyricSegment? currentSegment;
  int currentSegmentIndex = -1;
  
  // ENHANCED Performance tracking
  List<PerformanceData> performanceHistory = [];
  double currentDetectedFrequency = 0.0;
  String currentDetectedNote = '';
  bool isCurrentlyOnPitch = false;
  double currentAccuracy = 0.0;
  
  // ENHANCED Visual feedback
  Color currentFeedbackColor = Colors.grey;
  String currentFeedbackText = 'Ready to sing';
  List<double> waveformData = List.filled(50, 0.0);
  
  // Animation controllers
  AnimationController? lyricAnimController;
  AnimationController? accuracyAnimController;
  Animation<double>? lyricAnimation;
  Animation<double>? accuracyAnimation;
  
  // ENHANCED Timers
  Timer? pitchAnalysisTimer;
  Timer? waveformTimer;
  
  // Session data
  DateTime? sessionStartTime;
  Duration totalPracticeTime = Duration.zero;
  int totalCorrectSegments = 0;
  double overallAccuracy = 0.0;

  // ADDED: Real-time pitch detection buffer
  List<double> pitchHistory = [];
  int analysisCounter = 0;

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
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    lyricAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: lyricAnimController!, curve: Curves.easeInOut),
    );

    accuracyAnimController = AnimationController(
      duration: Duration(milliseconds: 400),
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
        pitchHistory.clear();
        analysisCounter = 0;
      });

      // Setup audio file path
      final directory = await getTemporaryDirectory();
      audioFilePath = '${directory.path}/karaoke_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start accompaniment playback
      await _accompanimentPlayer.play(AssetSource(widget.song.accompanimentPath));
      
      // Start ENHANCED voice recording
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
      _startEnhancedVoicePitchDetection();
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
    progressTimer = Timer.periodic(Duration(milliseconds: 50), (timer) { // More frequent updates
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        currentTime += 0.05; // Smaller increments for smoother progress
      });

      if (sessionStartTime != null) {
        totalPracticeTime = DateTime.now().difference(sessionStartTime!);
      }

      _updateCurrentSegment();
    });
  }

  // ENHANCED Lyric timing - now properly synced
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
          currentFeedbackText = 'Get ready for next line...';
        });
      }
    }
  }

  // ENHANCED Voice Detection Implementation
  void _startEnhancedVoicePitchDetection() {
    pitchAnalysisTimer = Timer.periodic(Duration(milliseconds: 100), (timer) { // More frequent analysis
      if (!isPlaying || !isRecording) {
        timer.cancel();
        return;
      }

      _analyzeEnhancedVoice();
    });
  }

  Future<void> _analyzeEnhancedVoice() async {
    if (audioFilePath == null || !File(audioFilePath!).existsSync()) {
      return;
    }

    try {
      // Read current audio file
      final audioFile = File(audioFilePath!);
      final fileSize = await audioFile.length();
      
      if (fileSize < 4000) return; // Need minimum data
      
      final audioBytes = await audioFile.readAsBytes();
      List<double> samples = _convertBytesToSamples(audioBytes);
      
      if (samples.length < 2048) return; // Need enough samples for FFT

      // Get recent samples for analysis (last 0.5 seconds)
      int recentSamplesCount = min(sampleRate ~/ 2, samples.length);
      int startIndex = samples.length - recentSamplesCount;
      List<double> recentSamples = samples.sublist(startIndex);
      
      // ENHANCED pitch detection
      double detectedFreq = RealVoiceDetection.detectPitchFromSamples(recentSamples, sampleRate);
      
      if (detectedFreq > 70 && detectedFreq < 800) { // Valid vocal range
        _processEnhancedDetectedFrequency(detectedFreq);
      } else {
        // Gradually clear detection for smoother experience
        if (currentDetectedFrequency > 0) {
          setState(() {
            currentDetectedFrequency *= 0.8; // Fade out
            if (currentDetectedFrequency < 50) {
              currentDetectedFrequency = 0.0;
              currentDetectedNote = '';
              currentAccuracy = 0.0;
              isCurrentlyOnPitch = false;
            }
          });
        }
      }
    } catch (e) {
      print('Error analyzing enhanced voice: $e');
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

  // ENHANCED Accuracy processing with smoothing
  void _processEnhancedDetectedFrequency(double frequency) {
    // Add to pitch history for smoothing
    pitchHistory.add(frequency);
    if (pitchHistory.length > 10) {
      pitchHistory.removeAt(0);
    }

    // Use median filtering for smoother detection
    List<double> sortedHistory = List.from(pitchHistory)..sort();
    double smoothedFreq = sortedHistory[sortedHistory.length ~/ 2];

    setState(() {
      currentDetectedFrequency = smoothedFreq;
      currentDetectedNote = RealVoiceDetection.frequencyToNote(smoothedFreq);
    });

    if (currentSegment != null) {
      // Calculate ENHANCED accuracy
      currentAccuracy = RealVoiceDetection.calculateAccuracy(smoothedFreq, currentSegment!.targetFrequency);
      
      // More sensitive pitch detection
      double frequencyDiff = (smoothedFreq - currentSegment!.targetFrequency).abs();
      double percentDiff = frequencyDiff / currentSegment!.targetFrequency;
      isCurrentlyOnPitch = percentDiff < 0.15 && currentAccuracy > 0.5; // 15% tolerance
      
      // Update visual feedback
      _updateEnhancedRealTimeFeedback();
      
      // Store performance data
      _recordEnhancedPerformanceData();
    }
    
    setState(() {});
  }

  void _updateEnhancedRealTimeFeedback() {
    if (isCurrentlyOnPitch && currentAccuracy > 0.8) {
      currentFeedbackColor = Color(0xFF4CAF50); // Green for excellent
      currentFeedbackText = '🎵 Perfect pitch!';
      accuracyAnimController?.forward().then((_) => accuracyAnimController?.reverse());
    } else if (currentAccuracy > 0.6) {
      currentFeedbackColor = Color(0xFF8BC34A); // Light green for good
      currentFeedbackText = '👍 Good! Keep singing';
    } else if (currentAccuracy > 0.4) {
      currentFeedbackColor = Color(0xFFFF9800); // Orange for okay
      currentFeedbackText = '🎯 Adjust your pitch';
    } else if (currentAccuracy > 0.2) {
      currentFeedbackColor = Color(0xFFFF5722); // Red-orange for needs work
      currentFeedbackText = '🎵 Listen and match';
    } else {
      currentFeedbackColor = Color(0xFFF44336); // Red for off-pitch
      currentFeedbackText = '🎤 Sing louder/clearer';
    }
  }

  void _recordEnhancedPerformanceData() {
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
    waveformTimer = Timer.periodic(Duration(milliseconds: 60), (timer) { // Smoother waveform
      if (!isPlaying || !isRecording) {
        timer.cancel();
        return;
      }
      
      final random = Random();
      
      for (int i = 0; i < waveformData.length; i++) {
        if (currentDetectedFrequency > 0) {
          // Active singing waveform based on real detection
          double baseAmplitude = 0.3 + (currentAccuracy * 0.6);
          double frequencyComponent = sin(DateTime.now().millisecondsSinceEpoch / 120.0 + i * 0.2) * baseAmplitude;
          double randomVariation = (random.nextDouble() - 0.5) * 0.1;
          waveformData[i] = (frequencyComponent + randomVariation).clamp(-1.0, 1.0);
        } else {
          // Background ambient waveform
          waveformData[i] = (random.nextDouble() - 0.5) * 0.05;
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

  Widget _buildEnhancedLyricsDisplay() {
    if (currentSegment == null) {
      // Show next upcoming lyric
      LyricSegment? nextSegment;
      for (var segment in widget.song.lyricSegments) {
        if (segment.startTime > currentTime) {
          nextSegment = segment;
          break;
        }
      }
      
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Text(
                '♪ Get Ready ♪',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (nextSegment != null) ...[
                SizedBox(height: 8),
                Text(
                  'Next: "${nextSegment.text}"',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
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
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentFeedbackColor.withOpacity(0.15), 
                  currentFeedbackColor.withOpacity(0.05),
                  Colors.white
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: currentFeedbackColor.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: currentFeedbackColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, color: currentFeedbackColor, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Now Singing',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.music_note, color: currentFeedbackColor, size: 16),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  currentSegment!.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: currentFeedbackColor,
                    height: 1.2,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 8, 
                        color: currentFeedbackColor.withOpacity(0.3),
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentFeedbackColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Target: ${currentSegment!.targetNote} (${currentSegment!.targetFrequency.toStringAsFixed(1)} Hz)',
                    style: TextStyle(
                      color: currentFeedbackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedProgressIndicator() {
    double progress = widget.song.duration.inSeconds > 0 
        ? currentTime / widget.song.duration.inSeconds 
        : 0.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDuration(Duration(seconds: currentTime.toInt()))}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [currentFeedbackColor.withOpacity(0.2), currentFeedbackColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: currentFeedbackColor.withOpacity(0.3)),
                ),
                child: Text(
                  'Accuracy: ${(currentAccuracy * 100).toInt()}%',
                  style: TextStyle(
                    color: currentFeedbackColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(widget.song.duration)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[200]!],
              ),
            ),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(currentFeedbackColor),
              minHeight: 8,
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

  // ENHANCED Live voice display
  Widget _buildEnhancedPitchDisplay() {
    if (!isPlaying || currentSegment == null) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: [
          // Left side - Your voice
          Expanded(
            child: Column(
              children: [
                Text('Your Voice', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text(
                  currentDetectedNote.isNotEmpty ? currentDetectedNote : '---',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: currentFeedbackColor,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  currentDetectedFrequency > 0 ? '${currentDetectedFrequency.toStringAsFixed(1)} Hz' : '---',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          
          // Middle - Accuracy indicator
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [currentFeedbackColor, currentFeedbackColor.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: currentFeedbackColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${(currentAccuracy * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Right side - Target
          Expanded(
            child: Column(
              children: [
                Text('Target', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text(
                  currentSegment!.targetNote,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${currentSegment!.targetFrequency.toStringAsFixed(1)} Hz',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
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
            // ENHANCED Header with song info
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
                    child: Icon(Icons.queue_music, color: Colors.white, size: 24),
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPlaying 
                            ? [Color(0xFF4CAF50).withOpacity(0.2), Color(0xFF4CAF50).withOpacity(0.1)]
                            : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPlaying ? Color(0xFF4CAF50) : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isPlaying ? Color(0xFF4CAF50) : Colors.grey[600],
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          isPlaying ? 'LIVE' : 'READY',
                          style: TextStyle(
                            color: isPlaying ? Color(0xFF4CAF50) : Colors.grey[600],
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

            // ENHANCED Progress indicator
            if (isPlaying) ...[
              SizedBox(height: 12),
              _buildEnhancedProgressIndicator(),
            ],

            // ENHANCED Current lyrics display
            SizedBox(height: 16),
            if (isPlaying && !showInstructions)
              _buildEnhancedLyricsDisplay(),

            // ENHANCED Live pitch display
            if (isPlaying && currentDetectedNote.isNotEmpty && currentSegment != null) ...[
              SizedBox(height: 16),
              _buildEnhancedPitchDisplay(),
            ],

            // ENHANCED Waveform visualization
            if (isPlaying && isRecording)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  borderRadius: BorderRadius.circular(16),
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
                      // ENHANCED Instructions
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: voiceColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.queue_music, color: voiceColor, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'Enhanced Karaoke Experience',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '🎵 Real-time voice detection with enhanced accuracy\n'
                              '🎯 Live pitch feedback - Green = perfect, Red = adjust\n'
                              '📊 Professional vocal analysis with timing\n'
                              '📈 Detailed performance report after singing',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Main karaoke button when not showing instructions
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

            // ENHANCED Bottom feedback and controls
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
                      height: 1.3,
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
                          'Start Enhanced Karaoke',
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

// Analysis Screen (keeping the same structure)
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
    
    // Calculate ENHANCED statistics
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
      bool needsImprovement = avgAccuracy < 0.6;
      
      analysisCards.add(
        Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: needsImprovement 
                  ? [Color(0xFFFFEBEE), Color(0xFFFFF5F5)]
                  : [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
            ),
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
                    needsImprovement ? Icons.trending_down : Icons.trending_up,
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: needsImprovement ? Color(0xFFE57373) : Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(avgAccuracy * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
                  '💡 Practice tip: Focus on matching this specific pitch frequency',
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
        title: Text('Enhanced Voice Analysis'),
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
                              'Enhanced Voice Analysis Complete',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Based on real-time voice detection technology',
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
                          'Final Score',
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
              'Enhanced Voice Analysis by Lyric',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Based on real-time voice detection. Red sections need focused practice.',
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