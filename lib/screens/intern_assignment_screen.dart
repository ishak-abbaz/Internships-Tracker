import 'package:flutter/material.dart';
import '../models/intern_assignment_model.dart';
import '../providers/internAssignment_provider.dart';
import '../theme.dart';

class InternAssignmentScreen extends StatefulWidget {
  const InternAssignmentScreen({super.key});

  @override
  State<InternAssignmentScreen> createState() => _InternAssignmentScreenState();
}

class _InternAssignmentScreenState extends State<InternAssignmentScreen> {
  final InternAssignmentNotifier _notifier = InternAssignmentNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.fetchAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Intern Assignments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _notifier,
        builder: (context, child) {
          if (_notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_notifier.error != null) {
            return Center(
              child: Text(
                _notifier.error ?? 'Failed to load assignments',
                style: const TextStyle(color: AppColors.red),
              ),
            );
          }

          if (_notifier.assignments.isEmpty) {
            return const Center(
              child: Text('No assignments found', style: TextStyle(color: AppColors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notifier.assignments.length,
            itemBuilder: (context, index) {
              final item = _notifier.assignments[index];
              return _AssignmentCard(
                assignment: item,
                onDelete: () async {
                  final confirmed = await _confirmDelete(context);
                  if (!confirmed) return;
                  final success = await _notifier.deleteAssignment(item.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Assignment deleted' : _notifier.error ?? 'Delete failed'),
                      backgroundColor: success ? AppColors.green : AppColors.red,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.greenLight,
        onPressed: () => _showCreateAssignmentDialog(context),
        child: const Icon(Icons.person_add_alt_1, color: Colors.black),
      ),
    );
  }

  Future<void> _showCreateAssignmentDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final internIdController = TextEditingController();
    final mentorNameController = TextEditingController();
    final departmentCodeController = TextEditingController();

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
              const Text('Assign Intern',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _inputField(controller: internIdController, label: 'Intern ID', icon: Icons.badge_rounded),
              const SizedBox(height: 12),
              _inputField(controller: mentorNameController, label: 'Mentor Full Name', icon: Icons.school_rounded),
              const SizedBox(height: 12),
              _inputField(controller: departmentCodeController, label: 'Department Code', icon: Icons.domain_rounded),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final success = await _notifier.createAssignment(
                    internId: internIdController.text.trim(),
                    mentorName: mentorNameController.text.trim(),
                    departmentCode: departmentCodeController.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Assignment created' : _notifier.error ?? 'Create failed'),
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
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
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

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete assignment?', style: TextStyle(color: Colors.white)),
        content: const Text('This cannot be undone.', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return result ?? false;
  }
}

class _AssignmentCard extends StatelessWidget {
  final InternAssignmentModel assignment;
  final VoidCallback onDelete;

  const _AssignmentCard({required this.assignment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assignment ID: ${assignment.id}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Intern: ${assignment.internId}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          Text('Mentor: ${assignment.mentorId}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          Text('Department: ${assignment.departmentId}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
