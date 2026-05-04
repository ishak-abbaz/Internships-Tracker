import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/adminInternsList_provider.dart';
import 'providers/attendance_provider.dart';
import 'models/intern_model.dart';
import 'screens/attendance_management_screen.dart';
import 'screens/evaluation_management_screen.dart';
import 'screens/training_module_management_screen.dart';
import 'theme.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});
  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AdminInternsListNotifier>().fetchInternsByMentor(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Mentor Workspace", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            _buildWelcomeHeader(user?.fullName ?? "Mentor"),
            const SizedBox(height: 25),

            // My Interns Section
            const Text("My Interns",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Consumer<AdminInternsListNotifier>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.greenLight));
                }
                if (provider.mentorInterns.isEmpty) {
                  return _buildEmptyState();
                }
                return Column(
                  children: provider.mentorInterns.map((intern) => _internCard(context, intern)).toList(),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.greenDeep, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.green.withOpacity(0.1), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,",
                    style: TextStyle(color: AppColors.grey.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 4),
                Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Active Mentor Session",
                      style: TextStyle(color: AppColors.greenLight, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Icon(Icons.school_rounded, color: AppColors.greenLight, size: 48),
        ],
      ),
    );
  }

  Widget _internCard(BuildContext context, InternModel intern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.surface,
          child: Text(intern.fullName[0].toUpperCase(),
              style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
        ),
        title: Text(intern.fullName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(intern.email,
            style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _InternDetailScreen(intern: intern)),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.person_off_rounded, color: AppColors.grey.withOpacity(0.3), size: 48),
          const SizedBox(height: 16),
          Text("No interns assigned yet",
              style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Drawer(
      backgroundColor: AppColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.greenLight.withOpacity(0.2),
                      child: const Icon(Icons.person, color: AppColors.greenLight, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(user?.fullName ?? "Mentor Name",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? "mentor@prolink.com",
                        style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    const SizedBox(height: 30),
                    const Divider(color: AppColors.border),
                    _drawerTile(Icons.dashboard_rounded, "Dashboard", () => Navigator.pop(context)),
                    _drawerTile(Icons.fact_check_rounded, "Attendance", () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AttendanceManagementScreen(mentorId: user?.id)));
                    }),
                    _drawerTile(Icons.assignment_rounded, "Evaluations", () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EvaluationManagementScreen(mentorId: user?.id)));
                    }),
                    _drawerTile(Icons.school_outlined, "Training Modules", () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrainingModuleManagementScreen(mentorId: user?.id)));
                    }),
                    const Divider(color: AppColors.border),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.redAccent, width: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.greenLight),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class _InternDetailScreen extends StatelessWidget {
  final InternModel intern;
  const _InternDetailScreen({required this.intern});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Intern Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.greenLight.withOpacity(0.2),
                    child: Text(intern.fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: AppColors.greenLight, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(intern.fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Basic Information",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.email_outlined, "Email Address", intern.email),
                  const Divider(color: AppColors.border, height: 32),
                  _infoRow(Icons.badge_outlined, "Registration Number", intern.registrationNr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.greenLight, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
