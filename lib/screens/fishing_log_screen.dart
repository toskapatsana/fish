import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fishing_provider.dart';
import '../models/catch_entry.dart';
import 'add_entry_screen.dart';

/// Screen displaying the list of all fishing catch entries.
/// 
/// Supports swipe-to-delete functionality and navigation
/// to add new entries.
class FishingLogScreen extends StatelessWidget {
  const FishingLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Fishing Log'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _navigateToAddEntry(context),
        ),
      ),
      child: SafeArea(
        child: Consumer<FishingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 20),
              );
            }

            if (provider.entries.isEmpty) {
              return _buildEmptyState(context);
            }

            return _buildEntryList(context, provider);
          },
        ),
      ),
    );
  }

  /// Builds the empty state when no entries exist.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 80,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
            const SizedBox(height: 24),
            Text(
              'No Catches Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + button to log your first catch!',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              child: const Text('Add First Catch'),
              onPressed: () => _navigateToAddEntry(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the scrollable list of entries.
  Widget _buildEntryList(BuildContext context, FishingProvider provider) {
    return CustomScrollView(
      slivers: [
        // Summary header
        SliverToBoxAdapter(
          child: _buildSummaryHeader(context, provider),
        ),
        
        // List of entries
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = provider.entries[index];
              return _buildEntryTile(context, entry, provider);
            },
            childCount: provider.entries.length,
          ),
        ),
        
        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  /// Builds the summary header showing total catches and weight.
  Widget _buildSummaryHeader(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${provider.entryCount}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              Text(
                'Total Catches',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
          Column(
            children: [
              Text(
                '${provider.totalWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGreen,
                ),
              ),
              Text(
                'Total Weight',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single entry tile with swipe-to-delete.
  Widget _buildEntryTile(
    BuildContext context,
    CatchEntry entry,
    FishingProvider provider,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: CupertinoColors.systemRed,
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, entry);
      },
      onDismissed: (direction) {
        provider.deleteEntry(entry.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Fish icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '🐟',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Entry details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.species,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location,
                          size: 14,
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel.resolveFrom(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(entry.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Weight badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting an entry.
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    CatchEntry entry,
  ) async {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Entry?'),
        content: Text(
          'Are you sure you want to delete the ${entry.species} catch? This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Navigates to the add entry screen.
  void _navigateToAddEntry(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const AddEntryScreen(),
      ),
    );
  }
}
