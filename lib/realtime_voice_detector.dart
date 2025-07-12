// lib/realtime_voice_detector.dart
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Specific frequencies based on your chart
class PreciseVoiceFrequencies {
  
  // BARITONE range (C2 - A2)
  static const Map<String, double> baritoneNotes = {
    'C2': 65.41,
    'C#2': 69.30,
    'D2': 73.42, 
    'D#2': 77.78,
    'E2': 82.41,
    'F2': 87.31,
    'F#2': 92.50,
    'G2': 98.00,
    'G#2': 103.83,
    'A2': 110.00,
    'A#2': 116.54,
    'B2': 123.47,
  };

  // TENOR range (exact from your chart - F2 to F3)
  static const Map<String, double> tenorNotes = {
    'F2': 87.31,
    'F#2': 92.50,    // Also G♭2
    'G2': 98.00,
    'G#2': 103.83,   // Also A♭2
    'A2': 110.00,
    'A#2': 116.54,   // Also B♭2
    'B2': 123.47,
    'C3': 130.81,
    'C#3': 138.59,   // Also D♭3
    'D3': 146.83,
    'D#3': 155.56,   // Also E♭3
    'E3': 164.81,
    'F3': 174.61,
  };

  // ALTO range (exact from your chart - C3 to C4)
  static const Map<String, double> altoNotes = {
    'C3': 130.81,
    'C#3': 138.59,   // Also D♭3
    'D3': 146.83,
    'D#3': 155.56,   // Also E♭3
    'E3': 164.81,
    'F3': 174.61,
    'F#3': 185.00,   // Also G♭3
    'G3': 196.00,
    'G#3': 207.65,   // Also A♭3
    'A3': 220.00,
    'A#3': 233.08,   // Also B♭3
    'B3': 246.94,
    'C4': 261.63,
  };

  // All notes combined for detection
  static Map<String, double> getAllNotes() {
    Map<String, double> allNotes = {};
    allNotes.addAll(baritoneNotes);
    allNotes.addAll(tenorNotes);
    allNotes.addAll(altoNotes);
    return allNotes;
  }

  // Detect voice type based on specific note with overlap handling
  static String classifyVoiceType(String note) {
    // Handle overlapping notes with priority logic
    Map<String, double> overlappingNotes = {
      'C3': 130.81, 'D3': 146.83, 'D#3': 155.56, 'E3': 164.81, 'F3': 174.61
    };
    
    if (overlappingNotes.containsKey(note)) {
      // For overlapping notes, use frequency-based classification
      // Higher frequencies (E3, F3) tend to be ALTO
      // Lower frequencies (C3, D3) tend to be TENOR
      if (note == 'E3' || note == 'F3') {
        return 'ALTO';  // Higher end of overlap
      } else if (note == 'C3' || note == 'D3' || note == 'D#3') {
        return 'TENOR'; // Lower end of overlap
      }
    }
    
    if (baritoneNotes.containsKey(note)) {
      return 'BARITONE';
    } else if (tenorNotes.containsKey(note)) {
      return 'TENOR';
    } else if (altoNotes.containsKey(note)) {
      return 'ALTO';
    }
    return 'UNKNOWN';
  }

  // Find closest note from detected frequency
  static Map<String, dynamic>? findExactNote(double frequency) {
    double tolerance = 6.0; // ±6 Hz tolerance for better accuracy with your charts
    Map<String, double> allNotes = getAllNotes();
    
    String? closestNote;
    double minDifference = double.infinity;
    
    for (var entry in allNotes.entries) {
      double difference = (frequency - entry.value).abs();
      if (difference < tolerance && difference < minDifference) {
        minDifference = difference;
        closestNote = entry.key;
      }
    }
    
    if (closestNote != null) {
      return {
        'note': closestNote,
        'frequency': allNotes[closestNote],
        'detected_frequency': frequency,
        'accuracy': ((tolerance - minDifference) / tolerance * 100).clamp(0, 100),
        'voice_type': classifyVoiceType(closestNote!),
      };
    }
    
    return null;
  }

  // Get color for voice type
  static Color getVoiceTypeColor(String voiceType) {
    switch (voiceType) {
      case 'BARITONE':
        return Color(0xFF4169E1); // Royal Blue
      case 'TENOR':
        return Color(0xFF32CD32); // Lime Green
      case 'ALTO':
        return Color(0xFFFF6347); // Tomato
      default:
        return Colors.grey;
    }
  }

  // Get note with enharmonic equivalent
  static String getNoteWithEnharmonic(String note) {
    Map<String, String> enharmonics = {
      // BARITONE range
      'C#2': 'C#2/D♭2', 'D#2': 'D#2/E♭2', 'F#2': 'F#2/G♭2',
      'G#2': 'G#2/A♭2', 'A#2': 'A#2/B♭2',
      // TENOR range
      'F#2': 'F#2/G♭2', 'G#2': 'G#2/A♭2', 'A#2': 'A#2/B♭2',
      'C#3': 'C#3/D♭3', 'D#3': 'D#3/E♭3',
      // ALTO range (exact from your chart)
      'C#3': 'C#3/D♭3', 'D#3': 'D#3/E♭3', 'F#3': 'F#3/G♭3',
      'G#3': 'G#3/A♭3', 'A#3': 'A#3/B♭3',
    };
    return enharmonics[note] ?? note;
  }
}

class RealTimeVoiceDetector extends StatefulWidget {
  @override
  _RealTimeVoiceDetectorState createState() => _RealTimeVoiceDetectorState();
}

class _RealTimeVoiceDetectorState extends State<RealTimeVoiceDetector>
    with TickerProviderStateMixin {

  // Audio recording
  final AudioRecorder _recorder = AudioRecorder();
  bool isListening = false;
  bool hasPermission = false;

  // Real-time audio analysis
  String? audioFilePath;
  StreamSubscription? audioStreamSubscription;
  Timer? analysisTimer;

  // Real-time detection data
  double currentFrequency = 0.0;
  String currentNote = '';
  String currentVoiceType = '';
  double accuracy = 0.0;
  Map<String, dynamic>? detectedNoteData;
  List<double> audioBuffer = [];
  
  // Audio analysis parameters
  static const int sampleRate = 44100;
  static const int bufferSize = 2048; // Buffer size for FFT analysis

  // Sustained note tracking
  String? sustainedNote;
  DateTime? sustainedStartTime;
  Timer? sustainedTimer;
  bool showingSustainedNotification = false;

  // Waveform visualization
  List<double> waveformData = List.filled(30, 0.0);
  Timer? waveformTimer;

  // Animation controllers
  AnimationController? pulseController;
  Animation<double>? pulseAnimation;
  AnimationController? accuracyController;
  Animation<double>? accuracyAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestPermissions();
  }

  void _initializeAnimations() {
    pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );

    accuracyController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    accuracyAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: accuracyController!, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _stopListening();
    pulseController?.dispose();
    accuracyController?.dispose();
    sustainedTimer?.cancel();
    waveformTimer?.cancel();
    analysisTimer?.cancel();
    
    // Clean up any remaining audio files
    if (audioFilePath != null && File(audioFilePath!).existsSync()) {
      File(audioFilePath!).delete().catchError((_) {});
    }
    
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    setState(() {
      hasPermission = status == PermissionStatus.granted;
    });
  }

  Future<void> _startListening() async {
    if (!hasPermission) {
      _showError('Microphone permission required');
      return;
    }

    try {
      setState(() {
        isListening = true;
        currentFrequency = 0.0;
        currentNote = '';
        currentVoiceType = '';
        audioBuffer.clear();
      });

      pulseController!.repeat(reverse: true);
      
      // Get temporary path for audio recording
      final directory = await getTemporaryDirectory();
      audioFilePath = '${directory.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // Start recording with stream for real-time analysis
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 48000,
            sampleRate: sampleRate,
            numChannels: 1,
          ),
          path: audioFilePath!,
        );
        
        _startRealTimeAnalysis();
        _startWaveformVisualization();
      }
    } catch (e) {
      print('Error starting listening: $e');
      _showError('Failed to start voice detection: $e');
    }
  }

  void _stopListening() async {
    try {
      setState(() {
        isListening = false;
        currentFrequency = 0.0;
        currentNote = '';
        currentVoiceType = '';
        sustainedNote = null;
        sustainedStartTime = null;
        showingSustainedNotification = false;
      });

      pulseController!.stop();
      pulseController!.reset();
      sustainedTimer?.cancel();
      waveformTimer?.cancel();
      analysisTimer?.cancel();
      
      await _recorder.stop();
      
      // Clean up temporary audio file
      if (audioFilePath != null && File(audioFilePath!).existsSync()) {
        await File(audioFilePath!).delete();
        audioFilePath = null;
      }
      
      audioBuffer.clear();
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  void _startRealTimeAnalysis() {
    // Analyze audio every 200ms for real-time detection
    analysisTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!isListening) {
        timer.cancel();
        return;
      }

      await _analyzeCurrentAudio();
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
      
      // Only analyze if file has sufficient data (at least 0.2 seconds of audio)
      if (fileSize < 8000) { // Approximately 0.2 seconds at 44.1kHz
        return;
      }

      // Read the latest audio data
      final audioBytes = await audioFile.readAsBytes();
      
      // Convert bytes to audio samples for analysis
      List<double> samples = _convertBytesToSamples(audioBytes);
      
      if (samples.length < 1000) {
        return; // Not enough samples
      }

      // Get the latest samples for analysis (last 1 second)
      int startIndex = samples.length > sampleRate ? samples.length - sampleRate : 0;
      List<double> recentSamples = samples.sublist(startIndex);
      
      // Detect pitch using autocorrelation method
      double detectedFreq = _detectPitchAutocorrelation(recentSamples);
      
      if (detectedFreq > 50 && detectedFreq < 800) { // Valid vocal range
        _processDetectedFrequency(detectedFreq);
      } else {
        // Clear detection if no valid frequency
        setState(() {
          currentFrequency = 0.0;
          currentNote = '';
          currentVoiceType = '';
          detectedNoteData = null;
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
        // Combine two bytes to form 16-bit sample
        int sample16 = bytes[i] | (bytes[i + 1] << 8);
        
        // Convert to signed 16-bit
        if (sample16 > 32767) sample16 -= 65536;
        
        // Normalize to -1.0 to 1.0
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
    int minPeriod = (sampleRate / 800).round(); // Highest frequency (800 Hz)
    int maxPeriod = (sampleRate / 50).round();  // Lowest frequency (50 Hz)
    
    double maxCorrelation = 0.0;
    int bestPeriod = 0;
    
    // Find the period with maximum correlation
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
    
    // Convert period to frequency
    if (bestPeriod > 0 && maxCorrelation > 0.3) { // Confidence threshold
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
      currentFrequency = frequency;
    });

    // Find the exact note
    Map<String, dynamic>? noteData = PreciseVoiceFrequencies.findExactNote(frequency);
    
    if (noteData != null) {
      setState(() {
        detectedNoteData = noteData;
        currentNote = noteData['note'];
        currentVoiceType = noteData['voice_type'];
        accuracy = noteData['accuracy'];
      });

      accuracyController!.forward();
      
      // Check for sustained note (3 seconds)
      _checkSustainedNote(currentNote);
      
    } else {
      setState(() {
        detectedNoteData = null;
        currentNote = '';
        currentVoiceType = '';
        accuracy = 0.0;
        sustainedNote = null;
        sustainedStartTime = null;
      });
      
      accuracyController!.reverse();
    }
  }

  void _checkSustainedNote(String note) {
    if (sustainedNote != note) {
      // New note detected
      setState(() {
        sustainedNote = note;
        sustainedStartTime = DateTime.now();
        showingSustainedNotification = false;
      });
      
      sustainedTimer?.cancel();
      sustainedTimer = Timer(Duration(seconds: 3), () {
        if (sustainedNote == note && isListening) {
          _showSustainedNoteNotification(note);
        }
      });
    }
  }

  void _showSustainedNoteNotification(String note) {
    setState(() {
      showingSustainedNotification = true;
    });

    String enharmonicNote = PreciseVoiceFrequencies.getNoteWithEnharmonic(note);
    String voiceType = PreciseVoiceFrequencies.classifyVoiceType(note);
    double frequency = PreciseVoiceFrequencies.getAllNotes()[note] ?? 0.0;

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PreciseVoiceFrequencies.getVoiceTypeColor(voiceType),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sustained Note Detected!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$enharmonicNote (${frequency.toStringAsFixed(1)} Hz) - $voiceType',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: PreciseVoiceFrequencies.getVoiceTypeColor(voiceType),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Hide notification flag after delay
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showingSustainedNotification = false;
        });
      }
    });
  }

  void _startWaveformVisualization() {
    waveformTimer = Timer.periodic(Duration(milliseconds: 80), (timer) {
      if (!isListening) {
        timer.cancel();
        return;
      }

      final random = Random();
      
      // Create waveform that responds to actual voice detection
      for (int i = 0; i < waveformData.length; i++) {
        if (currentNote.isNotEmpty && currentFrequency > 0) {
          // More active waveform when note is detected
          double baseAmplitude = 0.3 + (accuracy / 100) * 0.5;
          // Use detected frequency to influence waveform pattern
          double frequencyFactor = (currentFrequency / 220.0).clamp(0.5, 2.0);
          double wave = sin(DateTime.now().millisecondsSinceEpoch / (200.0 / frequencyFactor) + i * 0.4) * baseAmplitude;
          double noise = (random.nextDouble() - 0.5) * 0.15;
          waveformData[i] = (wave + noise).clamp(-1.0, 1.0);
        } else {
          // Minimal waveform when no note detected
          waveformData[i] = (random.nextDouble() - 0.5) * 0.08;
        }
      }

      setState(() {});
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFrequencyDisplay() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentNote.isNotEmpty 
              ? [
                  PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType).withOpacity(0.1),
                  PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType).withOpacity(0.05),
                ]
              : [Color(0xFFF8F9FA), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentNote.isNotEmpty 
              ? PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Live frequency
          Text(
            'Live Frequency',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            '${currentFrequency.toStringAsFixed(1)} Hz',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: currentNote.isNotEmpty 
                  ? PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType)
                  : Colors.grey[700],
            ),
          ),
          
          if (currentNote.isNotEmpty) ...[
            SizedBox(height: 16),
            
            // Detected note
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                PreciseVoiceFrequencies.getNoteWithEnharmonic(currentNote),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType),
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Voice type
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentVoiceType,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Accuracy bar
            AnimatedBuilder(
              animation: accuracyAnimation!,
              builder: (context, child) {
                return Row(
                  children: [
                    Icon(Icons.gps_fixed, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (accuracy / 100) * accuracyAnimation!.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: accuracy > 70 
                                  ? Color(0xFF4CAF50)
                                  : accuracy > 40 
                                      ? Colors.orange
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${accuracy.toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveformVisualization() {
    if (!isListening) return SizedBox.shrink();
    
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(waveformData.length, (index) {
            final height = (waveformData[index].abs() * 35) + 8;
            Color barColor = currentNote.isNotEmpty 
                ? PreciseVoiceFrequencies.getVoiceTypeColor(currentVoiceType)
                : Colors.grey[400]!;
                
            return Container(
              width: 2.5,
              height: height,
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
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
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
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
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
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
                        'Real-Time Voice Detection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Precise note detection • Live frequency analysis',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Status indicator
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isListening 
                  ? (currentNote.isNotEmpty ? Color(0xFF4CAF50).withOpacity(0.1) : Color(0xFFFF9800).withOpacity(0.1))
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isListening 
                    ? (currentNote.isNotEmpty ? Color(0xFF4CAF50) : Color(0xFFFF9800))
                    : Colors.grey,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isListening 
                      ? (currentNote.isNotEmpty ? Icons.mic : Icons.hearing)
                      : Icons.mic_none,
                  color: isListening 
                      ? (currentNote.isNotEmpty ? Color(0xFF4CAF50) : Color(0xFFFF9800))
                      : Colors.grey,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  isListening 
                      ? (currentNote.isNotEmpty ? 'VOICE DETECTED' : 'LISTENING...')
                      : 'READY',
                  style: TextStyle(
                    color: isListening 
                        ? (currentNote.isNotEmpty ? Color(0xFF4CAF50) : Color(0xFFFF9800))
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),
          
          // Frequency display
          _buildFrequencyDisplay(),
          
          // Waveform visualization
          _buildWaveformVisualization(),
          
          Spacer(),
          
          // Main control button
          Center(
            child: GestureDetector(
              onTap: isListening ? _stopListening : _startListening,
              child: AnimatedBuilder(
                animation: pulseAnimation!,
                builder: (context, child) {
                  return Container(
                    width: isListening ? 120 * pulseAnimation!.value : 120,
                    height: isListening ? 120 * pulseAnimation!.value : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isListening 
                            ? [Color(0xFF4CAF50), Color(0xFF2E7D32)]
                            : [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isListening ? Color(0xFF4CAF50) : Color(0xFF2196F3)).withOpacity(0.4),
                          blurRadius: isListening ? 20 : 8,
                          spreadRadius: isListening ? 5 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            isListening ? 'Tap to stop detection' : 'Tap to start voice detection',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (isListening && currentNote.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Try humming "Ahh" or singing a clear note',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF9800),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          SizedBox(height: 40),
          
          // Instructions
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Sing or hum any note clearly\n'
                  '• See real-time frequency and note detection\n'
                  '• Hold a note for 3+ seconds to get classification\n'
                  '• System detects BARITONE, TENOR, or ALTO range',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
}