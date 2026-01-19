import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fishing_provider.dart';

/// Screen for adding a new catch entry.
/// 
/// Uses iOS-style Cupertino widgets including CupertinoDatePicker
/// for selecting the catch date.
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  // Form controllers
  final _locationController = TextEditingController();
  final _speciesController = TextEditingController();
  final _weightController = TextEditingController();

  // Form values
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _locationController.dispose();
    _speciesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Catch'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: _isSaving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveEntry,
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message (if any)
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Date picker section
                    _buildSectionHeader('Date'),
                    _buildDatePicker(),
                    const SizedBox(height: 24),

                    // Location input
                    _buildSectionHeader('Location'),
                    _buildTextField(
                      controller: _locationController,
                      placeholder: 'e.g., Lake Michigan, North Shore',
                      icon: CupertinoIcons.location,
                    ),
                    const SizedBox(height: 24),

                    // Species input
                    _buildSectionHeader('Fish Species'),
                    _buildTextField(
                      controller: _speciesController,
                      placeholder: 'e.g., Bass, Trout, Salmon',
                      icon: CupertinoIcons.tag,
                    ),
                    const SizedBox(height: 24),

                    // Weight input
                    _buildSectionHeader('Weight (kg)'),
                    _buildTextField(
                      controller: _weightController,
                      placeholder: 'e.g., 2.5',
                      icon: CupertinoIcons.chart_bar,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button (for easier access)
                    CupertinoButton.filled(
                      onPressed: _isSaving ? null : _saveEntry,
                      child: _isSaving
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                          : const Text(
                              'Save Catch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  /// Builds a section header label.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
      ),
    );
  }

  /// Builds the error banner when validation fails.
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the date picker section.
  Widget _buildDatePicker() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.systemGrey6.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.calendar,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateFormat.format(_selectedDate),
                style: const TextStyle(fontSize: 17),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a styled text field.
  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        placeholderStyle: TextStyle(
          color: CupertinoColors.placeholderText.resolveFrom(context),
        ),
        keyboardType: keyboardType,
        padding: const EdgeInsets.all(16),
        decoration: null,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            icon,
            color: CupertinoColors.systemBlue,
          ),
        ),
        style: const TextStyle(fontSize: 17),
      ),
    );
  }

  /// Shows the iOS-style date picker in a modal sheet.
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header with Done button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Today'),
                    onPressed: () {
                      setState(() => _selectedDate = DateTime.now());
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Date picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Validates the form and saves the entry.
  Future<void> _saveEntry() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    // Validate inputs
    final location = _locationController.text.trim();
    final species = _speciesController.text.trim();
    final weightText = _weightController.text.trim();

    if (location.isEmpty) {
      setState(() => _errorMessage = 'Please enter a location');
      return;
    }

    if (species.isEmpty) {
      setState(() => _errorMessage = 'Please enter the fish species');
      return;
    }

    if (weightText.isEmpty) {
      setState(() => _errorMessage = 'Please enter the weight');
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      setState(() => _errorMessage = 'Please enter a valid weight');
      return;
    }

    if (weight > 1000) {
      setState(() => _errorMessage = 'Weight seems too high. Please check.');
      return;
    }

    // Save the entry
    setState(() => _isSaving = true);

    final provider = context.read<FishingProvider>();
    final success = await provider.addEntry(
      date: _selectedDate,
      location: location,
      species: species,
      weight: weight,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      // Show success feedback and navigate back
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = 'Failed to save. Please try again.');
    }
  }
}
