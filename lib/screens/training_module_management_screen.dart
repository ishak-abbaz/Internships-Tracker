import 'package:flutter/material.dart';
import '../models/training_module_model.dart';
import '../providers/trainingModule_provider.dart';
import '../theme.dart';

class TrainingModuleManagementScreen extends StatefulWidget {
  const TrainingModuleManagementScreen({super.key});

  @override
  State<TrainingModuleManagementScreen> createState() => _TrainingModuleManagementScreenState();
}

class _TrainingModuleManagementScreenState extends State<TrainingModuleManagementScreen> {
  final TrainingModuleNotifier _notifier = TrainingModuleNotifier();
  final TextEditingController _departmentCodeController = TextEditingController();

  @override
  void dispose() {
    _departmentCodeController.dispose();
    super.dispose();
  }

  void _fetchModules() {
    final code = _departmentCodeController.text.trim();
    if (code.isEmpty) return;
    _notifier.fetchForDepartment(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Training Modules'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _notifier,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _inputField(
                controller: _departmentCodeController,
                label: 'Department Code',
                icon: Icons.domain_rounded,
                onSubmitted: (_) => _fetchModules(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchModules,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Load Modules', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_notifier.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_notifier.error != null)
                Text(_notifier.error ?? 'Error', style: const TextStyle(color: AppColors.red))
              else if (_notifier.modules.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.library_books_outlined, size: 48, color: AppColors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No modules found for this department',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._notifier.modules.map(_ModuleTile.new),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.greenLight,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create Module',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _inputField(controller: titleController, label: 'Title', icon: Icons.title_rounded),
              const SizedBox(height: 12),
              _inputField(
                controller: descriptionController,
                label: 'Description',
                icon: Icons.description_rounded,
              ),
              const SizedBox(height: 12),
              _inputField(controller: urlController, label: 'URL', icon: Icons.link_rounded),
              const SizedBox(height: 12),
              _inputField(
                controller: _departmentCodeController,
                label: 'Department Code',
                icon: Icons.domain_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final success = await _notifier.createModule(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    url: urlController.text.trim(),
                    departmentCode: _departmentCodeController.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Module created' : _notifier.error ?? 'Create failed'),
                      backgroundColor: success ? AppColors.green : AppColors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Create', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      onFieldSubmitted: onSubmitted,
      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey),
        prefixIcon: Icon(icon, color: AppColors.greenLight),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final TrainingModuleModel module;

  const _ModuleTile(this.module);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(module.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(module.description, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Dept: ${module.departmentCode}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
