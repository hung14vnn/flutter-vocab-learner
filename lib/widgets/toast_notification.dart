import 'package:flutter/material.dart';

class ToastNotification {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        position: position,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  // Convenience methods
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      position: position,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      position: position,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      position: position,
    );
  }
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      position: position,
    );
  }
  static void showLoading(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.loading,
      duration: duration,
      position: position,
    );
  }
  static void hide(BuildContext context) {
    final overlay = Overlay.of(context);
    if (overlay.mounted) {
      overlay.dispose();
    }
  }
}

enum ToastType { success, error, info, warning, loading }
enum ToastPosition { top, center, bottom }

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getSlideBegin(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getSlideBegin() {
    switch (widget.position) {
      case ToastPosition.top:
        return const Offset(0, -1);
      case ToastPosition.center:
        return const Offset(0, 0);
      case ToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    double topPosition;
    double? bottomPosition;
    
    switch (widget.position) {
      case ToastPosition.top:
        topPosition = mediaQuery.padding.top + 50;
        bottomPosition = null;
        break;
      case ToastPosition.center:
        topPosition = mediaQuery.size.height / 2 - 30;
        bottomPosition = null;
        break;
      case ToastPosition.bottom:
        topPosition = 0;
        bottomPosition = mediaQuery.padding.bottom + 100;
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: bottomPosition == null ? topPosition : null,
          bottom: bottomPosition,
          left: 20,
          right: 20,
          child: IgnorePointer(
            ignoring: _controller.value == 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
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

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.warning:
        return Colors.orange.shade600;
      case ToastType.info:
        return Colors.grey.shade800;
      case ToastType.loading:
        return Colors.blue.shade600;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
      case ToastType.loading:
        return Icons.hourglass_empty;
    }
  }
}
