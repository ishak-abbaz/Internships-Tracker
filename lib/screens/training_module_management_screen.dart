import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/training_module_model.dart';
import '../providers/trainingModule_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/adminDepartments_provider.dart';
import '../theme.dart';

class TrainingModuleManagementScreen extends StatefulWidget {
  final String? mentorId;
  final bool isAdmin;
  const TrainingModuleManagementScreen({super.key, this.mentorId, this.isAdmin = false});

  @override
  State<TrainingModuleManagementScreen> createState() => _TrainingModuleManagementScreenState();
}

class _TrainingModuleManagementScreenState extends State<TrainingModuleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
      context.read<AdminDepartmentsNotifier>().fetchDepartments();
    });
  }

  void _refresh() {
    final notifier = context.read<TrainingModuleNotifier>();
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    if (widget.isAdmin || user.userRole == 'Admin') {
      notifier.fetchAllAdmin();
    } else if (user.userRole == 'Mentor') {
      if (widget.mentorId != null) {
        notifier.fetchForMentor(widget.mentorId!);
      } else {
        notifier.fetchAllAdmin(); // Mentors should also see all modules if they are to manage them
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TrainingModuleNotifier>();
    final user = context.watch<AuthProvider>().currentUser;
    final bool canManage = widget.isAdmin || user?.userRole == 'Admin' || user?.userRole == 'Mentor';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('TRAINING MODULES'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (notifier.isLoading && notifier.modules.isEmpty)
              const Center(child: CircularProgressIndicator(color: AppColors.greenLight))
            else if (notifier.error != null && notifier.modules.isEmpty)
              _buildErrorState(notifier.error!)
            else if (notifier.modules.isEmpty)
              _buildEmptyState()
            else
              ...notifier.modules.map((m) => _ModuleCard(
                    module: m,
                    onEdit: canManage ? () => _showEditDialog(m) : null,
                    onDelete: canManage ? () => _confirmDelete(m) : null,
                  )),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              backgroundColor: AppColors.green,
              onPressed: () => _showCreateDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.error_outline, color: AppColors.red, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
          TextButton(onPressed: _refresh, child: const Text('Retry', style: TextStyle(color: AppColors.greenLight))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.library_books_outlined, color: AppColors.grey.withOpacity(0.3), size: 64),
          const SizedBox(height: 16),
          const Text('No training modules found', style: TextStyle(color: AppColors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    _showFormDialog();
  }

  void _showEditDialog(TrainingModuleModel module) {
    _showFormDialog(module: module);
  }

  void _showFormDialog({TrainingModuleModel? module}) {
    final isEditing = module != null;
    final titleController = TextEditingController(text: module?.title);
    final descController = TextEditingController(text: module?.description);
    final urlController = TextEditingController(text: module?.url);
    String? selectedDeptCode = module?.departmentCode;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final deptsNotifier = context.watch<AdminDepartmentsNotifier>();
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit Module' : 'New Training Module',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: proLinkInputDecoration(label: 'Title', hint: 'e.g. Intro to Docker', icon: Icons.title),
                      validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: proLinkInputDecoration(label: 'Description', hint: 'Short module summary', icon: Icons.description),
                      validator: (v) => v == null || v.isEmpty ? 'Description required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: urlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: proLinkInputDecoration(label: 'Resource URL', hint: 'Google Drive / PDF Link', icon: Icons.link),
                      validator: (v) => v == null || v.isEmpty ? 'URL required' : null,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          hint: const Text("Select Department", style: TextStyle(color: AppColors.grey)),
                          value: deptsNotifier.departments.any((d) => d.code == selectedDeptCode) ? selectedDeptCode : null,
                          items: deptsNotifier.departments.fold<List<DropdownMenuItem<String>>>(
                            [],
                            (list, dept) {
                              if (!list.any((item) => item.value == dept.code)) {
                                list.add(DropdownMenuItem(
                                  value: dept.code,
                                  child: Text(dept.name, style: const TextStyle(color: Colors.white)),
                                ));
                              }
                              return list;
                            },
                          ),
                          onChanged: (val) => setModalState(() => selectedDeptCode = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: isEditing ? 'Update Module' : 'Create Module',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedDeptCode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a department')));
                          return;
                        }
                        
                        final notifier = context.read<TrainingModuleNotifier>();
                        bool success;
                        if (isEditing) {
                          success = await notifier.updateModule(module.id, {
                            'title': titleController.text,
                            'description': descController.text,
                            'url': urlController.text,
                            'departmentCode': selectedDeptCode,
                          });
                        } else {
                          success = await notifier.createModule(
                            title: titleController.text,
                            description: descController.text,
                            url: urlController.text,
                            departmentCode: selectedDeptCode!,
                          );
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          showProAlert(
                            context,
                            title: success ? (isEditing ? 'Updated' : 'Created') : 'Error',
                            message: success 
                                ? 'Training module has been ${isEditing ? 'updated' : 'created'} successfully.' 
                                : (notifier.error ?? 'Failed to process request'),
                            isError: !success,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(TrainingModuleModel module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Module?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${module.title}"?', style: const TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<TrainingModuleNotifier>().deleteModule(module.id);
              if (mounted) {
                showProAlert(
                  context,
                  title: success ? 'Deleted' : 'Error',
                  message: success ? 'The module has been removed.' : 'Delete failed',
                  isError: !success,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final TrainingModuleModel module;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ModuleCard({required this.module, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: glassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    module.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (onEdit != null)
                  IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_note, color: AppColors.greenLight)),
                if (onDelete != null)
                  IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: AppColors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              module.description,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(module.departmentCode, AppColors.gold),
                if (module.mentorEmail != null)
                  Expanded(
                    child: Text(
                      'By: ${module.mentorEmail}',
                      style: const TextStyle(color: AppColors.grey, fontSize: 11),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}