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
            children: [
              Icon(Icons.volume_up, color: Colors.white),
              SizedBox(width: 10),
              Text('Test notification sent!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                ? [Color(0xFF1B5E20), Color(0xFF004D40), Color(0xFF263238)]
                : [Color(0xFF2E7D32), Color(0xFF00897B), Color(0xFF42A5F5)],
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
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
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
                      // Notifications Section
                      _buildSectionTitle('Notifications', Icons.notifications_active),
                      SizedBox(height: 15),
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
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: reminderMinutes,
                                  underline: Container(),
                                  dropdownColor: Colors.grey[800],
                                  style: TextStyle(color: Colors.white, fontSize: 14),
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
                                icon: Icon(Icons.play_arrow, size: 16),
                                label: Text('Test'),
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

                      SizedBox(height: 30),

                      // Prayer Calculation Section
                      _buildSectionTitle('Prayer Calculation', Icons.calculate),
                      SizedBox(height: 15),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: Icons.calculate,
                              title: 'Calculation Method',
                              subtitle: calculationMethod,
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: calculationMethod,
                                  underline: Container(),
                                  dropdownColor: Colors.grey[800],
                                  style: TextStyle(color: Colors.white, fontSize: 13),
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
                                icon: Icon(Icons.refresh, color: Colors.white),
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

                      SizedBox(height: 30),

                      // About Section
                      _buildSectionTitle('About', Icons.info_outline),
                      SizedBox(height: 15),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: Icons.mosque,
                              title: 'About Sajdah',
                              subtitle: 'Prayer times & Qibla direction',
                              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                              onTap: () => _showAboutDialog(),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.info_outline,
                              title: 'App Version',
                              subtitle: '1.0.0 - Modern UI Edition',
                              trailing: SizedBox.shrink(),
                            ),
                            Divider(color: Colors.white24, height: 1),
                            _buildSettingTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Your data is safe',
                              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                              onTap: () => _showPrivacyDialog(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 80), // Space for bottom nav
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
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
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
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
        duration: Duration(seconds: 2),
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
            SizedBox(width: 10),
            Text('About Sajdah'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sajdah helps you stay connected to your prayers with:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 15),
              _buildFeature('✨', 'Accurate prayer times based on your location'),
              _buildFeature('🔔', 'Azaan notifications with authentic sound'),
              _buildFeature('🧭', 'Qibla direction compass'),
              _buildFeature('📐', 'Multiple calculation methods'),
              _buildFeature('🌓', 'Beautiful dark & light themes'),
              _buildFeature('📱', 'Home screen widget support'),
              SizedBox(height: 15),
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
            child: Text('Close'),
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
            SizedBox(width: 10),
            Text('Privacy Policy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sajdah Prayer Times App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 15),
              Text('We respect your privacy. This app:'),
              SizedBox(height: 10),
              _buildPrivacyPoint('📍', 'Uses location only for accurate prayer time calculations'),
              _buildPrivacyPoint('🔒', 'Does not collect or store personal data'),
              _buildPrivacyPoint('🚫', 'Does not share data with third parties'),
              _buildPrivacyPoint('💾', 'Stores preferences locally on your device'),
              _buildPrivacyPoint('✅', 'Works completely offline after initial setup'),
              SizedBox(height: 15),
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
            child: Text('Close'),
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
          Text(emoji, style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.4),
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
          Text(icon, style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}