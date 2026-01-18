class BpmClassifier {
  static const int _bradycardiaThreshold = 110;
  static const int _tachycardiaThreshold = 160;

  /// Classifies the average BPM based on gestational age.
  ///
  /// Returns:
  /// - 'Possible Bradycardia (Consult Doctor)' if BPM < 110
  /// - 'Possible Tachycardia (Consult Doctor)' if BPM > 160
  /// - 'Normal Range' otherwise
  /// - 'Unclassified' if data is empty or gestational age < 20 weeks (rule from backend)
  static String classify(List<int> bpmData, int gestationalAgeWeeks) {
    if (bpmData.isEmpty) {
      return 'Unclassified';
    }

    // Backend rule: Classification applies for gestational age >= 20 weeks
    // Python: if gestational_age >= 20: ...
    if (gestationalAgeWeeks < 20) {
      // Note: We might want to show the value anyway, but strictly following backend rules:
      return 'Unclassified (Age < 20w)';
    }

    final double averageBpm = bpmData.reduce((a, b) => a + b) / bpmData.length;

    if (averageBpm < _bradycardiaThreshold) {
      return 'Possible Bradycardia (Consult Doctor)';
    } else if (averageBpm > _tachycardiaThreshold) {
      return 'Possible Tachycardia (Consult Doctor)';
    } else {
      return 'Normal Range';
    }
  }

  /// Simple classification for purely BPM based feedback without age context
  static String classifySimple(double averageBpm) {
    if (averageBpm < _bradycardiaThreshold) {
      return 'Possible Bradycardia (Consult Doctor)';
    } else if (averageBpm > _tachycardiaThreshold) {
      return 'Possible Tachycardia (Consult Doctor)';
    } else {
      return 'Normal Range';
    }
  }
}
