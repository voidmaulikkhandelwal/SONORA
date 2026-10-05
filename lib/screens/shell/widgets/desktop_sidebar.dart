import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonora/core/widgets/liquid_glass.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LiquidGlass(
      width: 224,
      margin: const EdgeInsets.fromLTRB(14, 14, 8, 92),
      borderRadius: BorderRadius.circular(28),
      blur: 24,
      surfaceOpacity: 0.40,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 14),
            child: Row(
              children: [
                Hero(
                  tag: 'sonora-logo',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'icons/sonora_nobg.png',
                      height: 42,
                      width: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SONORA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Liquid glass music',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Search',
                  onPressed: () => context.go('/search'),
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: scheme.outline.withValues(alpha: 0.10),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onDestinationSelected(0),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  selected: currentIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
                _NavItem(
                  icon: Icons.library_music_rounded,
                  label: 'Library',
                  selected: currentIndex == 2,
                  onTap: () => onDestinationSelected(2),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  selected: currentIndex == 3,
                  onTap: () => onDestinationSelected(3),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: LiquidGlass(
              padding: const EdgeInsets.all(13),
              borderRadius: BorderRadius.circular(20),
              blur: 12,
              surfaceOpacity: 0.20,
              shadow: false,
              child: Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 18,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your collection',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Favorites · History · Downloads',
                          maxLines: 2,
                          style: TextStyle(fontSize: 10.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    final background = selected
        ? scheme.primary
        : _hovered
            ? scheme.onSurface.withValues(alpha: 0.06)
            : Colors.transparent;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              child: Row(
                children: [
                  Icon(widget.icon, size: 20, color: foreground),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
