import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/internship_assignment_model.dart';
import '../models/intern_model.dart';
import '../models/mentor_model.dart';
import '../models/department_model.dart';
import '../providers/internship_assignment_provider.dart';
import '../providers/adminInternsList_provider.dart';
import '../providers/adminMentors_provider.dart';
import '../providers/adminDepartments_provider.dart';
import '../theme.dart';

class InternAssignmentScreen extends StatefulWidget {
  const InternAssignmentScreen({super.key});

  @override
  State<InternAssignmentScreen> createState() => _InternAssignmentScreenState();
}

class _InternAssignmentScreenState extends State<InternAssignmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternshipAssignmentNotifier>().fetchAssignments();
      context.read<AdminInternsListNotifier>().fetchInterns();
      context.read<AdminMentorsNotifier>().fetchMentors();
      context.read<AdminDepartmentsNotifier>().fetchDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<InternshipAssignmentNotifier>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Intern Assignments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.greenLight),
            onPressed: () {
              notifier.fetchAssignments();
              context.read<AdminInternsListNotifier>().fetchInterns();
              context.read<AdminMentorsNotifier>().fetchMentors();
              context.read<AdminDepartmentsNotifier>().fetchDepartments();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (notifier.isLoading && notifier.assignments.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.green));
          }

          if (notifier.error != null && notifier.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red),
                  const SizedBox(height: 16),
                  Text(
                    notifier.error ?? 'Failed to load assignments',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => notifier.fetchAssignments(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notifier.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind_outlined, size: 64, color: AppColors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No assignments found', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await notifier.fetchAssignments();
              await context.read<AdminInternsListNotifier>().fetchInterns();
              await context.read<AdminMentorsNotifier>().fetchMentors();
              await context.read<AdminDepartmentsNotifier>().fetchDepartments();
            },
            color: AppColors.green,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifier.assignments.length,
              itemBuilder: (context, index) {
                final item = notifier.assignments[index];
                return _AssignmentCard(
                  assignment: item,
                  onEdit: () => _showAssignmentDialog(context, assignment: item),
                  onDelete: () async {
                    final confirmed = await _confirmDelete(context);
                    if (!confirmed) return;
                    final success = await notifier.deleteAssignment(item.id);
                    if (!context.mounted) return;
                    showProAlert(
                      context,
                      title: success ? 'Success' : 'Error',
                      message: success ? 'Assignment deleted successfully' : notifier.error ?? 'Delete failed',
                      isError: !success,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        onPressed: () => _showAssignmentDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAssignmentDialog(BuildContext context, {InternshipAssignmentModel? assignment}) async {
    final isEditing = assignment != null;
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController(text: assignment?.subject);
    
    String? selectedInternId = assignment?.internId;
    String? selectedMentorId = assignment?.mentorId;
    String? selectedDeptId = assignment?.departmentId;
    DateTime? startDate = assignment?.startDate;
    DateTime? endDate = assignment?.endDate;

    final notifier = context.read<InternshipAssignmentNotifier>();
    final interns = context.read<AdminInternsListNotifier>().interns;
    final mentors = context.read<AdminMentorsNotifier>().mentors;
    final departments = context.read<AdminDepartmentsNotifier>().departments;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Update Assignment' : 'New Assignment',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!isEditing) ...[
                    _buildInputLabel('Select Intern'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedInternId,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: Colors.white),
                      decoration: proLinkInputDecoration(
                        label: 'Intern',
                        hint: 'Select an intern',
                        icon: Icons.person_outline_rounded,
                      ),
                      items: interns.map((intern) {
                        return DropdownMenuItem(
                          value: intern.id,
                          child: Text(intern.fullName, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) => setModalState(() => selectedInternId = v),
                      validator: (v) => v == null ? 'Please select an intern' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildInputLabel('Mentor & Department'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedMentorId,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                      label: 'Mentor',
                      hint: 'Select a mentor',
                      icon: Icons.school_outlined,
                    ),
                    items: mentors.map((mentor) {
                      return DropdownMenuItem(
                        value: mentor.id,
                        child: Text(mentor.fullName, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setModalState(() => selectedMentorId = v),
                    validator: (v) => v == null ? 'Please select a mentor' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDeptId,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                      label: 'Department',
                      hint: 'Select a department',
                      icon: Icons.business_outlined,
                    ),
                    items: departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept.id,
                        child: Text(dept.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setModalState(() => selectedDeptId = v),
                    validator: (v) => v == null ? 'Please select a department' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('Internship Details'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: subjectController,
                    decoration: proLinkInputDecoration(
                      label: 'Subject',
                      hint: 'e.g. Flutter Development',
                      icon: Icons.subject_rounded,
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => v!.isEmpty ? 'Subject is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.green,
                                    onPrimary: Colors.white,
                                    surface: AppColors.surface,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) setModalState(() => startDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Date', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  startDate == null ? 'Select' : DateFormat('MMM dd, yyyy').format(startDate!),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? startDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.green,
                                    onPrimary: Colors.white,
                                    surface: AppColors.surface,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) setModalState(() => endDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Date', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  endDate == null ? 'Select' : DateFormat('MMM dd, yyyy').format(endDate!),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: isEditing ? 'Update Assignment' : 'Create Assignment',
                    isLoading: notifier.isLoading,
                    onTap: () async {
                      if (!formKey.currentState!.validate()) return;
                    if (startDate == null || endDate == null) {
                        showProAlert(
                          context,
                          title: 'Missing Dates',
                          message: 'Please select start and end dates',
                          isError: true,
                        );
                        return;
                      }

                      bool success;
                      if (isEditing) {
                        success = await notifier.updateAssignment(
                          assignment.id,
                          {
                            if (selectedMentorId != null) 'mentor_id': selectedMentorId,
                            if (selectedDeptId != null) 'department_id': selectedDeptId,
                            'subject': subjectController.text.trim(),
                            if (startDate != null) 'start_date': startDate!.toIso8601String(),
                            if (endDate != null) 'end_date': endDate!.toIso8601String(),
                          },
                        );
                      } else {
                        success = await notifier.createAssignment(
                          internId: selectedInternId!,
                          mentorId: selectedMentorId!,
                          departmentId: selectedDeptId!,
                          subject: subjectController.text.trim(),
                          startDate: startDate!,
                          endDate: endDate!,
                        );
                      }

                      if (!context.mounted) return;
                      if (success) {
                        Navigator.pop(context);
                        showProAlert(
                          context,
                          title: 'Success',
                          message: isEditing ? 'Assignment updated successfully' : 'Assignment created successfully',
                        );
                      } else {
                        showProAlert(
                          context,
                          title: 'Error',
                          message: notifier.error ?? 'Action failed',
                          isError: true,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.greenLight,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
        title: const Text('Remove Assignment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this assignment? This will remove the link between the intern and the mentor.',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _AssignmentCard extends StatelessWidget {
  final InternshipAssignmentModel assignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AssignmentCard({required this.assignment, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.subject,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 14, color: AppColors.greenLight),
                          const SizedBox(width: 4),
                          Text(
                            '${assignment.startDate != null ? df.format(assignment.startDate!) : "N/A"} - ${assignment.endDate != null ? df.format(assignment.endDate!) : "N/A"}',
                            style: const TextStyle(color: AppColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, color: AppColors.greenLight, size: 22),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 22),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            _infoRow(Icons.person_outline, 'Intern', assignment.internName ?? assignment.internId),
            const SizedBox(height: 8),
            _infoRow(Icons.school_outlined, 'Mentor', assignment.mentorName ?? assignment.mentorId),
            const SizedBox(height: 8),
            _infoRow(Icons.business_outlined, 'Dept', assignment.departmentName ?? assignment.departmentId ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
