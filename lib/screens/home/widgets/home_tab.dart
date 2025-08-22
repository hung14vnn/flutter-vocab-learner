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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.3),
            theme.colorScheme.surface.withValues(alpha: 0.8),
            theme.colorScheme.surface.withValues(alpha: 0.25),
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
                                  color: isDarkMode
                                      ? modernGreenDarkMode
                                      : modernGreenLightMode,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatCard(
                                  title: 'Words Learned',
                                  value: '${progressProvider.learnedWords}',
                                  icon: Icons.trending_up,
                                  color: isDarkMode
                                      ? modernGreenDarkMode
                                      : modernGreenLightMode,
                                  isDarkMode: isDarkMode,
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
                                  color: isDarkMode
                                      ? modernGreenDarkMode
                                      : modernGreenLightMode,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatCard(
                                  title: 'Accuracy',
                                  value:
                                      '${(progressProvider.averageAccuracy * 100).toStringAsFixed(1)}%',
                                  icon: Icons.track_changes,
                                  color: isDarkMode
                                      ? modernPurpleDarkMode
                                      : modernPurpleLightMode,
                                  isDarkMode: isDarkMode,
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
                                      color: isDarkMode
                                          ? modernGreyDarkMode
                                          : modernGreyLightMode,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Start learning to see your progress here!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? modernGreyDarkMode
                                            : modernGreyLightMode,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20.0),
                              itemCount:
                                  progressProvider.userProgress.length > 5
                                  ? 5
                                  : progressProvider.userProgress.length,
                              itemBuilder: (context, index) {
                                final progress =
                                    progressProvider.userProgress[index];
                                final progressPercentage = ((progress.correctAnswers.length + progress.wrongAnswers.length) / (progress.wordIds.isNotEmpty ? progress.wordIds.length : 1) * 100);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        progress.isLearned
                                            ? (isDarkMode
                                                ? modernGreenDarkMode.withValues(alpha: 0.1)
                                                : modernGreenLightMode.withValues(alpha: 0.05))
                                            : (isDarkMode
                                                ? modernOrangeDarkMode.withValues(alpha: 0.1)
                                                : modernOrangeDarkMode.withValues(alpha: 0.05)),
                                        theme.colorScheme.surface.withValues(alpha: 0.02),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: progress.isLearned
                                          ? (isDarkMode
                                              ? modernGreenDarkMode.withValues(alpha: 0.3)
                                              : modernGreenLightMode.withValues(alpha: 0.3))
                                          : (isDarkMode
                                              ? modernOrangeDarkMode.withValues(alpha: 0.3)
                                              : modernOrangeDarkMode.withValues(alpha: 0.3)),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        showBlurDialog(
                                          context: context,
                                          blurStrength: 6.0,
                                          builder: (dialogContext) =>
                                              ProgressDialog(progress: progress),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: progress.isLearned
                                                        ? (isDarkMode
                                                            ? modernGreenDarkMode.withValues(alpha: 0.2)
                                                            : modernGreenLightMode.withValues(alpha: 0.2))
                                                        : (isDarkMode
                                                            ? modernOrangeDarkMode.withValues(alpha: 0.2)
                                                            : modernOrangeDarkMode.withValues(alpha: 0.2)),
                                                  ),
                                                  child: Icon(
                                                    progress.isLearned
                                                        ? Icons.check_circle_rounded
                                                        : Icons.schedule_rounded,
                                                    color: progress.isLearned
                                                        ? (isDarkMode
                                                            ? modernGreenDarkMode
                                                            : modernGreenLightMode)
                                                        : (isDarkMode
                                                            ? modernOrangeDarkMode
                                                            : modernOrangeDarkMode),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        renderNameGame(progress.gameId) ??
                                                            progress.gameId,
                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                          color: theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      renderTextDate(
                                                        progress.due,
                                                        progress.isLearned,
                                                        isDarkMode,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 6.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: progress.isLearned
                                                        ? (isDarkMode
                                                            ? modernGreenDarkMode.withValues(alpha: 0.15)
                                                            : modernGreenLightMode.withValues(alpha: 0.15))
                                                        : (isDarkMode
                                                            ? modernOrangeDarkMode.withValues(alpha: 0.15)
                                                            : modernOrangeDarkMode.withValues(alpha: 0.15)),
                                                  ),
                                                  child: Text(
                                                    progress.isLearned
                                                        ? 'Learned'
                                                        : 'In Progress',
                                                    style: TextStyle(
                                                      color: progress.isLearned
                                                          ? (isDarkMode
                                                                ? modernGreenDarkMode
                                                                : modernGreenLightMode)
                                                          : (isDarkMode
                                                                ? modernOrangeDarkMode
                                                                : modernOrangeDarkMode),
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.trending_up_rounded,
                                                  size: 16,
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Progress: ${progressPercentage.toStringAsFixed(1)}%',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  width: 60,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                                  ),
                                                  child: FractionallySizedBox(
                                                    alignment: Alignment.centerLeft,
                                                    widthFactor: progressPercentage / 100,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(2),
                                                        color: progressPercentage >= 80
                                                            ? (isDarkMode
                                                                ? modernGreenDarkMode
                                                                : modernGreenLightMode)
                                                            : progressPercentage >= 60
                                                                ? (isDarkMode
                                                                    ? modernYellowDarkMode
                                                                    : modernYellowLightMode)
                                                                : (isDarkMode
                                                                    ? modernRedDarkMode
                                                                    : modernOrangeDarkMode),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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

  static Widget renderTextDate(DateTime due, bool isLearned, bool isDarkMode) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateOnly = DateTime(due.year, due.month, due.day);
    if (dateOnly == today) {
      return Text(
        "Today",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned
              ? (isDarkMode ? modernGreenDarkMode : modernGreenLightMode)
              : (isDarkMode ? modernOrangeDarkMode : modernOrangeLightMode),
        ),
      );
    }
    if (dateOnly == yesterday) {
      return Text(
        "Yesterday",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned
              ? (isDarkMode ? modernPurpleDarkMode : modernPurpleLightMode)
              : (isDarkMode ? modernOrangeDarkMode : modernOrangeLightMode),
        ),
      );
    }
    if (DateTime.now().difference(due).inDays < 7) {
      return Text(
        "Last ${DateFormat('EEEE').format(due)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned
              ? (isDarkMode ? modernGreenDarkMode : modernGreenLightMode)
              : (isDarkMode ? modernOrangeDarkMode : modernOrangeLightMode),
        ),
      );
    }
    return Text(
      DateFormat('yMd').format(due),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isLearned
            ? (isDarkMode ? modernGreenDarkMode : modernGreenLightMode)
            : (isDarkMode ? modernOrangeDarkMode : modernOrangeLightMode),
      ),
    );
  }

  static String? renderNameGame(String gameId) {
    return kPracticeGames
        .where((game) => game.gameId == gameId)
        .map((game) => game.name)
        .firstOrNull;
  }
}
