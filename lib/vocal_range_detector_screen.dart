// lib/vocal_range_detector_enhanced.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';

class VocalRangeDetectorEnhanced extends StatefulWidget {
  @override
  _VocalRangeDetectorEnhancedState createState() => _VocalRangeDetectorEnhancedState();
}

class _VocalRangeDetectorEnhancedState extends State<VocalRangeDetectorEnhanced>
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
  ];

  // Test states
  String currentStep = 'start';
  bool isRecording = false;
  bool isPlayingBack = false;
  String detectedNote = '';
  double detectedFrequency = 0.0;
  
  // Recording paths
  String? lowestRecordingPath;
  String? highestRecordingPath;
  
  // Results
  String lowestNote = '';
  double lowestFrequency = 0.0;
  String highestNote = '';
  double highestFrequency = 0.0;
  String vocalRange = '';

  // Animation
  AnimationController? pulseController;
  Animation<double>? pulseAnimation;
  Timer? recordingTimer;
  Timer? simulationTimer;

  // Waveform data
  List<double> waveformData = List.filled(30, 0.0);

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    pulseController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController?.dispose();
    recordingTimer?.cancel();
    simulationTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Microphone permission denied');
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
        detectedNote = '';
        detectedFrequency = 0.0;
      });
      
      pulseController!.repeat(reverse: true);
      
      // Start recording
      final path = await _getRecordingPath('lowest_note_${DateTime.now().millisecondsSinceEpoch}.m4a');
      
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        lowestRecordingPath = path;
        startFrequencySimulation();
        
        // Auto stop after 8 seconds
        recordingTimer = Timer(Duration(seconds: 8), () {
          stopRecording();
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
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
        detectedNote = '';
        detectedFrequency = 0.0;
      });
      
      pulseController!.repeat(reverse: true);
      
      // Start recording
      final path = await _getRecordingPath('highest_note_${DateTime.now().millisecondsSinceEpoch}.m4a');
      
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        highestRecordingPath = path;
        startFrequencySimulation();
        
        // Auto stop after 8 seconds
        recordingTimer = Timer(Duration(seconds: 8), () {
          stopRecording();
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        isRecording = false;
        currentStep = 'lowest';
      });
    }
  }

  void startFrequencySimulation() {
    final random = Random();
    
    simulationTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (!isRecording) {
        timer.cancel();
        return;
      }

      double simulatedFreq;
      if (currentStep == 'lowest') {
        simulatedFreq = 100 + random.nextDouble() * 150;
      } else {
        simulatedFreq = 250 + random.nextDouble() * 200;
      }

      for (int i = 0; i < waveformData.length; i++) {
        waveformData[i] = random.nextDouble() * 2 - 1;
      }

      String closestNote = '';
      double closestDiff = double.infinity;
      
      for (var noteData in musicalNotes) {
        double diff = (simulatedFreq - noteData['frequency']).abs();
        if (diff < closestDiff) {
          closestDiff = diff;
          closestNote = noteData['note'];
        }
      }

      setState(() {
        detectedFrequency = simulatedFreq;
        detectedNote = closestNote;
      });
    });
  }

  void stopRecording() async {
    try {
      setState(() {
        isRecording = false;
      });
      
      pulseController!.stop();
      pulseController!.reset();
      recordingTimer?.cancel();
      simulationTimer?.cancel();

      // Stop recording
      await _recorder.stop();

      if (detectedNote.isNotEmpty) {
        if (currentStep == 'lowest') {
          lowestNote = detectedNote;
          lowestFrequency = detectedFrequency;
          
          Timer(Duration(seconds: 1), () {
            startHighestTest();
          });
        } else {
          highestNote = detectedNote;
          highestFrequency = detectedFrequency;
          calculateVocalRange();
          showResults();
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void calculateVocalRange() {
    if (lowestFrequency <= 130 && highestFrequency <= 260) {
      vocalRange = 'BASS';
    } else if (lowestFrequency <= 130 && highestFrequency <= 349) {
      vocalRange = 'BARITONE';
    } else if (lowestFrequency <= 174 && highestFrequency <= 440) {
      vocalRange = 'TENOR';
    } else if (lowestFrequency >= 130 && highestFrequency >= 260 && highestFrequency <= 440) {
      vocalRange = 'ALTO';
    } else if (lowestFrequency >= 174 && highestFrequency >= 349) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording not found')),
      );
      return;
    }

    try {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing recording')),
      );
    }
  }

  void showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: 300,
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
                    'Learning Course',
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
                      'Summary',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                'Results',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              
              SizedBox(height: 12),
              
              // Waveform
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
                    children: List.generate(15, (index) {
                      final random = Random();
                      final height = random.nextDouble() * 40 + 10;
                      return Container(
                        width: 6,
                        height: height,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(3),
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
                  fontSize: 28,
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
                            Text(lowestNote, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _playRecording(lowestRecordingPath),
                              child: Icon(
                                isPlayingBack ? Icons.stop : Icons.play_arrow,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Highest:', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        Row(
                          children: [
                            Text(highestNote, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _playRecording(highestRecordingPath),
                              child: Icon(
                                isPlayingBack ? Icons.stop : Icons.play_arrow,
                                color: Color(0xFF2196F3),
                                size: 20,
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
              
              // Playback instruction
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Finish', style: TextStyle(fontSize: 14)),
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
      detectedNote = '';
      detectedFrequency = 0.0;
      lowestNote = '';
      lowestFrequency = 0.0;
      highestNote = '';
      highestFrequency = 0.0;
      vocalRange = '';
      lowestRecordingPath = null;
      highestRecordingPath = null;
    });
  }

  String getInstructionText() {
    switch (currentStep) {
      case 'start':
        return 'Let\'s help you find your comfortable vocal range. Your voice will be recorded for playback.';
      case 'lowest':
        return 'Hum or sing your LOWEST comfortable note.';
      case 'highest':
        return 'Now hum or sing your HIGHEST comfortable note.';
      default:
        return '';
    }
  }

  String getActivityTitle() {
    switch (currentStep) {
      case 'lowest':
        return 'Activity:\nFind your LOWEST comfortable note by humming.';
      case 'highest':
        return 'Activity:\nFind your HIGHEST comfortable note by humming.';
      default:
        return 'Activity:\nLet\'s discover your vocal range!';
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
                Text(
                  'Learning Course',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
                Text(
                  'Humming/Singing',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Waveform Visualization
          if (isRecording)
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
                    final height = (waveformData[index].abs() * 50) + 8;
                    return Container(
                      width: 4,
                      height: height,
                      margin: EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Detected Note Display
          if (detectedNote.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Detected Note',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    detectedNote,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
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
                      }
                    },
                    child: AnimatedBuilder(
                      animation: pulseAnimation!,
                      builder: (context, child) {
                        return Container(
                          width: isRecording ? 100 * pulseAnimation!.value : 100,
                          height: isRecording ? 100 * pulseAnimation!.value : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording ? Color(0xFF2196F3) : Color(0xFFF5F5F5),
                            border: Border.all(
                              color: Color(0xFF2196F3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: isRecording ? Colors.white : Color(0xFF2196F3),
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
                        : isRecording 
                            ? 'Recording...' 
                            : 'Tap to Stop',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
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