import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<Widget>? children;

  const BookCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: elevation ?? 4,
        shadowColor: colorScheme.shadow.withOpacity(0.15),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.cardColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            // Add a subtle paper texture effect
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with leading, title, and trailing
                  Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.crimsonText(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: GoogleFonts.crimsonText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 16),
                        trailing!,
                      ],
                    ],
                  ),
                  
                  // Additional content
                  if (children != null && children!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...children!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookPageWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const BookPageWidget({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        // Add a subtle paper gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.95),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book-style header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.crimsonText(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),
                  // Decorative book corner
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isOutlined;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const BookButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isOutlined = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isPrimary ? colorScheme.primary : colorScheme.secondary,
          side: BorderSide(
            color: (isPrimary ? colorScheme.primary : colorScheme.secondary).withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      );
    }
    
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      );
    }
    
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}
