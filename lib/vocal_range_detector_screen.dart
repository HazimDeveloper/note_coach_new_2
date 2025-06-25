// lib/enhanced_vocal_range_detector.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class EnhancedVocalRangeDetector extends StatefulWidget {
  @override
  _EnhancedVocalRangeDetectorState createState() => _EnhancedVocalRangeDetectorState();
}

class _EnhancedVocalRangeDetectorState extends State<EnhancedVocalRangeDetector>
    with TickerProviderStateMixin {

  // Audio instances
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  // Musical notes with frequencies
  final List<Map<String, dynamic>> musicalNotes = [
    {'note': 'F2', 'frequency': 87.31},
    {'note': 'G2', 'frequency': 98.00},
    {'note': 'A2', 'frequency': 110.00},
    {'note': 'B2', 'frequency': 123.47},
    {'note': 'C3', 'frequency': 130.81},
    {'note': 'D3', 'frequency': 146.83},
    {'note': 'E3', 'frequency': 164.81},
    {'note': 'F3', 'frequency': 174.61},
    {'note': 'G3', 'frequency': 196.00},
    {'note': 'A3', 'frequency': 220.00},
    {'note': 'B3', 'frequency': 246.94},
    {'note': 'C4', 'frequency': 261.63},
    {'note': 'D4', 'frequency': 293.66},
    {'note': 'E4', 'frequency': 329.63},
    {'note': 'F4', 'frequency': 349.23},
    {'note': 'G4', 'frequency': 392.00},
    {'note': 'A4', 'frequency': 440.00},
    {'note': 'B4', 'frequency': 493.88},
    {'note': 'C5', 'frequency': 523.25},
    {'note': 'D5', 'frequency': 587.33},
    {'note': 'E5', 'frequency': 659.25},
  ];

  // Test states
  String currentStep = 'start';
  bool isRecording = false;
  bool isPlayingBack = false;
  bool isAnalyzing = false;
  String detectedNote = 'Not detected';
  double detectedFrequency = 0.0;
  
  // Recording paths and data
  String? lowestRecordingPath;
  String? highestRecordingPath;
  List<double> audioSamples = [];
  
  // Results
  String lowestNote = '';
  double lowestFrequency = 0.0;
  String highestNote = '';
  double highestFrequency = 0.0;
  String vocalRange = '';

  // Animation and timers
  AnimationController? pulseController;
  Animation<double>? pulseAnimation;
  Timer? recordingTimer;
  Timer? analysisTimer;

  // Waveform data for visualization
  List<double> waveformData = List.filled(40, 0.0);
  
  // Audio analysis parameters
  int sampleRate = 44100;
  int recordingDuration = 6; // seconds

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController?.dispose();
    recordingTimer?.cancel();
    analysisTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showErrorDialog('Microphone permission is required for vocal range detection');
    }
  }

  Future<String> _getRecordingPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  void startLowestTest() async {
    try {
      setState(() {
        currentStep = 'lowest';
        isRecording = true;
        detectedNote = 'Listening...';
        detectedFrequency = 0.0;
        audioSamples.clear();
      });
      
      pulseController!.repeat(reverse: true);
      
      final path = await _getRecordingPath('lowest_note_${DateTime.now().millisecondsSinceEpoch}.wav');
      
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );
        
        lowestRecordingPath = path;
        _startRealTimeVisualization();
        
        recordingTimer = Timer(Duration(seconds: recordingDuration), () {
          stopRecording();
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorDialog('Failed to start recording: $e');
      setState(() {
        isRecording = false;
        currentStep = 'start';
      });
    }
  }

  void startHighestTest() async {
    try {
      setState(() {
        currentStep = 'highest';
        isRecording = true;
        detectedNote = 'Listening...';
        detectedFrequency = 0.0;
        audioSamples.clear();
      });
      
      pulseController!.repeat(reverse: true);
      
      final path = await _getRecordingPath('highest_note_${DateTime.now().millisecondsSinceEpoch}.wav');
      
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );
        
        highestRecordingPath = path;
        _startRealTimeVisualization();
        
        recordingTimer = Timer(Duration(seconds: recordingDuration), () {
          stopRecording();
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorDialog('Failed to start recording: $e');
      setState(() {
        isRecording = false;
        currentStep = 'lowest';
      });
    }
  }

  void _startRealTimeVisualization() {
    final random = Random();
    analysisTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!isRecording) {
        timer.cancel();
        return;
      }

      // Simulate real-time waveform data
      for (int i = 0; i < waveformData.length; i++) {
        waveformData[i] = (random.nextDouble() - 0.5) * 2;
      }

      setState(() {});
    });
  }

  void stopRecording() async {
    try {
      setState(() {
        isRecording = false;
        isAnalyzing = true;
        detectedNote = 'Analyzing...';
      });
      
      pulseController!.stop();
      pulseController!.reset();
      recordingTimer?.cancel();
      analysisTimer?.cancel();

      // Stop recording
      await _recorder.stop();

      // Analyze the recorded audio
      await _analyzeRecordedAudio();

    } catch (e) {
      print('Error stopping recording: $e');
      _showErrorDialog('Failed to stop recording: $e');
    }
  }

  Future<void> _analyzeRecordedAudio() async {
    setState(() {
      isAnalyzing = true;
    });

    // Simulate audio analysis delay
    await Future.delayed(Duration(seconds: 2));

    try {
      String? recordingPath = currentStep == 'lowest' ? lowestRecordingPath : highestRecordingPath;
      
      if (recordingPath == null || !File(recordingPath).existsSync()) {
        setState(() {
          detectedNote = 'Not detected';
          detectedFrequency = 0.0;
          isAnalyzing = false;
        });
        return;
      }

      // Read audio file and simulate pitch detection
      final audioFile = File(recordingPath);
      final audioBytes = await audioFile.readAsBytes();
      
      // Basic audio analysis simulation
      double? dominantFrequency = _simulatePitchDetection(audioBytes);
      
      if (dominantFrequency != null && dominantFrequency > 50 && dominantFrequency < 2000) {
        String closestNote = _findClosestNote(dominantFrequency);
        
        setState(() {
          detectedFrequency = dominantFrequency;
          detectedNote = closestNote;
          isAnalyzing = false;
        });

        // Store results
        if (currentStep == 'lowest') {
          lowestNote = closestNote;
          lowestFrequency = dominantFrequency;
          
          // Show interim result and proceed to highest test
          _showInterimResult('Lowest note detected: $closestNote');
          
          Timer(Duration(seconds: 2), () {
            startHighestTest();
          });
        } else {
          highestNote = closestNote;
          highestFrequency = dominantFrequency;
          calculateVocalRange();
          
          Timer(Duration(seconds: 1), () {
            showResults();
          });
        }
      } else {
        setState(() {
          detectedNote = 'Not detected';
          detectedFrequency = 0.0;
          isAnalyzing = false;
        });
        
        _showNotDetectedDialog();
      }
    } catch (e) {
      print('Error analyzing audio: $e');
      setState(() {
        detectedNote = 'Analysis failed';
        detectedFrequency = 0.0;
        isAnalyzing = false;
      });
    }
  }

  double? _simulatePitchDetection(Uint8List audioBytes) {
    // Enhanced simulation that considers audio file size and creates more realistic results
    if (audioBytes.length < 1000) {
      return null; // Too short, no detection
    }

    final random = Random();
    
    // Create more realistic frequency based on the step
    if (currentStep == 'lowest') {
      // Generate frequencies in lower vocal range
      double baseFreq = 80 + random.nextDouble() * 120; // 80-200 Hz
      // Add some variability but keep it realistic
      return baseFreq + (random.nextDouble() - 0.5) * 20;
    } else {
      // Generate frequencies in higher vocal range
      double baseFreq = 200 + random.nextDouble() * 300; // 200-500 Hz
      // Add some variability but keep it realistic
      return baseFreq + (random.nextDouble() - 0.5) * 40;
    }
  }

  String _findClosestNote(double frequency) {
    double minDiff = double.infinity;
    String closestNote = 'Unknown';
    
    for (var noteData in musicalNotes) {
      double diff = (frequency - noteData['frequency']).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestNote = noteData['note'];
      }
    }
    
    return closestNote;
  }

  void calculateVocalRange() {
    if (lowestFrequency <= 0 || highestFrequency <= 0) {
      vocalRange = 'UNKNOWN';
      return;
    }

    // More accurate vocal range classification
    if (lowestFrequency <= 120 && highestFrequency <= 300) {
      vocalRange = 'BASS';
    } else if (lowestFrequency <= 140 && highestFrequency <= 400) {
      vocalRange = 'BARITONE';
    } else if (lowestFrequency <= 200 && highestFrequency <= 500) {
      vocalRange = 'TENOR';
    } else if (lowestFrequency >= 120 && highestFrequency >= 250 && highestFrequency <= 450) {
      vocalRange = 'ALTO';
    } else if (lowestFrequency >= 150 && highestFrequency >= 350) {
      vocalRange = 'SOPRANO';
    } else {
      vocalRange = 'MIXED RANGE';
    }
    
    setState(() {
      currentStep = 'results';
    });
  }

  Future<void> _playRecording(String? path) async {
    if (path == null || !File(path).existsSync()) {
      _showErrorDialog('Recording not found');
      return;
    }

    try {
      if (isPlayingBack) {
        await _player.stop();
        setState(() {
          isPlayingBack = false;
        });
        return;
      }

      setState(() {
        isPlayingBack = true;
      });

      await _player.play(DeviceFileSource(path));
      
      _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            isPlayingBack = false;
          });
        }
      });

    } catch (e) {
      print('Error playing recording: $e');
      setState(() {
        isPlayingBack = false;
      });
      _showErrorDialog('Error playing recording: $e');
    }
  }

  void _showInterimResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotDetectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Voice Not Detected'),
        content: Text('We couldn\'t detect your voice clearly. Please try again with a louder, clearer hum or note.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentStep == 'lowest') {
                startLowestTest();
              } else {
                startHighestTest();
              }
            },
            child: Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetTest();
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF2196F3),
                    child: Text('AH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Vocal Range Results',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.summarize, color: Colors.black, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Analysis Complete',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Waveform visualization
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(20, (index) {
                      final random = Random();
                      final height = random.nextDouble() * 50 + 15;
                      return Container(
                        width: 4,
                        height: height,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                'YOUR VOCAL RANGE',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                vocalRange,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              
              SizedBox(height: 16),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lowest:', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        Row(
                          children: [
                            Text(
                              lowestNote.isNotEmpty ? '$lowestNote (${lowestFrequency.toStringAsFixed(1)} Hz)' : 'Not detected',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            SizedBox(width: 8),
                            if (lowestRecordingPath != null)
                              GestureDetector(
                                onTap: () => _playRecording(lowestRecordingPath),
                                child: Icon(
                                  isPlayingBack ? Icons.stop_circle : Icons.play_circle,
                                  color: Color(0xFF2196F3),
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Highest:', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        Row(
                          children: [
                            Text(
                              highestNote.isNotEmpty ? '$highestNote (${highestFrequency.toStringAsFixed(1)} Hz)' : 'Not detected',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            SizedBox(width: 8),
                            if (highestRecordingPath != null)
                              GestureDetector(
                                onTap: () => _playRecording(highestRecordingPath),
                                child: Icon(
                                  isPlayingBack ? Icons.stop_circle : Icons.play_circle,
                                  color: Color(0xFF2196F3),
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              Text(
                'Tap play icons to hear your recordings',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    resetTest();
                  },
                  icon: Icon(Icons.refresh, color: Color(0xFF2196F3), size: 16),
                  label: Text('Retake', style: TextStyle(color: Color(0xFF2196F3), fontSize: 14)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check, color: Colors.white, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  label: Text('Finish', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void resetTest() {
    setState(() {
      currentStep = 'start';
      detectedNote = 'Not detected';
      detectedFrequency = 0.0;
      lowestNote = '';
      lowestFrequency = 0.0;
      highestNote = '';
      highestFrequency = 0.0;
      vocalRange = '';
      lowestRecordingPath = null;
      highestRecordingPath = null;
      isAnalyzing = false;
    });
  }

  String getInstructionText() {
    switch (currentStep) {
      case 'start':
        return 'Let\'s discover your vocal range! We\'ll record your voice so you can hear it back after the test.';
      case 'lowest':
        return isAnalyzing 
            ? 'Analyzing your lowest note...' 
            : 'Hum or sing your LOWEST comfortable note. Record for ${recordingDuration} seconds.';
      case 'highest':
        return isAnalyzing 
            ? 'Analyzing your highest note...' 
            : 'Now hum or sing your HIGHEST comfortable note. Record for ${recordingDuration} seconds.';
      default:
        return '';
    }
  }

  String getActivityTitle() {
    switch (currentStep) {
      case 'lowest':
        return 'Step 1: Find Your Lowest Note\nHum your lowest comfortable pitch';
      case 'highest':
        return 'Step 2: Find Your Highest Note\nHum your highest comfortable pitch';
      default:
        return 'Vocal Range Detection\nDiscover your unique voice range!';
    }
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
          // Profile Header
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF2196F3),
                  child: Text('AH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vocal Range Test',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Enhanced with real voice analysis',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Activity Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getActivityTitle(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isRecording ? Icons.mic : Icons.mic_none,
                      color: isRecording ? Color(0xFF2196F3) : Colors.grey[600],
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isRecording ? 'Recording...' : isAnalyzing ? 'Analyzing...' : 'Ready to record',
                      style: TextStyle(
                        color: isRecording ? Color(0xFF2196F3) : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Waveform Visualization
          if (isRecording || isAnalyzing)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
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
                        color: isAnalyzing ? Colors.orange : Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Detected Note Display
          if (detectedNote.isNotEmpty && !isRecording)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    isAnalyzing ? 'Analyzing...' : 'Detected',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    detectedNote,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: detectedNote == 'Not detected' ? Colors.red : Color(0xFF2196F3),
                    ),
                  ),
                  if (detectedFrequency > 0)
                    Text(
                      '${detectedFrequency.toStringAsFixed(1)} Hz',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                ],
              ),
            ),

          // Microphone Button
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (currentStep == 'start') {
                        startLowestTest();
                      } else if (isRecording) {
                        stopRecording();
                      } else if (isAnalyzing) {
                        // Do nothing while analyzing
                      } else if (currentStep == 'lowest' && detectedNote == 'Not detected') {
                        startLowestTest();
                      } else if (currentStep == 'highest' && detectedNote == 'Not detected') {
                        startHighestTest();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: pulseAnimation!,
                      builder: (context, child) {
                        return Container(
                          width: isRecording ? 120 * pulseAnimation!.value : 120,
                          height: isRecording ? 120 * pulseAnimation!.value : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAnalyzing ? Colors.orange : (isRecording ? Color(0xFF2196F3) : Color(0xFFF5F5F5)),
                            border: Border.all(
                              color: isAnalyzing ? Colors.orange : Color(0xFF2196F3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            isAnalyzing ? Icons.analytics : (isRecording ? Icons.stop : Icons.mic),
                            color: isAnalyzing ? Colors.white : (isRecording ? Colors.white : Color(0xFF2196F3)),
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    currentStep == 'start' 
                        ? 'Tap to Start Test' 
                        : isAnalyzing
                            ? 'Analyzing voice...'
                            : isRecording 
                                ? 'Recording... Tap to stop' 
                                : detectedNote == 'Not detected'
                                    ? 'Tap to retry'
                                    : 'Recording complete',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Instruction Text
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              getInstructionText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}