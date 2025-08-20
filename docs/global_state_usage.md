# Global State Usage Guide

This guide explains how to easily access the current user's ID and authentication state throughout your Flutter app.

## Overview

The global state utilities provide several convenient ways to access the userId without having to manually get the AuthProvider every time.

## Available Methods

### 1. Context Extensions (Recommended)

The easiest and most convenient way to access userId:

```dart
import '../utils/global_state.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get userId without listening to changes
    final userId = context.userId;
    
    // Get userId with listening to changes (rebuilds widget when userId changes)
    final userIdWithListener = context.userIdWithListener;
    
    // Check if user is authenticated
    final isAuthenticated = context.isAuthenticated;
    
    // Get AuthProvider instance
    final authProvider = context.authProvider;
    
    return Text('User ID: ${userId ?? "Not authenticated"}');
  }
}
```

### 2. Static Methods

Use static methods when you need to access userId from outside widgets:

```dart
import '../utils/global_state.dart';

class MyService {
  static Future<void> performAction(BuildContext context) async {
    final userId = GlobalState.getUserId(context);
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Use userId for API calls, database operations, etc.
    print('Performing action for user: $userId');
  }
}
```

### 3. Enhanced AuthProvider

The AuthProvider now includes a convenient `userId` getter:

```dart
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId; // New convenient getter
    
    return Text('User ID: ${userId ?? "Not authenticated"}');
  }
}
```

## Migration Examples

### Before (Old Way)
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final userId = authProvider.user?.uid;
```

### After (New Way)
```dart
final userId = context.userId;
```

## Use Cases

### 1. Service Classes
```dart
class VocabService {
  static Future<List<VocabWord>> getUserVocab(BuildContext context) async {
    final userId = GlobalState.getUserId(context);
    if (userId == null) throw Exception('User not authenticated');
    
    // Fetch vocab for user
    return await FirebaseFirestore.instance
        .collection('vocab')
        .where('userId', isEqualTo: userId)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => VocabWord.fromFirestore(doc)).toList());
  }
}
```

### 2. Conditional UI
```dart
class ConditionalWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!context.isAuthenticated) {
      return LoginButton();
    }
    
    return UserContent(userId: context.userId!);
  }
}
```

### 3. Progress Tracking
```dart
Future<void> recordProgress(BuildContext context, Map<String, dynamic> progressData) async {
  final userId = context.userId;
  if (userId == null) return;
  
  await ProgressService.recordSession(
    userId: userId,
    data: progressData,
  );
}
```

## Benefits

1. **Cleaner Code**: No more repetitive AuthProvider boilerplate
2. **Consistent Access**: Same pattern throughout the app
3. **Better Readability**: Clear intent with `context.userId`
4. **Null Safety**: Built-in null handling
5. **Type Safety**: Proper Dart typing
6. **Performance**: Efficient access without unnecessary rebuilds

## Best Practices

1. **Use context extensions** for widget classes
2. **Use static methods** for service classes and utility functions
3. **Use with listener** only when you need reactive updates
4. **Always check for null** when userId might not be available
5. **Handle authentication state** gracefully in your UI

## Error Handling

```dart
void performUserAction(BuildContext context) {
  final userId = context.userId;
  
  if (userId == null) {
    // Handle unauthenticated state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please sign in to continue')),
    );
    return;
  }
  
  // Proceed with authenticated action
  doSomethingWithUserId(userId);
}
```
