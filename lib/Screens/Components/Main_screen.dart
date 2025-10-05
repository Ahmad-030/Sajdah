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

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: GlassyNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _animationController.forward(from: 0);
        },
        selectedColor: const Color(0xFF4CAF50),
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