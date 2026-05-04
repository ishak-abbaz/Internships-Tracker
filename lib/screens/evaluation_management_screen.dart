import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/evaluation_model.dart';
import '../models/intern_model.dart';
import '../models/mentor_model.dart';
import '../providers/adminInternsList_provider.dart';
import '../providers/adminMentors_provider.dart';
import '../providers/evaluation_provider.dart';
import '../theme.dart';

class EvaluationManagementScreen extends StatefulWidget {
  final bool isAdmin;
  final String? mentorId;

  const EvaluationManagementScreen({
    super.key,
    this.isAdmin = true,
    this.mentorId,
  });

  @override
  State<EvaluationManagementScreen> createState() => _EvaluationManagementScreenState();
}

class _EvaluationManagementScreenState extends State<EvaluationManagementScreen> {
  String? _selectedInternId;
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final evaluationNotifier = context.read<EvaluationNotifier>();
      if (widget.isAdmin) {
        evaluationNotifier.fetchAll();
      } else if (widget.mentorId != null) {
        _selectedMentorId = widget.mentorId;
        evaluationNotifier.fetchForMentor(widget.mentorId!);
      }
      context.read<AdminInternsListNotifier>().fetchInterns();
      context.read<AdminMentorsNotifier>().fetchMentors();
    });
  }

  void _fetchEvaluations() {
    context.read<EvaluationNotifier>().fetchFiltered(
      internId: _selectedInternId,
      mentorId: _selectedMentorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final evaluationNotifier = context.watch<EvaluationNotifier>();
    final internsNotifier = context.watch<AdminInternsListNotifier>();
    final mentorsNotifier = context.watch<AdminMentorsNotifier>();

    final interns = widget.isAdmin 
        ? internsNotifier.interns 
        : internsNotifier.interns.where((i) => i.mentorId == widget.mentorId).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Evaluations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDropdown<InternModel>(
                  label: 'Intern',
                  items: interns,
                  value: _selectedInternId,
                  itemLabel: (intern) => intern.fullName,
                  itemValue: (intern) => intern.id,
                  onChanged: (id) {
                    setState(() {
                      _selectedInternId = id;
                    });
                    _fetchEvaluations();
                  },
                ),
                const SizedBox(height: 12),
                if (widget.isAdmin)
                  _buildDropdown<MentorModel>(
                    label: 'Mentor',
                    items: mentorsNotifier.mentors,
                    value: _selectedMentorId,
                    itemLabel: (mentor) => mentor.fullName,
                    itemValue: (mentor) => mentor.id,
                    onChanged: (id) {
                      setState(() {
                        _selectedMentorId = id;
                      });
                      _fetchEvaluations();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: evaluationNotifier.isLoading
                ? const Center(child: CircularProgressIndicator())
                : evaluationNotifier.error != null
                    ? Center(child: Text(evaluationNotifier.error!, style: const TextStyle(color: AppColors.red)))
                    : evaluationNotifier.records.isEmpty
                        ? const Center(child: Text('No evaluations found', style: TextStyle(color: AppColors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: evaluationNotifier.records.length,
                            itemBuilder: (context, index) => _EvaluationTile(
                              evaluation: evaluationNotifier.records[index],
                              onEdit: () => _showEditDialog(context, evaluationNotifier.records[index]),
                              onDelete: () => _showDeleteConfirm(context, evaluationNotifier.records[index]),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.greenLight,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required String? value,
    required String Function(T) itemLabel,
    required String Function(T) itemValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 5),
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
              value: value,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    "Select $label",
                    style: const TextStyle(color: AppColors.grey),
                  ),
                ),
                ...items.map((item) => DropdownMenuItem(
                  value: itemValue(item),
                  child: Text(
                    itemLabel(item),
                    style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
                  ),
                )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final weekLabelController = TextEditingController();
    final feedbackController = TextEditingController();
    int overallMark = 60;
    String? dialogInternId = _selectedInternId;
    String? dialogMentorId = widget.isAdmin ? _selectedMentorId : widget.mentorId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Create Evaluation',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildDropdown<InternModel>(
                    label: 'Intern',
                    items: context.read<AdminInternsListNotifier>().interns,
                    value: dialogInternId,
                    itemLabel: (i) => i.fullName,
                    itemValue: (i) => i.id,
                    onChanged: (id) => setModalState(() => dialogInternId = id),
                  ),
                  if (widget.isAdmin) ...[
                    const SizedBox(height: 12),
                    _buildDropdown<MentorModel>(
                      label: 'Mentor',
                      items: context.read<AdminMentorsNotifier>().mentors,
                      value: dialogMentorId,
                      itemLabel: (m) => m.fullName,
                      itemValue: (m) => m.id,
                      onChanged: (id) => setModalState(() => dialogMentorId = id),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weekLabelController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: 'Week Label', hint: 'Week 1', icon: Icons.calendar_view_week),
                  ),
                  const SizedBox(height: 12),
                  Text('Overall Mark: $overallMark', style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: overallMark.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$overallMark',
                    activeColor: AppColors.greenLight,
                    onChanged: (value) => setModalState(() => overallMark = value.toInt()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: feedbackController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: 'Feedback', hint: 'Good progress...', icon: Icons.feedback_outlined),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (dialogInternId == null || dialogMentorId == null) return;
                      final evaluation = EvaluationModel(
                        id: '',
                        internId: dialogInternId!,
                        mentorId: dialogMentorId!,
                        weekLabel: weekLabelController.text.trim().isEmpty ? null : weekLabelController.text.trim(),
                        overallMark: overallMark,
                        feedback: feedbackController.text.trim().isEmpty ? null : feedbackController.text.trim(),
                        evaluatedAt: DateTime.now(),
                      );
                      final success = await context.read<EvaluationNotifier>().createEvaluation(evaluation);
                      if (!context.mounted) return;
                      if (success) {
                        _fetchEvaluations();
                      }
                      Navigator.pop(context);
                      showProAlert(
                        context,
                        title: success ? 'Success' : 'Error',
                        message: success ? 'Evaluation saved successfully' : context.read<EvaluationNotifier>().error ?? 'Save failed',
                        isError: !success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SAVE EVALUATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, EvaluationModel evaluation) async {
    final formKey = GlobalKey<FormState>();
    final weekLabelController = TextEditingController(text: evaluation.weekLabel);
    final feedbackController = TextEditingController(text: evaluation.feedback);
    int overallMark = evaluation.overallMark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Edit Evaluation',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Text('Intern: ${evaluation.internName ?? 'Unknown'}', style: const TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weekLabelController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: 'Week Label', hint: 'Week 1', icon: Icons.calendar_view_week),
                  ),
                  const SizedBox(height: 12),
                  Text('Overall Mark: $overallMark', style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: overallMark.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$overallMark',
                    activeColor: AppColors.greenLight,
                    onChanged: (value) => setModalState(() => overallMark = value.toInt()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: feedbackController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: 'Feedback', hint: 'Good progress...', icon: Icons.feedback_outlined),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await context.read<EvaluationNotifier>().updateEvaluation(
                            evaluationId: evaluation.id,
                            weekLabel: weekLabelController.text.trim(),
                            overallMark: overallMark,
                            feedback: feedbackController.text.trim(),
                          );
                      if (!context.mounted) return;
                      if (success) {
                        _fetchEvaluations();
                      }
                      Navigator.pop(context);
                      showProAlert(
                        context,
                        title: success ? 'Success' : 'Error',
                        message: success ? 'Evaluation updated successfully' : context.read<EvaluationNotifier>().error ?? 'Update failed',
                        isError: !success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('UPDATE EVALUATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirm(BuildContext context, EvaluationModel evaluation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Evaluation', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this evaluation?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<EvaluationNotifier>().deleteEvaluation(evaluation.id);
      if (context.mounted) {
        showProAlert(
          context,
          title: success ? 'Success' : 'Error',
          message: success ? 'Evaluation deleted' : context.read<EvaluationNotifier>().error ?? 'Delete failed',
          isError: !success,
        );
      }
    }
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

class _EvaluationTile extends StatelessWidget {
  final EvaluationModel evaluation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EvaluationTile({
    required this.evaluation,
    required this.onEdit,
    required this.onDelete,
  });

  Color _markColor(int mark) {
    if (mark >= 80) return AppColors.greenLight;
    if (mark >= 70) return AppColors.teal;
    if (mark >= 60) return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evaluation.internName ?? 'Unknown Intern',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Mentor: ${evaluation.mentorName ?? 'Unknown'}',
                      style: const TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.teal, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _markColor(evaluation.overallMark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _markColor(evaluation.overallMark).withOpacity(0.5)),
                    ),
                    child: Text(
                      '${evaluation.overallMark}%',
                      style: TextStyle(color: _markColor(evaluation.overallMark), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          if (evaluation.weekLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.greenLight),
                  const SizedBox(width: 8),
                  Text(evaluation.weekLabel!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          if (evaluation.feedback != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.comment_outlined, size: 14, color: AppColors.greenLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    evaluation.feedback!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _formatDate(evaluation.createdAt),
              style: const TextStyle(color: AppColors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day}/${date.month}/${date.year}";
  }
}
