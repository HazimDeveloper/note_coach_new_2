// lib/vocal_range_detector_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class VocalRangeDetectorScreen extends StatefulWidget {
  @override
  _VocalRangeDetectorScreenState createState() => _VocalRangeDetectorScreenState();
}

class _VocalRangeDetectorScreenState extends State<VocalRangeDetectorScreen>
    with TickerProviderStateMixin {

  // Musical notes with frequencies (same as your original code)
  final List<Map<String, dynamic>> musicalNotes = [
    {'note': 'F2', 'frequency': 87.31},
    {'note': 'F#2/G♭2', 'frequency': 92.50},
    {'note': 'G2', 'frequency': 98.00},
    {'note': 'G#2/A♭2', 'frequency': 103.83},
    {'note': 'A2', 'frequency': 110.00},
    {'note': 'A#2/B♭2', 'frequency': 116.54},
    {'note': 'B2', 'frequency': 123.47},
    {'note': 'C3', 'frequency': 130.81},
    {'note': 'C#3/D♭3', 'frequency': 138.59},
    {'note': 'D3', 'frequency': 146.83},
    {'note': 'D#3/E♭3', 'frequency': 155.56},
    {'note': 'E3', 'frequency': 164.81},
    {'note': 'F3', 'frequency': 174.61},
    {'note': 'F#3/G♭3', 'frequency': 185.00},
    {'note': 'G3', 'frequency': 196.00},
    {'note': 'G#3/A♭3', 'frequency': 207.65},
    {'note': 'A3', 'frequency': 220.00},
    {'note': 'A#3/B♭3', 'frequency': 233.08},
    {'note': 'B3', 'frequency': 246.94},
    {'note': 'C4', 'frequency': 261.63},
    {'note': 'C#4/D♭4', 'frequency': 277.18},
    {'note': 'D4', 'frequency': 293.66},
    {'note': 'D#4/E♭4', 'frequency': 311.13},
    {'note': 'E4', 'frequency': 329.63},
    {'note': 'F4', 'frequency': 349.23},
    {'note': 'F#4/G♭4', 'frequency': 369.99},
    {'note': 'G4', 'frequency': 392.00},
    {'note': 'G#4/A♭4', 'frequency': 415.30},
    {'note': 'A4', 'frequency': 440.00},
    {'note': 'A#4/B♭4', 'frequency': 466.16},
    {'note': 'B4', 'frequency': 493.88},
    {'note': 'C5', 'frequency': 523.25},
  ];

  // Test states
  String currentStep = 'start'; // start, lowest, highest, results
  bool isRecording = false;
  String detectedNote = '';
  double detectedFrequency = 0.0;
  
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
    super.dispose();
  }

  void startLowestTest() {
    setState(() {
      currentStep = 'lowest';
      isRecording = true;
      detectedNote = '';
      detectedFrequency = 0.0;
    });
    
    pulseController!.repeat(reverse: true);
    startFrequencySimulation();
    
    // Auto stop after 8 seconds
    recordingTimer = Timer(Duration(seconds: 8), () {
      stopRecording();
    });
  }

  void startHighestTest() {
    setState(() {
      currentStep = 'highest';
      isRecording = true;
      detectedNote = '';
      detectedFrequency = 0.0;
    });
    
    pulseController!.repeat(reverse: true);
    startFrequencySimulation();
    
    // Auto stop after 8 seconds
    recordingTimer = Timer(Duration(seconds: 8), () {
      stopRecording();
    });
  }

  void startFrequencySimulation() {
    final random = Random();
    
    simulationTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (!isRecording) {
        timer.cancel();
        return;
      }

      // Simulate frequency detection based on current step
      double simulatedFreq;
      if (currentStep == 'lowest') {
        // Simulate lower frequencies for lowest test
        simulatedFreq = 100 + random.nextDouble() * 150; // 100-250 Hz range
      } else {
        // Simulate higher frequencies for highest test
        simulatedFreq = 250 + random.nextDouble() * 200; // 250-450 Hz range
      }

      // Generate waveform data
      for (int i = 0; i < waveformData.length; i++) {
        waveformData[i] = random.nextDouble() * 2 - 1; // -1 to 1
      }

      // Find closest note
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

  void stopRecording() {
    setState(() {
      isRecording = false;
    });
    
    pulseController!.stop();
    pulseController!.reset();
    recordingTimer?.cancel();
    simulationTimer?.cancel();

    // Save the detected note
    if (detectedNote.isNotEmpty) {
      if (currentStep == 'lowest') {
        lowestNote = detectedNote;
        lowestFrequency = detectedFrequency;
        
        // Wait a moment then start highest test
        Timer(Duration(seconds: 1), () {
          startHighestTest();
        });
      } else {
        // Highest test completed
        highestNote = detectedNote;
        highestFrequency = detectedFrequency;
        calculateVocalRange();
        showResults();
      }
    }
  }

  void calculateVocalRange() {
    // Enhanced vocal range classification
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

  void showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.summarize, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Summary',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Step Information (like in report)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Text(
              getStepInfo(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),

          SizedBox(height: 10),
              
              // Results section with waveform visualization
              Text(
                'Results',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              
              SizedBox(height: 16),
              
              // Waveform visualization (simplified)
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.graphic_eq, color: Color(0xFF2196F3), size: 30),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Vocal Range Result
              Text(
                'YOUR VOCAL RANGE',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
              
              SizedBox(height: 20),
              
              // Detailed results
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lowest:', style: TextStyle(color: Colors.white70)),
                        Text(lowestNote, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Highest:', style: TextStyle(color: Colors.white70)),
                        Text(highestNote, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
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
                  onPressed: () {
                    Navigator.pop(context);
                    resetTest();
                  },
                  icon: Icon(Icons.refresh, color: Color(0xFF2196F3), size: 16),
                  label: Text('Retake', style: TextStyle(color: Color(0xFF2196F3))),
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
                  child: Text('Finish'),
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
    });
  }

  String getInstructionText() {
    switch (currentStep) {
      case 'start':
        return 'Let\'s help you find your comfortable vocal range. Start by pressing "Run Test" when ready.';
      case 'lowest':
        return 'Hum or sing your LOWEST comfortable note that you can comfortably sing by humming.';
      case 'highest':
        return 'Now hum or sing your HIGHEST comfortable note that you can comfortably sing by humming.';
      default:
        return '';
    }
  }

  String getActivityTitle() {
    switch (currentStep) {
      case 'lowest':
        return 'Activity:\nFind your LOWEST comfortable note that you can comfortably sing by humming.';
      case 'highest':
        return 'Activity:\nFind your HIGHEST comfortable note that you can comfortably sing by humming.';
      default:
        return 'Activity:\nLet\'s discover your vocal range to determine the most suitable songs for you!';
    }
  }

  String getStepInfo() {
    switch (currentStep) {
      case 'lowest':
        return 'Let\'s help you find your comfortable vocal range. Start singing your lowest note by pressing "Run Test" when ready.';
      case 'highest':
        return 'Now let\'s find your highest comfortable note. Press the microphone when ready.';
      default:
        return 'We\'ll guide you through finding your vocal range step by step.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Course'),
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
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Humming/Singing',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Waveform Visualization (exactly like report)
          if (isRecording)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFF1a1a1a),
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

          // Detected Note Display (shown at bottom as per report)
          if (detectedNote.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Detected Note',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                            color: isRecording ? Color(0xFF2196F3) : Color(0xFF1a1a1a),
                            border: Border.all(
                              color: Color(0xFF2196F3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.mic,
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
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Instruction Text (bottom, like report)
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                if (currentStep == 'start')
                  Text(
                    getInstructionText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                if (currentStep != 'start')
                  Text(
                    currentStep == 'lowest' 
                        ? 'Hold your lowest comfortable note for best results'
                        : 'Hold your highest comfortable note for best results',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}