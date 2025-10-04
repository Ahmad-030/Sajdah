import 'dart:ui';

import 'package:flutter/material.dart';

import '../Services/Location_Service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String calculationMethod = 'Hanafi';
  int reminderMinutes = 10;
  bool notificationsEnabled = true;
  String locationText = 'Khurarianwala, Punjab';

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
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      setState(() {
        locationText = '${location['city']}, ${location['country']}';
      });
    } catch (e) {
      print('Error loading location: $e');
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
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
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
                      onChanged: (value) {
                        setState(() {
                          reminderMinutes = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    icon: Icons.volume_up,
                    title: 'Test Azaan Sound',
                    subtitle: 'Preview notification sound',
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🕌 Playing Azaan sound...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
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
                      onChanged: (value) {
                        setState(() {
                          calculationMethod = value!;
                        });
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
                      onPressed: () {
                        _loadLocation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📍 Updating location...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
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
                            'Sajdah helps you stay connected to your prayers with accurate prayer times, Azaan notifications, and Qibla direction.\n\nMay Allah accept your prayers.',
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
                    onTap: () {},
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
