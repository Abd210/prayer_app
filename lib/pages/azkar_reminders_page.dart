import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../services/azkar_reminder_service.dart';
import '../models/azkar_model.dart';
import '../models/azakdata.dart';

class AzkarRemindersPage extends StatefulWidget {
  const AzkarRemindersPage({Key? key}) : super(key: key);

  @override
  State<AzkarRemindersPage> createState() => _AzkarRemindersPageState();
}

class _AzkarRemindersPageState extends State<AzkarRemindersPage> {
  List<AzkarReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    final reminders = await AzkarReminderService.getReminders();

    if (mounted) {
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    }
  }

  // Convert DhikrItem to AzkarModel
  List<AzkarModel> _convertToAzkarModels(List<DhikrItem> items, String category) {
    return items.map((item) {
      return AzkarModel(
        id: const Uuid().v4(),
        text: item.arabic.length > 20 ? item.arabic.substring(0, 20) + "..." : item.arabic,
        textAr: item.arabic,
        category: category,
        translation: item.translation,
        count: item.repeat,
      );
    }).toList();
  }

  // Get all available azkar
  List<AzkarModel> _getAllAzkar() {
    final allAzkar = [
      ..._convertToAzkarModels(morningAdhkar, "Morning"),
      ..._convertToAzkarModels(eveningAdhkar, "Evening"),
      ..._convertToAzkarModels(sleepAzkar, "Sleep"),
      ..._convertToAzkarModels(afterPrayersAzkar, "After Prayer"),
    ];
    
    return allAzkar;
  }

  void _showAddReminderDialog() async {
    // Get all azkar items
    final allAzkar = _getAllAzkar();

    showDialog(
      context: context,
      builder: (context) => SelectAzkarDialog(
        azkarItems: allAzkar,
        onAzkarSelected: (azkar) {
          Navigator.of(context).pop();
          _showReminderDetailsDialog(azkar);
        },
      ),
    );
  }

  void _showReminderDetailsDialog(AzkarModel azkar, {AzkarReminder? existingReminder}) {
    showDialog(
      context: context,
      builder: (context) => ReminderDetailsDialog(
        azkar: azkar,
        reminder: existingReminder,
        onSave: (reminder) async {
          if (existingReminder != null) {
            await AzkarReminderService.updateReminder(reminder);
          } else {
            await AzkarReminderService.addReminder(reminder);
          }
          await _loadReminders();
        },
      ),
    );
  }

  Future<void> _deleteReminder(AzkarReminder reminder) async {
    final result = await AzkarReminderService.removeReminder(reminder.id);
    if (result) {
      await _loadReminders();
    }
  }

  Future<void> _toggleReminderEnabled(AzkarReminder reminder) async {
    final result = await AzkarReminderService.toggleReminder(
      reminder.id,
      !reminder.isEnabled,
    );
    if (result) {
      await _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Azkar Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Reminder',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Azkar Reminders',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add reminders to get notified about your azkar',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddReminderDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Reminder'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    // We don't need to get the azkar by ID since we have the title
                    
                    return Dismissible(
                      key: Key(reminder.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteReminder(reminder);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reminder removed'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () async {
                                await AzkarReminderService.addReminder(reminder);
                                await _loadReminders();
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(reminder.title, 
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: reminder.isEnabled 
                                ? theme.textTheme.titleMedium?.color
                                : theme.disabledColor,
                            ),
                          ),
                          subtitle: Text(
                            _formatReminderTime(reminder),
                            style: TextStyle(
                              color: reminder.isEnabled
                                ? theme.textTheme.bodyMedium?.color
                                : theme.disabledColor,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(reminder.isEnabled ? 0.9 : 0.3),
                            child: Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: reminder.isEnabled,
                                onChanged: (value) => _toggleReminderEnabled(reminder),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Create a dummy AzkarModel since we don't need the actual one
                                  final dummyAzkar = AzkarModel(
                                    id: reminder.azkarId,
                                    text: reminder.title,
                                    textAr: reminder.title,
                                    count: 1,
                                  );
                                  _showReminderDetailsDialog(dummyAzkar, existingReminder: reminder);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Create a dummy AzkarModel
                            final dummyAzkar = AzkarModel(
                              id: reminder.azkarId,
                              text: reminder.title,
                              textAr: reminder.title,
                              count: 1,
                            );
                            _showReminderDetailsDialog(dummyAzkar, existingReminder: reminder);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatReminderTime(AzkarReminder reminder) {
    final time = '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}';
    final days = _formatDays(reminder.days);
    return '$time, $days';
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) {
      return 'Every day';
    }
    
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((day) => dayNames[day]).join(', ');
  }
}

class SelectAzkarDialog extends StatefulWidget {
  final List<AzkarModel> azkarItems;
  final Function(AzkarModel) onAzkarSelected;

  const SelectAzkarDialog({
    Key? key,
    required this.azkarItems,
    required this.onAzkarSelected,
  }) : super(key: key);

  @override
  State<SelectAzkarDialog> createState() => _SelectAzkarDialogState();
}

class _SelectAzkarDialogState extends State<SelectAzkarDialog> {
  String _searchQuery = '';
  
  List<AzkarModel> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return widget.azkarItems;
    }
    
    return widget.azkarItems.where((azkar) {
      return azkar.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             azkar.textAr.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Select Azkar'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search azkar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final azkar = _filteredItems[index];
                  return ListTile(
                    title: Text(
                      azkar.text.length > 50 
                          ? '${azkar.text.substring(0, 50)}...' 
                          : azkar.text,
                    ),
                    subtitle: Text(
                      azkar.reference.isNotEmpty 
                          ? azkar.reference 
                          : 'Repeat ${azkar.count} times',
                    ),
                    onTap: () => widget.onAzkarSelected(azkar),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class ReminderDetailsDialog extends StatefulWidget {
  final AzkarModel azkar;
  final AzkarReminder? reminder;
  final Function(AzkarReminder) onSave;

  const ReminderDetailsDialog({
    Key? key,
    required this.azkar,
    this.reminder,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ReminderDetailsDialog> createState() => _ReminderDetailsDialogState();
}

class _ReminderDetailsDialogState extends State<ReminderDetailsDialog> {
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;
  late TextEditingController _titleController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    
    if (widget.reminder != null) {
      _selectedTime = widget.reminder!.time;
      _isEnabled = widget.reminder!.isEnabled;
      
      // Initialize selected days (0 = Sunday, 1 = Monday, etc.)
      _selectedDays = List.generate(7, (index) => 
        widget.reminder!.days.contains(index)
      );
      
      _titleController = TextEditingController(text: widget.reminder!.title);
    } else {
      // Default values for new reminder
      _selectedTime = TimeOfDay.now();
      _isEnabled = true;
      _selectedDays = List.generate(7, (index) => true); // Default to every day
      
      // Default title is the beginning of the azkar text
      final title = widget.azkar.text.length > 30 
          ? '${widget.azkar.text.substring(0, 30)}...' 
          : widget.azkar.text;
      _titleController = TextEditingController(text: title);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (pickedTime != null && mounted) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _toggleDay(int index) {
    setState(() {
      _selectedDays[index] = !_selectedDays[index];
    });
  }

  void _saveReminder() {
    // Convert selected days boolean list to day indices
    final selectedDayIndices = <int>[];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        selectedDayIndices.add(i);
      }
    }
    
    // Validate that at least one day is selected
    if (selectedDayIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }
    
    // Create or update reminder
    final reminder = AzkarReminder(
      id: widget.reminder?.id ?? const Uuid().v4(),
      azkarId: widget.azkar.id,
      title: _titleController.text,
      time: _selectedTime,
      days: selectedDayIndices,
      isEnabled: _isEnabled,
    );
    
    widget.onSave(reminder);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.reminder != null ? 'Edit Reminder' : 'Add Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Reminder Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Repeat on:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(_getDayName(i)),
                    selected: _selectedDays[i],
                    onSelected: (_) => _toggleDay(i),
                    selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enabled'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveReminder,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[day];
  }
} 