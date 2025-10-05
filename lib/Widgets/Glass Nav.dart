import 'package:flutter/material.dart';
import 'dart:ui';

class GlassyNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final List<GlassyNavItem> items;

  const GlassyNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.items,
  }) : super(key: key);

  @override
  State<GlassyNavigationBar> createState() => _GlassyNavigationBarState();
}

class _GlassyNavigationBarState extends State<GlassyNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.5),
                ]
                    : [
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.5),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    widget.items.length,
                        (index) => _buildNavItem(
                      context,
                      widget.items[index],
                      index == widget.currentIndex,
                          () {
                        widget.onTap(index);
                        _animationController.forward(from: 0);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      GlassyNavItem item,
      bool isSelected,
      VoidCallback onTap,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [
                widget.selectedColor.withOpacity(0.3),
                widget.selectedColor.withOpacity(0.2),
              ],
            )
                : null,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(
              color: widget.selectedColor.withOpacity(0.5),
              width: 1.5,
            )
                : null,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: widget.selectedColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 10 : 8),
                decoration: isSelected
                    ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.selectedColor,
                      widget.selectedColor.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.selectedColor.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
                    : null,
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected
                      ? widget.selectedColor
                      : isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                  fontSize: isSelected ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassyNavItem {
  final IconData icon;
  final String label;

  const GlassyNavItem({
    required this.icon,
    required this.label,
  });
}