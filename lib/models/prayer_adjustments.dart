/// A model class to hold prayer time adjustments in minutes
class CustomPrayerAdjustments {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const CustomPrayerAdjustments({
    this.fajr = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });
  
  /// Convenience method to get adjustment for a specific prayer
  int getForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'dhuhr':
      case 'thuhr':
      case 'zuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return 0;
    }
  }
} 