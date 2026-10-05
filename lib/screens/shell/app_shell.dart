import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonora/services/update_service/update_service.dart';

import 'package:sonora/core/widgets/liquid_glass.dart';

import 'widgets/bottom_player.dart';
import 'widgets/desktop_sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('AppShell'));

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateService.autoCheck(context);
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDesktop = Platform.isWindows || width >= 900;

    if (!isDesktop) {
      return _buildCompact(context);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: GlassBackdrop()),
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DesktopSidebar(
                  currentIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 14, 88),
                    child: LiquidGlass(
                      borderRadius: BorderRadius.circular(28),
                      blur: 18,
                      surfaceOpacity: 0.28,
                      child: widget.navigationShell,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          widget.navigationShell,
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.music_house_fill),
            icon: Icon(CupertinoIcons.music_house),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.search),
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.library_music),
            icon: Icon(Icons.library_music_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.settings_solid),
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
