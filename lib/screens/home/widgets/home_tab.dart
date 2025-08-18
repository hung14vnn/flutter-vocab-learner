import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocab_learner/consts/shortcut_consts.dart';
import 'package:vocab_learner/providers/auth_provider.dart';
import 'package:vocab_learner/providers/progress_provider.dart';
import 'package:vocab_learner/consts/app_consts.dart';
import 'package:vocab_learner/screens/home/widgets/progress_dialog.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';
import 'package:vocab_learner/widgets/book_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _showActionSelectionDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final user = authProvider.appUser;
    final unpinnedActions = kShortcuts
        .where(
          (shortcut) =>
              !(user?.pinnedQuickActions?.contains(shortcut.name) ?? false),
        )
        .toList();

    if (unpinnedActions.isEmpty) {
      ToastNotification.showInfo(
        context,
        message: 'All actions are already pinned',
      );
      return;
    }

    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Action to Pin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unpinnedActions.length,
            itemBuilder: (context, index) {
              final shortcut = unpinnedActions[index];
              return ListTile(
                leading: Icon(shortcut.icon),
                title: Text(shortcut.name),
                subtitle: Text(shortcut.description),
                onTap: () async {
                  final success = await authProvider.pinQuickAction(
                    shortcut.name,
                  );
                  if (context.mounted) {
                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      ToastNotification.showError(
                        context,
                        message: 'Cannot pin more than 2 actions',
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Widget> getPinnedActionCards(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final user = authProvider.appUser;
    final pinnedActions = user?.pinnedQuickActions ?? <String>[];
    
    return pinnedActions.take(2).map((action) {
      final shortcut = kShortcuts.firstWhere(
        (shortcut) => shortcut.name == action,
        orElse: () => kShortcuts.first,
      );
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: BookButton(
          text: shortcut.name,
          icon: shortcut.icon,
          onPressed: shortcut.onTap,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return BookPageWidget(
      title: '${renderGreetingBasedOnTime()}, ${user?.displayName.split(" ").first}!',
      child: Consumer<ProgressProvider>(
        builder: (context, progressProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Overview Card
                BookCard(
                  title: 'Your Learning Journey',
                  subtitle: 'Track your vocabulary progress',
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Words Learned',
                            progressProvider.userProgress
                                .where((p) => p.isLearned)
                                .length
                                .toString(),
                            Icons.check_circle_outline,
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'In Progress',
                            progressProvider.userProgress
                                .where((p) => !p.isLearned)
                                .length
                                .toString(),
                            Icons.schedule_outlined,
                            theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick Actions
                BookCard(
                  title: 'Quick Actions',
                  subtitle: 'Jump into your learning journey',
                  children: [
                    ...getPinnedActionCards(context, authProvider),
                    const SizedBox(height: 12),
                    BookButton(
                      text: 'Add Quick Action',
                      icon: Icons.add,
                      isOutlined: true,
                      onPressed: () => _showActionSelectionDialog(context, authProvider),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Recent Activity
                BookCard(
                  title: 'Recent Activity',
                  subtitle: 'Your latest learning progress',
                  children: [
                    if (progressProvider.userProgress.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Start learning to see your progress here!',
                                style: GoogleFonts.crimsonText(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...progressProvider.userProgress
                          .take(5)
                          .map((progress) => Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorScheme.surface.withOpacity(0.15),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  leading: Icon(
                                    progress.isLearned ? Icons.check : Icons.schedule,
                                    color: progress.isLearned
                                        ? Colors.lightGreen[800]
                                        : Colors.orangeAccent[800],
                                    size: 20,
                                  ),
                                  title: renderTextDate(progress.due, progress.isLearned),
                                  subtitle: Text(
                                    'Accuracy: ${(progress.accuracy * 100).toStringAsFixed(1)}%',
                                  ),
                                  trailing: Text(
                                    progress.isLearned ? 'Learned' : 'In Progress',
                                    style: TextStyle(
                                      color: progress.isLearned
                                          ? modernGreen
                                          : modernOrange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    showBlurDialog(
                                      context: context,
                                      blurStrength: 6.0,
                                      builder: (dialogContext) => ProgressDialog(
                                        progress: progress,
                                      ),
                                    );
                                  },
                                ),
                              ))
                          .toList(),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.crimsonText(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String renderGreetingBasedOnTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static Widget renderTextDate(DateTime due, bool isLearned) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(due.year, due.month, due.day);
    if (dateOnly == today) {
      return Text(
        "Today",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned ? modernGreen : modernOrange,
        ),
      );
    }
    if (dateOnly == yesterday) {
      return Text(
        "Yesterday",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned ? modernPurple : modernOrange,
        ),
      );
    }
    if (DateTime.now().difference(due).inDays < 7) {
      return Text(
        "Last ${DateFormat('EEEE').format(due)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned ? modernGreen : modernOrange,
        ),
      );
    }
    return Text(
      DateFormat('yMd').format(due),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isLearned ? modernGreen : modernOrange,
      ),
    );
  }
}
