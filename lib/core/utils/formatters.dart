class Formatters {
  Formatters._();

  /// 82955 -> '83k', 1200000 -> '1.2M', 340 -> '340'.
  static String compactCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}k';
    }
    return count.toString();
  }

  /// 178995 -> '49h 43m'.
  static String durationFromSeconds(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours <= 0) {
      return '${minutes}m';
    }
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  /// A stable, deterministic 3.6-4.9 "popularity" proxy derived from a
  /// download/reference count, for sources (Gutendex) that expose no rating.
  static double popularityRating(int referenceCount) {
    if (referenceCount <= 0) return 3.6;
    final scaled = 3.6 + (referenceCount.toDouble().clamp(0, 200000) / 200000) * 1.3;
    return double.parse(scaled.clamp(3.6, 4.9).toStringAsFixed(1));
  }
}
