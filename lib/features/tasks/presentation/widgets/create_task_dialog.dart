import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

// Conditional import for File
import 'dart:io' if (dart.library.html) '../../data/repositories/io_stub.dart' as io;

import '../../domain/entities/task.dart';
import '../../domain/entities/picked_file.dart';
import '../providers/task_providers.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../../projects/data/services/project_member_service.dart';
import 'image_thumbnail_widget.dart';
import '../../../../core/constants/api_endpoints.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  final String projectId;
  final Task? task;

  const CreateTaskDialog({
    super.key,
    required this.projectId,
    this.task,
  });

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _dueDate;
  int? _estimatedHours;
  String? _assigneeId;
  List<PickedFile> _selectedFiles = [];
  List<User> _availableUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _estimatedHours = widget.task!.estimatedHours;
      _assigneeId = widget.task!.assigneeId;
      _tagsController.text = widget.task!.tags.join(', ');
    }
    // Load users for assignee dropdown
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      // Try to load project members first, fallback to all users
      try {
        final members = await ProjectMemberService.getProjectMembers(widget.projectId);
        setState(() {
          _availableUsers = members;
          _isLoadingUsers = false;
        });
      } catch (e) {
        // If project members fail, load all users
        await ref.read(userStateProvider.notifier).loadUsers();
        final usersState = ref.read(userStateProvider);
        usersState.when(
          data: (users) {
            setState(() {
              _availableUsers = users.where((user) => user.isActive).toList();
              _isLoadingUsers = false;
            });
          },
          loading: () {},
          error: (error, stackTrace) {
            setState(() {
              _availableUsers = [];
              _isLoadingUsers = false;
            });
          },
        );
      }
    } catch (e) {
      setState(() {
        _availableUsers = [];
        _isLoadingUsers = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 900 ? 650.0 : screenWidth * 0.9;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Create New Task'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: dialogWidth,
          minWidth: dialogWidth,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'Enter task title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task description',
                  ),
                  maxLines: null,
                  minLines: 3,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Priority and Estimated Hours
                Column(
                  children: [
                    DropdownButtonFormField<TaskPriority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Est. Hours',
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _estimatedHours = int.tryParse(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _assigneeId,
                  decoration: InputDecoration(
                    labelText: 'Assignee',
                    suffixIcon: _isLoadingUsers
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ..._availableUsers.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text(user.fullName),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _assigneeId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(
                    _dueDate != null 
                        ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDueDate(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Enter tags separated by commas',
                  ),
                ),
                const SizedBox(height: 16),
                // File attachments section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          tooltip: 'Add Files',
                        ),
                      ],
                    ),
                    // Show existing attachments if editing
                    if (widget.task != null && widget.task!.attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final existingAttachments = widget.task!.attachments;
                          final existingImages = existingAttachments.where((url) => url.isImageUrl).toList();
                          final existingFiles = existingAttachments.where((url) => !url.isImageUrl).toList();
                          final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (existingImages.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: existingImages.map((imageUrl) {
                                    final fileName = imageUrl.split('/').last;
                                    final fullUrl = imageUrl.startsWith('http') ? imageUrl : '$baseUrl$imageUrl';
                                    return ImageThumbnailWidget(
                                      imageUrl: fullUrl,
                                      imageName: fileName,
                                      size: 30,
                                    );
                                  }).toList(),
                                ),
                                if (existingFiles.isNotEmpty || _selectedFiles.isNotEmpty) const SizedBox(height: 12),
                              ],
                              if (existingFiles.isNotEmpty) ...[
                                ...existingFiles.map((fileUrl) {
                                  final fileName = fileUrl.split('/').last;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                if (_selectedFiles.isNotEmpty) const SizedBox(height: 12),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                    // Show newly selected files
                    if (_selectedFiles.isNotEmpty) ...[
                      if (widget.task != null && widget.task!.attachments.isNotEmpty) 
                        const SizedBox(height: 8),
                      // Separate images and files
                      Builder(
                        builder: (context) {
                          final images = _selectedFiles.where((f) => f.isImage).toList();
                          final files = _selectedFiles.where((f) => !f.isImage).toList();
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image thumbnails
                              if (images.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: images.map((imageFile) {
                                    final originalIndex = _selectedFiles.indexOf(imageFile);
                                    return FutureBuilder<Uint8List?>(
                                      future: _getImageBytes(imageFile),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            ),
                                          );
                                        }
                                        return ImageThumbnailWidget(
                                          imageBytes: snapshot.data,
                                          imageName: imageFile.name,
                                          size: 30,
                                          onRemove: () {
                                            setState(() {
                                              _selectedFiles.removeAt(originalIndex);
                                            });
                                          },
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                                if (files.isNotEmpty) const SizedBox(height: 12),
                              ],
                              // Other files list
                              if (files.isNotEmpty) ...[
                                ...files.map((file) {
                                  final originalIndex = _selectedFiles.indexOf(file);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            file.name,
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 18),
                                          onPressed: () {
                                            setState(() {
                                              _selectedFiles.removeAt(originalIndex);
                                            });
                                          },
                                          tooltip: 'Remove',
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ],
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
          onPressed: _saveTask,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final platformFile in result.files) {
            if (kIsWeb) {
              // On web, use bytes
              if (platformFile.bytes != null) {
                _selectedFiles.add(PickedFile(
                  name: platformFile.name,
                  bytes: platformFile.bytes,
                ));
              }
            } else {
              // On mobile/desktop, use path
              if (platformFile.path != null) {
                _selectedFiles.add(PickedFile(
                  name: platformFile.name,
                  path: platformFile.path,
                ));
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  Future<Uint8List?> _getImageBytes(PickedFile pickedFile) async {
    if (pickedFile.isWeb) {
      return pickedFile.bytes;
    } else {
      // On mobile, read from file path
      if (kIsWeb) {
        return null;
      }
      try {
        final file = io.File(pickedFile.path!);
        return await file.readAsBytes();
      } catch (e) {
        return null;
      }
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskNotifier = ref.read(taskNotifierProvider.notifier);
      
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      
      final files = _selectedFiles.isNotEmpty ? _selectedFiles : null;
      
      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          assigneeId: _assigneeId,
          dueDate: _dueDate,
          estimatedHours: _estimatedHours,
          tags: tags,
          updatedAt: DateTime.now(),
        );
        taskNotifier.updateTask(updatedTask, pickedFiles: files);
      } else {
        // Create new task
        final newTask = Task.create(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          projectId: widget.projectId,
          priority: _selectedPriority,
          assigneeId: _assigneeId,
          dueDate: _dueDate,
          tags: tags,
          estimatedHours: _estimatedHours,
        );
        taskNotifier.createTask(newTask, pickedFiles: files);
      }
      
      Navigator.of(context).pop();
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 
 