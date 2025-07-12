// lib/utils/pitch_detection_utils.dart
import 'dart:math';
import 'dart:typed_data';

class PitchDetectionUtils {
  
  // Professional pitch detection using autocorrelation method
  static double detectPitchFromAudio(Uint8List audioData, int sampleRate) {
    // Convert bytes to audio samples
    List<double> samples = _bytesToSamples(audioData);
    
    if (samples.length < 1024) return 0.0; // Need minimum samples
    
    // Apply windowing to reduce spectral leakage
    List<double> windowedSamples = _applyHannWindow(samples);
    
    // Use autocorrelation for pitch detection
    double pitch = _autocorrelationPitchDetection(windowedSamples, sampleRate);
    
    // Validate pitch is in vocal range
    if (pitch < 50 || pitch > 1200) return 0.0;
    
    return pitch;
  }
  
  // Convert audio bytes to normalized samples
  static List<double> _bytesToSamples(Uint8List bytes) {
    List<double> samples = [];
    
    // Assuming 16-bit PCM audio
    for (int i = 0; i < bytes.length - 1; i += 2) {
      int sample = (bytes[i + 1] << 8) | bytes[i];
      if (sample > 32767) sample -= 65536; // Convert to signed
      samples.add(sample / 32768.0); // Normalize to [-1, 1]
    }
    
    return samples;
  }
  
  // Apply Hann window to reduce spectral leakage
  static List<double> _applyHannWindow(List<double> samples) {
    List<double> windowed = [];
    int length = samples.length;
    
    for (int i = 0; i < length; i++) {
      double window = 0.5 * (1 - cos(2 * pi * i / (length - 1)));
      windowed.add(samples[i] * window);
    }
    
    return windowed;
  }
  
  // Autocorrelation-based pitch detection
  static double _autocorrelationPitchDetection(List<double> samples, int sampleRate) {
    int length = samples.length;
    List<double> autocorr = List.filled(length ~/ 2, 0.0);
    
    // Calculate autocorrelation
    for (int lag = 0; lag < length ~/ 2; lag++) {
      double sum = 0.0;
      for (int i = 0; i < length - lag; i++) {
        sum += samples[i] * samples[i + lag];
      }
      autocorr[lag] = sum;
    }
    
    // Find the first peak after the initial peak
    double maxVal = autocorr[0];
    int bestLag = 0;
    
    // Skip the first few samples to avoid finding the DC component
    for (int lag = sampleRate ~/ 1200; lag < sampleRate ~/ 50; lag++) {
      if (autocorr[lag] > maxVal * 0.3 && autocorr[lag] > autocorr[lag - 1] && 
          autocorr[lag] > autocorr[lag + 1]) {
        maxVal = autocorr[lag];
        bestLag = lag;
        break;
      }
    }
    
    if (bestLag == 0) return 0.0;
    
    // Parabolic interpolation for more precise frequency
    double betterLag = _parabolicInterpolation(autocorr, bestLag);
    
    return sampleRate / betterLag;
  }
  
  // Parabolic interpolation for sub-sample precision
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
  
  // Calculate pitch accuracy as percentage
  static double calculatePitchAccuracy(double detectedFreq, double targetFreq) {
    if (targetFreq == 0 || detectedFreq == 0) return 0.0;
    
    double ratio = detectedFreq / targetFreq;
    double cents = 1200 * log(ratio) / ln2; // Convert to cents
    
    // Perfect pitch is 0 cents, ±50 cents is acceptable
    double accuracy = max(0.0, 1.0 - (cents.abs() / 50.0));
    return accuracy.clamp(0.0, 1.0);
  }
  
  // Check if two frequencies are in the same octave
  static bool isSameNote(double freq1, double freq2) {
    if (freq1 == 0 || freq2 == 0) return false;
    
    double ratio = freq1 / freq2;
    
    // Check if the ratio is a power of 2 (same note, different octave)
    double logRatio = log(ratio) / ln2;
    double remainder = logRatio - logRatio.round();
    
    return remainder.abs() < 0.1; // Within 10% of an octave
  }
  
  // Convert frequency to musical note name
  static String frequencyToNoteName(double frequency) {
    if (frequency <= 0) return "---";
    
    // A4 = 440 Hz is our reference
    double a4 = 440.0;
    double c0 = a4 * pow(2, -4.75); // C0 frequency
    
    double h = 12 * (log(frequency / c0) / ln2);
    int octave = (h / 12).floor();
    int noteNumber = (h % 12).round();
    
    List<String> noteNames = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
    ];
    
    if (noteNumber < 0 || noteNumber >= noteNames.length) return "---";
    
    return noteNames[noteNumber] + octave.toString();
  }
  
  // Calculate vibrato rate and depth
  static Map<String, double> analyzeVibrato(List<double> pitchHistory) {
    if (pitchHistory.length < 20) {
      return {'rate': 0.0, 'depth': 0.0};
    }
    
    // Simple vibrato detection using zero crossings
    List<double> detrended = _removeTrend(pitchHistory);
    int crossings = 0;
    double totalDepth = 0.0;
    
    for (int i = 1; i < detrended.length; i++) {
      if ((detrended[i - 1] >= 0 && detrended[i] < 0) ||
          (detrended[i - 1] < 0 && detrended[i] >= 0)) {
        crossings++;
      }
      totalDepth += detrended[i].abs();
    }
    
    double rate = crossings / 2.0; // Hz (assuming 1 second of data)
    double depth = totalDepth / detrended.length;
    
    return {'rate': rate, 'depth': depth};
  }
  
  // Remove linear trend from data
  static List<double> _removeTrend(List<double> data) {
    int n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += data[i];
      sumXY += i * data[i];
      sumX2 += i * i;
    }
    
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;
    
    List<double> detrended = [];
    for (int i = 0; i < n; i++) {
      detrended.add(data[i] - (slope * i + intercept));
    }
    
    return detrended;
  }
  
  // Generate reference tone for a given frequency
  static List<double> generateReferenceTone(double frequency, double duration, int sampleRate) {
    int numSamples = (duration * sampleRate).round();
    List<double> samples = [];
    
    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sample = 0.5 * sin(2 * pi * frequency * t);
      
      // Apply fade in/out to avoid clicks
      if (i < sampleRate * 0.1) {
        sample *= i / (sampleRate * 0.1);
      } else if (i > numSamples - sampleRate * 0.1) {
        sample *= (numSamples - i) / (sampleRate * 0.1);
      }
      
      samples.add(sample);
    }
    
    return samples;
  }
  
  // Calculate signal-to-noise ratio
  static double calculateSNR(List<double> signal) {
    if (signal.isEmpty) return 0.0;
    
    double mean = signal.reduce((a, b) => a + b) / signal.length;
    double signalPower = signal.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / signal.length;
    
    // Estimate noise as high-frequency components
    List<double> highFreq = [];
    for (int i = 1; i < signal.length; i++) {
      highFreq.add(signal[i] - signal[i - 1]);
    }
    
    double noisePower = highFreq.map((x) => x * x).reduce((a, b) => a + b) / highFreq.length;
    
    if (noisePower == 0) return double.infinity;
    
    return 10 * log(signalPower / noisePower) / ln10; // SNR in dB
  }
  
  // Real-time pitch smoothing using median filter
  static double smoothPitch(List<double> recentPitches) {
    if (recentPitches.isEmpty) return 0.0;
    if (recentPitches.length == 1) return recentPitches[0];
    
    List<double> sorted = List.from(recentPitches)..sort();
    int middle = sorted.length ~/ 2;
    
    if (sorted.length % 2 == 0) {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    } else {
      return sorted[middle];
    }
  }
}

// Additional vocal coaching utilities
class VocalCoachingUtils {
  
  // Determine vocal effort level
  static String getEffortLevel(double energy) {
    if (energy < 0.2) return 'Too quiet - sing louder';
    if (energy < 0.4) return 'Good volume';
    if (energy < 0.7) return 'Strong voice';
    if (energy < 0.9) return 'Very strong - be careful';
    return 'Too loud - protect your voice';
  }
  
  // Suggest breathing technique based on performance
  static String getBreathingTip(double accuracy, double energy) {
    if (energy < 0.3) {
      return 'Take a deeper breath for better support';
    }
    if (accuracy < 0.6) {
      return 'Focus on steady airflow for better pitch control';
    }
    if (accuracy > 0.9) {
      return 'Excellent breath control!';
    }
    return 'Maintain steady breathing';
  }
  
  // Generate practice recommendation
  static String getPracticeRecommendation(List<double> accuracyHistory) {
    if (accuracyHistory.isEmpty) return 'Keep practicing!';
    
    double avgAccuracy = accuracyHistory.reduce((a, b) => a + b) / accuracyHistory.length;
    
    if (avgAccuracy < 0.5) {
      return 'Focus on pitch matching exercises';
    } else if (avgAccuracy < 0.7) {
      return 'Good progress! Try slower songs';
    } else if (avgAccuracy < 0.9) {
      return 'Great work! Challenge yourself with faster songs';
    } else {
      return 'Excellent! You\'re ready for advanced techniques';
    }
  }
  
  // Calculate improvement over time
  static double calculateImprovement(List<double> earlyScores, List<double> recentScores) {
    if (earlyScores.isEmpty || recentScores.isEmpty) return 0.0;
    
    double earlyAvg = earlyScores.reduce((a, b) => a + b) / earlyScores.length;
    double recentAvg = recentScores.reduce((a, b) => a + b) / recentScores.length;
    
    return ((recentAvg - earlyAvg) / earlyAvg) * 100; // Percentage improvement
  }
  
  // Vocal health check
  static Map<String, dynamic> checkVocalHealth(Duration practiceTime, double avgEnergy) {
    bool needsRest = false;
    String warning = '';
    
    if (practiceTime.inMinutes > 30) {
      needsRest = true;
      warning = 'Consider taking a break - you\'ve been practicing for ${practiceTime.inMinutes} minutes';
    }
    
    if (avgEnergy > 0.8) {
      needsRest = true;
      warning = 'You\'re singing quite loudly - give your voice a rest';
    }
    
    return {
      'needsRest': needsRest,
      'warning': warning,
      'recommendation': needsRest ? 'Drink water and rest your voice' : 'Keep up the good work!'
    };
  }
}