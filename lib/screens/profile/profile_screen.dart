import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.appUser;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Unknown User',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'No email',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Options
                Expanded(
                  child: ListView(
                    children: [
                      _buildLanguageSettingsCard(context, authProvider),
                      const SizedBox(height: 16),
                      _buildStatsCard(context, user),
                      const SizedBox(height: 16),
                      _buildAISettingsCard(context, authProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSettingsCard(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final currentLanguage = authProvider.appUser?.language ?? 'English';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose your native language for AI-generated definitions',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.language, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Native Language',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'Vietnamese',
                        child: Text('Tiếng Việt'),
                      ),
                      DropdownMenuItem(
                        value: 'Spanish',
                        child: Text('Español'),
                      ),
                      DropdownMenuItem(
                        value: 'French',
                        child: Text('Français'),
                      ),
                      DropdownMenuItem(value: 'German', child: Text('Deutsch')),
                      DropdownMenuItem(value: 'Chinese', child: Text('中文')),
                      DropdownMenuItem(value: 'Japanese', child: Text('日本語')),
                      DropdownMenuItem(value: 'Korean', child: Text('한국어')),
                    ],
                    onChanged: (String? newLanguage) {
                      if (newLanguage != null &&
                          newLanguage != currentLanguage) {
                        _updateUserLanguage(context, authProvider, newLanguage);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Words Learned',
                  '${user?.totalWordsLearned ?? 0}',
                  Icons.book,
                ),
                _buildStatItem(
                  context,
                  'Current Streak',
                  '${user?.currentStreak ?? 0}',
                  Icons.local_fire_department,
                ),
                _buildStatItem(
                  context,
                  'Longest Streak',
                  '${user?.longestStreak ?? 0}',
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAISettingsCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.appUser;
    if (user == null) return const SizedBox.shrink();
    String? modelName = user.modelName;
    String? modelVersion = user.modelVersion;
    String apiKey = user.apiKey ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'AI Generative Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: 'Save',
                      onPressed: () async {
                        final updatedUser = user.copyWith(
                          modelName: modelName,
                          modelVersion: modelVersion,
                          apiKey: apiKey,
                        );
                        await authProvider.updateUserProfile(updatedUser);
                        if (context.mounted) {
                          ToastNotification.showSuccess(
                            context,
                            message: 'AI settings updated successfully!',
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure your AI model, version, and API key for vocabulary generation and analysis.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.model_training, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: modelName,
                          decoration: const InputDecoration(
                            labelText: 'Model Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'gemini',
                              child: Text('Gemini'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              modelName = newValue ?? modelName;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.vaccines, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: modelVersion,
                          decoration: const InputDecoration(
                            labelText: 'Model Version',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'gemini-1.5-flash',
                              child: Text('Gemini 1.5 Flash (Deprecated)'),
                            ),
                            DropdownMenuItem(
                              value: 'gemini-2.0-flash-lite',
                              child: Text('Gemini 2.0 Flash Lite'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              modelVersion = newValue ?? modelVersion;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.key, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: apiKey.isNotEmpty
                              ? '••••••••${apiKey.substring(apiKey.length - 3)}'
                              : '',
                          decoration: const InputDecoration(
                            labelText: 'API Key',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              apiKey = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Future<List<String>> _getModelVersion({String? modelName, String? apiKey}) async {
  //   const timeout = Duration(seconds: 30);

  //   try {
  //     final url = _getApiUrl(modelName);
  //     final headers = _getHeaders(modelName, apiKey);

  //     if (url == null || headers == null) {
  //       return [];
  //     }

  //     final response = await http.get(url, headers: headers).timeout(timeout);

  //     if (response.statusCode == 200) {
  //       return _parseVersions(response.body, modelName);
  //     } else {
  //       print('API request failed with status: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //       return [];
  //     }

  //   } on TimeoutException {
  //     print('Request timed out');
  //     return [];
  //   } catch (e) {
  //     print('Error: $e');
  //     return [];
  //   }
  // }

  // Uri? _getApiUrl(String? modelName) {
  //   switch (modelName?.toLowerCase()) {
  //     case 'gemini':
  //     case 'google':
  //       return Uri.parse('https://generativelanguage.googleapis.com/v1/models');
  //     case 'openai':
  //       return Uri.parse('https://api.openai.com/v1/models');
  //     default:
  //       return null;
  //   }
  // }

  // Map<String, String>? _getHeaders(String? modelName, String? apiKey) {
  //   switch (modelName?.toLowerCase()) {
  //     case 'gemini':
  //     case 'google':
  //       return {
  //         'Authorization': 'Bearer $apiKey',
  //         'Content-Type': 'application/json',
  //       };
  //     case 'openai':
  //       return {
  //         'Authorization': 'Bearer $apiKey',
  //         'Content-Type': 'application/json',
  //       };
  //     default:
  //       return null;
  //   }
  // }

  // List<String> _parseVersions(String responseBody, String? modelName) {
  //   try {
  //     final data = json.decode(responseBody);

  //     switch (modelName?.toLowerCase()) {
  //       case 'gemini':
  //       case 'google':
  //         if (data['models'] != null) {
  //           return List<String>.from(
  //             data['models'].map((model) => model['name'] ?? model['displayName'] ?? '')
  //           );
  //         }
  //         break;
  //       case 'openai':
  //         if (data['data'] != null) {
  //           return List<String>.from(
  //             data['data'].map((model) => model['id'] ?? '')
  //           );
  //         }
  //         break;
  //     }

  //     return [];
  //   } catch (e) {
  //     print('Error parsing response: $e');
  //     return [];
  //   }
  // }

  Future<void> _updateUserLanguage(
    BuildContext context,
    AuthProvider authProvider,
    String newLanguage,
  ) async {
    final user = authProvider.appUser;
    if (user == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Updating language...'),
            ],
          ),
        ),
      );

      // Update user with new language
      final updatedUser = user.copyWith(language: newLanguage);
      await authProvider.updateUserProfile(updatedUser);

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show success message
      if (context.mounted) {
        ToastNotification.showSuccess(
          context,
          message: 'Language updated to $newLanguage',
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ToastNotification.showError(
          context,
          message: 'Failed to update language: $e',
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
