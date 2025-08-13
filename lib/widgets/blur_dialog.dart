import 'package:flutter/material.dart';
import 'dart:ui';

class BlurDialog extends StatelessWidget {
  final Widget child;
  final double blurStrength;

  const BlurDialog({
    super.key,
    required this.child,
    this.blurStrength = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }
}

/// Helper function to show a dialog with blur background
Future<T?> showBlurDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,

  double blurStrength = 5.0,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.3),
    builder: (context) => BlurDialog(
      blurStrength: blurStrength,
      child: builder(context),
    ),
  );
}

/// Custom page route with blur background
class BlurDialogRoute<T> extends PageRoute<T> {
  final Widget child;
  final double blurStrength;

  BlurDialogRoute({
    required this.child,
    this.blurStrength = 5.0,
    super.settings,
  });

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.3);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: animation.value * blurStrength,
          sigmaY: animation.value * blurStrength,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }
}
