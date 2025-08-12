import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/vocab_provider.dart';

class VocabFilterSection extends StatefulWidget {
  final VoidCallback? onClose;

  const VocabFilterSection({super.key, this.onClose});

  @override
  State<VocabFilterSection> createState() => _VocabFilterSectionState();
}

class _VocabFilterSectionState extends State<VocabFilterSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    _searchController.text = vocabProvider.searchQuery;
    _startDate = vocabProvider.createdAfter;
    _endDate = vocabProvider.createdBefore;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, VocabProvider vocabProvider) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      vocabProvider.setSearchQuery(value);
    });
  }

  Widget _buildCompactDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
    required ThemeData theme,
  }) {
    // Handle empty items list
    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'No options available',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Ensure the value exists in items, fallback to first item if not
    final validValue = items.contains(value) ? value : items.first;

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        isDense: true,
      ),
      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(_formatDropdownText(item)),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  String _formatDropdownText(String item) {
    if (item == 'all') return 'All';
    if (item.isEmpty) return item;

    // Handle special cases
    switch (item.toLowerCase()) {
      case 'new':
        return 'New';
      case 'learning':
        return 'Learning';
      case 'reviewed':
        return 'Reviewed';
      case 'mastered':
        return 'Mastered';
      default:
        return item[0].toUpperCase() + item.substring(1);
    }
  }

  Future<void> _selectDateRange(
    BuildContext context,
    VocabProvider vocabProvider,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      vocabProvider.setDateRangeFilter(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.9),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _debounceTimer?.cancel();
                      vocabProvider.clearAllFilters();
                      _searchController.clear();
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search words...',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _debounceTimer?.cancel();
                            _searchController.clear();
                            vocabProvider.setSearchQuery('');
                          },
                        )
                      : null,
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  _onSearchChanged(value, vocabProvider);
                },
              ),
              const SizedBox(height: 16),

              // Filter dropdowns - simplified layout
              _buildCompactDropdown(
                value: vocabProvider.selectedDifficulty,
                label: 'Difficulty',
                items: vocabProvider.availableDifficulties.isNotEmpty
                    ? vocabProvider.availableDifficulties
                    : ['all'],
                onChanged: (value) {
                  if (value != null) vocabProvider.setDifficultyFilter(value);
                },
                theme: theme,
              ),
              const SizedBox(height: 8),
              _buildCompactDropdown(
                value: vocabProvider.selectedPartOfSpeech,
                label: 'Part of Speech',
                items: vocabProvider.availablePartsOfSpeech.isNotEmpty
                    ? vocabProvider.availablePartsOfSpeech
                    : ['all'],
                onChanged: (value) {
                  if (value != null) vocabProvider.setPartOfSpeechFilter(value);
                },
                theme: theme,
              ),
              const SizedBox(height: 8),
              _buildCompactDropdown(
                value: vocabProvider.selectedState,
                label: 'Mastery Level',
                items: vocabProvider.availableStates.isNotEmpty
                    ? vocabProvider.availableStates
                    : ['all'],
                onChanged: (value) {
                  if (value != null) vocabProvider.setStateFilter(value);
                },
                theme: theme,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context, vocabProvider),
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Select date range',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
