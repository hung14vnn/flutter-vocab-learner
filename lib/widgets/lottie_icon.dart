import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieIcon extends StatefulWidget {
  final String animationPath;
  final String? darkAnimationPath;
  final double size;
  final bool isNetwork;
  final VoidCallback? onTap;
  final bool autoPlay;
  final bool repeat;

  const LottieIcon({
    super.key,
    required this.animationPath,
    this.darkAnimationPath,
    this.size = 50.0,
    this.isNetwork = false,
    this.onTap,
    this.autoPlay = true,
    this.repeat = false,
  });

  @override
  State<LottieIcon> createState() => _LottieIconState();
}

class _LottieIconState extends State<LottieIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animationPath = isDark && widget.darkAnimationPath != null
        ? widget.darkAnimationPath!
        : widget.animationPath;

    return GestureDetector(
      onTap: widget.onTap ?? () {
        if (_controller.isCompleted) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.isNetwork
            ? Lottie.network(
                animationPath,
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  if (widget.autoPlay) {
                    if (widget.repeat) {
                      _controller.repeat();
                    } else {
                      _controller.forward();
                    }
                  }
                },
              )
            : Lottie.asset(
                animationPath,
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  if (widget.autoPlay) {
                    if (widget.repeat) {
                      _controller.repeat();
                    } else {
                      _controller.forward();
                    }
                  }
                },
              ),
      ),
    );
  }
}

// Usage example:
class LottieIconUsage extends StatelessWidget {
  const LottieIconUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Network animation (autoplay)
            LottieIcon(
              animationPath: 'https://lottie.host/embed/your-animation-url',
              isNetwork: true,
              size: 100,
              repeat: true,
              autoPlay: true,
            ),

            const SizedBox(height: 20),

            // Local asset (autoplay)
            LottieIcon(
              animationPath: 'assets/animations/heart.json',
              isNetwork: false,
              size: 80,
              autoPlay: true,
            ),
          ],
        ),
      ),
    );
  }
}