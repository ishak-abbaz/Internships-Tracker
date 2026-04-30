import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import '../theme.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  final AttendanceNotifier _notifier = AttendanceNotifier();
  final TextEditingController _internIdController = TextEditingController();
  final TextEditingController _mentorIdController = TextEditingController();

  @override
  void dispose() {
    _internIdController.dispose();
    _mentorIdController.dispose();
    super.dispose();
  }

  void _fetchAttendance() {
    final internId = _internIdController.text.trim();
    if (internId.isEmpty) return;
    _notifier.fetchForIntern(internId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Attendance'),
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
                controller: _internIdController,
                label: 'Intern ID',
                icon: Icons.badge_rounded,
                onSubmitted: (_) => _fetchAttendance(),
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: _mentorIdController,
                label: 'Mentor ID',
                icon: Icons.school_rounded,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Load Attendance', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_notifier.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_notifier.error != null)
                Text(_notifier.error ?? 'Error', style: const TextStyle(color: AppColors.red))
              else if (_notifier.records.isEmpty)
                const Text('No attendance records', style: TextStyle(color: AppColors.grey))
              else
                ..._notifier.records.map(_AttendanceTile.new),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.greenLight,
        onPressed: () => _showMarkDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _showMarkDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String status = 'present';
    final notesController = TextEditingController();

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
              const Text('Mark Attendance',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _inputField(
                controller: _internIdController,
                label: 'Intern ID',
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: _mentorIdController,
                label: 'Mentor ID',
                icon: Icons.school_rounded,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                dropdownColor: AppColors.surface,
                items: const ['present', 'absent', 'late', 'excused']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => status = value ?? 'present',
                decoration: const InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final attendance = AttendanceModel(
                    id: '',
                    internId: _internIdController.text.trim(),
                    mentorId: _mentorIdController.text.trim(),
                    attendanceDate: DateTime.now(),
                    status: status,
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  final success = await _notifier.createAttendance(attendance);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Attendance saved' : _notifier.error ?? 'Save failed'),
                      backgroundColor: success ? AppColors.green : AppColors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
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

class _AttendanceTile extends StatelessWidget {
  final AttendanceModel record;

  const _AttendanceTile(this.record);

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${record.status}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Date: ${record.attendanceDate.toLocal().toString().split(" ").first}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          if (record.notes != null)
            const Icon(Icons.sticky_note_2_outlined, color: AppColors.greenLight),
        ],
      ),
    );
  }
}
