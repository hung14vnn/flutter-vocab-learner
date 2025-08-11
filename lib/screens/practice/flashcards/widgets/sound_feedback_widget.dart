import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SoundFeedbackWidget {
  // Private constructor to prevent instantiation
  SoundFeedbackWidget._();

  /// Play a success sound for correct answers
  static Future<void> playCorrectSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      // Provide haptic feedback for correct answers
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error playing correct sound: $e');
    }
  }

  /// Play an error sound for incorrect answers
  static Future<void> playIncorrectSound() async {
    try {
      // Use alert sound for incorrect answers
      await SystemSound.play(SystemSoundType.alert);
      // Provide stronger haptic feedback for errors
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error playing incorrect sound: $e');
    }
  }

  /// Play a flip sound when cards are flipped
  static Future<void> playFlipSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error playing flip sound: $e');
    }
  }

  /// Play a completion sound when game is finished
  static Future<void> playCompletionSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      // Provide success haptic feedback
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing completion sound: $e');
    }
  }

  /// Show a visual feedback overlay for correct/incorrect answers
  static void showVisualFeedback(BuildContext context, bool isCorrect) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _FeedbackOverlay(isCorrect: isCorrect),
    );

    overlay.insert(overlayEntry);

    // Remove overlay after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }
}

class _FeedbackOverlay extends StatefulWidget {
  final bool isCorrect;

  const _FeedbackOverlay({required this.isCorrect});

  @override
  State<_FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<_FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: widget.isCorrect 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 60,
                      color: widget.isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
