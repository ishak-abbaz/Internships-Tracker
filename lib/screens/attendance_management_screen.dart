import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/adminInternsList_provider.dart';
import '../theme.dart';

class AttendanceManagementScreen extends StatefulWidget {
  final String? mentorId;
  const AttendanceManagementScreen({super.key, this.mentorId});

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  String? _selectedInternId;
  DateTime _viewDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminInternsListNotifier>().fetchInterns();
      context.read<AttendanceNotifier>().fetchAll();
    });
  }

  void _fetchAttendance() {
    final notifier = context.read<AttendanceNotifier>();
    if (_selectedInternId == null) {
      notifier.clearStats(); // Clear stats when no intern is selected
      notifier.fetchAll();
      return;
    }
    notifier.fetchForIntern(_selectedInternId!);
    notifier.fetchStats(_selectedInternId!);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AttendanceNotifier>();
    final internsNotifier = context.watch<AdminInternsListNotifier>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('ATTENDANCE TRACKER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.greenLight),
            onPressed: _fetchAttendance,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader("Management"),
                  const SizedBox(height: 16),
                  _buildInternSelection(internsNotifier),
                  const SizedBox(height: 16),
                  if (notifier.stats != null && _selectedInternId != null)
                    _buildStatsDashboard(notifier),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: notifier.isLoading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : notifier.records.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                            child: Text('No records for this intern',
                                style: TextStyle(color: AppColors.greyDark))))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _AttendanceListItem(
                            record: notifier.records[index],
                            onEdit: () => _showMarkDialog(context, existing: notifier.records[index]),
                            onDelete: () => _confirmDelete(context, notifier.records[index]),
                          ),
                          childCount: notifier.records.length,
                        ),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        onPressed: () => _showMarkDialog(context),
        label: const Text("MARK ATTENDANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInternSelection(AdminInternsListNotifier internsNotifier) {
    final interns = widget.mentorId == null 
        ? internsNotifier.interns 
        : internsNotifier.interns.where((i) => i.mentorId == widget.mentorId).toList();

    return glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          dropdownColor: AppColors.surface,
          value: _selectedInternId,
          hint: const Text("All Interns", style: TextStyle(color: Colors.white)),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.people_outline, size: 18, color: AppColors.greenLight),
                  SizedBox(width: 12),
                  Text("All Interns", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            ...interns.map((intern) {
              return DropdownMenuItem<String?>(
                value: intern.id,
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: AppColors.greenLight),
                    const SizedBox(width: 12),
                    Text(intern.fullName, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }),
          ],
          onChanged: (val) {
            setState(() => _selectedInternId = val);
            context.read<AttendanceNotifier>().clearStats(); // Clear stats before fetching new ones
            _fetchAttendance();
          },
        ),
      ),
    );
  }

  Widget _buildStatsDashboard(AttendanceNotifier notifier) {
    final stats = notifier.stats!;
    // The backend returns statistics in a format like { total, byStatus: [{status, count, percentage}] }
    // We map these safely.
    int getCount(String status) {
      final list = stats['byStatus'] as List?;
      final item = list?.firstWhere((e) => e['status'] == status, orElse: () => null);
      return item?['count'] ?? 0;
    }

    return Row(
      children: [
        Expanded(
          child: _statCard("Present", getCount('present').toString(), AppColors.greenLight, Icons.check_circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Absent", getCount('absent').toString(), AppColors.red, Icons.cancel),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Late", getCount('late').toString(), AppColors.orange, Icons.access_time),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return glassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AttendanceModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Delete Record", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to remove this attendance entry?", style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<AttendanceNotifier>().deleteAttendance(record.id);
      if (success) _fetchAttendance();
    }
  }

  Future<void> _showMarkDialog(BuildContext context, {AttendanceModel? existing}) async {
    if (_selectedInternId == null && existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an intern first")));
      return;
    }

    final formKey = GlobalKey<FormState>();
    String status = existing?.status ?? 'present';
    final notesController = TextEditingController(text: existing?.notes);
    DateTime selectedDate = existing?.attendanceDate ?? DateTime.now();
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text(existing == null ? 'MARK ATTENDANCE' : 'EDIT RECORD',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.2)),
                const SizedBox(height: 24),
                
                // Date Selector
                GestureDetector(
                  onTap: () async {
                    if (existing != null) return; // Date is immutable on update
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setModalState(() => selectedDate = picked);
                  },
                  child: glassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.greenLight),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Attendance Date", style: TextStyle(color: AppColors.grey, fontSize: 11)),
                            Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        if (existing == null) const Icon(Icons.edit, size: 16, color: AppColors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: AppColors.surface,
                  items: const ['present', 'absent', 'late', 'excused']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13))))
                      .toList(),
                  onChanged: (value) => status = value ?? 'present',
                  decoration: proLinkInputDecoration(label: "Status", hint: "", icon: Icons.verified_user),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: notesController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Notes / Observation", hint: "e.g. Arrived 10 mins late", icon: Icons.notes),
                ),
                const SizedBox(height: 32),

                GradientButton(
                  label: existing == null ? "SAVE ATTENDANCE" : "UPDATE RECORD",
                  isLoading: isSaving,
                  onTap: () async {
                    setModalState(() => isSaving = true);
                    final notifier = context.read<AttendanceNotifier>();
                    bool success;
                    
                    if (existing == null) {
                      success = await notifier.createAttendance(AttendanceModel(
                        id: '',
                        internId: _selectedInternId!,
                        mentorId: widget.mentorId ?? '',
                        attendanceDate: selectedDate,
                        status: status,
                        notes: notesController.text.trim(),
                      ));
                    } else {
                      success = await notifier.updateAttendance(
                        attendanceId: existing.id,
                        status: status,
                        notes: notesController.text.trim(),
                      );
                    }

                    if (!context.mounted) return;
                    setModalState(() => isSaving = false);
                    if (success) {
                      _fetchAttendance();
                      Navigator.pop(context);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? 'Attendance processed' : notifier.error ?? 'Error occurred'),
                      backgroundColor: success ? AppColors.green : AppColors.red,
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceListItem extends StatelessWidget {
  final AttendanceModel record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AttendanceListItem({required this.record, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (record.status.toLowerCase()) {
      case 'present': statusColor = AppColors.greenLight; statusIcon = Icons.check_circle; break;
      case 'absent': statusColor = AppColors.red; statusIcon = Icons.cancel; break;
      case 'late': statusColor = AppColors.orange; statusIcon = Icons.access_time; break;
      default: statusColor = AppColors.teal; statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: glassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (record.internName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(record.internName!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  Text(record.status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text("${record.attendanceDate.day}/${record.attendanceDate.month}/${record.attendanceDate.year}",
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                  if (record.notes != null && record.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(record.notes!, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_note, color: AppColors.grey), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
