import 'package:flutter/material.dart';
import 'package:vocab_learner/consts/app_consts.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';

class ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isPinned;
  final VoidCallback? onPin;
  final VoidCallback? onUnpin;
  final bool showPinButton;
  final bool isEmpty;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isPinned = false,
    this.onPin,
    this.onUnpin,
    this.showPinButton = false,
    this.isEmpty = false,
  });

  const ActionCard.empty({super.key, required this.onTap})
    : title = 'Add Action',
      subtitle = 'Tap to pin an action to the home screen',
      icon = Icons.add,
      color = Colors.grey,
      isPinned = false,
      onPin = null,
      onUnpin = null,
      showPinButton = false,
      isEmpty = true;

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _showPinButton = false;
  bool _isLongPressed = false;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.455;

    return SizedBox(
      width: cardWidth,
      child: AnimatedScale(
        scale: _isLongPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Card(
          color: widget.isEmpty
              ? Colors.grey.withValues(alpha: 0.1)
              : widget.color.withValues(alpha: 0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: widget.isEmpty
                  ? Colors.grey.withValues(alpha: 0.3)
                  : widget.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.isEmpty
                      ? Colors.grey.withValues(alpha: 0.05)
                      : widget.color.withValues(alpha: 0.05),
                  widget.isEmpty
                      ? Colors.grey.withValues(alpha: 0.15)
                      : widget.color.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: InkWell(
              onTap: () {
                if (widget.isEmpty) {
                  widget.onTap!();
                } else {
                  ToastNotification.showInfo(
                    context,
                    message: 'Action not implemented yet',
                  );
                }
              },
              onLongPress: widget.showPinButton && !widget.isEmpty
                  ? () {
                      setState(() {
                        _showPinButton = !_showPinButton;
                      });
                    }
                  : null,
              onTapDown: (_) {
                if (widget.showPinButton && !widget.isEmpty) {
                  setState(() {
                    _isLongPressed = true;
                  });
                }
              },
              onTapUp: (_) {
                if (widget.showPinButton && !widget.isEmpty) {
                  setState(() {
                    _isLongPressed = false;
                  });
                }
              },
              onTapCancel: () {
                if (widget.showPinButton && !widget.isEmpty) {
                  setState(() {
                    _isLongPressed = false;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: widget.isEmpty
                              ? Colors.grey[300]
                              : widget.color,
                          radius: 24,
                          child: Icon(
                            widget.icon,
                            color: widget.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: widget.isEmpty ? Colors.grey[600] : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: widget.isEmpty
                                ? Colors.grey[500]
                                : modernGrey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (_showPinButton && widget.showPinButton && !widget.isEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.isPinned && widget.onUnpin != null) {
                            widget.onUnpin!();
                            ToastNotification.showInfo(
                              context,
                              message: 'Unpinned ${widget.title}',
                            );
                          } else if (!widget.isPinned && widget.onPin != null) {
                            widget.onPin!();
                            ToastNotification.showInfo(
                              context,
                              message: 'Pinned ${widget.title}',
                            );
                          }
                          setState(() {
                            _showPinButton = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            size: 16,
                            color: widget.isPinned
                                ? widget.color
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
