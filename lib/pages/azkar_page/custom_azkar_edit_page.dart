import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:prayer/models/custom_azkar_model.dart';
import 'package:prayer/utils/custom_azkar_service.dart';
import 'package:prayer/generated/l10n/app_localizations.dart';

class CustomAzkarEditPage extends StatefulWidget {
  final CustomAzkar? azkar;

  const CustomAzkarEditPage({Key? key, this.azkar}) : super(key: key);

  @override
  State<CustomAzkarEditPage> createState() => _CustomAzkarEditPageState();
}

class _CustomAzkarEditPageState extends State<CustomAzkarEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _arabicTitleController = TextEditingController();
  
  String _id = '';
  Color _selectedColor = Colors.blue;
  String _selectedIconName = 'menu_book';
  List<CustomDhikrItem> _items = [];
  bool _isEditing = false;
  bool _isSaving = false;

  // Available icons
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'menu_book', 'icon': Icons.menu_book},
    {'name': 'sunny_snowing', 'icon': Icons.sunny_snowing},
    {'name': 'nights_stay_outlined', 'icon': Icons.nights_stay_outlined},
    {'name': 'bed', 'icon': Icons.bed},
    {'name': 'wb_sunny_outlined', 'icon': Icons.wb_sunny_outlined},
    {'name': 'done_all', 'icon': Icons.done_all},
    {'name': 'book_outlined', 'icon': Icons.book_outlined},
    {'name': 'book', 'icon': Icons.book},
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'star', 'icon': Icons.star},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.azkar != null;
    
    if (_isEditing) {
      // Load existing azkar data
      final azkar = widget.azkar!;
      _id = azkar.id;
      _titleController.text = azkar.title;
      _arabicTitleController.text = azkar.arabicTitle;
      _items = List.from(azkar.items);
      
      // Load color
      if (azkar.color != null) {
        try {
          _selectedColor = Color(int.parse(azkar.color!));
        } catch (e) {
          // Use default color if parsing fails
        }
      }
      
      // Load icon
      if (azkar.icon != null && _availableIcons.any((item) => item['name'] == azkar.icon)) {
        _selectedIconName = azkar.icon!;
      }
    } else {
      // Generate a new ID for a new azkar
      _id = CustomAzkarService.generateUniqueId();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _arabicTitleController.dispose();
    super.dispose();
  }

  Future<void> _saveAzkar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.addItemsFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });

    final azkar = CustomAzkar(
      id: _id,
      title: _titleController.text.trim(),
      arabicTitle: _arabicTitleController.text.trim(),
      items: _items,
      color: _selectedColor.value.toString(),
      icon: _selectedIconName,
    );

    bool success;
    if (_isEditing) {
      success = await CustomAzkarService.updateCustomAzkar(azkar);
    } else {
      success = await CustomAzkarService.addCustomAzkar(azkar);
    }

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSaving),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomDhikrItemEditPage(
          onSave: (item) {
            setState(() {
              _items.add(item);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _editItem(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomDhikrItemEditPage(
          item: _items[index],
          onSave: (item) {
            setState(() {
              _items[index] = item;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _removeItem(int index) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.delete),
        content: Text(loc.deleteItemConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openColorPicker() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.selectColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _selectIcon() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.selectIcon),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableIcons.map((item) {
              final isSelected = _selectedIconName == item['name'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIconName = item['name'] as String;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 36,
                    color: isSelected ? _selectedColor : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? loc.editAzkar : loc.createAzkar),
        actions: [
          IconButton(
            icon: Icon(_isSaving ? Icons.hourglass_top : Icons.check),
            onPressed: _isSaving ? null : _saveAzkar,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title & Arabic Title Fields
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.basicInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: loc.title,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _arabicTitleController,
                      decoration: InputDecoration(
                        labelText: loc.arabicTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Color & Icon Selection
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.appearance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.color_lens),
                            label: Text(loc.selectColor),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _openColorPicker,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(_availableIcons
                                .firstWhere((item) => item['name'] == _selectedIconName)['icon'] as IconData),
                            label: Text(loc.selectIcon),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _selectIcon,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Items Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.items,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(loc.addItem),
                          onPressed: _addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.note_add_outlined,
                                size: 48,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loc.noItemsYet,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: theme.colorScheme.surface,
                            child: ListTile(
                              title: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  item.arabic,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: Text(
                                '${loc.repeat}: ${item.repeat}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editItem(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                              onTap: () => _editItem(index),
                            ),
                          );
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
}

class CustomDhikrItemEditPage extends StatefulWidget {
  final CustomDhikrItem? item;
  final Function(CustomDhikrItem) onSave;

  const CustomDhikrItemEditPage({
    Key? key,
    this.item,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CustomDhikrItemEditPage> createState() => _CustomDhikrItemEditPageState();
}

class _CustomDhikrItemEditPageState extends State<CustomDhikrItemEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _arabicController = TextEditingController();
  final _translationController = TextEditingController();
  int _repeat = 1;
  String _id = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.item != null;
    
    if (_isEditing) {
      _id = widget.item!.id;
      _arabicController.text = widget.item!.arabic;
      _translationController.text = widget.item!.translation;
      _repeat = widget.item!.repeat;
    } else {
      _id = DateTime.now().millisecondsSinceEpoch.toString();
      _translationController.text = 'One time';
    }
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final item = CustomDhikrItem(
      id: _id,
      arabic: _arabicController.text.trim(),
      translation: _translationController.text.trim(),
      repeat: _repeat,
    );
    
    widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? loc.editItem : loc.addItem),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveItem,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.arabicText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _arabicController,
                      maxLines: 5,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: loc.enterArabicText,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.settings,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _translationController,
                      decoration: InputDecoration(
                        labelText: loc.description,
                        border: const OutlineInputBorder(),
                        hintText: 'e.g., "3 times", "One time"',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      "${loc.repeat}: $_repeat",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _repeat.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: _repeat.toString(),
                      onChanged: (value) {
                        setState(() {
                          _repeat = value.round();
                        });
                      },
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 3, 7, 10, 33, 99].map((presetValue) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _repeat = presetValue;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(40, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                backgroundColor: _repeat == presetValue
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surfaceVariant,
                                foregroundColor: _repeat == presetValue
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              child: Text(presetValue.toString()),
                            ),
                          );
                        }).toList(),
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
} 