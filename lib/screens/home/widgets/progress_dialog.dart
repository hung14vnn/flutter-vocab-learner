import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocab_learner/models/user_progress.dart';
import 'package:vocab_learner/consts/app_consts.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/providers/vocab_provider.dart';
import 'package:vocab_learner/models/vocab_word.dart';
import 'package:vocab_learner/screens/practice/flashcards/flashcards_game_screen.dart';
class ProgressDialog extends StatefulWidget {
  final UserProgress progress;

  const ProgressDialog({super.key, required this.progress});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> with TickerProviderStateMixin {
  bool _showWordsList = false;
  List<VocabWord> _words = [];
  bool _isLoadingWords = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.progress.isLearned ? pastelGreen : pastelOrange;
    final statusIcon = widget.progress.isLearned ? Icons.check_circle : Icons.schedule;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 600, // Fixed height
        width: 400,  // Fixed width
        padding: const EdgeInsets.all(24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Progress view (slides left when words list is shown)
              SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-1.0, 0.0),
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                )),
                child: _buildProgressView(context, theme, statusColor, statusIcon),
              ),
              // Words list view (slides in from right)
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: 552, // Same height as progress view
                  width: 352,  // Full width minus padding
                  child: _showWordsList 
                    ? _buildWordsListView(context, theme)
                    : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressView(BuildContext context, ThemeData theme, Color statusColor, IconData statusIcon) {
    return SizedBox(
      height: 552, // Fixed height minus padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header with status icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 32,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'Progress Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),           
          GestureDetector(
            onTap: () => _loadAndShowWordsList(),
            child: _buildInfoCard(
              icon: Icons.book,
              title: 'Words',
              value: '${widget.progress.wordIds.length}',
              color: pastelBlue,
              isClickable: true,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.track_changes,
            title: 'Accuracy',
            value: '${(widget.progress.accuracy * 100).toStringAsFixed(1)}%',
            color: pastelPurple,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.calendar_today,
            title: 'Due Date',
            value: DateFormat('MMM dd, yyyy').format(widget.progress.due),
            color: pastelOrange,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: statusIcon,
            title: 'Status',
            value: widget.progress.isLearned ? 'Learned' : 'In Progress',
            color: statusColor,
          ),
          const Spacer(),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!widget.progress.isLearned) // Only show Continue button if not learned
                TextButton(
                  onPressed: () {
                    _continueProgress();
                  },
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordsListView(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Header with back button
        Row(
          children: [
            IconButton(
              onPressed: () => _goBackToProgress(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                'Words in Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
        const SizedBox(height: 16),
        
        // Words list
        Expanded(
          child: _isLoadingWords
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _words.isEmpty
              ? const Center(
                  child: Text(
                    'No words found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  itemCount: _words.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final word = _words[index];
                    final isLearned = word.state == WordState.masteredState;
                    return Card(
                      color: pastelBlue.withOpacity(0.1),
                      child: ListTile(
                        title: Text(
                          word.word,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(word.definition.isNotEmpty ? word.definition : '-'),
                        trailing: isLearned
                            ? Icon(Icons.check_circle, color: pastelGreen)
                            : Icon(Icons.schedule, color: pastelOrange),
                      ),
                    );
                  },
                ),
        ),
        
        const SizedBox(height: 16),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadAndShowWordsList() async {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    
    setState(() {
      _isLoadingWords = true;
      _showWordsList = true;
    });
    
    // Start slide animation
    _animationController.forward();
    
    try {
      // Get the words using the word IDs from progress
      final words = await vocabProvider.getWordsByIds(widget.progress.wordIds);
      
      if (mounted) {
        setState(() {
          _words = words;
          _isLoadingWords = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _words = [];
          _isLoadingWords = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load words: $e')),
        );
      }
    }
  }

  void _goBackToProgress() async {
    // Start reverse animation
    await _animationController.reverse();
    
    if (mounted) {
      setState(() {
        _showWordsList = false;
      });
    }
  }

  Future<void> _continueProgress() async {
    if (widget.progress.isLearned) {
      // If already learned, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This progress is already completed!')),
      );
      return;
    }

    try {
      final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
      
      // Get the words for this progress
      final words = await vocabProvider.getWordsByIds(widget.progress.wordIds);
      
      if (words.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No words found for this progress')),
        );
        return;
      }

      final wordsToReview = words.where((word) => 
        ![...widget.progress.wrongAnswers, ...widget.progress.correctAnswers].contains(word.id)
      ).toList();

      final selectedWords = wordsToReview.isNotEmpty ? wordsToReview : words;

      // Close the dialog
      Navigator.of(context).pop();

      // Navigate to flashcards with specific words
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FlashcardsGameScreen(
            specificWords: selectedWords,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to continue progress: $e')),
      );
    }
  }

  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isClickable = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
        ],
      ),
    );
  }
}
