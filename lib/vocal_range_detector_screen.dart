// lib/vocal_range_detector_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:note_coach_new_2/vocal_range_frequencies.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

class VocalRangeDetectorScreen extends StatefulWidget {
  @override
  State<VocalRangeDetectorScreen> createState() => _VocalRangeDetectorScreenState();
}

class _VocalRangeDetectorScreenState extends State<VocalRangeDetectorScreen> {
  final _audioRecorder = FlutterAudioCapture();
  final _pitchDetector = PitchDetector(audioSampleRate: 44100, bufferSize: 2000);
  final _pitchHandler = PitchHandler(InstrumentType.guitar); // Or use GUITAR/UKULELE/PIANO

  double? _frequency;
  String? _note;
  double? _centsOffset;
  bool _isDetecting = false;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestMicPermission();
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      hasPermission = status == PermissionStatus.granted;
    });
    if (!hasPermission) {
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Microphone Permission Required'),
        content: Text('Please grant microphone access to use pitch detection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startDetection() async {
    if (_isDetecting) return;
    if (!hasPermission) {
      await _requestMicPermission();
      if (!hasPermission) return;
    }
    setState(() {
      _isDetecting = true;
      _frequency = null;
      _note = null;
      _centsOffset = null;
    });

    await _audioRecorder.start(
      (dynamic obj) async {
        final buffer = Float64List.fromList(obj.cast<double>());
        final List<double> audioSample = buffer.toList();
        final result = await _pitchDetector.getPitchFromFloatBuffer(audioSample);
        if (result.pitched) {
          final freq = result.pitch;
          final closestNote = VocalRangeFrequencies.findClosestNote(freq);
          String noteName = closestNote != null
              ? VocalRangeFrequencies.getNoteWithEnharmonic(freq)
              : '--';
          double? noteFreq = closestNote != null ? closestNote['frequency'] as double : null;
          double? cents;
          if (noteFreq != null && freq > 0) {
            cents = 1200 * (log(freq / noteFreq) / ln2);
          }
          setState(() {
            _frequency = freq;
            _note = noteName;
            _centsOffset = cents;
          });
        } else {
          setState(() {
            _frequency = null;
            _note = null;
            _centsOffset = null;
          });
        }
      },
      (Object e) {
        print('Audio error: $e');
      },
      sampleRate: 44100,
      bufferSize: 2000,
    );
  }

  void _stopDetection() async {
    await _audioRecorder.stop();
    setState(() {
      _isDetecting = false;
      _frequency = null;
      _note = null;
    });
  }

  @override
  void dispose() {
    _audioRecorder.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFF22C55E);
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Pitch Detector'),
        backgroundColor: mainColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large frequency display
              Text(
                _frequency != null ? '${_frequency!.toStringAsFixed(1)} Hz' : '-- Hz',
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: mainColor),
              ),
              SizedBox(height: 12),
              // Note name
              Text(
                _note ?? '--',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: mainColor),
              ),
              SizedBox(height: 12),
              // Cents offset
              Text(
                _centsOffset != null ? '${_centsOffset!.abs().toStringAsFixed(1)} cents ${_centsOffset! > 0 ? 'sharp' : _centsOffset! < 0 ? 'flat' : 'in tune'}' : '-- cents',
                style: TextStyle(fontSize: 24, color: Colors.black87),
              ),
              SizedBox(height: 32),
              // Tuner needle/bar
              SizedBox(
                height: 80,
                child: _centsOffset != null
                    ? CustomPaint(
                        size: Size(300, 80),
                        painter: TunerNeedlePainter(_centsOffset!),
                      )
                    : Container(height: 80),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isDetecting ? _stopDetection : _startDetection,
                    icon: Icon(_isDetecting ? Icons.stop : Icons.mic),
                    label: Text(_isDetecting ? 'Stop' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TunerNeedlePainter extends CustomPainter {
  final double cents;
  TunerNeedlePainter(this.cents);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.8;
    final barWidth = size.width * 0.9;
    final barHeight = 8.0;
    final needleLength = size.height * 0.7;
    final maxCents = 50.0; // +/- 50 cents
    final percent = (cents.clamp(-maxCents, maxCents) + maxCents) / (2 * maxCents);
    final needleX = size.width * percent;

    // Draw bar
    final barRect = Rect.fromCenter(center: Offset(centerX, centerY), width: barWidth, height: barHeight);
    final barPaint = Paint()..color = Colors.grey.shade300;
    canvas.drawRRect(RRect.fromRectAndRadius(barRect, Radius.circular(4)), barPaint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;
    canvas.drawLine(Offset(centerX, centerY - 18), Offset(centerX, centerY + 18), centerLinePaint);

    // Draw needle
    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(needleX, centerY),
      Offset(needleX, centerY - needleLength),
      needlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant TunerNeedlePainter oldDelegate) {
    return oldDelegate.cents != cents;
  }
}
