import 'package:flutter/material.dart';
import '../Services/Notification_Service.dart';
import '../Services/PrayerTime_Service.dart';

// Add this to your Settings screen or create a separate test screen
class NotificationTesterWidget extends StatefulWidget {
  const NotificationTesterWidget({Key? key}) : super(key: key);

  @override
  State<NotificationTesterWidget> createState() => _NotificationTesterWidgetState();
}

class _NotificationTesterWidgetState extends State<NotificationTesterWidget> {
  String testResult = 'Tap a button to test';
  bool isLoading = false;

  Future<void> _testImmediateNotification() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing immediate notification...';
    });

    try {
      await NotificationService.showImmediateNotification(
        title: '🕌 Azaan Test',
        body: 'This is how prayer notifications will appear with azan sound',
      );

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        testResult = '✅ SUCCESS: Check if you heard the azan sound!';
        isLoading = false;
      });

      _showSnackBar('Test notification sent! Did you hear the azan?', Colors.green);
    } catch (e) {
      setState(() {
        testResult = '❌ ERROR: ${e.toString()}';
        isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _testScheduledNotification() async {
    setState(() {
      isLoading = true;
      testResult = 'Scheduling test notification in 10 seconds...';
    });

    try {
      final testTime = DateTime.now().add(const Duration(seconds: 10));

      await NotificationService.schedulePrayerNotification(
        id: 999,
        prayerName: 'Test',
        prayerTime: testTime,
      );

      setState(() {
        testResult = '✅ Scheduled for: ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}:${testTime.second.toString().padLeft(2, '0')}\n\nWait 10 seconds for notification with azan sound...';
        isLoading = false;
      });

      _showSnackBar('Notification scheduled! Wait 10 seconds...', Colors.orange);
    } catch (e) {
      setState(() {
        testResult = '❌ ERROR: ${e.toString()}';
        isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _checkAlarmStates() async {
    setState(() {
      isLoading = true;
      testResult = 'Checking alarm states...';
    });

    try {
      final alarms = await PrayerTimeService.loadAllAlarmStates();

      String result = '📋 Alarm States:\n\n';
      alarms.forEach((prayer, enabled) {
        result += '${enabled ? "✅" : "❌"} $prayer: ${enabled ? "ENABLED" : "DISABLED"}\n';
      });

      setState(() {
        testResult = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResult = '❌ ERROR: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _checkSoundFile() async {
    setState(() {
      isLoading = true;
      testResult = 'Checking azan sound configuration...';
    });

    await Future.delayed(const Duration(seconds: 1));

    String result = '🔊 Sound File Check:\n\n';
    result += '✅ Sound configured in code: "azan"\n';
    result += '📁 Expected location:\n';
    result += '   android/app/src/main/res/raw/azan.mp3\n\n';
    result += 'To verify file exists:\n';
    result += '1. Check the file is present\n';
    result += '2. File must be named "azan.mp3" (lowercase)\n';
    result += '3. Must be valid audio file\n\n';
    result += 'Tap "Test Now" to verify sound plays';

    setState(() {
      testResult = result;
      isLoading = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bug_report, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Notification Tester',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Test Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: isLoading ? null : _testImmediateNotification,
                icon: const Icon(Icons.volume_up),
                label: const Text('Test Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _testScheduledNotification,
                icon: const Icon(Icons.schedule),
                label: const Text('Test in 10s'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _checkAlarmStates,
                icon: const Icon(Icons.alarm),
                label: const Text('Check Alarms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _checkSoundFile,
                icon: const Icon(Icons.audio_file),
                label: const Text('Check Sound'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Result Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              testResult,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Quick Tips:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Ensure phone is not in silent mode\n'
                      '• Volume should be UP\n'
                      '• Disable "Do Not Disturb"\n'
                      '• Grant all notification permissions\n'
                      '• For Android 12+: Allow "Alarms & reminders"',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

// Usage: Add this to your Settings screen build method
// Just insert: NotificationTesterWidget(),