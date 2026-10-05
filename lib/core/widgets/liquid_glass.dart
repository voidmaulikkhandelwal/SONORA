import 'dart:ui';

import 'package:flutter/material.dart';

/// SONORA liquid glass surface.
///
/// Mirrors the structure of the reference mobile "liquidGlass" modifier:
///   1. backdrop blur (reference default 8dp, player surfaces use 4x)
///   2. translucent surface tint (reference default opacity 0.4)
///   3. specular highlight rim + soft drop shadow
///
/// Everything is drawn with core Flutter painting (no shaders), so it renders
/// identically on every Windows GPU.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 8,
    this.surfaceOpacity = 0.4,
    this.tint,
    this.padding,
    this.width,
    this.height,
    this.margin,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Gaussian blur sigma applied to whatever sits behind the glass.
  final double blur;

  /// Opacity of the tint layer, 0..1.
  final double surfaceOpacity;

  /// Surface tint. Defaults to a neutral white (dark theme) / white (light).
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = tint ?? (isDark ? const Color(0xFF1B1B1F) : Colors.white);
    final sigma = blur <= 0 ? 0.01 : blur;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                  blurRadius: 28,
                  spreadRadius: -10,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              color: base.withValues(alpha: surfaceOpacity.clamp(0.0, 1.0)),
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.16 : 0.45),
                  Colors.white.withValues(alpha: isDark ? 0.03 : 0.08),
                  Colors.white.withValues(alpha: isDark ? 0.07 : 0.20),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.24 : 0.60),
                width: 1,
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft ambient glow used behind glass panels so the blur has something to
/// refract (the mobile app gets this from album artwork and content).
class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, this.accent});

  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = accent ?? scheme.primary;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? Colors.black : const Color(0xFFF2F2F5),
          ),
        ),
        Positioned(
          left: -180,
          top: -160,
          child: _Orb(color: glow.withValues(alpha: isDark ? 0.20 : 0.16), size: 560),
        ),
        Positioned(
          right: -200,
          bottom: -220,
          child: _Orb(color: glow.withValues(alpha: isDark ? 0.14 : 0.12), size: 640),
        ),
        Positioned(
          right: 160,
          top: 80,
          child: _Orb(color: glow.withValues(alpha: isDark ? 0.08 : 0.08), size: 360),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
