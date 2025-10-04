import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int reminderMinutes = 10;
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
      reminderMinutes = prefs.getInt('reminder_minutes') ?? 10;
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
      body: 'This is how prayer notifications will appear',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Test notification sent!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                      const Color(0xFF1B5E20),
                      const Color(0xFF004D40),
                    ]
                        : [
                      const Color(0xFF2E7D32),
                      const Color(0xFF00897B),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications Section
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.notifications_active,
                    title: 'Enable Notifications',
                    subtitle: 'Receive prayer time notifications',
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (value) async {
                        setState(() {
                          notificationsEnabled = value;
                        });
                        await _saveSettings();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  value
                                      ? '🔔 Notifications enabled'
                                      : '🔕 Notifications disabled'
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.alarm,
                    title: 'Reminder Before Prayer',
                    subtitle: '$reminderMinutes minutes before',
                    trailing: DropdownButton<int>(
                      value: reminderMinutes,
                      underline: Container(),
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
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.volume_up,
                    title: 'Test Notification',
                    subtitle: 'Preview notification sound',
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: _testNotification,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Calculation Method Section
                  _buildSectionTitle('Prayer Calculation'),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.calculate,
                    title: 'Calculation Method',
                    subtitle: calculationMethod,
                    trailing: DropdownButton<String>(
                      value: calculationMethod,
                      underline: Container(),
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

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📐 Calculation method changed to $value'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Refresh',
                                onPressed: () {
                                  // Trigger refresh in home screen
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    subtitle: locationText,
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        setState(() {
                          locationText = 'Updating...';
                        });
                        await _loadLocation();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('📍 Location updated'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // About Section
                  _buildSectionTitle('About'),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    trailing: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.mosque,
                    title: 'About Sajdah',
                    subtitle: 'Prayer times & Qibla direction',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('About Sajdah'),
                          content: const Text(
                            'Sajdah helps you stay connected to your prayers with:\n\n'
                                '• Accurate prayer times\n'
                                '• Azaan notifications\n'
                                '• Qibla direction compass\n'
                                '• Multiple calculation methods\n\n'
                                'May Allah accept your prayers. 🤲',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Privacy Policy'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'Sajdah Prayer Times App\n\n'
                                  'We respect your privacy. This app:\n\n'
                                  '• Uses location only for prayer times\n'
                                  '• Does not collect personal data\n'
                                  '• Does not share data with third parties\n'
                                  '• Stores preferences locally on your device\n\n'
                                  'Location permission is required only for accurate prayer time calculations.',
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
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.rate_review_outlined,
                    title: 'Rate Us',
                    subtitle: 'Help us improve',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⭐ Thank you for your support!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
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
}