import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseTestWidget extends StatefulWidget {
  const FirebaseTestWidget({super.key});

  @override
  State<FirebaseTestWidget> createState() => _FirebaseTestWidgetState();
}

class _FirebaseTestWidgetState extends State<FirebaseTestWidget> {
  bool _isFirebaseInitialized = false;
  String _status = 'Checking Firebase...';

  @override
  void initState() {
    super.initState();
    _checkFirebase();
  }

  Future<void> _checkFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        setState(() {
          _isFirebaseInitialized = true;
          _status = 'Firebase is initialized successfully!';
        });
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        setState(() {
          _isFirebaseInitialized = true;
          _status = 'Firebase initialized successfully!';
        });
      }
    } catch (e) {
      setState(() {
        _isFirebaseInitialized = false;
        _status = 'Firebase initialization failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFirebaseInitialized ? Icons.check_circle : Icons.error,
              size: 64,
              color: _isFirebaseInitialized ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (_isFirebaseInitialized) ...[
              const SizedBox(height: 24),
              const Text('Firebase Apps:'),
              ...Firebase.apps.map((app) => Text('• ${app.name}')),
            ],
          ],
        ),
      ),
    );
  }
}
