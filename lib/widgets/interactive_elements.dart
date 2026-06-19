import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class MagneticHoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const MagneticHoverButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<MagneticHoverButton> createState() => _MagneticHoverButtonState();
}

class _MagneticHoverButtonState extends State<MagneticHoverButton> {
  double _x = 0.0;
  double _y = 0.0;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _x = 0.0;
        _y = 0.0;
      }),
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          final centerX = size.width / 2;
          final centerY = size.height / 2;
          
          final localX = event.localPosition.dx;
          final localY = event.localPosition.dy;
          
          setState(() {
            // Apply a slight delay factor or standard magnetic factor
            _x = (localX - centerX) * 0.15;
            _y = (localY - centerY) * 0.15;
          });
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isHovered ? 50 : 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_x, _y, 0.0)
            ..multiply(Matrix4.diagonal3Values(_isHovered ? 1.05 : 1.0, _isHovered ? 1.05 : 1.0, 1.0)),
          child: widget.child,
        ),
      ),
    );
  }
}

class BouncingBadge extends StatefulWidget {
  final String text;
  const BouncingBadge({super.key, required this.text});

  @override
  State<BouncingBadge> createState() => _BouncingBadgeState();
}

class _BouncingBadgeState extends State<BouncingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, -0.25),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: AppTheme.tertiary, // Sunset Gold
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(color: Colors.white, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.tertiary.withOpacity(0.4),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class PulsingSparkle extends StatefulWidget {
  final Color color;
  const PulsingSparkle({super.key, required this.color});

  @override
  State<PulsingSparkle> createState() => _PulsingSparkleState();
}

class _PulsingSparkleState extends State<PulsingSparkle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.6, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Icon(
          Icons.auto_awesome,
          color: widget.color,
          size: 18.0,
        ),
      ),
    );
  }
}
