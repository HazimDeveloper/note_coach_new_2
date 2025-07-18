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
import 'vocal_range_frequencies.dart';

// Simple syllabus-based target display
class SingingSyllabus {
  static String getCurrentLevel() {
    // This could be based on user progress, stored preferences, etc.
    // For now, default to INTERMEDIATE
    return 'INTERMEDIATE';
  }

  static String formatTargetNote(
    TimedLyricSegment segment,
    double currentTime,
  ) {
    String level = getCurrentLevel();

    // Get current syllable target
    SyllableTarget? currentSyllable = segment.getCurrentSyllableTarget(
      currentTime,
    );

    // Debug: Print current syllable info
    if (currentSyllable != null) {
      print(
        'Current syllable: ${currentSyllable.syllable} -> ${currentSyllable.targetNote} at time $currentTime',
      );
      if (level == 'BEGINNER') {
        return currentSyllable.targetNote; // Just show basic note name
      } else {
        return currentSyllable.getEnhancedTargetNote(); // Show with enharmonic
      }
    } else {
      print(
        'No syllable found at time $currentTime, using segment target: ${segment.targetNote}',
      );
    }

    // Fallback to segment target
    if (level == 'BEGINNER') {
      return segment.targetNote; // Just show basic note name
    } else {
      return segment.getEnhancedTargetNote(); // Show with enharmonic
    }
  }

  static String formatTargetFrequency(
    TimedLyricSegment segment,
    double currentTime,
  ) {
    String level = getCurrentLevel();

    // Get current syllable target
    SyllableTarget? currentSyllable = segment.getCurrentSyllableTarget(
      currentTime,
    );
    if (currentSyllable != null) {
      if (level == 'BEGINNER') {
        return '--- Hz'; // Hide frequency for beginners
      } else {
        return '${currentSyllable.getPreciseTargetFrequency().toStringAsFixed(1)} Hz';
      }
    }

    // Fallback to segment target
    if (level == 'BEGINNER') {
      return '--- Hz'; // Hide frequency for beginners
    } else {
      return '${segment.getPreciseTargetFrequency().toStringAsFixed(1)} Hz';
    }
  }
}

// Enhanced Song Data with syllable-level timing and frequency matching
class SyllableTarget {
  final String syllable;
  final double startTime;
  final double endTime;
  final double targetFrequency;
  final String targetNote;

  SyllableTarget({
    required this.syllable,
    required this.startTime,
    required this.endTime,
    required this.targetFrequency,
    required this.targetNote,
  });

  // Get the most accurate frequency from vocal range database
  double getPreciseTargetFrequency() {
    var closestNote = VocalRangeFrequencies.findClosestNote(targetFrequency);
    if (closestNote != null) {
      return closestNote['frequency'];
    }
    return targetFrequency;
  }

  // Get enhanced note name with enharmonic equivalents
  String getEnhancedTargetNote() {
    return VocalRangeFrequencies.getNoteWithEnharmonic(targetFrequency);
  }
}

class TimedLyricSegment {
  final String text;
  final double startTime; // in seconds
  final double endTime;
  final double targetFrequency;
  final String targetNote;
  final bool isHighlight; // untuk lyric yang perlu ditonjolkan
  final List<SyllableTarget> syllables; // Individual syllable targets

  TimedLyricSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.targetFrequency,
    required this.targetNote,
    this.isHighlight = false,
    this.syllables = const [],
  });

  // Get the most accurate frequency from vocal range database
  double getPreciseTargetFrequency() {
    // Use the vocal range frequencies for more accurate targets
    var closestNote = VocalRangeFrequencies.findClosestNote(targetFrequency);
    if (closestNote != null) {
      return closestNote['frequency'];
    }
    return targetFrequency; // Fallback to original frequency
  }

  // Get enhanced note name with enharmonic equivalents
  String getEnhancedTargetNote() {
    return VocalRangeFrequencies.getNoteWithEnharmonic(targetFrequency);
  }

  // Get current syllable target based on time
  SyllableTarget? getCurrentSyllableTarget(double currentTime) {
    // Calculate relative time within this segment
    double relativeTime = currentTime - startTime;

    for (var syllable in syllables) {
      if (relativeTime >= syllable.startTime &&
          relativeTime <= syllable.endTime) {
        return syllable;
      }
    }
    return null;
  }
}

class EnhancedSongWithPitchData {
  final String title;
  final String artist;
  final String voiceType;
  final String accompanimentPath;
  final String previewPath;
  final Duration duration;
  final List<TimedLyricSegment> lyricSegments;

  EnhancedSongWithPitchData({
    required this.title,
    required this.artist,
    required this.voiceType,
    required this.accompanimentPath,
    required this.previewPath,
    required this.duration,
    required this.lyricSegments,
  });
}

// Song Database with Real Timing Data and Precise Vocal Range Frequencies
// All target frequencies are now aligned with the vocal range database from the PDF
class PitchDetectionSongDatabase {
  static List<EnhancedSongWithPitchData> getSongs() {
    return [
      // 1. CINTA LUAR BIASA - 29 seconds (TENOR MALE)
      EnhancedSongWithPitchData(
        title: "Cinta Luar Biasa",
        artist: "Andmesh Kamaleng",
        voiceType: "TENOR MALE",
        accompanimentPath:
            "song/Andmesh - Cinta Luar Biasa - TENOR MALE-Accompaniment.mp3",
        previewPath: "song/preview/Andmesh - Cinta Luar Biasa - TENOR MALE.mp3",
        duration: Duration(seconds: 29),
        lyricSegments: [
          // ANDMESH KAMALENG – CINTA LUAR BIASA (TENOR MALE)
          // A3 E4 A3 A3 A3 C#4 B3
          // Ra Sa Ini Tak Ter Ta Han
          TimedLyricSegment(
            text: "Rasa ini",
            startTime: 1.0,
            endTime: 4.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ra",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "sa",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "ini",
                startTime: 1.0,
                endTime: 2.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "tak tertahan",
            startTime: 4.0,
            endTime: 8.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "tak",
                startTime: 0.0,
                endTime: 1.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "ter",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "ta",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "han",
                startTime: 2.0,
                endTime: 4.0,
                targetFrequency: 277.18,
                targetNote: "C#4",
              ),
            ],
          ),
          // A3 E4 A3 A3 A3 C#4 B3
          // Ha Ti Ini Sela Lu Untuk Mu
          TimedLyricSegment(
            text: "Hati ini",
            startTime: 8.0,
            endTime: 10.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ha",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "ti",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "ini",
                startTime: 1.0,
                endTime: 2.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "selalu untukmu",
            startTime: 10.0,
            endTime: 11.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "se",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "la",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "lu",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "untuk",
                startTime: 1.5,
                endTime: 2.5,
                targetFrequency: 277.18,
                targetNote: "C#4",
              ),
              SyllableTarget(
                syllable: "mu",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
            ],
          ),
          // D4 C#3 D4 E4 D4 C#4 D4 – E4
          // Te Ri Ma Lah La Gu Ini
          TimedLyricSegment(
            text: "Terimalah lagu ini",
            startTime: 15.0,
            endTime: 18.0,
            targetFrequency: 293.66,
            targetNote: "D4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Te",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
              SyllableTarget(
                syllable: "ri",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 138.59,
                targetNote: "C#3",
              ),
              SyllableTarget(
                syllable: "ma",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
              SyllableTarget(
                syllable: "lah",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "lagu",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
              SyllableTarget(
                syllable: "ini",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 277.18,
                targetNote: "C#4",
              ),
            ],
          ),
          // A3 B3 B3 A3 A3 G#3 A3
          // Da Ri O Rang Bi A Sa
          TimedLyricSegment(
            text: "dari orang biasa",
            startTime: 18.0,
            endTime: 22.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "da",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "ri",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "orang",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "bi",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "asa",
                startTime: 2.0,
                endTime: 3.0,
                targetFrequency: 207.65,
                targetNote: "G#3",
              ),
            ],
          ),
          // A3 E4 D4 D4 C#4 D4 C#4
          // Ta Pi Cin Ta Ku Pa Da Mu
          TimedLyricSegment(
            text: "Tapi cintaku padamu",
            startTime: 22.0,
            endTime: 25.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ta",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "pi",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "cin",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
              SyllableTarget(
                syllable: "ta",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 277.18,
                targetNote: "C#4",
              ),
              SyllableTarget(
                syllable: "pa",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
            ],
          ),
          // B3 A3 C#4 B3
          // Lu Ar Bi Asa
          TimedLyricSegment(
            text: "luar biasa",
            startTime: 25.0,
            endTime: 27.0,
            targetFrequency: 246.94,
            targetNote: "B3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "lu",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ar",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "bi",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 277.18,
                targetNote: "C#4",
              ),
              SyllableTarget(
                syllable: "asa",
                startTime: 1.5,
                endTime: 3.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
            ],
          ),
        ],
      ),

      // 2. BUKAN CINTA BIASA - 25 seconds (TENOR FEMALE)
      EnhancedSongWithPitchData(
        title: "Bukan Cinta Biasa",
        artist: "Dato' Siti Nurhaliza",
        voiceType: "TENOR FEMALE",
        accompanimentPath:
            "song/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE-Accompaniment.mp3",
        previewPath:
            "song/preview/Dato' Siti Nurhaliza - Bukan Cinta Biasa - TENOR FEMALE.mp3",
        duration: Duration(seconds: 25),
        lyricSegments: [
          // DATO' SITI NURHALIZA – BUKAN CINTA BIASA (TENOR FEMALE)
          // G4 G4 E4 E4 E4 E4 F#4 G4 E4 A4
          // Me Nga Pa Mere Ka Sela Lu Ber Ta Nya
          TimedLyricSegment(
            text: "Mengapa mereka selalu bertanya",
            startTime: 0.0,
            endTime: 7.0,
            targetFrequency: 392.00, // G4 - precise frequency from vocal range
            targetNote: "G4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Me",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "nga",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "pa",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "mere",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "ka",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "sela",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "lu",
                startTime: 3.0,
                endTime: 3.5,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "ber",
                startTime: 3.5,
                endTime: 4.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "ta",
                startTime: 4.0,
                endTime: 4.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "nya",
                startTime: 4.5,
                endTime: 7.0,
                targetFrequency: 440.00,
                targetNote: "A4",
              ),
            ],
          ),
          // E4 F#4 G4 E4 F#4 G4 B4 A4 G4 A4
          // Cin Ta Ku Bu Kan Di A Tas Ker Tas
          TimedLyricSegment(
            text: "Cintaku bukan di atas kertas",
            startTime: 7.0,
            endTime: 11.0,
            targetFrequency: 329.63,
            targetNote: "E4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Cin",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "ta",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "bu",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "kan",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "di",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "atas",
                startTime: 3.0,
                endTime: 3.5,
                targetFrequency: 493.88,
                targetNote: "B4",
              ),
              SyllableTarget(
                syllable: "ker",
                startTime: 3.5,
                endTime: 4.0,
                targetFrequency: 440.00,
                targetNote: "A4",
              ),
            ],
          ),
          // F#4 G4 A4 F#4 G4 A4 C5 B4 A4
          // Cin Ta Ku Ge Ta Ran Yang Sa Ma
          TimedLyricSegment(
            text: "Cintaku getaran yang sama",
            startTime: 11.0,
            endTime: 14.0,
            targetFrequency: 369.99,
            targetNote: "F#4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Cin",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "ta",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 440.00,
                targetNote: "A4",
              ),
              SyllableTarget(
                syllable: "ge",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "ta",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "ran",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 440.00,
                targetNote: "A4",
              ),
              SyllableTarget(
                syllable: "yang",
                startTime: 3.0,
                endTime: 3.5,
                targetFrequency: 523.25,
                targetNote: "C5",
              ),
              SyllableTarget(
                syllable: "sa",
                startTime: 3.5,
                endTime: 4.0,
                targetFrequency: 493.88,
                targetNote: "B4",
              ),
            ],
          ),
          // E4 F#4 G4 C4 B3 C4
          // Tak Per Lu Di Pak Sa
          TimedLyricSegment(
            text: "Tak perlu dipaksa",
            startTime: 14.0,
            endTime: 17.0,
            targetFrequency: 329.63,
            targetNote: "E4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Tak",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "per",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "lu",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "di",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "pak",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "sa",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
            ],
          ),
          // E4 F#4 G4 B3 A3 B3
          // Tak Per Lu Di Ca Ri
          TimedLyricSegment(
            text: "Tak perlu dicari",
            startTime: 17.0,
            endTime: 19.0,
            targetFrequency: 329.63,
            targetNote: "E4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Tak",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "per",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "lu",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "di",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ca",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "ri",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
            ],
          ),
          // G4 G4 F#4 F#4 E4 E4 F#4 G4 A4 A4
          // Ker Na Ku Ya Kin A Da Ja Wab Nya
          TimedLyricSegment(
            text: "Kerna ku yakin ada jawabnya",
            startTime: 19.0,
            endTime: 24.0,
            targetFrequency: 392.00,
            targetNote: "G4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ker",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "na",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "ya",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "kin",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "a",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 329.63,
                targetNote: "E4",
              ),
              SyllableTarget(
                syllable: "da",
                startTime: 3.0,
                endTime: 3.5,
                targetFrequency: 369.99,
                targetNote: "F#4",
              ),
              SyllableTarget(
                syllable: "ja",
                startTime: 3.5,
                endTime: 4.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
            ],
          ),
        ],
      ),

      // 3. JANGAN MATI RASA ITU - 32 seconds (ALTO)
      EnhancedSongWithPitchData(
        title: "Jangan Mati Rasa Itu",
        artist: "Aina Abdul",
        voiceType: "ALTO",
        accompanimentPath:
            "song/Aina Abdul - Jangan Mati Rasa Itu - ALTO-Accompaniment.mp3",
        previewPath:
            "song/preview/Aina Abdul - Jangan Mati Rasa Itu - ALTO.mp3",
        duration: Duration(seconds: 32),
        lyricSegments: [
          // AINA ABDUL – JANGAN MATI RASA ITU (ALTO)
          // Eb4 Db4 F4 F4 G4 Ab4 C4
          // Ka Sih Mu Te Rus Hi Dup
          TimedLyricSegment(
            text: "Kasihmu",
            startTime: 1.0,
            endTime: 4.0,
            targetFrequency: 311.13, // Eb4
            targetNote: "Eb4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ka",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 311.13,
                targetNote: "Eb4",
              ),
              SyllableTarget(
                syllable: "sih",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 277.18,
                targetNote: "Db4",
              ),
              SyllableTarget(
                syllable: "mu",
                startTime: 1.0,
                endTime: 2.0,
                targetFrequency: 349.23,
                targetNote: "F4",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "terus hidup",
            startTime: 4.0,
            endTime: 7.0,
            targetFrequency: 277.18, // Db4
            targetNote: "Db4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "te",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 349.23,
                targetNote: "F4",
              ),
              SyllableTarget(
                syllable: "rus",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "hi",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 415.30,
                targetNote: "Ab4",
              ),
              SyllableTarget(
                syllable: "dup",
                startTime: 1.5,
                endTime: 3.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
            ],
          ),
          // F4 G4 Ab4 B3 C4 D4 F4 G4
          // Ja Ngan Ma Ti Ra Sa I Tu
          TimedLyricSegment(
            text: "Jangan mati rasa",
            startTime: 7.0,
            endTime: 11.0,
            targetFrequency: 349.23, // F4
            targetNote: "F4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ja",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 349.23,
                targetNote: "F4",
              ),
              SyllableTarget(
                syllable: "ngan",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "ma",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 415.30,
                targetNote: "Ab4",
              ),
              SyllableTarget(
                syllable: "ti",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ra",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "sa",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "itu",
            startTime: 11.0,
            endTime: 16.0,
            targetFrequency: 392.00, // G4
            targetNote: "G4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "i",
                startTime: 0.0,
                endTime: 1.0,
                targetFrequency: 349.23,
                targetNote: "F4",
              ),
              SyllableTarget(
                syllable: "tu",
                startTime: 1.0,
                endTime: 3.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
            ],
          ),
          // F4 G4 Ab4 C5
          // Ba Gai Ma Na
          TimedLyricSegment(
            text: "Bagaimana",
            startTime: 16.0,
            endTime: 24.0,
            targetFrequency: 415.30, // Ab4
            targetNote: "Ab4",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ba",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 349.23,
                targetNote: "F4",
              ),
              SyllableTarget(
                syllable: "gai",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 392.00,
                targetNote: "G4",
              ),
              SyllableTarget(
                syllable: "ma",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 415.30,
                targetNote: "Ab4",
              ),
              SyllableTarget(
                syllable: "na",
                startTime: 1.5,
                endTime: 3.0,
                targetFrequency: 523.25,
                targetNote: "C5",
              ),
            ],
          ),
          // Eb5 Db5 C5 Eb5 Db5 Db5 C5 Bb4 Ab4 C4
          // Ha Rus Ku Ja La ni Tan Pa Ka Mu
          TimedLyricSegment(
            text: "harus ku",
            startTime: 24.0,
            endTime: 26.0,
            targetFrequency: 622.25, // Eb5
            targetNote: "Eb5",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "ha",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 622.25,
                targetNote: "Eb5",
              ),
              SyllableTarget(
                syllable: "rus",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 554.37,
                targetNote: "Db5",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 1.0,
                endTime: 3.0,
                targetFrequency: 523.25,
                targetNote: "C5",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "jalani",
            startTime: 26.0,
            endTime: 28.0,
            targetFrequency: 554.37, // Db5
            targetNote: "Db5",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "ja",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 622.25,
                targetNote: "Eb5",
              ),
              SyllableTarget(
                syllable: "la",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 554.37,
                targetNote: "Db5",
              ),
              SyllableTarget(
                syllable: "ni",
                startTime: 1.0,
                endTime: 3.0,
                targetFrequency: 554.37,
                targetNote: "Db5",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "tanpa kamu",
            startTime: 28.0,
            endTime: 31.0,
            targetFrequency: 523.25, // C5
            targetNote: "C5",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "tan",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 523.25,
                targetNote: "C5",
              ),
              SyllableTarget(
                syllable: "pa",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 466.16,
                targetNote: "Bb4",
              ),
              SyllableTarget(
                syllable: "ka",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 415.30,
                targetNote: "Ab4",
              ),
              SyllableTarget(
                syllable: "mu",
                startTime: 1.5,
                endTime: 3.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
            ],
          ),
        ],
      ),

      // 4. HASRAT - 28 seconds (BARITONE)
      EnhancedSongWithPitchData(
        title: "Hasrat",
        artist: "Amir Jahari",
        voiceType: "BARITONE",
        accompanimentPath:
            "song/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE-Accompaniment.mp3",
        previewPath:
            "song/preview/AMIR JAHARI - HASRAT (OST IMAGINUR) - BARITONE.mp3",
        duration: Duration(seconds: 28),
        lyricSegments: [
          // AMIR JAHARI – HASRAT (BARITONE)
          // B3 C4 B3 B3 – A3
          // Te Ri Ak Lah
          TimedLyricSegment(
            text: "Teriaklah",
            startTime: 2.0,
            endTime: 5.0,
            targetFrequency: 246.94,
            targetNote: "B3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Te",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ri",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "ak",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "lah",
                startTime: 1.5,
                endTime: 3.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
            ],
          ),
          // B3 C4 B3 B3 A3 A3 G3 D3
          // Se Ku At Ma Na Pun A Ku
          TimedLyricSegment(
            text: "sekuat mana pun aku",
            startTime: 5.0,
            endTime: 9.0,
            targetFrequency: 246.94,
            targetNote: "B3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "se",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "at",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ma",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "na",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "pun",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "a",
                startTime: 3.0,
                endTime: 3.5,
                targetFrequency: 196.00,
                targetNote: "G3",
              ),
              SyllableTarget(
                syllable: "ku",
                startTime: 3.5,
                endTime: 4.0,
                targetFrequency: 146.83,
                targetNote: "D3",
              ),
            ],
          ),
          // B3 C4 B3 – A3 G3 C4 C4 D4 B4 - A3
          // Sua Ra Ini Ti Ada Men De Ngar
          TimedLyricSegment(
            text: "Suara ini",
            startTime: 9.0,
            endTime: 12.0,
            targetFrequency: 246.94,
            targetNote: "B3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Su",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "a",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "ra",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ini",
                startTime: 1.5,
                endTime: 3.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
            ],
          ),
          TimedLyricSegment(
            text: "tiada mendengar",
            startTime: 12.0,
            endTime: 16.0,
            targetFrequency: 220.00,
            targetNote: "A3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "ti",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 196.00,
                targetNote: "G3",
              ),
              SyllableTarget(
                syllable: "a",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "da",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "men",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 293.66,
                targetNote: "D4",
              ),
              SyllableTarget(
                syllable: "de",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 493.88,
                targetNote: "B4",
              ),
              SyllableTarget(
                syllable: "ngar",
                startTime: 2.5,
                endTime: 4.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
            ],
          ),
          // B3 C4 B3 B3 – A3
          // Te Ri Ak Lah
          TimedLyricSegment(
            text: "Teriaklah",
            startTime: 16.0,
            endTime: 20.0,
            targetFrequency: 246.94,
            targetNote: "B3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Te",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ri",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "ak",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "lah",
                startTime: 1.5,
                endTime: 4.0,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
            ],
          ),
          // B3 C4 B3 B3 A3 G3 E3
          // Ber Hen Ti Lah Ber Ha Rap
          TimedLyricSegment(
            text: "Berhentilah berharap",
            startTime: 20.0,
            endTime: 24.0,
            targetFrequency: 196.00,
            targetNote: "G3",
            isHighlight: true,
            syllables: [
              SyllableTarget(
                syllable: "Ber",
                startTime: 0.0,
                endTime: 0.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "hen",
                startTime: 0.5,
                endTime: 1.0,
                targetFrequency: 261.63,
                targetNote: "C4",
              ),
              SyllableTarget(
                syllable: "ti",
                startTime: 1.0,
                endTime: 1.5,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "lah",
                startTime: 1.5,
                endTime: 2.0,
                targetFrequency: 246.94,
                targetNote: "B3",
              ),
              SyllableTarget(
                syllable: "ber",
                startTime: 2.0,
                endTime: 2.5,
                targetFrequency: 220.00,
                targetNote: "A3",
              ),
              SyllableTarget(
                syllable: "ha",
                startTime: 2.5,
                endTime: 3.0,
                targetFrequency: 196.00,
                targetNote: "G3",
              ),
              SyllableTarget(
                syllable: "rap",
                startTime: 3.0,
                endTime: 4.0,
                targetFrequency: 164.81,
                targetNote: "E3",
              ),
            ],
          ),
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

  // Validate that all target frequencies are within the correct vocal ranges
  static bool validateTargetFrequencies(EnhancedSongWithPitchData song) {
    String voiceType = song.voiceType.toUpperCase();

    for (var segment in song.lyricSegments) {
      double frequency = segment.targetFrequency;

      // Check if frequency is within the expected range for the voice type
      switch (voiceType) {
        case 'BARITONE':
          if (frequency < 65.41 || frequency > 440.00) return false; // C2 to A4
          break;
        case 'TENOR MALE':
        case 'TENOR':
          if (frequency < 87.31 || frequency > 523.25) return false; // F2 to C5
          break;
        case 'TENOR FEMALE':
          if (frequency < 87.31 || frequency > 523.25) return false; // F2 to C5
          break;
        case 'ALTO':
          if (frequency < 130.81 || frequency > 698.46)
            return false; // C3 to F5
          break;
        default:
          if (frequency < 80 || frequency > 800)
            return false; // General vocal range
      }
    }

    return true;
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
  final double confidenceScore;

  PitchPerformanceData({
    required this.accuracy,
    required this.wasOnPitch,
    required this.detectedFrequency,
    required this.detectedNote,
    required this.segment,
    required this.timestamp,
    required this.confidenceScore,
  });
}

// Main Enhanced Singing Practice with Real-time Pitch Detection
class EnhancedSingingPracticeWithPitch extends StatefulWidget {
  final EnhancedSongWithPitchData song;

  const EnhancedSingingPracticeWithPitch({Key? key, required this.song})
    : super(key: key);

  @override
  _EnhancedSingingPracticeWithPitchState createState() =>
      _EnhancedSingingPracticeWithPitchState();
}

class _EnhancedSingingPracticeWithPitchState
    extends State<EnhancedSingingPracticeWithPitch>
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
  TimedLyricSegment?
  lastDisplayedSegment; // Track the last segment that was displayed

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
    // Cancel all timers immediately without calling setState
    progressTimer?.cancel();
    pitchAnalysisTimer?.cancel();
    waveformTimer?.cancel();

    // Stop animations
    lyricAnimController?.stop();
    accuracyAnimController?.stop();
    pulseController?.stop();

    // Stop audio
    _accompanimentPlayer.stop();
    _recorder.stop();

    // Clean up audio file safely
    _cleanupAudioFile();

    // Dispose controllers
    lyricAnimController?.dispose();
    accuracyAnimController?.dispose();
    pulseController?.dispose();
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
      CurvedAnimation(
        parent: accuracyAnimController!,
        curve: Curves.elasticOut,
      ),
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
        lastDisplayedSegment = null; // Reset last displayed segment
        performanceHistory.clear();
        totalCorrectSegments = 0;
        currentFeedbackText = 'Karaoke starting...';
        currentFeedbackColor = Color(0xFF2196F3);
      });

      // Start accompaniment playback
      await _accompanimentPlayer.play(
        AssetSource(widget.song.accompanimentPath),
      );

      // Create unique audio file path with better error handling
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      audioFilePath = '${directory.path}/karaoke_audio_$timestamp.wav';

      // Ensure the directory exists
      final audioDir = Directory(directory.path);
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

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
      _startAccompanimentPositionMonitoring();
      pulseController!.repeat(reverse: true);

      // Listen for song completion
      _accompanimentPlayer.onPlayerComplete.listen((_) {
        // Add a small delay to ensure all final data is captured
        Timer(Duration(milliseconds: 500), () {
          if (mounted) {
            _completePractice();
          }
        });
      });
    } catch (e) {
      print('Error starting karaoke: $e');
      if (mounted) {
        _showErrorDialog('Failed to start karaoke: $e');
      }
    }
  }

  void _startAccompanimentPositionMonitoring() {
    // Monitor accompaniment player position for better synchronization
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!isPlaying || !mounted) {
        timer.cancel();
        return;
      }

      try {
        Duration? position = await _accompanimentPlayer.getCurrentPosition();
        if (position != null && mounted) {
          // Sync current time with actual audio position
          double audioTime = position.inMilliseconds / 1000.0;
          if ((audioTime - currentTime).abs() > 0.2) {
            // If there's a significant difference, sync to audio position
            setState(() {
              currentTime = audioTime;
            });
            _updateCurrentSegment();
          }
        }
      } catch (e) {
        // Continue with timer-based tracking if position monitoring fails
      }
    });
  }

  void _startProgressTracking() {
    // Use higher frequency timer for more precise timing
    progressTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!isPlaying || !mounted) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          currentTime += 0.05; // More precise time increments
          totalPracticeTime = Duration(
            milliseconds: (currentTime * 1000).round(),
          );
        });
      }

      // Check if song has ended (add buffer time)
      if (currentTime >= widget.song.duration.inSeconds + 1.0) {
        _completePractice();
        return;
      }

      _updateCurrentSegment();

      // Force UI update for syllable-level target changes
      if (mounted && currentSegment != null) {
        setState(() {
          // This will trigger the target display to update with current syllable
        });
      }
    });
  }

  void _updateCurrentSegment() {
    if (!mounted) return; // Prevent widget lifecycle errors

    TimedLyricSegment? newSegment;
    int newIndex = -1;

    // Find the current segment based on timing with strict boundaries
    for (int i = 0; i < widget.song.lyricSegments.length; i++) {
      final segment = widget.song.lyricSegments[i];

      // Only activate segment if we're within its exact time range
      if (currentTime >= segment.startTime && currentTime <= segment.endTime) {
        newSegment = segment;
        newIndex = i;
        break;
      }
    }

    // Update current segment if it changed
    if (newSegment != currentSegment) {
      if (mounted) {
        setState(() {
          currentSegment = newSegment;
          currentSegmentIndex = newIndex;
        });
      }

      if (newSegment != null) {
        // Update last displayed segment when we have a new active segment
        lastDisplayedSegment = newSegment;

        // Immediate feedback without animation delay
        if (mounted) {
          setState(() {
            currentFeedbackText = newSegment!.isHighlight
                ? '⭐ ${newSegment.text} ⭐'
                : '🎵 ${newSegment.text}';
          });
        }

        // Animate the lyric change after setting text
        if (lyricAnimController != null) {
          lyricAnimController?.forward().then(
            (_) => lyricAnimController?.reverse(),
          );
        }

        // Reset accuracy for new segment and clear previous data
        if (mounted) {
          setState(() {
            currentAccuracy = 0.0;
            isCurrentlyOnPitch = false;
            currentDetectedFrequency = 0.0;
            currentDetectedNote = '';
            confidenceScore = 0.0;
          });
        }
      } else {
        // During instrumental, keep the last displayed segment visible
        if (mounted) {
          setState(() {
            currentFeedbackText = lastDisplayedSegment != null
                ? '🎵 ${lastDisplayedSegment!.text}'
                : '🎶 Instrumental...';
            currentAccuracy = 0.0;
            isCurrentlyOnPitch = false;
          });
        }
      }
    }
  }

  String _getInstrumentalMessage() {
    // Get current time in the song
    int currentMinute = (currentTime / 60).floor();
    int currentSecond = (currentTime % 60).floor();

    // Different messages based on song progress
    if (currentTime < 5.0) {
      return '🎼 Get ready to sing! 🎼';
    } else if (currentTime < widget.song.duration.inSeconds * 0.25) {
      return '🎵 Instrumental Break 🎵';
    } else if (currentTime < widget.song.duration.inSeconds * 0.5) {
      return '🎶 Musical Interlude 🎶';
    } else if (currentTime < widget.song.duration.inSeconds * 0.75) {
      return '🎼 Bridge Section 🎼';
    } else if (currentTime < widget.song.duration.inSeconds - 3) {
      return '🎵 Final Instrumental 🎵';
    } else {
      return '🎶 Song Ending 🎶';
    }
  }

  void _startRealTimePitchDetection() {
    pitchAnalysisTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (!isPlaying || !isRecording || !mounted) {
        timer.cancel();
        return;
      }

      _analyzeCurrentAudio();
    });
  }

  Future<void> _analyzeCurrentAudio() async {
    if (audioFilePath == null) return;

    try {
      // Check if file exists before trying to read it
      final audioFile = File(audioFilePath!);
      if (!await audioFile.exists()) {
        return;
      }

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
      int startIndex = samples.length > sampleRate
          ? samples.length - sampleRate
          : 0;
      List<double> recentSamples = samples.sublist(startIndex);

      // Detect pitch using autocorrelation method
      double detectedFreq = _detectPitchAutocorrelation(recentSamples);

      if (detectedFreq > 50 && detectedFreq < 1200) {
        _processDetectedFrequency(detectedFreq);
      } else {
        // Only update state if widget is still mounted
        if (mounted) {
          setState(() {
            currentDetectedFrequency = 0.0;
            currentDetectedNote = '';
            currentAccuracy = 0.0;
            isCurrentlyOnPitch = false;
            confidenceScore = 0.0;
          });
        }
      }
    } catch (e) {
      // Log error but don't crash the app
      print('Error analyzing audio: $e');
      // Don't update state if there's an error to prevent widget issues
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

    // Use FFT-based pitch detection for better accuracy
    double detectedFreq = _detectPitchFFT(windowedSamples);

    if (detectedFreq > 0) {
      return detectedFreq;
    }

    // Fallback to autocorrelation if FFT fails
    return _detectPitchAutocorrelationFallback(windowedSamples);
  }

  double _detectPitchFFT(List<double> samples) {
    if (samples.length < 1024) return 0.0;

    // Use power of 2 for FFT efficiency
    int fftSize = 2048;
    List<double> paddedSamples = List.filled(fftSize, 0.0);

    // Copy samples and apply window
    for (int i = 0; i < samples.length && i < fftSize; i++) {
      paddedSamples[i] = samples[i];
    }

    // Apply Hanning window
    for (int i = 0; i < fftSize; i++) {
      double window = 0.5 * (1 - cos(2 * pi * i / (fftSize - 1)));
      paddedSamples[i] *= window;
    }

    // Perform FFT (simplified implementation)
    List<double> magnitudes = _computeFFTMagnitudes(paddedSamples);

    // Find peak frequency in vocal range
    double peakFreq = _findPeakFrequency(magnitudes);

    return peakFreq;
  }

  List<double> _computeFFTMagnitudes(List<double> samples) {
    // Simplified FFT implementation
    int n = samples.length;
    List<double> magnitudes = List.filled(n ~/ 2, 0.0);

    for (int k = 0; k < n ~/ 2; k++) {
      double real = 0.0;
      double imag = 0.0;

      for (int i = 0; i < n; i++) {
        double angle = -2 * pi * k * i / n;
        real += samples[i] * cos(angle);
        imag += samples[i] * sin(angle);
      }

      magnitudes[k] = sqrt(real * real + imag * imag);
    }

    return magnitudes;
  }

  double _findPeakFrequency(List<double> magnitudes) {
    // Find the strongest frequency in vocal range
    int minBin = (50 * magnitudes.length * 2 / sampleRate).round();
    int maxBin = (1200 * magnitudes.length * 2 / sampleRate).round();

    double maxMagnitude = 0.0;
    int peakBin = 0;

    for (int i = minBin; i < maxBin && i < magnitudes.length; i++) {
      if (magnitudes[i] > maxMagnitude) {
        maxMagnitude = magnitudes[i];
        peakBin = i;
      }
    }

    // Calculate frequency from bin
    double frequency = peakBin * sampleRate / (magnitudes.length * 2);

    // Only return if magnitude is significant
    if (maxMagnitude > 100.0) {
      return frequency;
    }

    return 0.0;
  }

  double _detectPitchAutocorrelationFallback(List<double> samples) {
    // Autocorrelation method for pitch detection
    int minPeriod = (sampleRate / 1200).round();
    int maxPeriod = (sampleRate / 50).round();

    double maxCorrelation = 0.0;
    int bestPeriod = 0;

    for (
      int period = minPeriod;
      period < maxPeriod && period < samples.length ~/ 2;
      period++
    ) {
      double correlation = 0.0;
      int samples_to_check = samples.length - period;

      for (int i = 0; i < samples_to_check; i++) {
        correlation += samples[i] * samples[i + period];
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
    // Check if widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      currentDetectedFrequency = frequency;
    });

    // Find the detected note
    currentDetectedNote = _frequencyToNote(frequency);

    // Calculate confidence based on clarity of detection
    confidenceScore = _calculateConfidence(frequency);

    if (currentSegment != null) {
      // Calculate accuracy against target note using precise frequency
      currentAccuracy = _calculatePitchAccuracy(
        frequency,
        currentSegment!.getPreciseTargetFrequency(),
      );

      // Determine if on pitch with voice type specific criteria
      double frequencyDiff =
          (currentDetectedFrequency -
                  currentSegment!.getPreciseTargetFrequency())
              .abs();
      double centsDiff =
          1200 *
          log(
            currentDetectedFrequency /
                currentSegment!.getPreciseTargetFrequency(),
          ) /
          ln2;

      // Voice type specific on-pitch criteria
      String voiceType = widget.song.voiceType.toUpperCase();
      double pitchTolerance;
      double accuracyThreshold;

      switch (voiceType) {
        case 'BARITONE':
          pitchTolerance = 20.0; // ±20 cents for baritone
          accuracyThreshold = 0.75;
          break;
        case 'TENOR MALE':
        case 'TENOR':
          pitchTolerance = 18.0; // ±18 cents for tenor
          accuracyThreshold = 0.78;
          break;
        case 'TENOR FEMALE':
          pitchTolerance = 16.0; // ±16 cents for female tenor
          accuracyThreshold = 0.80;
          break;
        case 'ALTO':
          pitchTolerance = 22.0; // ±22 cents for alto
          accuracyThreshold = 0.72;
          break;
        default:
          pitchTolerance = 20.0;
          accuracyThreshold = 0.75;
      }

      isCurrentlyOnPitch =
          centsDiff.abs() < pitchTolerance &&
          currentAccuracy > accuracyThreshold;

      // Update visual feedback
      _updateRealTimeFeedback();

      // Store performance data only when we have a valid segment
      _recordPerformanceData();

      // Only animate if widget is still mounted
      if (mounted) {
        accuracyAnimController?.forward().then(
          (_) => accuracyAnimController?.reverse(),
        );
      }
    } else {
      // If no current segment, still calculate accuracy based on closest segment
      if (widget.song.lyricSegments.isNotEmpty) {
        TimedLyricSegment? closestSegment;
        double minTimeDiff = double.infinity;

        for (final segment in widget.song.lyricSegments) {
          double timeDiff = (currentTime - segment.startTime).abs();
          if (timeDiff < minTimeDiff) {
            minTimeDiff = timeDiff;
            closestSegment = segment;
          }
        }

        if (closestSegment != null && minTimeDiff < 1.5) {
          // Only if within 1.5 seconds for better precision
          currentAccuracy = _calculatePitchAccuracy(
            currentDetectedFrequency,
            closestSegment!.getPreciseTargetFrequency(),
          );
          double centsDiff =
              1200 *
              log(
                currentDetectedFrequency /
                    closestSegment!.getPreciseTargetFrequency(),
              ) /
              ln2;

          // Use same voice type specific criteria
          String voiceType = widget.song.voiceType.toUpperCase();
          double pitchTolerance;
          double accuracyThreshold;

          switch (voiceType) {
            case 'BARITONE':
              pitchTolerance = 20.0;
              accuracyThreshold = 0.75;
              break;
            case 'TENOR MALE':
            case 'TENOR':
              pitchTolerance = 18.0;
              accuracyThreshold = 0.78;
              break;
            case 'TENOR FEMALE':
              pitchTolerance = 16.0;
              accuracyThreshold = 0.80;
              break;
            case 'ALTO':
              pitchTolerance = 22.0;
              accuracyThreshold = 0.72;
              break;
            default:
              pitchTolerance = 20.0;
              accuracyThreshold = 0.75;
          }

          isCurrentlyOnPitch =
              centsDiff.abs() < pitchTolerance &&
              currentAccuracy > accuracyThreshold;
        } else {
          currentAccuracy = 0.0;
          isCurrentlyOnPitch = false;
        }
      } else {
        currentAccuracy = 0.0;
        isCurrentlyOnPitch = false;
      }

      if (mounted) {
        setState(() {
          currentFeedbackColor = Colors.grey;
          currentFeedbackText = _getInstrumentalMessage();
        });
      }
    }
  }

  String _frequencyToNote(double frequency) {
    if (frequency < 50 || frequency > 1200) return '---';

    // Use the vocal range frequencies for more accurate note detection
    // Import the vocal range data
    var closestNote = VocalRangeFrequencies.findClosestNote(frequency);
    if (closestNote != null) {
      return VocalRangeFrequencies.getNoteWithEnharmonic(frequency);
    }

    // Fallback to standard calculation if not found in vocal ranges
    double a4 = 440.0;
    double c0 = a4 * pow(2, -4.75);
    double h = 12 * (log(frequency / c0) / ln2);
    int octave = (h / 12).floor();
    int noteNumber = (h % 12).round();

    List<String> noteNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];

    if (noteNumber < 0 || noteNumber >= noteNames.length) return "---";

    return noteNames[noteNumber] + octave.toString();
  }

  double _calculateConfidence(double frequency) {
    // More realistic confidence calculation based on vocal range data
    double baseConfidence = 0.4;

    // Check if frequency is within expected vocal ranges
    if (VocalRangeFrequencies.isInVocalRange(frequency)) {
      baseConfidence += 0.3; // Good vocal range
    }

    // Voice type specific confidence
    String voiceType = widget.song.voiceType.toUpperCase();
    bool isInVoiceRange = false;

    switch (voiceType) {
      case 'BARITONE':
        isInVoiceRange = frequency >= 65.41 && frequency <= 440.00; // C2 to A4
        break;
      case 'TENOR MALE':
      case 'TENOR':
        isInVoiceRange = frequency >= 87.31 && frequency <= 523.25; // F2 to C5
        break;
      case 'TENOR FEMALE':
        isInVoiceRange = frequency >= 87.31 && frequency <= 523.25; // F2 to C5
        break;
      case 'ALTO':
        isInVoiceRange = frequency >= 130.81 && frequency <= 698.46; // C3 to F5
        break;
      default:
        isInVoiceRange = frequency >= 80 && frequency <= 800;
    }

    if (isInVoiceRange) {
      baseConfidence += 0.2; // Within expected voice type range
    }

    // Frequency stability (simulated)
    double stabilityFactor = 0.7 + (Random().nextDouble() * 0.3);
    baseConfidence *= stabilityFactor;

    // Amplitude confidence (simulated)
    double amplitudeFactor = 0.6 + (Random().nextDouble() * 0.4);
    baseConfidence *= amplitudeFactor;

    return baseConfidence.clamp(0.0, 1.0);
  }

  double _calculatePitchAccuracy(double detectedFreq, double targetFreq) {
    if (targetFreq == 0 || detectedFreq == 0) return 0.0;

    double ratio = detectedFreq / targetFreq;
    double cents = 1200 * log(ratio) / ln2;

    // Voice type specific tolerance levels based on vocal range characteristics
    String voiceType = widget.song.voiceType.toUpperCase();
    double tolerance;

    switch (voiceType) {
      case 'BARITONE':
        tolerance = 20.0; // Baritones typically have more stable lower range
        break;
      case 'TENOR MALE':
      case 'TENOR':
        tolerance = 18.0; // Tenors have good control in their range
        break;
      case 'TENOR FEMALE':
        tolerance = 16.0; // Female tenors often have precise control
        break;
      case 'ALTO':
        tolerance = 22.0; // Altos have wider natural range
        break;
      default:
        tolerance = 20.0;
    }

    // More precise accuracy calculation based on voice type
    double accuracy;
    if (cents.abs() <= tolerance * 0.6) {
      accuracy = 1.0; // Perfect pitch
    } else if (cents.abs() <= tolerance) {
      accuracy =
          0.95 -
          (cents.abs() - tolerance * 0.6) /
              (tolerance * 0.4) *
              0.15; // 80-95% for excellent
    } else if (cents.abs() <= tolerance * 1.5) {
      accuracy =
          0.8 -
          (cents.abs() - tolerance) /
              (tolerance * 0.5) *
              0.25; // 55-80% for good
    } else if (cents.abs() <= tolerance * 2.5) {
      accuracy =
          0.55 -
          (cents.abs() - tolerance * 1.5) / tolerance * 0.35; // 20-55% for fair
    } else if (cents.abs() <= tolerance * 4.0) {
      accuracy =
          0.2 -
          (cents.abs() - tolerance * 2.5) /
              (tolerance * 1.5) *
              0.15; // 5-20% for poor
    } else {
      accuracy = 0.05; // Very poor
    }

    return accuracy.clamp(0.0, 1.0);
  }

  void _updateRealTimeFeedback() {
    if (currentSegment == null || !mounted) return;

    // More precise feedback based on accuracy levels
    if (isCurrentlyOnPitch && currentAccuracy > 0.9) {
      currentFeedbackColor = Color(0xFF4CAF50);
      currentFeedbackText = currentSegment!.isHighlight
          ? '🌟 Perfect! Key moment!'
          : '✅ Perfect pitch!';
    } else if (isCurrentlyOnPitch && currentAccuracy > 0.75) {
      currentFeedbackColor = Color(0xFF4CAF50);
      currentFeedbackText = currentSegment!.isHighlight
          ? '⭐ Excellent! Key moment!'
          : '🎯 Excellent pitch!';
    } else if (currentAccuracy > 0.6) {
      currentFeedbackColor = Color(0xFFFF9800);
      currentFeedbackText = currentSegment!.isHighlight
          ? '⭐ Good! Important part'
          : '🎯 Good! Minor adjustment needed';
    } else if (currentAccuracy > 0.4) {
      currentFeedbackColor = Color(0xFFFF5722);
      currentFeedbackText = currentSegment!.isHighlight
          ? '🎯 Key moment - adjust pitch'
          : '🔄 Adjust your pitch';
    } else if (currentAccuracy > 0.2) {
      currentFeedbackColor = Color(0xFFF44336);
      currentFeedbackText = currentSegment!.isHighlight
          ? '🔴 Important - listen carefully'
          : '🎵 Listen and match the pitch';
    } else {
      currentFeedbackColor = Color(0xFF9E9E9E);
      currentFeedbackText = currentSegment!.isHighlight
          ? '🔇 Key moment - no pitch detected'
          : '🔇 No pitch detected';
    }
  }

  void _recordPerformanceData() {
    if (currentSegment == null) return;

    // Only record if we have meaningful data with sufficient confidence
    if (currentDetectedFrequency > 50 &&
        currentDetectedFrequency < 1200 &&
        confidenceScore > 0.4 &&
        currentAccuracy > 0.1) {
      // Check if we already have recent data for this segment to avoid duplicates
      bool hasRecentData = performanceHistory.any(
        (p) =>
            p.segment == currentSegment! &&
            DateTime.now().difference(p.timestamp).inMilliseconds < 500,
      );

      if (!hasRecentData) {
        performanceHistory.add(
          PitchPerformanceData(
            accuracy: currentAccuracy,
            wasOnPitch: isCurrentlyOnPitch,
            detectedFrequency: currentDetectedFrequency,
            detectedNote: currentDetectedNote,
            segment: currentSegment!,
            timestamp: DateTime.now(),
            confidenceScore: confidenceScore,
          ),
        );

        if (isCurrentlyOnPitch) {
          totalCorrectSegments++;
        }
      }
    }
  }

  void _startWaveformVisualization() {
    waveformTimer = Timer.periodic(Duration(milliseconds: 80), (timer) {
      if (!isPlaying || !isRecording || !mounted) {
        timer.cancel();
        return;
      }

      final random = Random();

      for (int i = 0; i < waveformData.length; i++) {
        if (currentSegment != null && currentDetectedFrequency > 0) {
          double baseAmplitude = 0.4 + (currentAccuracy * 0.5);
          double frequencyFactor = (currentDetectedFrequency / 220.0).clamp(
            0.5,
            2.0,
          );
          double wave =
              sin(
                DateTime.now().millisecondsSinceEpoch /
                        (200.0 / frequencyFactor) +
                    i * 0.4,
              ) *
              baseAmplitude;
          double noise = (random.nextDouble() - 0.5) * 0.15;
          waveformData[i] = (wave + noise).clamp(-1.0, 1.0);
        } else {
          waveformData[i] = (random.nextDouble() - 0.5) * 0.08;
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _stopPractice() {
    if (mounted) {
      setState(() {
        isPlaying = false;
        isRecording = false;
      });
    }

    // Cancel all timers immediately
    progressTimer?.cancel();
    pitchAnalysisTimer?.cancel();
    waveformTimer?.cancel();

    // Stop animations
    lyricAnimController?.stop();
    accuracyAnimController?.stop();
    pulseController?.stop();

    // Stop audio
    _accompanimentPlayer.stop();
    _recorder.stop();

    // Clean up audio file safely
    _cleanupAudioFile();
  }

  void _cleanupAudioFile() {
    if (audioFilePath != null) {
      try {
        final file = File(audioFilePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Error deleting audio file: $e');
        // Don't crash the app if file deletion fails
      }
      audioFilePath = null;
    }
  }

  void _resetPractice() {
    // Stop any ongoing practice
    _stopPractice();

    // Show reset feedback
    if (mounted) {
      setState(() {
        currentFeedbackText = 'Resetting practice...';
        currentFeedbackColor = Color(0xFF2196F3);
      });
    }

    // Small delay to show the reset message
    Timer(Duration(milliseconds: 500), () {
      if (mounted) {
        // Reset all state variables
        setState(() {
          isPlaying = false;
          isRecording = false;
          showInstructions = true;
          currentTime = 0.0;
          currentSegment = null;
          currentSegmentIndex = -1;
          lastDisplayedSegment = null; // Reset last displayed segment
          currentDetectedFrequency = 0.0;
          currentDetectedNote = '';
          isCurrentlyOnPitch = false;
          currentAccuracy = 0.0;
          confidenceScore = 0.0;
          performanceHistory.clear();
          totalCorrectSegments = 0;
          overallAccuracy = 0.0;
          currentFeedbackColor = Colors.grey;
          currentFeedbackText = 'Ready to sing';
          sessionStartTime = null;
          totalPracticeTime = Duration.zero;
          audioFilePath = null;
        });

        // Reset waveform data
        waveformData = List.filled(40, 0.0);

        // Reset animation controllers
        lyricAnimController?.reset();
        accuracyAnimController?.reset();
        pulseController?.reset();
      }
    });
  }

  void _completePractice() {
    _stopPractice();

    if (!mounted) return; // Prevent widget lifecycle errors

    // Calculate final statistics with improved validation
    if (performanceHistory.isNotEmpty) {
      // Filter out invalid entries with stricter criteria
      var validPerformances = performanceHistory
          .where(
            (p) =>
                p.accuracy > 0.1 &&
                p.detectedFrequency > 50 &&
                p.detectedFrequency < 1200 &&
                p.confidenceScore > 0.3,
          )
          .toList();

      if (validPerformances.isNotEmpty) {
        // Calculate weighted average based on confidence
        double totalWeight = 0.0;
        double weightedSum = 0.0;

        for (var performance in validPerformances) {
          double weight =
              performance.accuracy * (performance.confidenceScore ?? 0.5);
          weightedSum += weight;
          totalWeight += 1.0;
        }

        overallAccuracy = totalWeight > 0 ? weightedSum / totalWeight : 0.0;
      } else {
        overallAccuracy = 0.0;
      }

      // Recalculate correct segments with stricter criteria
      totalCorrectSegments = performanceHistory
          .where((p) => p.wasOnPitch && p.accuracy > 0.6)
          .length;
    } else {
      overallAccuracy = 0.0;
      totalCorrectSegments = 0;
    }

    // Ensure we have meaningful data before showing analysis
    if (mounted) {
      if (performanceHistory.length >= 5) {
        _showKaraokeAnalysis();
      } else {
        _showInsufficientDataDialog();
      }
    }
  }

  void _showInsufficientDataDialog() {
    if (!mounted) return; // Prevent widget lifecycle errors

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Insufficient Data'),
          ],
        ),
        content: Text(
          'Not enough singing data was captured for analysis. '
          'Please try singing more clearly and ensure your microphone is working properly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showKaraokeAnalysis() {
    if (!mounted) return; // Prevent widget lifecycle errors

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KaraokeAnalysisScreen(
          song: widget.song,
          performanceHistory: performanceHistory,
          totalPracticeTime: totalPracticeTime,
          overallAccuracy: overallAccuracy,
          onRestart: () {
            // Pop the analysis screen and go back to song selection
            Navigator.pop(context); // Close analysis screen
            Navigator.pop(context); // Go back to song preview/selection
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Prevent widget lifecycle errors

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
    final voiceColor = PitchDetectionSongDatabase.getVoiceTypeColor(
      widget.song.voiceType,
    );

    return Scaffold(
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
                        '${widget.song.artist} • Real-time Karaoke',
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
                        isRecording
                            ? Icons.fiber_manual_record
                            : Icons.mic_none,
                        color: isRecording
                            ? Color(0xFF4CAF50)
                            : Colors.grey[600],
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isRecording ? 'LIVE' : 'READY',
                        style: TextStyle(
                          color: isRecording
                              ? Color(0xFF4CAF50)
                              : Colors.grey[600],
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
                        '${_formatDuration(widget.song.duration)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: widget.song.duration.inSeconds > 0
                        ? (currentTime / widget.song.duration.inSeconds).clamp(
                            0.0,
                            1.0,
                          )
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentFeedbackColor,
                    ),
                    minHeight: 6,
                  ),
                  // Debug info
                  SizedBox(height: 8),
                  Text(
                    'Debug: Time=${currentTime.toStringAsFixed(1)}s, Segments=${widget.song.lyricSegments.length}, Current=${currentSegment?.text ?? "None"}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],

          // Current lyrics display
          SizedBox(height: 20),
          if (isPlaying && !showInstructions)
            AnimatedBuilder(
              animation: lyricAnimation!,
              builder: (context, child) {
                // Get the appropriate lyric to display
                TimedLyricSegment? displaySegment =
                    currentSegment ?? lastDisplayedSegment;

                // If no current segment (instrumental), keep showing the last lyrics
                // This helps users remember what they just sang and prepare for next part

                return Transform.scale(
                  scale: lyricAnimation!.value,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: displaySegment?.isHighlight == true
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
                        color: displaySegment?.isHighlight == true
                            ? Color(0xFFFFD700).withOpacity(0.5)
                            : currentFeedbackColor.withOpacity(0.3),
                        width: displaySegment?.isHighlight == true ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (displaySegment?.isHighlight == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'KEY MOMENT',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                            ],
                          ),
                        if (displaySegment?.isHighlight == true)
                          SizedBox(height: 8),
                        Text(
                          displaySegment?.text ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: displaySegment?.isHighlight == true
                                ? 28
                                : 24,
                            fontWeight: FontWeight.bold,
                            color: displaySegment?.isHighlight == true
                                ? Color(0xFFFFD700)
                                : currentFeedbackColor,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (displaySegment != null &&
                            currentSegment != null) ...[
                          Text(
                            'Voice Type: ${widget.song.voiceType}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

          // Real-time pitch feedback
          if (isPlaying &&
              currentDetectedNote.isNotEmpty &&
              currentSegment != null)
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
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            'Target',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentSegment != null
                                ? SingingSyllabus.formatTargetNote(
                                    currentSegment!,
                                    currentTime,
                                  )
                                : '---',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            currentSegment != null
                                ? SingingSyllabus.formatTargetFrequency(
                                    currentSegment!,
                                    currentTime,
                                  )
                                : '--- Hz',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                          if (currentSegment != null) ...[
                            SizedBox(height: 2),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: voiceColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.song.voiceType,
                                style: TextStyle(
                                  color: voiceColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Waveform visualization
          if (isPlaying && isRecording && currentSegment != null)
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
                border: Border.all(
                  color: currentFeedbackColor.withOpacity(0.3),
                ),
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
                          colors: [
                            currentFeedbackColor,
                            currentFeedbackColor.withOpacity(0.6),
                          ],
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
                          Icon(Icons.queue_music, color: voiceColor, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Real-time Karaoke',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '• Live lyric display with exact timing\n'
                            '• Real-time pitch detection & feedback\n'
                            '• Key moments highlighted with stars\n'
                            '• Performance scoring & analysis',
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
                      onPressed: isInitialized ? _startKaraokePractice : null,
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Start Karaoke',
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

// Analysis Screen for Karaoke Results
class KaraokeAnalysisScreen extends StatelessWidget {
  final EnhancedSongWithPitchData song;
  final List<PitchPerformanceData> performanceHistory;
  final Duration totalPracticeTime;
  final double overallAccuracy;
  final VoidCallback? onRestart;

  const KaraokeAnalysisScreen({
    Key? key,
    required this.song,
    required this.performanceHistory,
    required this.totalPracticeTime,
    required this.overallAccuracy,
    this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final voiceColor = PitchDetectionSongDatabase.getVoiceTypeColor(
      song.voiceType,
    );

    // Calculate comprehensive statistics
    var highlightPerformances = performanceHistory
        .where((p) => p.segment.isHighlight)
        .toList();
    var regularPerformances = performanceHistory
        .where((p) => !p.segment.isHighlight)
        .toList();

    double highlightAccuracy = highlightPerformances.isNotEmpty
        ? highlightPerformances.map((p) => p.accuracy).reduce((a, b) => a + b) /
              highlightPerformances.length
        : 0.0;

    double regularAccuracy = regularPerformances.isNotEmpty
        ? regularPerformances.map((p) => p.accuracy).reduce((a, b) => a + b) /
              regularPerformances.length
        : 0.0;

    // Calculate additional metrics
    int totalSegments = performanceHistory.length;
    int correctSegments = performanceHistory.where((p) => p.wasOnPitch).length;
    double consistencyScore = totalSegments > 0
        ? correctSegments / totalSegments
        : 0.0;

    // Find best and worst performances
    PitchPerformanceData? bestPerformance = performanceHistory.isNotEmpty
        ? performanceHistory.reduce((a, b) => a.accuracy > b.accuracy ? a : b)
        : null;
    PitchPerformanceData? worstPerformance = performanceHistory.isNotEmpty
        ? performanceHistory.reduce((a, b) => a.accuracy < b.accuracy ? a : b)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Karaoke Analysis'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                        child: Icon(Icons.queue_music, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'by ${song.artist} • ${song.voiceType}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
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
                          overallAccuracy > 0.8
                              ? Color(0xFF4CAF50)
                              : overallAccuracy > 0.6
                              ? Color(0xFFFF9800)
                              : Color(0xFFF44336),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Consistency',
                          '${(consistencyScore * 100).toInt()}%',
                          consistencyScore > 0.8
                              ? Color(0xFF4CAF50)
                              : consistencyScore > 0.6
                              ? Color(0xFFFF9800)
                              : Color(0xFFF44336),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Segments',
                          '$totalSegments',
                          Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
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
                          'Correct',
                          '$correctSegments',
                          Color(0xFF4CAF50),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Voice Type',
                          song.voiceType.split(' ').first,
                          voiceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Performance Breakdown
            Text(
              'Performance Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            Container(
              width: double.infinity,
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
                        'KEY MOMENTS',
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
                    '${highlightPerformances.length} lyrics',
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 11),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Best and Worst Performances
            if (bestPerformance != null && worstPerformance != null) ...[
              Text(
                'Performance Highlights',
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
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF4CAF50).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Color(0xFF4CAF50),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'BEST PERFORMANCE',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            bestPerformance.segment.text,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(bestPerformance.accuracy * 100).toInt()}% accuracy',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
                        color: Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFF44336).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: Color(0xFFF44336),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'NEEDS WORK',
                                style: TextStyle(
                                  color: Color(0xFFF44336),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            worstPerformance.segment.text,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(worstPerformance.accuracy * 100).toInt()}% accuracy',
                            style: TextStyle(
                              color: Color(0xFFF44336),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),
            ],

            // Performance insights
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
                      Icon(Icons.insights, color: Color(0xFF9C27B0)),
                      SizedBox(width: 8),
                      Text(
                        'Karaoke Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInsightsText(
                    highlightAccuracy,
                    regularAccuracy,
                    overallAccuracy,
                    consistencyScore,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: Icon(Icons.refresh, color: voiceColor),
                    label: Text(
                      'Sing Again',
                      style: TextStyle(color: voiceColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: voiceColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildInsightsText(
    double highlightAccuracy,
    double regularAccuracy,
    double overallAccuracy,
    double consistencyScore,
  ) {
    if (overallAccuracy > 0.9) {
      return Text(
        '🌟 Outstanding performance! You\'ve mastered this song!\n'
        '🎯 Your pitch accuracy is exceptional across all sections\n'
        '🚀 Try more challenging songs to continue improving\n'
        '⭐ Consider recording your performance to share',
        style: TextStyle(color: Colors.grey[700], height: 1.4),
      );
    } else if (overallAccuracy > 0.8) {
      return Text(
        '🌟 Excellent work! You\'re very close to perfection!\n'
        '🎯 Focus on the sections that scored slightly lower\n'
        '📈 Your consistency shows great practice habits\n'
        '🎵 Try singing with more emotion and expression',
        style: TextStyle(color: Colors.grey[700], height: 1.4),
      );
    } else if (highlightAccuracy < regularAccuracy) {
      return Text(
        '🌟 Focus more on the starred moments - they\'re the key parts!\n'
        '🎯 Practice the important sections to improve your score\n'
        '📈 Your regular singing is good, now master the highlights\n'
        '🎧 Listen to the original song more to internalize the melody',
        style: TextStyle(color: Colors.grey[700], height: 1.4),
      );
    } else if (highlightAccuracy > 0.8) {
      return Text(
        '🌟 Excellent work on the key moments!\n'
        '🎵 You\'ve mastered the important parts of the song\n'
        '🔄 Work on consistency in regular sections\n'
        '🚀 Try more challenging songs to continue improving',
        style: TextStyle(color: Colors.grey[700], height: 1.4),
      );
    } else if (consistencyScore < 0.5) {
      return Text(
        '🎯 Good progress! Focus on consistency\n'
        '🎧 Listen to the original song more to internalize the melody\n'
        '⭐ Pay special attention to the starred moments\n'
        '🔄 Practice each section multiple times for better accuracy',
        style: TextStyle(color: Colors.grey[700], height: 1.4),
      );
    } else {
      return Text(
        '🎯 Good progress! Focus on both key and regular sections\n'
        '🎧 Listen to the original song more to internalize the melody\n'
        '⭐ Pay special attention to the starred moments\n'
        '🔄 Practice with a metronome to improve timing',
        style: TextStyle(color: Colors.grey[700], height: 1.4),
      );
    }
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
