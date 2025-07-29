import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/providers/auth_provider.dart';
import 'package:vocab_learner/providers/progress_provider.dart';
import 'package:vocab_learner/consts/app_consts.dart';
import 'package:vocab_learner/screens/home/widgets/action_card.dart';
import 'package:vocab_learner/screens/home/widgets/progress_dialog.dart';
import 'package:vocab_learner/screens/home/widgets/stat_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName =
        Provider.of<AuthProvider>(context).appUser?.displayName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${renderGreetingBasedOnTime()}, ${userName.split(" ").first}!',
        ),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Overview Card
                Card(
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
                                title: 'Words Learned',
                                value: '${progressProvider.wordsLearned}',
                                icon: Icons.check_circle,
                                color: pastelGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatCard(
                                title: 'In Progress',
                                value: '${progressProvider.wordsInProgress}',
                                icon: Icons.trending_up,
                                color: pastelOrange,
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
                                color: pastelBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatCard(
                                title: 'Accuracy',
                                value:
                                    '${(progressProvider.averageAccuracy * 100).toStringAsFixed(1)}%',
                                icon: Icons.track_changes,
                                color: pastelPurple,
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

                Row(
                  children: [
                    Expanded(
                      child: ActionCard(
                        title: 'Start Practice',
                        subtitle: 'Review words due today',
                        icon: Icons.quiz,
                        color: theme.colorScheme.primary,
                        onTap: () {
                          // Simple navigation message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Navigate to Practice tab to start practicing!',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionCard(
                        title: 'Browse Words',
                        subtitle: 'Explore vocabulary',
                        icon: Icons.book,
                        color: theme.colorScheme.primary,
                        onTap: () {
                          // Navigate to vocabulary screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Navigate to Vocabulary tab to browse words!',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                                    color: pastelGrey,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Start learning to see your progress here!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: pastelGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: progressProvider.userProgress.length > 5
                                ? 5
                                : progressProvider.userProgress.length,
                            itemBuilder: (context, index) {
                              final progress =
                                  progressProvider.userProgress[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: progress.isLearned
                                      ? Colors.lightGreen[800]
                                      : Colors.orangeAccent[800],
                                  child: Icon(
                                    progress.isLearned
                                        ? Icons.check
                                        : Icons.schedule,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
                                        ? pastelGreen
                                        : pastelOrange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ProgressDialog(
                                        progress: progress,
                                      );
                                    },
                                  );
                                }
                                  // Here you can implement navigation to a detailed view
                                  // For example, Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressDetailScreen(progress: progress))
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
    );
    
  }
  
  static String renderGreetingBasedOnTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static Widget renderTextDate(DateTime due, bool isLearned) {
    if (DateTime.now().difference(due).inDays == 0) {
      return Text(
        "Today",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned ? pastelGreen : pastelOrange,
        ),
      );
    }
    if (DateTime.now().difference(due).inDays == 1) {
      return Text(
        "Yesterday",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned ? pastelGreen : pastelOrange,
        ),
      );
    }
    if (DateTime.now().difference(due).inDays < 7) {
      return Text(
        "Last ${DateFormat('EEEE').format(due)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLearned ? pastelGreen : pastelOrange,
        ),
      );
    }
    return Text(
      "Date: ${DateFormat('yMd').format(due)}",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isLearned ? pastelGreen : pastelOrange,
      ),
    );
  }
}