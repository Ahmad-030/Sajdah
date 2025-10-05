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

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  String calculationMethod = 'Hanafi';
  int reminderMinutes = 5;
  bool notificationsEnabled = true;
  String locationText = 'Loading...';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _loadSettings();
    _loadLocation();

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.showImmediateNotification(
      title: '🕌 Azaan Test',
      body: 'This is how prayer notifications will appear with sound',
    );

    if (mounted) {
      _showSnackBar('Test notification sent!', Colors.green);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
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
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ]
                : [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize your prayer experience',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Settings Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notifications Section
                        _buildSectionHeader('Notifications'),
                        const SizedBox(height: 12),

                        _buildModernCard(
                          child: Column(
                            children: [
                              _buildModernToggle(
                                icon: Icons.notifications_active_rounded,
                                title: 'Enable Notifications',
                                subtitle: 'Receive azaan alerts',
                                value: notificationsEnabled,
                                onChanged: (value) async {
                                  setState(() {
                                    notificationsEnabled = value;
                                  });
                                  await _saveSettings();
                                  _showSnackBar(
                                    value ? 'Notifications enabled' : 'Notifications disabled',
                                    value ? Colors.green : Colors.grey,
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildModernDropdown(
                                icon: Icons.alarm_rounded,
                                title: 'Reminder Before Prayer',
                                subtitle: '$reminderMinutes minutes before',
                                value: reminderMinutes,
                                items: [5, 10, 15, 20, 30],
                                onChanged: (value) async {
                                  setState(() {
                                    reminderMinutes = value!;
                                  });
                                  await _saveSettings();
                                },
                              ),
                              _buildDivider(),
                              _buildModernButton(
                                icon: Icons.volume_up_rounded,
                                title: 'Test Notification',
                                subtitle: 'Preview azaan sound',
                                buttonText: 'Test',
                                buttonColor: Colors.green,
                                onPressed: _testNotification,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Prayer Settings
                        _buildSectionHeader('Prayer Calculation'),
                        const SizedBox(height: 12),

                        _buildModernCard(
                          child: Column(
                            children: [
                              _buildModernDropdown(
                                icon: Icons.calculate_rounded,
                                title: 'Calculation Method',
                                subtitle: calculationMethod,
                                value: calculationMethod,
                                items: methods,
                                onChanged: (value) async {
                                  setState(() {
                                    calculationMethod = value as String;
                                  });
                                  await _saveSettings();
                                  await PrayerTimeService.saveCalculationMethod(value as String);
                                  _showSnackBar('Method updated', Colors.blue);
                                },
                                isString: true,
                              ),
                              _buildDivider(),
                              _buildModernButton(
                                icon: Icons.location_on_rounded,
                                title: 'Location',
                                subtitle: locationText,
                                buttonText: 'Refresh',
                                buttonColor: Colors.blue,
                                onPressed: () async {
                                  setState(() {
                                    locationText = 'Updating...';
                                  });
                                  await _loadLocation();
                                  _showSnackBar('Location updated', Colors.blue);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        _buildSectionHeader('About'),
                        const SizedBox(height: 12),

                        _buildModernCard(
                          child: Column(
                            children: [
                              _buildModernTile(
                                icon: Icons.mosque_rounded,
                                title: 'About Sajdah',
                                subtitle: 'v1.0.0 - Modern Edition',
                                trailing: Icons.arrow_forward_ios_rounded,
                                onTap: () => _showAboutDialog(),
                              ),
                              _buildDivider(),
                              _buildModernTile(
                                icon: Icons.privacy_tip_rounded,
                                title: 'Privacy Policy',
                                subtitle: 'Your data is safe',
                                trailing: Icons.arrow_forward_ios_rounded,
                                onTap: () => _showPrivacyDialog(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildModernCard({
    required Widget child,
    LinearGradient? gradient,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    bool isString = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: DropdownButton<T>(
              value: value,
              underline: Container(),
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: items
                  .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(isString ? item.toString() : '$item min'),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(trailing, color: Colors.white.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.mosque_rounded, color: Color(0xFF4CAF50)),
            SizedBox(width: 12),
            Text('About Sajdah', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Sajdah helps you stay connected to your prayers with:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 20),
              Text('✨ Accurate prayer times based on location',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('🔔 Azaan notifications with authentic sound',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('🕌 Jamat times (15 min after Adhan)',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('🧭 Qibla direction compass',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('📐 Multiple calculation methods',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('🌓 Beautiful modern themes',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              SizedBox(height: 20),
              Text(
                'May Allah accept your prayers. 🤲',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4CAF50))),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.privacy_tip_rounded, color: Color(0xFF4CAF50)),
            SizedBox(width: 12),
            Text('Privacy Policy', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Sajdah Prayer Times App',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text('We respect your privacy. This app:',
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 16),
              Text('📍 Uses location only for prayer calculations',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('🔒 Does not collect or store personal data',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('🚫 Does not share data with third parties',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('💾 Stores preferences locally on device',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              Text('✅ Works completely offline after setup',
                  style: TextStyle(color: Colors.white70, height: 1.5)),
              SizedBox(height: 20),
              Text(
                'Location permission is required only for calculating prayer times based on your geographical position.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4CAF50))),
          ),
        ],
      ),
    );
  }
}