import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/consts/shortcut_consts.dart';
import 'package:vocab_learner/providers/auth_provider.dart';
import 'package:vocab_learner/providers/progress_provider.dart';
import 'package:vocab_learner/consts/app_consts.dart';
import 'package:vocab_learner/screens/home/widgets/action_card.dart';
import 'package:vocab_learner/screens/home/widgets/progress_dialog.dart';
import 'package:vocab_learner/screens/home/widgets/stat_card.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';

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

  List<Widget> _buildQuickActionCards(
    BuildContext context,
    AuthProvider authProvider,
    dynamic user,
    ThemeData theme,
  ) {
    List<Widget> cards = [];
    final pinnedActions = user?.pinnedQuickActions ?? <String>[];

    // Add pinned action cards
    for (final action in pinnedActions.take(2)) {
      final shortcut = kShortcuts.firstWhere(
        (shortcut) => shortcut.name == action,
        orElse: () => kShortcuts.first,
      );

      cards.add(
        ActionCard(
          title: shortcut.name,
          subtitle: shortcut.description,
          icon: shortcut.icon,
          color: theme.colorScheme.primary,
          onTap: shortcut.onTap,
          isPinned: true,
          showPinButton: true,
          onUnpin: () => authProvider.unpinQuickAction(shortcut.name),
        ),
      );
    }

    // Fill remaining slots with empty cards
    while (cards.length < 2) {
      cards.add(
        ActionCard.empty(
          onTap: () => _showActionSelectionDialog(context, authProvider),
        ),
      );
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.surface.withValues(alpha: 0.6),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            '${renderGreetingBasedOnTime()}, ${user?.displayName.split(" ").first}!',
          ),
        ),
        body: Consumer<ProgressProvider>(
          builder: (context, progressProvider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Overview Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Days Practiced',
                                  value: '${progressProvider.progressLearned}',
                                  icon: Icons.check_circle,
                                  color: modernGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatCard(
                                  title: 'Words Learned',
                                  value: '${progressProvider.learnedWords}',
                                  icon: Icons.trending_up,
                                  color: modernOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'To Review',
                                  value: '${progressProvider.wordsToReview}',
                                  icon: Icons.schedule,
                                  color: modernBlue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatCard(
                                  title: 'Accuracy',
                                  value:
                                      '${(progressProvider.averageAccuracy * 100).toStringAsFixed(1)}%',
                                  icon: Icons.track_changes,
                                  color: modernPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _buildQuickActionCards(
                      context,
                      authProvider,
                      user,
                      theme,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          width: 1,
                        ),
                      ),
                      child: progressProvider.userProgress.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.emoji_events,
                                      size: 48,
                                      color: modernGrey,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Start learning to see your progress here!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: modernGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount:
                                  progressProvider.userProgress.length > 5
                                  ? 5
                                  : progressProvider.userProgress.length,
                              itemBuilder: (context, index) {
                                final progress =
                                    progressProvider.userProgress[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: theme.colorScheme.surface.withValues(
                                      alpha: 0.15,
                                    ),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    leading: Icon(
                                      progress.isLearned
                                          ? Icons.check
                                          : Icons.schedule,
                                      color: progress.isLearned
                                          ? Colors.lightGreen[800]
                                          : Colors.orangeAccent[800],
                                      size: 20,
                                    ),
                                    title: renderTextDate(
                                      progress.due,
                                      progress.isLearned,
                                    ),
                                    subtitle: Text(
                                      'Accuracy: ${(progress.accuracy * 100).toStringAsFixed(1)}%',
                                    ),
                                    trailing: Text(
                                      progress.isLearned
                                          ? 'Learned'
                                          : 'In Progress',
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
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
    final yesterday = today.subtract(Duration(days: 1));
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
