import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(VocalRangeApp());
}

class VocalRangeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocal Range Detector',
      theme: ThemeData.dark().copyWith(
        dialogBackgroundColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF000000),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF000000),
          elevation: 0,
        ),
      ),
      home: VocalRangeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VocalRangeScreen extends StatefulWidget {
  @override
  _VocalRangeScreenState createState() => _VocalRangeScreenState();
}

class _VocalRangeScreenState extends State<VocalRangeScreen>
    with TickerProviderStateMixin {

  // Musical notes with frequencies (same as your images)
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
    
    // Auto stop after 10 seconds
    recordingTimer = Timer(Duration(seconds: 10), () {
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
    
    // Auto stop after 10 seconds
    recordingTimer = Timer(Duration(seconds: 10), () {
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
        simulatedFreq = 200 + random.nextDouble() * 150; // 200-350 Hz range
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
        
        // Show success and move to highest test
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF1a1a1a),
            title: Text('Lowest Note Detected!', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 16),
                Text(
                  lowestNote,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Text(
                  '${lowestFrequency.toStringAsFixed(1)} Hz',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text(
                  'Now let\'s find your highest note!',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  startHighestTest();
                },
                child: Text('Continue', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
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
    // Simple vocal range classification based on frequency ranges
    if (lowestFrequency <= 130 && highestFrequency <= 260) {
      vocalRange = 'BARITONE';
    } else if (lowestFrequency <= 174 && highestFrequency >= 174 && highestFrequency <= 349) {
      vocalRange = 'TENOR';
    } else if (lowestFrequency >= 130 && highestFrequency >= 260) {
      vocalRange = 'ALTO';
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
        title: Text('Your Vocal Range', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note, color: Colors.blue, size: 60),
            SizedBox(height: 20),
            Text(
              vocalRange,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetTest();
            },
            child: Text('Test Again', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: TextStyle(color: Colors.blue)),
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
        return 'Press "Find Lowest Note" to start your vocal range test';
      case 'lowest':
        return isRecording 
            ? 'Sing your LOWEST comfortable note and hold it...' 
            : 'Tap "Start" to find your lowest note';
      case 'highest':
        return isRecording 
            ? 'Sing your HIGHEST comfortable note and hold it...' 
            : 'Tap "Start" to find your highest note';
      case 'results':
        return 'Test completed! Your vocal range has been determined.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocal Range', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Instruction text
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              getInstructionText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),

          // Current detection display
          if (isRecording || detectedNote.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    detectedNote.isEmpty ? '---' : detectedNote,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isRecording ? Colors.blue : Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    detectedFrequency > 0 ? '${detectedFrequency.toStringAsFixed(1)} Hz' : '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

          // Frequency list (same design as your images)
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: musicalNotes.length,
                itemBuilder: (context, index) {
                  final noteData = musicalNotes[index];
                  final note = noteData['note'];
                  final frequency = noteData['frequency'];
                  final isActive = note == detectedNote && isRecording;
                  
                  return Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      color: Color(0xFF1a1a1a),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF333333), width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Indicator circle
                        Container(
                          width: 60,
                          child: Center(
                            child: isActive
                                ? AnimatedBuilder(
                                    animation: pulseAnimation!,
                                    builder: (context, child) {
                                      return Container(
                                        width: 20 * pulseAnimation!.value,
                                        height: 20 * pulseAnimation!.value,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                          ),
                        ),
                        
                        // Note name
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isActive ? Colors.blue : Colors.white,
                            ),
                          ),
                        ),
                        
                        // Frequency
                        Container(
                          width: 80,
                          child: Text(
                            '${frequency.toStringAsFixed(2)} Hz',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive ? Colors.blue : Colors.white54,
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                if (currentStep == 'start')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: startLowestTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Find Lowest Note',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                
                if (currentStep == 'lowest' || currentStep == 'highest')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isRecording ? stopRecording : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecording ? Colors.red : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isRecording ? 'Stop Recording' : 'Recording...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                if (currentStep == 'results')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: resetTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Test Again',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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