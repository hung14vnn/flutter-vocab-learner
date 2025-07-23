import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/consts/app_consts.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';
import '../vocab/vocab_list_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeTab(),
    VocabListScreen(),
    PracticeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutSine,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Vocabulary',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

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
                              child: _StatCard(
                                title: 'Words Learned',
                                value: '${progressProvider.wordsLearned}',
                                icon: Icons.check_circle,
                                color: pastelGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
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
                              child: _StatCard(
                                title: 'To Review',
                                value: '${progressProvider.wordsToReview}',
                                icon: Icons.schedule,
                                color: pastelBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
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
                      child: _ActionCard(
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
                      child: _ActionCard(
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
                                title: Text('${progress.due}'),
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

  String renderGreetingBasedOnTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: pastelGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 24,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: pastelGrey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
