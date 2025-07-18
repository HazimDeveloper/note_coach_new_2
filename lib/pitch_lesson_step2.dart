import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:note_coach_new_2/pitch_lesson_step3.dart';
import 'realtime_voice_detector.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

// Pitch Lesson Step 2 - Listen to Different Pitches (White Theme)
class PitchLessonStep2 extends StatefulWidget {
  @override
  _PitchLessonStep2State createState() => _PitchLessonStep2State();
}

class _PitchLessonStep2State extends State<PitchLessonStep2> {
  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Audio files mapping
  final Map<String, String> audioTones = {
    'A3': 'audio/tones/A3_220Hz.mp3',  // Remove 'assets/' prefix for audioplayers
    'C4': 'audio/tones/C4_262Hz.mp3', 
    'E4': 'audio/tones/E4_330Hz.mp3',
    'A4': 'audio/tones/A4_440Hz.mp3',
  };
  
  final Map<String, String> frequencies = {
    'A3': '220 Hz',
    'C4': '262 Hz',
    'E4': '330 Hz', 
    'A4': '440 Hz',
  };

  String? currentlyPlaying;
  String? sustainedNoteResult;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Header with Progress
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pitch Lesson',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lightbulb, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Step 2 of 4',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5, // 50% progress (step 2 of 4)
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Title
            Text(
              'Listen to Different Pitches',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Description
            Text(
              'Let\'s hear different pitch levels. Pay attention to how they sound different.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Audio Instructions
            Text(
              'Tap to hear different pitches:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Audio Buttons Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: audioTones.keys.map((note) => _buildAudioButton(note)).toList(),
            ),
            
            SizedBox(height: 40),
            
            // What is Pitch Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is Pitch?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Pitch refers to the highness or lowness of a sound, determined by its frequency. Matching pitch is essential for singing in tune.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Did You Know Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Did you know?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Pitch is just frequency.\nA higher frequency means a higher pitch.\nHigher pitch = faster vibrations.\nLower pitch = slower vibrations.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Real-time Voice Type Detector
            Text(
              'Try singing or humming a note below to see your note if you hold it for 3 seconds:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomSustainedNoteDetector(
                onSustainedNote: (note, frequency, voiceType) {
                  setState(() {
                    sustainedNoteResult = '$note (${frequency.toStringAsFixed(1)} Hz) - $voiceType';
                  });
                },
              ),
            ),
            if (sustainedNoteResult != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                    SizedBox(height: 8),
                    Text('Sustained Note Detected!', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(sustainedNoteResult!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
            SizedBox(height: 32),
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 16),
                    label: Text('Previous', style: TextStyle(color: Colors.grey[700])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PitchLessonStep3()),
                    ),
                    icon: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    label: Text('Next', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildAudioButton(String note) {
    final isPlaying = currentlyPlaying == note;
    
    return GestureDetector(
      onTap: () => _playTone(note),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying ? Color(0xFF2196F3) : Colors.grey[400]!,
            width: isPlaying ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: isPlaying ? Color(0xFF2196F3) : Colors.grey[700],
              size: 32,
            ),
            SizedBox(height: 12),
            Text(
              note,
              style: TextStyle(
                color: isPlaying ? Color(0xFF2196F3) : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              frequencies[note]!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playTone(String note) async {
    try {
      if (currentlyPlaying == note) {
        // Stop current tone
        await _audioPlayer.stop();
        setState(() {
          currentlyPlaying = null;
        });
      } else {
        // Stop any currently playing audio
        await _audioPlayer.stop();
        
        // Play new tone
        setState(() {
          currentlyPlaying = note;
        });
        
        // Play audio from assets
        await _audioPlayer.play(AssetSource(audioTones[note]!));
        
        // Listen for completion
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              currentlyPlaying = null;
            });
          }
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      // If file not found, show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio file not found: ${audioTones[note]}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        currentlyPlaying = null;
      });
    }
  }
}

class CustomSustainedNoteDetector extends StatefulWidget {
  final void Function(String note, double frequency, String voiceType) onSustainedNote;
  const CustomSustainedNoteDetector({required this.onSustainedNote});

  @override
  State<CustomSustainedNoteDetector> createState() => _CustomSustainedNoteDetectorState();
}

class _CustomSustainedNoteDetectorState extends State<CustomSustainedNoteDetector> with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool isListening = false;
  bool hasPermission = false;
  String? audioFilePath;
  Timer? analysisTimer;
  double currentFrequency = 0.0;
  String currentNote = '';
  String currentVoiceType = '';
  String? sustainedNote;
  DateTime? sustainedStartTime;
  Timer? sustainedTimer;
  bool showingSustained = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _stopListening();
    analysisTimer?.cancel();
    sustainedTimer?.cancel();
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
    if (!hasPermission) return;
    setState(() {
      isListening = true;
      currentFrequency = 0.0;
      currentNote = '';
      currentVoiceType = '';
      sustainedNote = null;
      sustainedStartTime = null;
      showingSustained = false;
    });
    final directory = await getTemporaryDirectory();
    audioFilePath = '${directory.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 48000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: audioFilePath!,
      );
      _startRealTimeAnalysis();
    }
  }

  void _stopListening() async {
    setState(() {
      isListening = false;
      currentFrequency = 0.0;
      currentNote = '';
      currentVoiceType = '';
      sustainedNote = null;
      sustainedStartTime = null;
      showingSustained = false;
    });
    analysisTimer?.cancel();
    sustainedTimer?.cancel();
    await _recorder.stop();
    if (audioFilePath != null && File(audioFilePath!).existsSync()) {
      await File(audioFilePath!).delete();
      audioFilePath = null;
    }
  }

  void _startRealTimeAnalysis() {
    analysisTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!isListening) {
        timer.cancel();
        return;
      }
      await _analyzeCurrentAudio();
    });
  }

  Future<void> _analyzeCurrentAudio() async {
    if (audioFilePath == null || !File(audioFilePath!).existsSync()) return;
    try {
      final audioFile = File(audioFilePath!);
      final fileSize = await audioFile.length();
      if (fileSize < 8000) return;
      final audioBytes = await audioFile.readAsBytes();
      List<double> samples = _convertBytesToSamples(audioBytes);
      if (samples.length < 1000) return;
      int sampleRate = 44100;
      int startIndex = samples.length > sampleRate ? samples.length - sampleRate : 0;
      List<double> recentSamples = samples.sublist(startIndex);
      double detectedFreq = _detectPitchAutocorrelation(recentSamples);
      if (detectedFreq > 50 && detectedFreq < 1200) {
        _processDetectedFrequency(detectedFreq);
      } else {
        setState(() {
          currentFrequency = 0.0;
          currentNote = '';
          currentVoiceType = '';
        });
      }
    } catch (e) {}
  }

  List<double> _convertBytesToSamples(Uint8List bytes) {
    List<double> samples = [];
    int startIndex = 44;
    if (bytes.length <= startIndex) return samples;
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
    int sampleRate = 44100;
    List<double> windowedSamples = _applyHammingWindow(samples);
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
      currentFrequency = frequency;
    });
    Map<String, dynamic>? noteData = PreciseVoiceFrequencies.findExactNote(frequency);
    if (noteData != null) {
      setState(() {
        currentNote = noteData['note'];
        currentVoiceType = noteData['voice_type'];
      });
      _checkSustainedNote(currentNote, frequency, currentVoiceType);
    } else {
      setState(() {
        currentNote = '';
        currentVoiceType = '';
        sustainedNote = null;
        sustainedStartTime = null;
      });
    }
  }

  void _checkSustainedNote(String note, double frequency, String voiceType) {
    if (sustainedNote != note) {
      setState(() {
        sustainedNote = note;
        sustainedStartTime = DateTime.now();
        showingSustained = false;
      });
      sustainedTimer?.cancel();
      sustainedTimer = Timer(Duration(seconds: 3), () {
        if (sustainedNote == note && isListening) {
          setState(() {
            showingSustained = true;
          });
          widget.onSustainedNote(note, frequency, voiceType);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isListening ? _stopListening : _startListening,
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? Colors.red : Color(0xFF2196F3),
              ),
            ),
            SizedBox(width: 16),
            if (isListening && currentNote.isNotEmpty)
              Text(
                'Current: $currentNote',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        if (!isListening && showingSustained && sustainedNote != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Sustained Note: $sustainedNote',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
            ),
          ),
      ],
    );
  }
}