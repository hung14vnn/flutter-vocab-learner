import 'package:flutter/material.dart';
import '../utils/global_state.dart';

/// Example screen demonstrating different ways to access userId using the new global state utilities
class UserIdAccessExampleScreen extends StatelessWidget {
  const UserIdAccessExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UserId Access Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Method 1: Using context extension (Recommended)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Method 1: Context Extension (Recommended)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Current User ID: ${context.userId ?? "Not authenticated"}'),
                    Text('Is Authenticated: ${context.isAuthenticated}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performUserAction(context),
                      child: const Text('Perform User Action'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Method 2: Using GlobalState static methods
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Method 2: GlobalState Static Methods',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('User ID: ${GlobalState.getUserId(context) ?? "Not authenticated"}'),
                    Text('Is Authenticated: ${GlobalState.isAuthenticated(context)}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Method 3: Using AuthProvider directly (for more complex operations)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Method 3: AuthProvider Direct Access',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final authProvider = context.authProvider;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: ${authProvider.userId ?? "Not authenticated"}'),
                            Text('User Email: ${authProvider.user?.email ?? "N/A"}'),
                            Text('Display Name: ${authProvider.appUser?.displayName ?? "N/A"}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Method 4: Using with listener for reactive updates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Method 4: With Listener (Reactive)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        // This will rebuild when userId changes
                        final userId = context.userIdWithListener;
                        return Text('Reactive User ID: ${userId ?? "Not authenticated"}');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example of using userId in a method
  void _performUserAction(BuildContext context) {
    final userId = context.userId;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    
    // Perform some action with userId
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action performed for user: $userId')),
    );
  }
}

/// Example of a service class that uses global state
class ExampleService {
  /// Example of accessing userId from a service class
  static Future<bool> performUserSpecificAction(BuildContext context, String action) async {
    final userId = GlobalState.getUserId(context);
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Simulate API call or database operation
    print('Performing $action for user: $userId');
    
    // Your actual service logic here
    await Future.delayed(const Duration(seconds: 1));
    
    return true;
  }
}

/// Example of a custom widget that needs userId
class UserSpecificWidget extends StatelessWidget {
  final String title;
  
  const UserSpecificWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final userId = context.userId;
    
    if (userId == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Please sign in to view this content'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Content for user: $userId'),
          ],
        ),
      ),
    );
  }
}
