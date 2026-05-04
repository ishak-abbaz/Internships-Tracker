import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/intern_models.dart';
import 'providers/intern_provider.dart';
import 'theme.dart';

String _nonEmpty(String? value, [String fallback = 'N/A']) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'N/A';
  }
  final local = date.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String _yesNo(bool? value) {
  if (value == null) {
    return 'N/A';
  }
  return value ? 'Yes' : 'No';
}

Future<void> _openExternalUrl(BuildContext context, String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No schedule file available.')),
    );
    return;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid schedule URL.')),
    );
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the schedule in the browser.')),
    );
  }
}

double _averageMark(List<InternEvaluationModel> evaluations) {
  if (evaluations.isEmpty) {
    return 0;
  }
  final total = evaluations.fold<double>(0, (sum, item) => sum + item.overallMark);
  return total / evaluations.length;
}

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InternProvider>().loadDashboardData();
      }
    });
  }

  List<Widget> get _pages => [
        InternHomeContent(onProfileTap: () => setState(() => _selectedIndex = 3)),
        const SchedulePage(),
        const ProfessionalIDPage(),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.calendar_month_rounded, 'Schedule', 1),
            _navItem(Icons.badge_rounded, 'ID Card', 2),
            _navItem(Icons.person_rounded, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.greenLight : AppColors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.greenLight : AppColors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class InternHomeContent extends StatelessWidget {
  final VoidCallback onProfileTap;

  const InternHomeContent({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        final assignment = provider.assignment;
        final workCard = provider.workCard;
        final profile = provider.profile ?? workCard?.profile;
        final schedules = provider.schedules;
        final evaluations = provider.evaluations;
        final modules = provider.trainingModules;

        final nextSchedule = schedules.isNotEmpty ? schedules.first : null;
        final latestEvaluation = evaluations.isNotEmpty ? evaluations.first : null;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: provider.loadDashboardData,
            color: AppColors.greenLight,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: onProfileTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(color: AppColors.grey, fontSize: 14),
                            ),
                            Text(
                              _nonEmpty(profile?.fullName, 'Intern'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onProfileTap,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.surface,
                          backgroundImage: workCard?.idPhotoUrl != null
                              ? NetworkImage(workCard!.idPhotoUrl!)
                              : null,
                          child: workCard?.idPhotoUrl == null
                              ? const Icon(Icons.person_rounded, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (provider.hasAnyError)
                    _ErrorBanner(message: provider.assignmentError ?? provider.schedulesError ?? provider.trainingModulesError ?? provider.workCardError ?? provider.evaluationsError ?? provider.profileError ?? 'Unable to load intern data.'),
                  const SizedBox(height: 24),
                  const Text(
                    'Internship Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _SummaryGrid(
                    department: assignment?.departmentName ?? workCard?.profile.department?.name ?? 'Not assigned',
                    mentor: assignment?.mentorName ?? 'Not assigned',
                    lastMark: latestEvaluation == null ? 'No evaluations yet' : '${latestEvaluation.overallMark.toStringAsFixed(1)} / 100',
                    onTrainingTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingModulesPage())),
                    onEvaluationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluationScreen())),
                  ),
                  const SizedBox(height: 20),
                  _TrainingShortcut(
                    count: modules.length,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingModulesPage())),
                  ),
                  const SizedBox(height: 16),
                  _EvaluationShortcut(
                    count: evaluations.length,
                    onTap: () {
                      provider.loadEvaluations();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluationScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfessionalIDPage extends StatelessWidget {
  const ProfessionalIDPage({super.key});

  Future<void> _uploadPhoto(BuildContext context) async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (pickerResult == null || pickerResult.files.single.bytes == null) {
      return;
    }

    final file = pickerResult.files.single;
    final success = await context.read<InternProvider>().uploadWorkIdPhoto(
          fileBytes: file.bytes!,
          fileName: file.name,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Work ID photo uploaded successfully.' : context.read<InternProvider>().uploadWorkIdPhotoError ?? 'Upload failed.'),
        backgroundColor: success ? AppColors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        final workCard = provider.workCard;

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text(
              'OFFICIAL IDENTIFICATION',
              style: TextStyle(letterSpacing: 2, fontSize: 12, color: AppColors.grey),
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  if (provider.workCardError != null)
                    _ErrorBanner(message: provider.workCardError!),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          child: const Icon(Icons.hub_rounded, color: AppColors.greenLight),
                        ),
                        const SizedBox(height: 30),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: AppColors.surface,
                              backgroundImage: workCard?.idPhotoUrl != null ? NetworkImage(workCard!.idPhotoUrl!) : null,
                              child: workCard?.idPhotoUrl == null
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.verified, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _nonEmpty(workCard?.profile.fullName, 'Intern Name'),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _nonEmpty(workCard?.profile.department?.name, 'Department'),
                          style: const TextStyle(color: AppColors.greenLight, fontSize: 14),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 40),
                          child: Divider(color: AppColors.border),
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.qr_code_2_rounded, size: 120, color: AppColors.bg),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          workCard?.workId == null ? 'WORK ID PENDING' : 'WORK ID ${workCard!.workId}',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton.icon(
                            onPressed: provider.isUploadingWorkIdPhoto ? null : () => _uploadPhoto(context),
                            icon: provider.isUploadingWorkIdPhoto
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Icon(Icons.upload_file_rounded, size: 18),
                            label: Text(provider.isUploadingWorkIdPhoto ? 'Uploading...' : 'Upload ID Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenLight,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _IDInfo(label: 'ROLE', value: _nonEmpty(workCard?.profile.userRole, 'Student')),
                              _IDInfo(label: 'WORK ID', value: workCard?.workId?.toString() ?? 'Pending'),
                              _IDInfo(label: 'DEPT', value: _nonEmpty(workCard?.profile.department?.code, 'N/A')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to exit the portal?',
            style: TextStyle(color: AppColors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text(
                'LOGOUT',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile ?? provider.workCard?.profile;
        final workCard = provider.workCard;
        final avatarUrl = workCard?.idPhotoUrl ?? profile?.idPhotoUrl;
        final workIdValue = profile?.workId ?? workCard?.workId;

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text('MY PROFILE'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () {
                  provider.loadProfile();
                  provider.loadWorkCard();
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.surface,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person_rounded, size: 40) : null,
                ),
                const SizedBox(height: 20),
                Text(
                  _nonEmpty(profile?.fullName, 'Intern Name'),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _nonEmpty(profile?.department?.name, 'Department not assigned'),
                  style: const TextStyle(color: AppColors.greenLight, fontSize: 14),
                ),
                const SizedBox(height: 40),
                _ProfileField(label: 'Profile ID', value: _nonEmpty(profile?.id), icon: Icons.fingerprint_rounded),
                _ProfileField(label: 'Work ID', value: workIdValue?.toString() ?? 'Pending', icon: Icons.badge_rounded),
                _ProfileField(label: 'Role', value: _nonEmpty(profile?.userRole, 'Student'), icon: Icons.verified_user_rounded),
                _ProfileField(label: 'Account Status', value: _nonEmpty(profile?.accountStatus), icon: Icons.shield_rounded),
                _ProfileField(label: 'Email Verified', value: _yesNo(profile?.isEmailVerified), icon: Icons.mark_email_read_rounded),
                _ProfileField(label: 'University ID', value: _nonEmpty(profile?.universityId), icon: Icons.school_rounded),
                _ProfileField(label: 'Department', value: _nonEmpty(profile?.department?.name), icon: Icons.business_rounded),
                _ProfileField(label: 'Department ID', value: _nonEmpty(profile?.departmentId), icon: Icons.account_tree_rounded),
                _ProfileField(label: 'Mentor', value: _nonEmpty(provider.assignment?.mentorName, 'Not assigned'), icon: Icons.school_rounded),
                _ProfileField(label: 'Mentor ID', value: _nonEmpty(profile?.mentorId), icon: Icons.badge_outlined),
                _ProfileField(label: 'Email', value: _nonEmpty(profile?.email, 'N/A'), icon: Icons.email_rounded),
                _ProfileField(label: 'Validated By Admin', value: _yesNo(profile?.isValidatedByAdmin), icon: Icons.verified_rounded),
                _ProfileField(label: 'Created At', value: _formatDate(profile?.createdAt), icon: Icons.calendar_today_rounded),
                _ProfileField(label: 'Updated At', value: _formatDate(profile?.updatedAt), icon: Icons.update_rounded),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('LOGOUT FROM PORTAL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 55),
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text(
              'MY SCHEDULE',
              style: TextStyle(letterSpacing: 1.5, fontSize: 14),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: provider.loadSchedules,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.loadSchedules,
            color: AppColors.greenLight,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                if (provider.schedulesError != null) _ErrorBanner(message: provider.schedulesError!),
                const SizedBox(height: 6),
                const Text(
                  'Upcoming sessions',
                  style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                if (provider.isSchedulesLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.schedules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No schedules available yet.', style: TextStyle(color: AppColors.grey)),
                    ),
                  )
                else
                  ...provider.schedules.map(
                    (schedule) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ScheduleCard(schedule: schedule),
                    ),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SemesterTimetablePage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_view_week_rounded, color: AppColors.gold),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Semester View',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Review your weekly placement plan',
                              style: TextStyle(color: AppColors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrainingModulesPage extends StatelessWidget {
  const TrainingModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text('TRAINING MODULES'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: provider.loadTrainingModules,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.loadTrainingModules,
            color: AppColors.greenLight,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                if (provider.trainingModulesError != null) _ErrorBanner(message: provider.trainingModulesError!),
                if (provider.isTrainingModulesLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.trainingModules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No training modules available.', style: TextStyle(color: AppColors.grey)),
                    ),
                  )
                else
                  ...provider.trainingModules.map(
                    (module) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ModuleDetailPage(module: module)),
                        ),
                        child: _ModuleTile(module: module),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModuleDetailPage extends StatelessWidget {
  final InternTrainingModuleModel module;

  const ModuleDetailPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('MODULE DETAILS'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_nonEmpty(module.description, 'No description available.'), style: const TextStyle(color: AppColors.grey, height: 1.5)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetaChip(label: 'Department', value: _nonEmpty(module.departmentCode, 'All')),
                      _MetaChip(label: 'Role', value: _nonEmpty(module.targetRole, 'All')),
                      _MetaChip(label: 'Version', value: module.version.toString()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'File URL',
                    style: TextStyle(color: AppColors.gold.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _openExternalUrl(context, module.fileUrl),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        module.fileUrl,
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openExternalUrl(context, module.fileUrl),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open in browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: module.fileUrl));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Module URL copied to clipboard.')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy URL'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.greenLight,
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(color: AppColors.greenLight.withOpacity(0.6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SemesterTimetablePage extends StatelessWidget {
  const SemesterTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text('SEMESTER TIMETABLE', style: TextStyle(fontSize: 14)),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (provider.schedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No schedule data available to build a timetable.', style: TextStyle(color: AppColors.grey)),
                )
              else
                DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.surface),
                  dataRowColor: MaterialStateProperty.all(AppColors.card.withOpacity(0.5)),
                  border: TableBorder.all(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                  columns: const [
                    DataColumn(label: Text('DAY', style: TextStyle(color: AppColors.gold))),
                    DataColumn(label: Text('TITLE', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('TIME', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('MENTOR', style: TextStyle(color: Colors.white))),
                  ],
                  rows: provider.schedules
                      .map(
                        (schedule) => DataRow(
                          cells: [
                            DataCell(Text(_nonEmpty(schedule.weekday), style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold))),
                            DataCell(Text(_nonEmpty(schedule.title), style: const TextStyle(color: Colors.white, fontSize: 12))),
                            DataCell(Text(schedule.timeRange, style: const TextStyle(color: Colors.white, fontSize: 12))),
                            DataCell(Text(_nonEmpty(schedule.mentorName), style: const TextStyle(color: Colors.white, fontSize: 12))),
                          ],
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class TrainingFilesPage extends StatelessWidget {
  const TrainingFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text('COURSE MATERIALS', style: TextStyle(fontSize: 14)),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: provider.trainingModules
                .map(
                  (module) => Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: AppColors.greenLight, size: 24),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(module.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(_nonEmpty(module.fileUrl, 'No file url provided'), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new_rounded, color: AppColors.greenLight),
                          onPressed: () => _openExternalUrl(context, module.fileUrl),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: AppColors.greenLight),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: module.fileUrl));
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File URL copied.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternProvider>(
      builder: (context, provider, _) {
        final evaluations = provider.evaluations;
        final average = _averageMark(evaluations);

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text(
              'PERFORMANCE REVIEW',
              style: TextStyle(fontSize: 14, letterSpacing: 1.2, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: provider.loadEvaluations,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.loadEvaluations,
            color: AppColors.greenLight,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                if (provider.evaluationsError != null) _ErrorBanner(message: provider.evaluationsError!),
                _buildScoreHeader(average, evaluations.length),
                const SizedBox(height: 30),
                const Text(
                  'EVALUATION LIST',
                  style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                if (provider.isEvaluationsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (evaluations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No evaluations available yet.', style: TextStyle(color: AppColors.grey)),
                    ),
                  )
                else
                  ...evaluations.map(
                    (evaluation) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _EvaluationCard(evaluation: evaluation),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreHeader(double average, int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.greenLight.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('Average Mark', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(color: AppColors.greenLight, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const Text('/100', style: TextStyle(color: AppColors.grey, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Text('$totalCount evaluation${totalCount == 1 ? '' : 's'} retrieved', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final String department;
  final String mentor;
  final String lastMark;
  final VoidCallback onTrainingTap;
  final VoidCallback onEvaluationTap;

  const _SummaryGrid({
    required this.department,
    required this.mentor,
    required this.lastMark,
    required this.onTrainingTap,
    required this.onEvaluationTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _summaryCard('Department', department, Icons.business, AppColors.greenLight, onTap: onTrainingTap),
        _summaryCard('My Mentor', mentor, Icons.school, AppColors.gold, onTap: onTrainingTap),
        _summaryCard('Last Mark', lastMark, Icons.grade, Colors.orangeAccent, onTap: onEvaluationTap),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(onTap: onTap, child: card);
  }
}

class _TrainingShortcut extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _TrainingShortcut({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.greenLight.withOpacity(0.2), AppColors.bg]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greenLight.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.school, color: AppColors.greenLight),
            const SizedBox(width: 15),
            Text(
              'Training Modules ($count)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _EvaluationShortcut extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _EvaluationShortcut({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.2), AppColors.bg]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.insights_rounded, color: AppColors.gold),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'See skills evaluations',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count evaluation${count == 1 ? '' : 's'} available',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _OverviewCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SchedulePreview extends StatelessWidget {
  final InternScheduleModel schedule;

  const _SchedulePreview({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 52, decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(schedule.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${schedule.weekday} • ${schedule.timeRange}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(_nonEmpty(schedule.mentorName), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvaluationPreview extends StatelessWidget {
  final InternEvaluationModel evaluation;

  const _EvaluationPreview({required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(evaluation.weekLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(evaluation.overallMark.toStringAsFixed(1), style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(_nonEmpty(evaluation.feedback, 'No feedback provided.'), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(_nonEmpty(evaluation.mentorName), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ],
    );
  }
}

class _ModulePreviewTile extends StatelessWidget {
  final InternTrainingModuleModel module;
  final VoidCallback onTap;

  const _ModulePreviewTile({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_lesson_rounded, color: AppColors.greenLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_nonEmpty(module.description, 'Module details available.'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final InternTrainingModuleModel module;

  const _ModuleTile({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surface,
            child: const Icon(Icons.menu_book_rounded, color: AppColors.greenLight),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  '${_nonEmpty(module.departmentCode, 'All')} • v${module.version}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: module.isActive ? 1 : 0.3,
                  backgroundColor: AppColors.surface,
                  color: module.isActive ? AppColors.green : AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }
}

class _EvaluationCard extends StatelessWidget {
  final InternEvaluationModel evaluation;

  const _EvaluationCard({required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(evaluation.weekLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                evaluation.overallMark.toStringAsFixed(1),
                style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_nonEmpty(evaluation.feedback, 'No feedback provided.'), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text('Mentor: ${_nonEmpty(evaluation.mentorName)}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Evaluated: ${_formatDate(evaluation.evaluatedAt)}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final InternScheduleModel schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: schedule.isActive ? AppColors.greenLight : AppColors.border, width: schedule.isActive ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 54,
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(schedule.weekday, style: const TextStyle(color: AppColors.greenLight, fontSize: 11, fontWeight: FontWeight.bold)),
                    if (schedule.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.greenLight.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                        child: const Text('ACTIVE', style: TextStyle(color: AppColors.greenLight, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(schedule.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(_formatDate(schedule.scheduleDate), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    const SizedBox(width: 15),
                    const Icon(Icons.access_time_rounded, color: AppColors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(schedule.timeRange, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Mentor: ${_nonEmpty(schedule.mentorName)}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                if (schedule.fileUrl != null && schedule.fileUrl!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _openExternalUrl(context, schedule.fileUrl!),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open schedule'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.greenLight,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IDInfo extends StatelessWidget {
  final String label;
  final String value;

  const _IDInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileField({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}