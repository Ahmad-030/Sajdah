import 'package:flutter/material.dart';
import '../../Widgets/Glass Nav.dart';

import '../Home_screen.dart';
import '../Qibla_screen.dart';
import '../Setting_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      const QiblaScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: GlassyNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary,
        unselectedColor: Colors.grey.withOpacity(0.6),
        items: const [
          GlassyNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          GlassyNavItem(
            icon: Icons.explore_rounded,
            label: 'Qibla',
          ),
          GlassyNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}