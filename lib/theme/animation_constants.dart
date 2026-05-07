import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// 🎬 Animation Constants & Utilities
/// Các hằng số animation để sử dụng trong toàn app

class AnimationConstants {
  // ==================== DURATIONS ====================
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // ==================== CURVES ====================
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveSpring = Curves.elasticOut;

  // ==================== SCALES ====================
  /// Button press scale
  static const double scalePress = 0.95;
  /// Subtle scale
  static const double scaleSubtle = 0.98;
  /// Large scale for animations
  static const double scaleLarge = 1.1;

  // ==================== OPACITY ====================
  static const double opacityHigh = 1.0;
  static const double opacityMedium = 0.7;
  static const double opacityLow = 0.4;
  static const double opacityVeryLow = 0.1;

  // ==================== BLUR RADII ====================
  static const double blurSmall = 8.0;
  static const double blurMedium = 12.0;
  static const double blurLarge = 16.0;
  static const double blurExtraLarge = 24.0;

  // ==================== OFFSET ====================
  static const Offset offsetSmall = Offset(0, 2);
  static const Offset offsetMedium = Offset(0, 4);
  static const Offset offsetLarge = Offset(0, 8);
}

/// 🎯 Reusable Animation Builders
class AnimationHelpers {
  /// Create a simple fade-in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    return _FadeInAnimation(
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// Create a slide-up animation
  static Widget slideInUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
  }) {
    return _SlideInUpAnimation(
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// Create a bounce-in animation
  static Widget bounceIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return _BounceInAnimation(
      duration: duration,
      child: child,
    );
  }

  /// Create a scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    return _ScaleInAnimation(
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

// ==================== FADE IN ANIMATION ====================
class _FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _FadeInAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<_FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

// ==================== SLIDE IN UP ANIMATION ====================
class _SlideInUpAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _SlideInUpAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SlideInUpAnimation> createState() => _SlideInUpAnimationState();
}

class _SlideInUpAnimationState extends State<_SlideInUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

// ==================== BOUNCE IN ANIMATION ====================
class _BounceInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _BounceInAnimation({
    required this.child,
    required this.duration,
  });

  @override
  State<_BounceInAnimation> createState() => _BounceInAnimationState();
}

class _BounceInAnimationState extends State<_BounceInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

// ==================== SCALE IN ANIMATION ====================
class _ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _ScaleInAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<_ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// 🎨 Animated Scaffold with background gradient
class AnimatedMagicScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final bool withGradient;

  const AnimatedMagicScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.withGradient = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: withGradient
          ? BoxDecoration(
              gradient: MagicSkyColors.backgroundGradient,
            )
          : null,
      child: Scaffold(
        backgroundColor: withGradient ? Colors.transparent : null,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

// Re-export MagicSkyColors for convenience