// Integration of Baritone frequency data into your vocal range detector

import 'dart:math';

class VocalRangeFrequencies {
  
  // Baritone range frequencies (based on your chart)
  static const List<Map<String, dynamic>> baritoneRange = [
    {'note': 'C2', 'frequency': 65.41, 'midi': 36},
    {'note': 'C#2', 'frequency': 69.30, 'midi': 37}, // Also D♭2
    {'note': 'D2', 'frequency': 73.42, 'midi': 38},
    {'note': 'D#2', 'frequency': 77.78, 'midi': 39}, // Also E♭2
    {'note': 'E2', 'frequency': 82.41, 'midi': 40},
    {'note': 'F2', 'frequency': 87.31, 'midi': 41},
    {'note': 'F#2', 'frequency': 92.50, 'midi': 42}, // Also G♭2
    {'note': 'G2', 'frequency': 98.00, 'midi': 43},
    {'note': 'G#2', 'frequency': 103.83, 'midi': 44}, // Also A♭2
    {'note': 'A2', 'frequency': 110.00, 'midi': 45},
    {'note': 'A#2', 'frequency': 116.54, 'midi': 46}, // Also B♭2
    {'note': 'B2', 'frequency': 123.47, 'midi': 47},
    {'note': 'C3', 'frequency': 130.81, 'midi': 48},
  ];

  // Tenor range frequencies (based on your chart)  
  static const List<Map<String, dynamic>> tenorRange = [
    {'note': 'F2', 'frequency': 87.31, 'midi': 41},
    {'note': 'F#2', 'frequency': 92.50, 'midi': 42}, // Also G♭2
    {'note': 'G2', 'frequency': 98.00, 'midi': 43},
    {'note': 'G#2', 'frequency': 103.83, 'midi': 44}, // Also A♭2
    {'note': 'A2', 'frequency': 110.00, 'midi': 45},
    {'note': 'A#2', 'frequency': 116.54, 'midi': 46}, // Also B♭2
    {'note': 'B2', 'frequency': 123.47, 'midi': 47},
    {'note': 'C3', 'frequency': 130.81, 'midi': 48},
    {'note': 'C#3', 'frequency': 138.59, 'midi': 49}, // Also D♭3
    {'note': 'D3', 'frequency': 146.83, 'midi': 50},
    {'note': 'D#3', 'frequency': 155.56, 'midi': 51}, // Also E♭3
    {'note': 'E3', 'frequency': 164.81, 'midi': 52},
    {'note': 'F3', 'frequency': 174.61, 'midi': 53},
  ];

  // Alto range frequencies (based on your chart)
  static const List<Map<String, dynamic>> altoRange = [
    {'note': 'C3', 'frequency': 130.81, 'midi': 48},
    {'note': 'C#3', 'frequency': 138.59, 'midi': 49}, // Also D♭3
    {'note': 'D3', 'frequency': 146.83, 'midi': 50},
    {'note': 'D#3', 'frequency': 155.56, 'midi': 51}, // Also E♭3
    {'note': 'E3', 'frequency': 164.81, 'midi': 52},
    {'note': 'F3', 'frequency': 174.61, 'midi': 53},
    {'note': 'F#3', 'frequency': 185.00, 'midi': 54}, // Also G♭3
    {'note': 'G3', 'frequency': 196.00, 'midi': 55},
    {'note': 'G#3', 'frequency': 207.65, 'midi': 56}, // Also A♭3
    {'note': 'A3', 'frequency': 220.00, 'midi': 57},
    {'note': 'A#3', 'frequency': 233.08, 'midi': 58}, // Also B♭3
    {'note': 'B3', 'frequency': 246.94, 'midi': 59},
    {'note': 'C4', 'frequency': 261.63, 'midi': 60}, // Middle C
  ];

  // Complete vocal ranges with proper frequency mappings
  static const Map<String, Map<String, dynamic>> vocalRanges = {
    'BASS': {
      'lowest': 41.20,  // E1
      'highest': 349.23, // F4
      'typical_low': 82.41, // E2 
      'typical_high': 261.63, // C4
      'range_notes': ['E1', 'F4'],
    },
    
    'BARITONE': {
      'lowest': 65.41,   // C2 (from your chart)
      'highest': 440.00, // A4
      'typical_low': 98.00,  // G2 (from your chart)  
      'typical_high': 349.23, // F4
      'range_notes': ['C2', 'A4'],
    },
    
    'TENOR': {
      'lowest': 87.31,   // F2 (from your chart)
      'highest': 523.25, // C5 (extended range)
      'typical_low': 130.81, // C3 (from your chart)
      'typical_high': 440.00, // A4
      'range_notes': ['F2', 'C5'],
    },
    
    'ALTO': {
      'lowest': 130.81,  // C3 (from your chart)
      'highest': 698.46, // F5 (extended range)
      'typical_low': 164.81, // E3 (from your chart) 
      'typical_high': 523.25, // C5
      'range_notes': ['C3', 'F5'],
    },
    
    'MEZZO_SOPRANO': {
      'lowest': 146.83,  // D3
      'highest': 783.99, // G5
      'typical_low': 196.00, // G3
      'typical_high': 587.33, // D5
      'range_notes': ['D3', 'G5'],
    },
    
    'SOPRANO': {
      'lowest': 174.61,  // F3
      'highest': 1046.50, // C6
      'typical_low': 261.63, // C4
      'typical_high': 698.46, // F5
      'range_notes': ['F3', 'C6'],
    },
  };

  // Enhanced vocal range classification using your frequency data
  static String classifyVocalRange(double lowestFreq, double highestFreq) {
    
    // More precise classification based on actual detected range
    for (String voiceType in vocalRanges.keys) {
      var range = vocalRanges[voiceType]!;
      
      double rangeLow = range['typical_low'];
      double rangeHigh = range['typical_high'];
      
      // Check if detected frequencies fall within typical range
      // Allow some flexibility (±20%)
      double lowTolerance = rangeLow * 0.8;
      double highTolerance = rangeHigh * 1.2;
      
      if (lowestFreq >= lowTolerance && lowestFreq <= rangeLow * 1.5 &&
          highestFreq >= rangeHigh * 0.7 && highestFreq <= highTolerance) {
        return voiceType;
      }
    }
    
    // Fallback classification based on frequency ranges
    if (lowestFreq <= 100 && highestFreq <= 350) {
      return 'BASS';
    } else if (lowestFreq <= 130 && highestFreq <= 450) {
      return 'BARITONE';  // Using your chart data
    } else if (lowestFreq <= 150 && highestFreq <= 550) {
      return 'TENOR';
    } else if (lowestFreq >= 120 && lowestFreq <= 180 && highestFreq >= 400 && highestFreq <= 700) {
      return 'ALTO';
    } else if (lowestFreq >= 140 && lowestFreq <= 200 && highestFreq >= 500 && highestFreq <= 800) {
      return 'MEZZO_SOPRANO';
    } else if (lowestFreq >= 160 && highestFreq >= 600) {
      return 'SOPRANO';
    }
    
    return 'MIXED_RANGE';
  }

  // Find closest note from baritone, tenor, or alto charts
  static Map<String, dynamic>? findClosestNote(double frequency) {
    double minDiff = double.infinity;
    Map<String, dynamic>? closestNote;
    
    // Check baritone, tenor, and alto ranges
    List<List<Map<String, dynamic>>> allRanges = [baritoneRange, tenorRange, altoRange];
    
    for (var range in allRanges) {
      for (var noteData in range) {
        double diff = (frequency - noteData['frequency']).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestNote = noteData;
        }
      }
    }
    
    // Only return if within reasonable range (±10 Hz tolerance)
    if (minDiff <= 10.0) {
      return closestNote;
    }
    
    return null;
  }

  // Generate realistic alto frequencies for simulation
  static double generateRealisticAltoFreq(bool isLowest) {
    final random = Random();
    
    if (isLowest) {
      // Alto lowest notes: C3 to F3 range (from your chart)
      List<double> lowFreqs = [130.81, 138.59, 146.83, 155.56, 164.81, 174.61];
      return lowFreqs[random.nextInt(lowFreqs.length)];
    } else {
      // Alto highest notes: typically G3 to C5 range  
      List<double> highFreqs = [196.00, 207.65, 220.00, 233.08, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25];
      return highFreqs[random.nextInt(highFreqs.length)];
    }
  }

  // Generate realistic tenor frequencies for simulation
  static double generateRealisticTenorFreq(bool isLowest) {
    final random = Random();
    
    if (isLowest) {
      // Tenor lowest notes: F2 to C3 range (from your chart)
      List<double> lowFreqs = [87.31, 92.50, 98.00, 103.83, 110.00, 116.54, 123.47, 130.81];
      return lowFreqs[random.nextInt(lowFreqs.length)];
    } else {
      // Tenor highest notes: typically C3 to G4/A4 range  
      List<double> highFreqs = [130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 196.00, 220.00, 246.94, 261.63, 293.66, 329.63, 392.00, 440.00];
      return highFreqs[random.nextInt(highFreqs.length)];
    }
  }

  // Generate realistic baritone frequencies for simulation
  static double generateRealisticBaritoneFreq(bool isLowest) {
    final random = Random();
    
    if (isLowest) {
      // Baritone lowest notes: C2 to G2 range
      List<double> lowFreqs = [65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00];
      return lowFreqs[random.nextInt(lowFreqs.length)];
    } else {
      // Baritone highest notes: typically C3 to F4 range  
      List<double> highFreqs = [130.81, 146.83, 164.81, 174.61, 196.00, 220.00, 246.94, 261.63, 293.66, 329.63, 349.23];
      return highFreqs[random.nextInt(highFreqs.length)];
    }
  }

  // Validation function to check if frequency is in male or female voice range
  static bool isInVocalRange(double frequency) {
    return frequency >= 65.41 && frequency <= 698.46; // C2 to F5 (covers baritone, tenor, and alto)
  }

  // Get note info with enharmonic equivalents (like your chart shows A#3/B♭3)
  static String getNoteWithEnharmonic(double frequency) {
    var note = findClosestNote(frequency);
    if (note == null) return 'Unknown';
    
    // Add enharmonic equivalents for display (covering baritone, tenor, and alto)
    Map<String, String> enharmonics = {
      // Baritone range
      'C#2': 'C#2/D♭2',
      'D#2': 'D#2/E♭2', 
      'F#2': 'F#2/G♭2',
      'G#2': 'G#2/A♭2',
      'A#2': 'A#2/B♭2',
      
      // Tenor range  
      'C#3': 'C#3/D♭3',
      'D#3': 'D#3/E♭3',
      
      // Alto range
      'F#3': 'F#3/G♭3',
      'G#3': 'G#3/A♭3',
      'A#3': 'A#3/B♭3',
    };
    
    String noteName = note['note'];
    return enharmonics[noteName] ?? noteName;
  }
}
