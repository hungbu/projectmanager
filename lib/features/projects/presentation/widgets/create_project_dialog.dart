import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

class CreateProjectDialog extends ConsumerStatefulWidget {
  final Project? project;

  const CreateProjectDialog({super.key, this.project});

  @override
  ConsumerState<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ProjectStatus _selectedStatus = ProjectStatus.active;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedColor;

  final List<String> _colorOptions = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#96CEB4', // Green
    '#FFEAA7', // Yellow
    '#DDA0DD', // Plum
    '#98D8C8', // Mint
    '#F7DC6F', // Gold
  ];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _selectedStatus = widget.project!.status;
      _startDate = widget.project!.startDate;
      _endDate = widget.project!.endDate;
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Project' : 'Create New Project'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'Enter project name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProjectStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: ProjectStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 400) {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Start Date'),
                              subtitle: Text(
                                _startDate != null 
                                    ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                    : 'Not set',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selectDate(true),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('End Date'),
                              subtitle: Text(
                                _endDate != null 
                                    ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                    : 'Not set',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selectDate(false),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(
                              _startDate != null 
                                  ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                  : 'Not set',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(true),
                          ),
                          ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(
                              _endDate != null 
                                  ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                  : 'Not set',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(false),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Project Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _colorOptions.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProject,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final projectNotifier = ref.read(projectNotifierProvider.notifier);
      
      if (widget.project != null) {
        // Update existing project
        final updatedProject = widget.project!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          color: _selectedColor,
          updatedAt: DateTime.now(),
        );
        projectNotifier.updateProject(updatedProject);
      } else {
        // Create new project
        final newProject = Project.create(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          ownerId: 'current_user_id', // TODO: Get from auth
          startDate: _startDate,
          endDate: _endDate,
          color: _selectedColor,
        );
        projectNotifier.createProject(newProject);
      }
      
      Navigator.of(context).pop();
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
} 