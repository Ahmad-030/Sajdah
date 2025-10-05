import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../Services/Location_Service.dart';
import '../Services/PrayerTime_Service.dart';
import '../Services/Notification_Service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String calculationMethod = 'Hanafi';
  int reminderMinutes = 5;
  bool notificationsEnabled = true;
  String locationText = 'Loading...';

  final List<String> methods = [
    'Hanafi',
    'ISNA',
    'Umm al-Qura',
    'Muslim World League',
    'Egyptian',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadLocation();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      calculationMethod = prefs.getString('calculation_method') ?? 'Hanafi';
      reminderMinutes = prefs.getInt('reminder_minutes') ?? 5;
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', calculationMethod);
    await prefs.setInt('reminder_minutes', reminderMinutes);
    await prefs.setBool('notifications_enabled', notificationsEnabled);
  }

  Future<void> _loadLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      setState(() {
        locationText = '${location['city']}, ${location['country']}';
      });
    } catch (e) {
      setState(() {
        locationText = 'Location unavailable';
      });
      print('Error loading location: $e');
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.showImmediateNotification(
      title: '🕌 Azaan Test',
      body: 'This is how prayer notifications will appear with sound',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.volume_up, color: Colors.white),
              SizedBox(width: 10),
              Text('Test notification sent!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openNotificationTester() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationTesterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1B5E20),
              const Color(0xFF0D4D3D),
              const Color(0xFF0A1F1C),
            ]
                : [
              const Color(0xFF2E7D32),
              const Color(0xFF00897B),
              const Color(0xFF42A5F5)
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Customize your prayer experience',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Tester Card
                      _buildSectionTitle('Testing & Debug', Icons.bug_report),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: Icons.science,
                              title: 'Notification Tester',
                              subtitle: 'Test azan sound & alarms',
                              trailing: ElevatedButton.icon(
                                onPressed: _openNotificationTester,
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Open'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Notifications Section
                      _buildSectionTitle('Notifications', Icons.notifications_active),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: Icons.notifications_active,
                              title: 'Enable Notifications',
                              subtitle: 'Receive azaan alerts',
                              trailing: Switch(
                                value: notificationsEnabled,
                                onChanged: (value) async {
                                  setState(() {
                                    notificationsEnabled = value;
                                  });
                                  await _saveSettings();
                                  _showSnackBar(
                                    value ? '🔔 Notifications enabled' : '🔕 Notifications disabled',
                                  );
                                },
                                activeColor: Colors.green,
                              ),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.alarm,
                              title: 'Reminder Before Prayer',
                              subtitle: '$reminderMinutes minutes before azaan',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: reminderMinutes,
                                  underline: Container(),
                                  dropdownColor: Colors.grey[800],
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  items: [5, 10, 15, 20, 30]
                                      .map((min) => DropdownMenuItem(
                                    value: min,
                                    child: Text('$min min'),
                                  ))
                                      .toList(),
                                  onChanged: (value) async {
                                    setState(() {
                                      reminderMinutes = value!;
                                    });
                                    await _saveSettings();
                                  },
                                ),
                              ),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.volume_up,
                              title: 'Test Notification',
                              subtitle: 'Preview azaan sound',
                              trailing: ElevatedButton.icon(
                                onPressed: _testNotification,
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Test'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Prayer Calculation Section
                      _buildSectionTitle('Prayer Calculation', Icons.calculate),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: Icons.calculate,
                              title: 'Calculation Method',
                              subtitle: calculationMethod,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: calculationMethod,
                                  underline: Container(),
                                  dropdownColor: Colors.grey[800],
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  items: methods
                                      .map((method) => DropdownMenuItem(
                                    value: method,
                                    child: Text(method),
                                  ))
                                      .toList(),
                                  onChanged: (value) async {
                                    setState(() {
                                      calculationMethod = value!;
                                    });
                                    await _saveSettings();
                                    await PrayerTimeService.saveCalculationMethod(value!);
                                    _showSnackBar('📐 Method: $value');
                                  },
                                ),
                              ),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.location_on,
                              title: 'Location',
                              subtitle: locationText,
                              trailing: IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: () async {
                                  setState(() {
                                    locationText = 'Updating...';
                                  });
                                  await _loadLocation();
                                  _showSnackBar('📍 Location updated');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // About Section
                      _buildSectionTitle('About', Icons.info_outline),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: Icons.mosque,
                              title: 'About Sajdah',
                              subtitle: 'Prayer times & Qibla direction',
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                              onTap: () => _showAboutDialog(),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.info_outline,
                              title: 'App Version',
                              subtitle: '1.0.0 - Modern UI Edition',
                              trailing: const SizedBox.shrink(),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Your data is safe',
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                              onTap: () => _showPrivacyDialog(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.mosque, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('About Sajdah'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sajdah helps you stay connected to your prayers with:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              _buildFeature('✨', 'Accurate prayer times based on your location'),
              _buildFeature('🔔', 'Azaan notifications with authentic sound'),
              _buildFeature('🧭', 'Qibla direction compass'),
              _buildFeature('📐', 'Multiple calculation methods'),
              _buildFeature('🌓', 'Beautiful dark & light themes'),
              _buildFeature('📱', 'Home screen widget support'),
              const SizedBox(height: 15),
              Text(
                'May Allah accept your prayers. 🤲',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Privacy Policy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sajdah Prayer Times App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              const Text('We respect your privacy. This app:'),
              const SizedBox(height: 10),
              _buildPrivacyPoint('📍', 'Uses location only for accurate prayer time calculations'),
              _buildPrivacyPoint('🔒', 'Does not collect or store personal data'),
              _buildPrivacyPoint('🚫', 'Does not share data with third parties'),
              _buildPrivacyPoint('💾', 'Stores preferences locally on your device'),
              _buildPrivacyPoint('✅', 'Works completely offline after initial setup'),
              const SizedBox(height: 15),
              Text(
                'Location permission is required only for calculating prayer times based on your geographical position.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

// Notification Tester Screen
class NotificationTesterScreen extends StatefulWidget {
  const NotificationTesterScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTesterScreen> createState() => _NotificationTesterScreenState();
}

class _NotificationTesterScreenState extends State<NotificationTesterScreen> {
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
        testResult = '✅ SUCCESS: Check if you heard the azan sound!\n\n'
            'If you heard the sound: Perfect! ✓\n'
            'If no sound: Check troubleshooting below';
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
        testResult = '✅ Scheduled for: ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}:${testTime.second.toString().padLeft(2, '0')}\n\n'
            'Wait 10 seconds for notification with azan sound...\n\n'
            'Keep app open or minimized.\n'
            'Notification will appear in 10 seconds.';
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

      result += '\n💡 Tip: Toggle alarms in Home screen';

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
    result += '📋 Verification steps:\n';
    result += '1. File must exist at above location\n';
    result += '2. File name: "azan.mp3" (lowercase)\n';
    result += '3. Must be valid MP3 audio file\n';
    result += '4. Recommended: 128kbps, 30-60s\n\n';
    result += '🧪 Tap "Test Now" to verify sound plays';

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

// Find the NotificationTesterScreen class in your Setting_screen.dart
// Replace the entire _NotificationTesterScreenState build method with this:

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Tester'),
        backgroundColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1B5E20),
              const Color(0xFF0D4D3D),
              const Color(0xFF0A1F1C),
            ]
                : [
              const Color(0xFF2E7D32),
              const Color(0xFF00897B),
              const Color(0xFF42A5F5)
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
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
                      children: const [
                        Icon(Icons.bug_report, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Notification Tester',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Test azan sound & alarm notifications',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Test Buttons
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 50) / 2,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _testImmediateNotification,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Test Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 50) / 2,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _testScheduledNotification,
                        icon: const Icon(Icons.schedule),
                        label: const Text('Test in 10s'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width - 50) / 2,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _checkAlarmStates,
                          icon: const Icon(Icons.alarm),
                          label: const Text('Check Alarms'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Result Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
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

                // Success Indicators ONLY
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Success Indicators:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '✅ "Test Now" plays azan immediately\n'
                            '✅ "Test in 10s" shows notification after 10s\n'
                            '✅ Alarm states show enabled/disabled correctly\n'
                            '✅ Sound file check shows correct path\n'
                            '✅ No errors in result display',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}