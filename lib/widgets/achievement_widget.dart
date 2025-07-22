import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AchievementType {
  common,
  rare,
  epic,
  legendary,
}

class AchievementWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;
  final String? imageUrl;
  final String? lottieAsset;
  final Duration animationDuration;
  final AchievementType type;
  final int? points;
  final bool enableSound;
  final bool enableHaptic;

  const AchievementWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onDismiss,
    this.imageUrl,
    this.lottieAsset,
    this.animationDuration = const Duration(milliseconds: 3000),
    this.type = AchievementType.common,
    this.points,
    this.enableSound = true,
    this.enableHaptic = true,
  });

  @override
  State<AchievementWidget> createState() => _AchievementWidgetState();
}

class _AchievementWidgetState extends State<AchievementWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _playEffects();
  }

  void _initializeAnimations() {
    // Main animation controller
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Particle effect controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse effect controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Scale animation with more dynamic curve
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Slide animation from top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Rotation animation for icon
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Fade out animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for background
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Shimmer effect for legendary achievements
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          widget.onDismiss?.call();
        }
      });
    });

    // Start particle effects for rare+ achievements
    if (widget.type != AchievementType.common) {
      _particleController.repeat(reverse: true);
    }

    // Start pulse for epic+ achievements
    if (widget.type == AchievementType.epic || widget.type == AchievementType.legendary) {
      _pulseController.repeat(reverse: true);
    }
  }

  Future<void> _playEffects() async {
    // Haptic feedback
    if (widget.enableHaptic) {
      switch (widget.type) {
        case AchievementType.common:
          HapticFeedback.lightImpact();
          break;
        case AchievementType.rare:
          HapticFeedback.mediumImpact();
          break;
        case AchievementType.epic:
        case AchievementType.legendary:
          HapticFeedback.heavyImpact();
          break;
      }
    }

    // Sound effects
    if (widget.enableSound && !_soundPlayed) {
      _soundPlayed = true;
      try {
        String soundFile = 'sounds/achievement_${widget.type.name}.mp3';
        await _audioPlayer.play(AssetSource(soundFile));
      } catch (e) {
        // Fallback to default sound or no sound
        debugPrint('Achievement sound not found: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.type) {
      case AchievementType.common:
        return Colors.grey.shade300;
      case AchievementType.rare:
        return Colors.blue.shade300;
      case AchievementType.epic:
        return Colors.purple.shade300;
      case AchievementType.legendary:
        return Colors.amber.shade300;
    }
  }

  List<Color> get _gradientColors {
    switch (widget.type) {
      case AchievementType.common:
        return [widget.color.withAlpha(200), widget.color.withAlpha(240)];
      case AchievementType.rare:
        return [
          widget.color.withAlpha(180),
          widget.color.withAlpha(220),
          Colors.blue.withAlpha(100),
        ];
      case AchievementType.epic:
        return [
          widget.color.withAlpha(160),
          widget.color.withAlpha(200),
          Colors.purple.withAlpha(120),
          Colors.pink.withAlpha(100),
        ];
      case AchievementType.legendary:
        return [
          widget.color.withAlpha(140),
          Colors.amber.withAlpha(180),
          Colors.orange.withAlpha(160),
          Colors.red.withAlpha(120),
        ];
    }
  }

  Widget _buildIcon() {
    Widget iconWidget;

    if (widget.lottieAsset != null) {
      // For now, fallback to icon since we removed Lottie dependency
      iconWidget = Icon(widget.icon, color: Colors.white, size: 28);
    } else if (widget.imageUrl != null) {
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          widget.imageUrl!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(widget.icon, color: Colors.white, size: 28);
          },
        ),
      );
    } else {
      iconWidget = Icon(widget.icon, color: Colors.white, size: 28);
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 0.5,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor.withAlpha(100), width: 1),
              boxShadow: [
                BoxShadow(
                  color: _borderColor.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: iconWidget,
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    if (widget.type != AchievementType.legendary) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                  end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withAlpha(50),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleEffects() {
    if (widget.type == AchievementType.common) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: ParticleEffectPainter(
              animation: _particleController,
              type: widget.type,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          left: 16,
          right: 16,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _controller.value < 0.85 ? 1.0 : _opacityAnimation.value,
                child: Stack(
                  children: [
                    // Particle effects background
                    _buildParticleEffects(),
                    
                    // Main achievement container
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: widget.type == AchievementType.epic || 
                                 widget.type == AchievementType.legendary 
                                 ? _pulseAnimation.value : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _gradientColors,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _borderColor,
                                width: widget.type == AchievementType.legendary ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withAlpha(100),
                                  blurRadius: widget.type == AchievementType.legendary ? 20 : 12,
                                  spreadRadius: widget.type == AchievementType.legendary ? 4 : 2,
                                ),
                                const BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icon with enhanced styling
                                _buildIcon(),
                                const SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.title,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: _getTitleSize(),
                                                shadows: const [
                                                  Shadow(
                                                    color: Colors.black45,
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                          if (widget.points != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withAlpha(40),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withAlpha(80),
                                                ),
                                              ),
                                              child: Text(
                                                '+${widget.points}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.description,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(230),
                                          fontSize: 14,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black45,
                                              blurRadius: 1,
                                            ),
                                          ],
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      if (widget.type != AchievementType.common) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              _getTypeIcon(),
                                              color: Colors.white.withAlpha(200),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getTypeLabel(),
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(200),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // Close button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      _controller.stop();
                                      widget.onDismiss?.call();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Shimmer effect for legendary
                    _buildShimmerEffect(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getTitleSize() {
    switch (widget.type) {
      case AchievementType.common:
        return 16;
      case AchievementType.rare:
        return 17;
      case AchievementType.epic:
        return 18;
      case AchievementType.legendary:
        return 19;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case AchievementType.common:
        return Icons.star_border;
      case AchievementType.rare:
        return Icons.star_half;
      case AchievementType.epic:
        return Icons.star;
      case AchievementType.legendary:
        return Icons.auto_awesome;
    }
  }

  String _getTypeLabel() {
    switch (widget.type) {
      case AchievementType.common:
        return 'Common';
      case AchievementType.rare:
        return 'Rare';
      case AchievementType.epic:
        return 'Epic';
      case AchievementType.legendary:
        return 'Legendary';
    }
  }
}

// Custom painter for particle effects
class ParticleEffectPainter extends CustomPainter {
  final AnimationController animation;
  final AchievementType type;

  ParticleEffectPainter({
    required this.animation,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (type == AchievementType.common) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;

    final particleCount = _getParticleCount();
    final colors = _getParticleColors();

    for (int i = 0; i < particleCount; i++) {
      final progress = (animation.value + i / particleCount) % 1.0;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      
      paint.color = colors[i % colors.length].withAlpha((opacity * 100).round());

      final x = size.width * 0.1 + (size.width * 0.8) * (i / particleCount);
      final y = size.height * 0.2 + 
                (size.height * 0.6) * progress * 
                (1 + 0.3 * (i % 3 - 1));

      final radius = _getParticleSize() * (1.0 - progress * 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  int _getParticleCount() {
    switch (type) {
      case AchievementType.rare:
        return 8;
      case AchievementType.epic:
        return 12;
      case AchievementType.legendary:
        return 16;
      case AchievementType.common:
        return 0;
    }
  }

  List<Color> _getParticleColors() {
    switch (type) {
      case AchievementType.rare:
        return [Colors.blue, Colors.cyan];
      case AchievementType.epic:
        return [Colors.purple, Colors.pink, Colors.indigo];
      case AchievementType.legendary:
        return [Colors.amber.shade400, Colors.amber, Colors.orange, Colors.yellow];
      case AchievementType.common:
        return [];
    }
  }

  double _getParticleSize() {
    switch (type) {
      case AchievementType.rare:
        return 2.0;
      case AchievementType.epic:
        return 2.5;
      case AchievementType.legendary:
        return 3.0;
      case AchievementType.common:
        return 0.0;
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) {
    return animation != oldDelegate.animation || type != oldDelegate.type;
  }
}

class AchievementSystem {
  static final Set<String> _shownAchievements = <String>{};
  static const Map<String, AchievementData> _achievementData = {
    'perfect_start': AchievementData(
      title: 'Perfect Start!',
      description: 'Got your first 3 answers correct!',
      icon: Icons.rocket_launch,
      color: Colors.purple,
      type: AchievementType.rare,
      points: 50,
    ),
    'halfway_hero': AchievementData(
      title: 'Halfway Hero!',
      description: 'Great progress with high accuracy!',
      icon: Icons.trending_up,
      color: Colors.orange,
      type: AchievementType.rare,
      points: 75,
    ),
    'perfectionist': AchievementData(
      title: 'Perfectionist!',
      description: 'Perfect accuracy achieved!',
      icon: Icons.star,
      color: Colors.amber,
      type: AchievementType.epic,
      points: 100,
    ),
    'excellence': AchievementData(
      title: 'Excellence!',
      description: '90%+ accuracy achieved!',
      icon: Icons.military_tech,
      color: Colors.green,
      type: AchievementType.rare,
      points: 75,
    ),
    'hot_streak': AchievementData(
      title: 'Hot Streak!',
      description: '5+ correct answers in a row!',
      icon: Icons.local_fire_department,
      color: Colors.red,
      type: AchievementType.epic,
      points: 120,
    ),
    'speed_demon': AchievementData(
      title: 'Speed Demon!',
      description: 'Answered 10 questions in under 30 seconds!',
      icon: Icons.flash_on,
      color: Colors.yellow,
      type: AchievementType.epic,
      points: 150,
    ),
    'scholar': AchievementData(
      title: 'Scholar!',
      description: 'Completed 100 vocabulary sessions!',
      icon: Icons.school,
      color: Colors.indigo,
      type: AchievementType.legendary,
      points: 500,
    ),
    'vocabulary_master': AchievementData(
      title: 'Vocabulary Master!',
      description: 'Learned 1000+ new words!',
      icon: Icons.auto_awesome,
      color: Colors.purple,
      type: AchievementType.legendary,
      points: 1000,
    ),
  };

  static void showAchievement(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    AchievementType type = AchievementType.common,
    int? points,
    String? lottieAsset,
    bool enableSound = true,
    bool enableHaptic = true,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AchievementWidget(
        title: title,
        description: description,
        icon: icon,
        color: color,
        type: type,
        points: points,
        lottieAsset: lottieAsset,
        enableSound: enableSound,
        enableHaptic: enableHaptic,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void showAchievementById(
    BuildContext context,
    String achievementId, {
    bool enableSound = true,
    bool enableHaptic = true,
  }) {
    final data = _achievementData[achievementId];
    if (data == null) return;

    if (_shownAchievements.contains(achievementId)) return;
    _shownAchievements.add(achievementId);

    showAchievement(
      context,
      title: data.title,
      description: data.description,
      icon: data.icon,
      color: data.color,
      type: data.type,
      points: data.points,
      enableSound: enableSound,
      enableHaptic: enableHaptic,
    );
  }

  static void checkAndShowAchievements(
    BuildContext context, {
    required int correctAnswers,
    required int totalAnswers,
    required int currentIndex,
    required int totalWords,
    Duration? averageTime,
    int? totalSessions,
    int? totalWordsLearned,
  }) {
    final accuracy = totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;

    // Perfect start achievement
    if (currentIndex == 2 && accuracy == 1.0) {
      showAchievementById(context, 'perfect_start');
    }

    // Halfway achievement
    if (currentIndex == (totalWords / 2).floor() && accuracy >= 0.8) {
      showAchievementById(context, 'halfway_hero');
    }

    // Accuracy achievements
    if (totalAnswers >= 5) {
      if (accuracy == 1.0) {
        showAchievementById(context, 'perfectionist');
      } else if (accuracy >= 0.9) {
        showAchievementById(context, 'excellence');
      }
    }

    // Streak achievements
    if (correctAnswers >= 5 && accuracy == 1.0) {
      showAchievementById(context, 'hot_streak');
    }

    // Speed achievements
    if (averageTime != null && 
        totalAnswers >= 10 && 
        averageTime.inSeconds < 3) {
      showAchievementById(context, 'speed_demon');
    }

    // Long-term achievements
    if (totalSessions != null && totalSessions >= 100) {
      showAchievementById(context, 'scholar');
    }

    if (totalWordsLearned != null && totalWordsLearned >= 1000) {
      showAchievementById(context, 'vocabulary_master');
    }
  }

  static void resetShownAchievements() {
    _shownAchievements.clear();
  }

  static List<AchievementData> getAllAchievements() {
    return _achievementData.values.toList();
  }

  static AchievementData? getAchievementById(String id) {
    return _achievementData[id];
  }
}

// Achievement data model
class AchievementData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int points;

  const AchievementData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.points,
  });
}
