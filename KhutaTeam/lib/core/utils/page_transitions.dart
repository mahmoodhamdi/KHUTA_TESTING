import 'package:flutter/material.dart';

/// Custom page route with fade transition.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Custom page route with slide transition from right.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Custom page route with slide up transition (for modals).
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Custom page route with scale and fade transition.
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleFadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutCubic;

            var fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            var scaleAnimation = Tween(begin: 0.95, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: animation.drive(scaleAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Extension to simplify navigation with custom transitions.
extension NavigatorExtensions on NavigatorState {
  /// Push with fade transition.
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return push(FadePageRoute<T>(page: page));
  }

  /// Push with slide transition.
  Future<T?> pushSlide<T extends Object?>(Widget page) {
    return push(SlidePageRoute<T>(page: page));
  }

  /// Push with slide up transition (modal style).
  Future<T?> pushSlideUp<T extends Object?>(Widget page) {
    return push(SlideUpPageRoute<T>(page: page));
  }

  /// Push with scale and fade transition.
  Future<T?> pushScaleFade<T extends Object?>(Widget page) {
    return push(ScaleFadePageRoute<T>(page: page));
  }
}
