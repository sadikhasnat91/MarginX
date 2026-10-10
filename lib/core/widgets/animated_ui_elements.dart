import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Smooth animated rolling counter for numbers and financial amounts.
class AnimatedCounter extends StatelessWidget {
  final num value;
  final String prefix;
  final String suffix;
  final int fractionDigits;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0${fractionDigits > 0 ? '.${'0' * fractionDigits}' : ''}');
    final targetVal = value.toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetVal),
      duration: duration,
      curve: curve,
      builder: (context, val, child) {
        final formatted = formatter.format(val);
        return Text(
          '$prefix$formatted$suffix',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// A card that smoothly elevates and scales slightly on mouse hover (desktop/web)
/// and gives tactile responsive feedback on tap.
class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? hoverBorderColor;
  final Color? borderColor;
  final double borderWidth;
  final double hoverScale;
  final List<BoxShadow>? shadows;

  const HoverableCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.hoverBorderColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.hoverScale = 1.015,
    this.shadows,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final r = widget.borderRadius ?? BorderRadius.circular(16);
    final bg = widget.backgroundColor ?? (isLight ? Colors.white : theme.colorScheme.surface);
    final bColor = _isHovered
        ? (widget.hoverBorderColor ?? theme.colorScheme.primary.withValues(alpha: 0.6))
        : (widget.borderColor ?? (isLight ? const Color(0xFFD8DEE6) : theme.dividerColor));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: r,
            border: Border.all(color: bColor, width: widget.borderWidth),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: isLight
                          ? Colors.black.withOpacity(0.08)
                          : theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : (widget.shadows ??
                    (isLight
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: r,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: r,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16.0),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing status indicator dot (e.g. green pulse for Delivered, amber for Confirmed, red for RTO).
class PulsingStatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const PulsingStatusDot({
    super.key,
    required this.color,
    this.size = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.25, 1.25),
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// A premium pill badge for statuses (Delivered, Shipped, Confirmed, etc.)
class StatusPill extends StatelessWidget {
  final String status;
  final Color? customColor;
  final bool showDot;

  const StatusPill({
    super.key,
    required this.status,
    this.customColor,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color = customColor ?? _getStatusColor(status, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            PulsingStatusDot(color: color, size: 7),
            const SizedBox(width: 6),
          ],
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  static Color _getStatusColor(String status, ThemeData theme) {
    final s = status.toLowerCase();
    if (s.contains('delivered') || s.contains('completed') || s.contains('active')) {
      return const Color(0xFF059669);
    }
    if (s.contains('return') || s.contains('rto') || s.contains('cancelled') || s.contains('failed')) {
      return const Color(0xFFDC2626);
    }
    if (s.contains('shipped') || s.contains('dispatch') || s.contains('processing')) {
      return const Color(0xFF2563EB);
    }
    if (s.contains('confirmed') || s.contains('pending')) {
      return const Color(0xFFD97706);
    }
    return Colors.grey;
  }
}
