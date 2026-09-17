import 'package:shared_preferences/shared_preferences.dart';

class HealthSyncService {
  static final HealthSyncService _instance = HealthSyncService._internal();
  factory HealthSyncService() => _instance;
  HealthSyncService._internal();

  // Check inactivity and trigger nudge
  // In production: uses health package for Apple Health / Google Fit
  Future<void> checkInactivityAndNotify() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getString('last_active_timestamp');

    if (lastActive != null) {
      final last = DateTime.parse(lastActive);
      final diff = DateTime.now().difference(last);

      if (diff.inHours >= 4) {
        await _triggerInactivityNudge();
      }
    }

    await prefs.setString('last_active_timestamp', DateTime.now().toIso8601String());
  }

  Future<void> _triggerInactivityNudge() async {
    // In production: fire local push notification via flutter_local_notifications
    // "You've been sitting for 4 hours. Ready for a 5-minute Reformly core stretch?"
    print('RETENTION PUSH: Time to use your Reformly board!');
  }

  // Called when Apple Health / Google Fit data is available
  Future<void> processHealthData({ required int steps, required double activeEnergy }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_steps', steps);
    await prefs.setDouble('today_active_energy', activeEnergy);

    if (steps < 1000) {
      await _triggerInactivityNudge();
    }
  }
}
