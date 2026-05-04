import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'theme.dart';
import 'mentor_dashboard.dart';
import 'intern_dashboard.dart';
import 'models/department_model.dart';
import 'models/intern_model.dart';
import 'models/mentor_model.dart';
import 'models/admin_office_models.dart';
import 'services/admin_department_service.dart';
import 'services/api_exception.dart';
import 'providers/adminInterns_provider.dart';
import 'providers/adminInternsList_provider.dart';
import 'providers/internship_assignment_provider.dart';
import 'providers/adminMentors_provider.dart';
import 'providers/adminDepartments_provider.dart';
import 'providers/createIntern_form_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_office_provider.dart';
import 'screens/intern_assignment_screen.dart';
import 'screens/attendance_management_screen.dart';
import 'screens/evaluation_management_screen.dart';
import 'screens/training_module_management_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF070D09),
  ));
  runApp(const ProLinkApp());
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminInternsListNotifier>().fetchPendingInterns();
      context.read<AdminInternsListNotifier>().fetchInterns();
      context.read<InternshipAssignmentNotifier>().fetchAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.bg,
      // ── THE THREE LINES MENU (DRAWER) - Unchanged ──
      drawer: ClipRRect(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        child: Drawer(
          backgroundColor: AppColors.surface,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: AppColors.card,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.greenLight.withOpacity(0.1),
                                child: Text(
                                  user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : "A",
                                  style: const TextStyle(color: AppColors.greenLight, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                user?.fullName ?? "Admin User",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user?.email ?? "admin@example.com",
                                style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 1. Core Navigation
                      _drawerTile(context, Icons.dashboard, "Dashboard", () => Navigator.pop(context)),

                      _drawerTile(context, Icons.business, "Departments", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageDepartmentsPage()));
                      }),

                      // 2. Academic & Scheduling
                      _drawerTile(context, Icons.calendar_today, "Schedules", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleManagementPage()));
                      }),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: AppColors.border),
                      ),

                      // 3. User Management
                      _drawerTile(context, Icons.people, "Manage Interns", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageInternsPage()));
                      }),

                      _drawerTile(context, Icons.school, "Manage Mentors", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageMentorsPage()));
                      }),

                      _drawerTile(context, Icons.assignment_ind, "Intern Assignments", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const InternAssignmentScreen()));
                      }),

                      _drawerTile(context, Icons.check_circle_outline, "Evaluations", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EvaluationManagementScreen(isAdmin: true)));
                      }),

                      _drawerTile(context, Icons.how_to_reg, "Attendance", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceManagementScreen(isAdmin: true)));
                      }),

                      _drawerTile(context, Icons.school_outlined, "Training Modules", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainingModuleManagementScreen(isAdmin: true)));
                      }),

                      _drawerTile(context, Icons.menu_book, "Policies", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PolicyManagementPage()));
                      }),

                      // 4. System & Exit
                      _drawerTile(context, Icons.settings, "Settings", () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSettingsPage()));
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GradientButton(
                  label: "Logout",
                  icon: Icons.logout,
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Admin Central", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. PENDING VALIDATIONS SECTION
            const Text("Pending Intern Validations",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Review and approve new student registrations.",
                style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 15),
            
            Consumer<AdminInternsListNotifier>(
              builder: (context, provider, child) {
                // Loading state
                if (provider.pendingLoading)
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                      ),
                    ),
                  );
                
                // Error state
                if (provider.error != null)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 40),
                          const SizedBox(height: 10),
                          const Text(
                            "❌ Error loading pending interns",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => provider.fetchPendingInterns(),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                
                // Empty state
                if (provider.pendingInternsList.isEmpty)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "✅ No pending interns",
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                    ),
                  );
                
                // Pending interns list
                return Column(
                  children: provider.pendingInternsList.take(2).map((intern) {
                    return _invitationCard(context, intern);
                  }).toList(),
                );
              },
            ),

            Center(
              child: TextButton(
                  onPressed: () {
                    // Navigates to the new list page
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllRequestsPage())
                    );
                  },
                  child: const Text("View Pending Requests", style: TextStyle(color: AppColors.greenLight))
              ),
            ),

            const SizedBox(height: 20),

            // 3. ASSIGNMENTS SECTION
            const Text("Assignments",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Consumer<InternshipAssignmentNotifier>(
              builder: (context, provider, child) {
                final total = provider.assignments.length;
                final active = provider.assignments.where((a) {
                  final now = DateTime.now();
                  return a.startDate.isBefore(now) && a.endDate.isAfter(now);
                }).length;
                
                return Row(
                  children: [
                    Expanded(
                        child: _buildSmallStatCard(
                            "Active Internships",
                            "$active",
                            AppColors.greenLight,
                            Icons.assignment_turned_in_rounded
                        )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildSmallStatCard(
                            "Total Assignments",
                            "$total",
                            AppColors.orange,
                            Icons.assignment_rounded
                        )
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            GradientButton(
              label: "Manage Assignments",
              icon: Icons.assignment_ind_rounded,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InternAssignmentScreen()));
              },
            ),

          ],
        ),
      ),
    );
  }

  // --- HELPER METHODS (These fix your "Method Not Found" errors) ---

  Widget _buildSmallStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card, // Matches your dark theme
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row with Number and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
              Icon(icon, color: color.withOpacity(0.4), size: 20), // Subtle icon
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmApprovePending(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Approve ${intern.fullName}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'They will gain access to the system.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = context.read<AdminInternsListNotifier>();
              final success = await notifier.approveIntern(intern.id);
              if (!context.mounted) return;

              if (success) {
                showProAlert(
                  context,
                  title: 'Success',
                  message: 'Intern approved successfully',
                );
              } else {
                showProAlert(
                  context,
                  title: 'Error',
                  message: notifier.error ?? 'Failed to approve intern',
                  isError: true,
                );
              }
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _confirmRejectPending(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reject ${intern.fullName}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'They will NOT gain access to the system.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = context.read<AdminInternsListNotifier>();
              final success = await notifier.rejectIntern(intern.id);
              if (!context.mounted) return;

              if (success) {
                showProAlert(
                  context,
                  title: 'Success',
                  message: 'Intern rejected successfully',
                );
              } else {
                showProAlert(
                  context,
                  title: 'Error',
                  message: notifier.error ?? 'Failed to reject intern',
                  isError: true,
                );
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color == Colors.white ? AppColors.greenLight : color, size: 22),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: AppColors.greenLight.withOpacity(0.1),
    );
  }

  Widget _invitationCard(BuildContext context, InternModel intern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border)
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surface, 
            child: Text(
              intern.fullName[0].toUpperCase(), 
              style: const TextStyle(color: AppColors.greenLight)
            )
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intern.fullName, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      "${intern.department ?? 'N/A'}${intern.departmentCode != null ? ' (${intern.departmentCode})' : ''}", 
                      style: const TextStyle(color: AppColors.grey, fontSize: 12)
                    ),
                  ]
              )
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _confirmApprovePending(intern),
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _confirmRejectPending(intern),
                icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          )
        ],
      ),
    );
  }}

  Widget _drawerTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }
class ManageMentorsPage extends StatefulWidget {
  const ManageMentorsPage({super.key});

  @override
  State<ManageMentorsPage> createState() => _ManageMentorsPageState();
}

class _ManageMentorsPageState extends State<ManageMentorsPage> {
  final AdminMentorsNotifier _mentorsNotifier = AdminMentorsNotifier();
  final AdminDepartmentService _departmentService = AdminDepartmentService();
  List<DepartmentModel> _departments = [];

  @override
  void initState() {
    super.initState();
    _mentorsNotifier.fetchMentors();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final depts = await _departmentService.fetchDepartments();
      setState(() => _departments = depts);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        setState(() => _departments = []);
        return;
      }
      if (mounted) {
        showProAlert(
          context,
          title: 'Error',
          message: 'Failed to load departments: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Mentor Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded, color: AppColors.greenLight),
            onPressed: () => _showAddMentorDialog(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _mentorsNotifier,
        builder: (context, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: _mentorsNotifier.search,
                  decoration: proLinkInputDecoration(
                    label: "Search Mentors",
                    hint: "Name...",
                    icon: Icons.search,
                  ),
                ),
              ),

              if (_mentorsNotifier.isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else if (_mentorsNotifier.error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _mentorsNotifier.error ?? 'Failed to load mentors',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _mentorsNotifier.mentors.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final mentor = _mentorsNotifier.mentors[index];
                      return _mentorCard(mentor, index);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Statistics Header
  // REMOVED: Total Mentors and Total Capacity stats

  // Individual Mentor Card with Popup Menu
  Widget _mentorCard(MentorModel mentor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.surface,
          child: Text(mentor.fullName.isNotEmpty ? mentor.fullName[0] : 'M',
              style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
        ),
        title: Text(mentor.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mentor.departmentId != null 
                ? "Dept: ${mentor.department?.code ?? mentor.departmentId}" 
                : "No Department",
              style: TextStyle(
                color: mentor.departmentId != null ? AppColors.greenLight : AppColors.grey, 
                fontSize: 12
              )
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.grey),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          onSelected: (value) {
            if (value == 'view') {
              _showMentorInfo(context, {
                'id': mentor.id,
                'name': mentor.fullName,
                'email': mentor.email,
                'department': mentor.department != null 
                    ? "${mentor.department!.name} (${mentor.department!.code})" 
                    : mentor.departmentId ?? 'N/A',
                'specialization': mentor.specialization ?? 'N/A'
              });
            } else if (value == 'edit') {
              _showEditMentorDialog(context, mentor);
            } else if (value == 'delete') {
              _confirmDeleteMentor(mentor.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.badge_outlined, color: AppColors.greenLight, size: 20),
                  SizedBox(width: 10),
                  Text("View Info", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                  SizedBox(width: 10),
                  Text("Edit", style: TextStyle(color: AppColors.gold)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Text("Delete", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMentorInfo(BuildContext context, Map<String, dynamic> mentor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.school, color: AppColors.greenLight, size: 30)
            ),
            const SizedBox(height: 15),
            Text(
                mentor['name'],
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const Divider(color: AppColors.border, height: 30),

            // University Email
            _infoRow(Icons.alternate_email, "University Gmail", (mentor['email'] ?? 'N/A').toString()),

            // Department
            _infoRow(Icons.business, "Department", (mentor['department'] ?? 'N/A').toString()),

            // Specialization
            _infoRow(Icons.workspace_premium, "Specialization", (mentor['specialization'] ?? 'N/A').toString()),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Create Mentor Form
  void _showAddMentorDialog(BuildContext context) {
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController specializationController = TextEditingController();
    String? selectedDepartmentId;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Register New Mentor",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Full Name
                TextField(
                    controller: fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: "Full Name", hint: "Dr. Name", icon: Icons.person)),
                const SizedBox(height: 15),

                // University Gmail
                TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.greenLight),
                    decoration: proLinkInputDecoration(
                        label: "University Gmail",
                        hint: "username@univ-constantine2.dz",
                        icon: Icons.alternate_email
                    )),
                const SizedBox(height: 15),

                // Password
                TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                        label: "Password",
                        hint: "Enter password",
                        icon: Icons.lock
                    )),
                const SizedBox(height: 15),

                // Department Dropdown
                _buildMentorDropdown(
                  "Department",
                  _departments.map((d) => d.name).toList(),
                  _departments.isNotEmpty ? _departments.first.name : null,
                  (value) {
                    setModalState(() {
                      final selected = _departments.firstWhere(
                        (d) => d.name == value,
                        orElse: () => _departments.first,
                      );
                      selectedDepartmentId = selected.id;
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Specialization
                TextField(
                    controller: specializationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                        label: "Specialization",
                        hint: "e.g. AI, Web Development",
                        icon: Icons.workspace_premium
                    )),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setModalState(() => isLoading = true);
                    final result = await _mentorsNotifier.createMentor(
                      fullName: fullNameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      departmentId: selectedDepartmentId ?? _departments.first.id,
                      specialization: specializationController.text,
                    );
                    
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (result != null) {
                      showProAlert(
                        context,
                        title: 'Success',
                        message: 'Mentor created successfully',
                      );
                    } else {
                      showProAlert(
                        context,
                        title: 'Error',
                        message: _mentorsNotifier.error ?? 'Failed to create mentor',
                        isError: true,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CREATE MENTOR ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // Delete Confirmation
  void _confirmDeleteMentor(String mentorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Remove Mentor?", style: TextStyle(color: Colors.white)),
        content: const Text("Warning: This will unassign all interns currently supervised by this mentor."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await _mentorsNotifier.deleteMentor(mentorId);
                if (mounted) {
                  if (success) {
                    showProAlert(
                      context,
                      title: 'Success',
                      message: 'Mentor removed successfully',
                    );
                  } else {
                    showProAlert(
                      context,
                      title: 'Error',
                      message: _mentorsNotifier.error ?? 'Failed to remove mentor',
                      isError: true,
                    );
                  }
                }
              },
              child: const Text("Remove", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  // Edit Mentor Dialog
  void _showEditMentorDialog(BuildContext context, MentorModel mentor) {
    final TextEditingController fullNameController = TextEditingController(text: mentor.fullName);
    final TextEditingController emailController = TextEditingController(text: mentor.email);
    final TextEditingController specializationController = TextEditingController(text: mentor.specialization);
    String? selectedDepartmentId = mentor.departmentId;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Edit Mentor",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Full Name
                TextField(
                    controller: fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: "Full Name", hint: "Dr. Name", icon: Icons.person)),
                const SizedBox(height: 15),

                // University Gmail
                TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.greenLight),
                    decoration: proLinkInputDecoration(
                        label: "University Gmail",
                        hint: "username@univ-constantine2.dz",
                        icon: Icons.alternate_email
                    )),
                const SizedBox(height: 15),

                // Department Dropdown
                _buildMentorDropdown(
                  "Department",
                  ['Select Department', ..._departments.map((d) => d.name)],
                  (selectedDepartmentId != null && _departments.any((d) => d.id == selectedDepartmentId)) 
                    ? _departments.firstWhere((d) => d.id == selectedDepartmentId).name 
                    : 'Select Department',
                  (value) {
                    setModalState(() {
                      if (value == 'Select Department') {
                        selectedDepartmentId = null;
                      } else {
                        final selected = _departments.firstWhere(
                          (d) => d.name == value,
                        );
                        selectedDepartmentId = selected.id;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Specialization
                TextField(
                    controller: specializationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                        label: "Specialization",
                        hint: "e.g. AI, Web Development",
                        icon: Icons.workspace_premium
                    )),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setModalState(() => isLoading = true);
                    final result = await _mentorsNotifier.updateMentor(
                      id: mentor.id,
                      fullName: fullNameController.text,
                      email: emailController.text,
                      departmentId: selectedDepartmentId,
                      specialization: specializationController.text,
                    );
                    
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (result != null) {
                      showProAlert(
                        context,
                        title: 'Success',
                        message: 'Mentor updated successfully',
                      );
                    } else {
                      showProAlert(
                        context,
                        title: 'Error',
                        message: _mentorsNotifier.error ?? 'Failed to update mentor',
                        isError: true,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("UPDATE MENTOR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for dropdown in manage mentors
  Widget _buildMentorDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: AppColors.surface,
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOfficeNotifier>().fetchSchedules();
      context.read<AdminDepartmentsNotifier>().fetchDepartments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _teacherController.dispose();
    _subjectController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(StateSetter setModalState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setModalState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // ── UPDATED ADD DIALOG ──
  void _showAddScheduleDialog() {
    String? selectedDept;
    String? selectedClass;
    String? selectedGroup;
    _teacherController.clear();
    _subjectController.clear();
    _titleController.clear();
    _selectedFile = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Create Section Schedule",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Schedule Title", hint: "e.g. Spring 2026 AI Dept", icon: Icons.title),
                ),
                const SizedBox(height: 15),

                // Department Pick
                Consumer<AdminDepartmentsNotifier>(
                  builder: (context, deptNotifier, _) {
                    final depts = deptNotifier.departments;
                    return _customDropdown(
                      "Department",
                      depts.map((d) => d.name).toList(),
                      selectedDept != null ? depts.firstWhere((d) => d.id == selectedDept).name : null,
                      (v) {
                        final dept = depts.firstWhere((d) => d.name == v);
                        setModalState(() => selectedDept = dept.id);
                      }
                    );
                  }
                ),

                const SizedBox(height: 15),
                Row(
                  children: [
                    // Class (M1, M2, L3)
                    Expanded(child: _customDropdown("Class/Year", ["M1", "M2", "L3"], selectedClass, (v) => setModalState(() => selectedClass = v))),
                    const SizedBox(width: 10),
                    // Group (G1, G2...)
                    Expanded(child: _customDropdown("Group", ["G 01", "G 02", "G 03"], selectedGroup, (v) => setModalState(() => selectedGroup = v))),
                  ],
                ),

                const SizedBox(height: 15),
                // Teacher Name
                TextField(
                  controller: _teacherController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Teacher Name", hint: "Dr. Full Name", icon: Icons.person_pin),
                ),

                const SizedBox(height: 15),
                // Subject/Module
                TextField(
                  controller: _subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Module/Subject", hint: "e.g. Mathematics", icon: Icons.book),
                ),

                const SizedBox(height: 20),
                // Upload PDF Button
                InkWell(
                  onTap: () => _pickFile(setModalState),
                  child: _uploadBox(_selectedFile, label: "Upload Time-Table PDF"),
                ),

                const SizedBox(height: 20),
                Consumer<AdminOfficeNotifier>(
                  builder: (context, notifier, child) {
                    return ElevatedButton(
                      onPressed: notifier.isLoading ? null : () async {
                        if (_titleController.text.isEmpty) return;
                        final success = await notifier.createSchedule(
                          title: _titleController.text,
                          teacherName: _teacherController.text,
                          moduleName: _subjectController.text,
                          academicYear: selectedClass,
                          group: selectedGroup,
                          departmentId: selectedDept,
                          file: _selectedFile,
                        );
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50)),
                      child: notifier.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SAVE SCHEDULE"),
                    );
                  }
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("Schedules"), backgroundColor: Colors.transparent),
      body: Consumer<AdminOfficeNotifier>(
        builder: (context, notifier, child) {
          final query = _searchController.text.toLowerCase();
          final filteredSchedules = notifier.schedules.where((s) {
            return s.title.toLowerCase().contains(query) ||
                (s.teacherName?.toLowerCase().contains(query) ?? false) ||
                (s.departmentName?.toLowerCase().contains(query) ?? false);
          }).toList();

          if (notifier.isLoading && notifier.schedules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ── SEARCH BAR ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Search Schedule", hint: "Teacher, Dept, or Title...", icon: Icons.search),
                ),
              ),

              // ── LIST ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => notifier.fetchSchedules(),
                  child: ListView.builder(
                    itemCount: filteredSchedules.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final s = filteredSchedules[index];
                      return _scheduleCard(s);
                    },
                  ),
                ),
              ),
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        onPressed: _showAddScheduleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── UI HELPERS ──
  Widget _scheduleCard(OfficeSchedule s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(s.title, style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold))),
              if (s.academicYear != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: Text("${s.academicYear} ${s.group ?? ''}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                )
            ],
          ),
          const SizedBox(height: 10),
          if (s.moduleName != null)
            Text(s.moduleName!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            children: [
              if (s.teacherName != null) ...[
                const Icon(Icons.person_outline, color: AppColors.grey, size: 14),
                const SizedBox(width: 5),
                Text("Teacher: ${s.teacherName}", style: const TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
              const Spacer(),
              if (s.fileUrl != null)
                TextButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(s.fileUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text("View", style: TextStyle(fontSize: 12)),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                onPressed: () => context.read<AdminOfficeNotifier>().deleteSchedule(s.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SHARED UI COMPONENTS ──

Widget _customDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: AppColors.surface,
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}

Widget _uploadBox(File? file, {String label = "Select PDF Document"}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, style: BorderStyle.solid)),
    child: Column(
      children: [
        Icon(file != null ? Icons.check_circle : Icons.upload_file, color: file != null ? AppColors.green : AppColors.greenLight),
        const SizedBox(height: 10),
        Text(file != null ? "File: ${file.path.split('/').last}" : label, 
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class ManageDepartmentsPage extends StatefulWidget {
  const ManageDepartmentsPage({super.key});

  @override
  State<ManageDepartmentsPage> createState() => _ManageDepartmentsPageState();
}

class _ManageDepartmentsPageState extends State<ManageDepartmentsPage> {
  final AdminDepartmentService _departmentService = AdminDepartmentService();

  bool _isLoading = true;
  String? _error;
  List<DepartmentModel> _departments = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _departmentService.fetchDepartments();
      if (!mounted) return;
      setState(() => _departments = items);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 404) {
        setState(() => _departments = []);
      } else {
        setState(() => _error = e.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load departments.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<DepartmentModel> get _filteredDepartments {
    final term = _searchTerm.trim().toLowerCase();
    if (term.isEmpty) {
      return _departments;
    }

    return _departments.where((dept) {
      return dept.name.toLowerCase().contains(term) ||
          dept.code.toLowerCase().contains(term) ||
          (dept.description ?? '').toLowerCase().contains(term);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Departments"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: AppColors.greenLight),
            onPressed: _showCreateDepartmentSheet,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Search Departments",
                hint: "Name, code, or description",
                icon: Icons.search,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.greenLight));
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    final departments = _filteredDepartments;
    if (departments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.greenLight,
      onRefresh: _loadDepartments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: departments.length,
        itemBuilder: (context, index) => _buildDepartmentCard(departments[index]),
      ),
    );
  }

  Widget _buildDepartmentCard(DepartmentModel dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: AppColors.greenLight, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dept.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(dept.code,
                        style: const TextStyle(color: AppColors.grey, fontSize: 12, letterSpacing: 1.2)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dept.isActive ? AppColors.greenLight.withOpacity(0.18) : AppColors.orange.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: dept.isActive ? AppColors.greenLight.withOpacity(0.4) : AppColors.orange.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  dept.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: dept.isActive ? AppColors.greenLight : AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if ((dept.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              dept.description!,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                dept.createdAt == null || dept.createdAt!.isEmpty ? 'Created: -' : 'Created: ${dept.createdAt}',
                style: const TextStyle(color: AppColors.greyDark, fontSize: 10),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_note, color: AppColors.greenLight),
                onPressed: () => _showEditDepartmentSheet(dept),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                onPressed: () => _confirmDelete(dept),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 40),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.white), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDepartments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.business_outlined, color: AppColors.grey, size: 38),
          const SizedBox(height: 12),
          const Text('No departments yet', style: TextStyle(color: AppColors.white)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showCreateDepartmentSheet,
            icon: const Icon(Icons.add, color: AppColors.greenLight),
            label: const Text('Create department', style: TextStyle(color: AppColors.greenLight)),
          ),
        ],
      ),
    );
  }

  void _showCreateDepartmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _DepartmentFormSheet(
        parentContext: this.context,
        service: _departmentService,
        onCreated: (created) => setState(() => _departments = [created, ..._departments]),
      ),
    );
  }

  void _showEditDepartmentSheet(DepartmentModel dept) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _DepartmentFormSheet(
        parentContext: this.context,
        service: _departmentService,
        department: dept,
        onUpdated: (updated) {
          setState(() {
            _departments = _departments.map((item) => item.id == dept.id ? updated : item).toList();
          });
        },
      ),
    );
  }

  void _confirmDelete(DepartmentModel dept) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Department', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete ${dept.name}? This action cannot be undone.',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _departmentService.deleteDepartment(dept.id);
                if (!mounted) return;
                setState(() => _departments = _departments.where((item) => item.id != dept.id).toList());
                showProAlert(
                  this.context,
                  title: 'Success',
                  message: 'Department deleted successfully.',
                );
              } on ApiException catch (e) {
                showProAlert(
                  this.context,
                  title: 'Error',
                  message: e.message,
                  isError: true,
                );
              } catch (_) {
                showProAlert(
                  this.context,
                  title: 'Error',
                  message: 'Unable to delete department.',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DepartmentFormSheet extends StatefulWidget {
  final BuildContext parentContext;
  final AdminDepartmentService service;
  final DepartmentModel? department;
  final ValueChanged<DepartmentModel>? onCreated;
  final ValueChanged<DepartmentModel>? onUpdated;

  const _DepartmentFormSheet({
    required this.parentContext,
    required this.service,
    this.department,
    this.onCreated,
    this.onUpdated,
  });

  @override
  State<_DepartmentFormSheet> createState() => _DepartmentFormSheetState();
}

class _DepartmentFormSheetState extends State<_DepartmentFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  late String _description;
  late bool _isActive;
  bool _isSaving = false;
  String? _submitError;

  bool get _isEdit => widget.department != null;

  @override
  void initState() {
    super.initState();
    final dept = widget.department;
    _name = dept?.name ?? '';
    _code = dept?.code ?? '';
    _description = dept?.description ?? '';
    _isActive = dept?.isActive ?? true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _submitError = null;
    });

    try {
      final name = _name.trim();
      final code = _code.trim();
      final description = _description.trim();

      if (_isEdit) {
        final updated = await widget.service.updateDepartment(
          id: widget.department!.id,
          name: name,
          code: code,
          description: description.isEmpty ? null : description,
          isActive: _isActive,
        );
        widget.onUpdated?.call(updated);
        if (!mounted) return;
        Navigator.pop(context);
        showProAlert(
          widget.parentContext,
          title: 'Success',
          message: 'Department updated successfully.',
        );
      } else {
        final created = await widget.service.createDepartment(
          name: name,
          code: code,
          description: description.isEmpty ? null : description,
        );
        widget.onCreated?.call(created);
        if (!mounted) return;
        Navigator.pop(context);
        showProAlert(
          widget.parentContext,
          title: 'Success',
          message: 'Department created successfully.',
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitError = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitError = _isEdit ? 'Unable to update department.' : 'Unable to create department.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEdit ? 'Edit Department' : 'Create Department',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _name,
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: 'Name',
                hint: 'Department name',
                icon: Icons.business,
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
              onChanged: (value) => _name = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _code,
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: 'Code',
                hint: _isEdit ? 'Short code' : 'Short code (e.g. DEV)',
                icon: Icons.tag,
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Code is required' : null,
              onChanged: (value) => _code = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _description,
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: 'Description',
                hint: 'Optional description',
                icon: Icons.notes,
              ),
              maxLines: 3,
              onChanged: (value) => _description = value,
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _isActive,
                    activeColor: AppColors.greenLight,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(width: 8),
                  Text(_isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ],
            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Text(_submitError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Save Changes' : 'Create'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PolicyManagementPage extends StatefulWidget {
  const PolicyManagementPage({super.key});

  @override
  State<PolicyManagementPage> createState() => _PolicyManagementPageState();
}

class _PolicyManagementPageState extends State<PolicyManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOfficeNotifier>().fetchPolicies();
      context.read<AdminDepartmentsNotifier>().fetchDepartments();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(StateSetter setModalState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setModalState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // ── ADD/UPLOAD DIALOG ──
  void _showUploadDialog() {
    String? selectedDept;
    _titleController.clear();
    _versionController.clear();
    _descController.clear();
    _selectedFile = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Upload New Handbook",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: proLinkInputDecoration(label: "Document Title", hint: "e.g. Code of Conduct", icon: Icons.description),
              ),
              const SizedBox(height: 15),

              // Department Pick
              Consumer<AdminDepartmentsNotifier>(
                builder: (context, deptNotifier, _) {
                  final depts = deptNotifier.departments;
                  return _customDropdown(
                    "Department",
                    depts.map((d) => d.name).toList(),
                    selectedDept != null ? depts.firstWhere((d) => d.id == selectedDept).name : null,
                    (v) {
                      final dept = depts.firstWhere((d) => d.name == v);
                      setModalState(() => selectedDept = dept.id);
                    }
                  );
                }
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _versionController,
                style: const TextStyle(color: Colors.white),
                decoration: proLinkInputDecoration(label: "Version Number", hint: "v1.1", icon: Icons.history),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: proLinkInputDecoration(label: "Description", hint: "Optional brief info", icon: Icons.info_outline),
              ),
              const SizedBox(height: 20),

              // Upload Area
              InkWell(
                onTap: () => _pickFile(setModalState),
                child: _uploadBox(_selectedFile),
              ),

              const SizedBox(height: 25),
              Consumer<AdminOfficeNotifier>(
                builder: (context, notifier, child) {
                  return ElevatedButton(
                    onPressed: notifier.isLoading ? null : () async {
                      if (_titleController.text.isEmpty) return;
                      final success = await notifier.createPolicy(
                        title: _titleController.text,
                        version: _versionController.text,
                        description: _descController.text,
                        departmentId: selectedDept,
                        file: _selectedFile,
                      );
                      if (success && mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 55)),
                    child: notifier.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("PUBLISH DOCUMENT", style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                }
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("Policy Handbooks"), backgroundColor: Colors.transparent),
      body: Consumer<AdminOfficeNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading && notifier.policies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => notifier.fetchPolicies(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifier.policies.length,
              itemBuilder: (context, index) {
                final doc = notifier.policies[index];
                return _buildPolicyCard(doc, index);
              },
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        onPressed: _showUploadDialog,
        child: const Icon(Icons.add_to_photos),
      ),
    );
  }

  // ── UI WIDGET: POLICY CARD ──
  Widget _buildPolicyCard(PolicyHandbook doc, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: doc.isActive ? AppColors.greenLight.withOpacity(0.3) : AppColors.border),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.menu_book, color: doc.isActive ? AppColors.greenLight : AppColors.grey),
        title: Text(doc.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: doc.description != null ? Text(doc.description!, style: const TextStyle(color: AppColors.grey, fontSize: 11)) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: doc.isActive,
              activeColor: AppColors.greenLight,
              onChanged: (val) async {
                final success = await context.read<AdminOfficeNotifier>().updatePolicy(
                  doc.id,
                  {'is_active': val},
                );
                if (!success && mounted) {
                  showProAlert(
                    context,
                    title: "Update Failed",
                    message: context.read<AdminOfficeNotifier>().error ?? "Failed to update status",
                    isError: true,
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
              onPressed: () => context.read<AdminOfficeNotifier>().deletePolicy(doc.id),
            ),
          ],
        ),
        children: [
          const Divider(color: AppColors.border, height: 1),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Document Details", style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.file_present, color: AppColors.grey, size: 18),
            title: Text("Version ${doc.version}", style: const TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: doc.createdAt != null 
              ? Text("Uploaded: ${doc.createdAt!.toLocal().toString().split(' ')[0]}", style: const TextStyle(color: AppColors.grey, fontSize: 11))
              : null,
            trailing: TextButton(
              onPressed: () async {
                if (doc.fileUrl != null) {
                  final url = Uri.parse(doc.fileUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: const Text("View", style: TextStyle(color: Colors.blue)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ManageInternsPage extends StatefulWidget {
  const ManageInternsPage({super.key});

  @override
  State<ManageInternsPage> createState() => _ManageInternsPageState();
}

class _ManageInternsPageState extends State<ManageInternsPage> {
  final TextEditingController _searchController = TextEditingController();
  late AdminInternsListNotifier _internsProvider;

  @override
  void initState() {
    super.initState();
    _internsProvider = AdminInternsListNotifier();
    // Fetch interns when page loads
    _internsProvider.fetchInterns();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Intern Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.greenLight),
            onPressed: () => _showAddInternDialog(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _internsProvider,
        builder: (context, child) {
          return Column(
            children: [
              // ── QUICK STATS ──
              _buildTopStats(),

              // ── SEARCH BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) => _internsProvider.searchInterns(query),
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Search Interns",
                    hint: "Search by Name or Registration NR...",
                    icon: Icons.search,
                  ),
                ),
              ),

              // ── LOADING STATE ──
              if (_internsProvider.isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading interns...",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              // ── ERROR STATE ──
              else if (_internsProvider.error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _internsProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _internsProvider.fetchInterns(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // ── EMPTY STATE ──
              else if (_internsProvider.interns.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: AppColors.grey,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No interns found",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              // ── INTERN LIST ──
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _internsProvider.interns.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final intern = _internsProvider.interns[index];
                      return _internCard(intern, index);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _miniStat("Total", "${_internsProvider.totalInterns}", Colors.blue),
          _miniStat("Active", "${_internsProvider.activeInterns}", AppColors.green),
          _miniStat("Pending", "${_internsProvider.pendingInterns}", AppColors.gold),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _internCard(InternModel intern, int index) {
    final isPending = intern.account_status == 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // ── AVATAR & INFO ──
            CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Text(intern.fullName[0].toUpperCase(), style: const TextStyle(color: AppColors.greenLight)),
            ),
            const SizedBox(width: 12),
            
            // ── NAME & DEPARTMENT ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(intern.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("${intern.department ?? 'N/A'}${intern.departmentCode != null ? ' (${intern.departmentCode})' : ''}", 
                    style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                ],
              ),
            ),
            
            // ── APPROVAL BUTTONS (Only for pending interns) ──
            if (isPending) ...[
              IconButton(
                onPressed: () => _confirmApprove(intern),
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _confirmReject(intern),
                icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
            
            // ── THREE DOTS MENU ──
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.grey),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'view') {
                  _showInternInfo(context, intern);
                } else if (value == 'edit') {
                  _showEditInternDialog(context, intern);
                } else if (value == 'delete') {
                  _confirmDelete(intern);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.greenLight, size: 20),
                      SizedBox(width: 10),
                      Text("View Info", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      SizedBox(width: 10),
                      Text("Edit", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10),
                      Text("Delete", style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInternInfo(BuildContext context, InternModel intern) {
    // Fetch department and mentor data when dialog opens
    Future.delayed(Duration.zero, () {
      if (intern.departmentId != null) {
        _internsProvider.fetchDepartmentById(intern.departmentId!);
      }
      if (intern.mentorId != null) {
        _internsProvider.fetchMentorById(intern.mentorId!);
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.border)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.greenDeep,
                  child: Text(intern.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 30, color: Colors.white)),
                ),
                const SizedBox(height: 15),
                Text(intern.fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Intern Student", style: TextStyle(color: AppColors.greenLight.withOpacity(0.8), fontSize: 14)),

                const Divider(color: AppColors.border, height: 30),

                // Academic Info Rows with Dynamic Loading
                _infoRow(Icons.email_outlined, "Email", intern.email),
                
                // Department - Load code from API
                AnimatedBuilder(
                  animation: _internsProvider,
                  builder: (context, child) {
                    String displayValue = 'Loading...';
                    if (!_internsProvider.loadingDepartment) {
                      if (intern.departmentId != null) {
                        // You could extend this to also show department code from cache
                        displayValue = intern.department ?? 'N/A';
                      } else {
                        displayValue = 'N/A';
                      }
                    }
                    return _infoRow(Icons.school, "Department", displayValue);
                  },
                ),
                
                // Mentor - Load full name from API
                AnimatedBuilder(
                  animation: _internsProvider,
                  builder: (context, child) {
                    String displayValue = 'Loading...';
                    if (!_internsProvider.loadingMentor) {
                      if (intern.mentorId != null) {
                        // You could extend this to lookup mentor name from cache
                        displayValue = intern.mentor ?? 'Not Assigned';
                      } else {
                        displayValue = 'Not Assigned';
                      }
                    }
                    return _infoRow(Icons.person_outlined, "Mentor", displayValue);
                  },
                ),
                
                _infoRow(Icons.info_outline, "Status", intern.account_status),

                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _confirmDelete(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Remove Intern?", style: TextStyle(color: Colors.white)),
        content: Text("Delete ${intern.fullName}? All academic records will be removed.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _internsProvider.deleteIntern(intern.id);
              if (!context.mounted) return;
              
              if (success) {
                showProAlert(
                  context,
                  title: "Success",
                  message: "Intern deleted successfully",
                );
              } else {
                showProAlert(
                  context,
                  title: "Error",
                  message: _internsProvider.error ?? 'Failed to delete intern',
                  isError: true,
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditInternDialog(BuildContext context, InternModel intern) {
    final TextEditingController _fullNameController = TextEditingController(text: intern.fullName);
    final TextEditingController _emailController = TextEditingController(text: intern.email);
    String? _selectedDepartmentId = intern.departmentId;
    String? _selectedMentorId = intern.mentorId;
    final _formNotifier = CreateInternFormNotifier();

    // Initial load of departments and mentors if department is already selected
    _formNotifier.initializeFormData().then((_) {
      if (_selectedDepartmentId != null) {
        _formNotifier.fetchMentorsByDepartment(_selectedDepartmentId!);
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Edit Intern",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Full Name
                TextField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Full Name", hint: "John Doe", icon: Icons.person),
                ),
                const SizedBox(height: 15),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Email",
                    hint: "username@univ-constantine2.dz",
                    icon: Icons.alternate_email,
                  ),
                ),
                const SizedBox(height: 15),

                // Department Dropdown
                AnimatedBuilder(
                  animation: _formNotifier,
                  builder: (context, child) {
                    if (_formNotifier.departmentsLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Loading departments...", style: TextStyle(color: AppColors.grey)),
                          ],
                        ),
                      );
                    }

                    return Container(
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
                          value: _selectedDepartmentId,
                          hint: const Text("Select Department", style: TextStyle(color: AppColors.grey)),
                          items: _formNotifier.departments
                              .map((dept) => DropdownMenuItem(
                                  value: dept.id,
                                  child: Text(dept.name, style: const TextStyle(color: Colors.white))))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDepartmentId = val;
                              _selectedMentorId = null;
                            });
                            if (val != null) {
                              _formNotifier.fetchMentorsByDepartment(val);
                            } else {
                              _formNotifier.clearMentors();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // Mentor Dropdown
                AnimatedBuilder(
                  animation: _formNotifier,
                  builder: (context, child) {
                    final isMentorDisabled = _selectedDepartmentId == null;

                    if (_selectedDepartmentId != null && _formNotifier.mentorsLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Loading mentors...", style: TextStyle(color: AppColors.grey)),
                          ],
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isMentorDisabled ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMentorDisabled ? AppColors.border.withOpacity(0.5) : AppColors.border,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          value: _selectedMentorId,
                          disabledHint: const Text("Select Department First", style: TextStyle(color: AppColors.greyDark)),
                          hint: const Text("Select Mentor", style: TextStyle(color: AppColors.grey)),
                          items: isMentorDisabled
                              ? <DropdownMenuItem<String>>[]
                              : _formNotifier.mentors
                                  .map((mentor) {
                                    final name = mentor['full_name'] ?? mentor['fullName'] ?? 'Unknown';
                                    final id = (mentor['_id'] ?? mentor['id'] ?? '').toString();
                                    return DropdownMenuItem<String>(
                                        value: id, child: Text(name, style: const TextStyle(color: Colors.white)));
                                  })
                                  .toList(),
                          onChanged: isMentorDisabled ? null : (val) => setState(() => _selectedMentorId = val),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // Save Button
                ElevatedButton(
                  onPressed: () async {
                    if (_fullNameController.text.isEmpty || _emailController.text.isEmpty) {
                      showProAlert(
                        context,
                        title: "Incomplete Form",
                        message: "Please fill in all required fields",
                        isError: true,
                      );
                      return;
                    }

                    final updateData = {
                      'full_name': _fullNameController.text.trim(),
                      'email': _emailController.text.trim(),
                      if (_selectedDepartmentId != null) 'department_id': _selectedDepartmentId,
                      if (_selectedMentorId != null) 'mentor_id': _selectedMentorId,
                    };

                    final success = await _internsProvider.updateIntern(intern.id, updateData);

                    if (!context.mounted) return;

                    if (success) {
                      showProAlert(
                        context,
                        title: "Success",
                        message: "Intern updated successfully",
                      );
                      Navigator.pop(context);
                    } else {
                      showProAlert(
                        context,
                        title: "Error",
                        message: _internsProvider.error ?? 'Failed to update intern',
                        isError: true,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmApprove(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Approve Intern?", style: TextStyle(color: Colors.white)),
        content: Text("Approve ${intern.fullName}? They will gain access to the system.",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _internsProvider.approveIntern(intern.id);
              if (!context.mounted) return;

              if (success) {
                showProAlert(
                  context,
                  title: "Approved",
                  message: "Intern approved successfully",
                );
              } else {
                showProAlert(
                  context,
                  title: "Error",
                  message: _internsProvider.error ?? 'Failed to approve intern',
                  isError: true,
                );
              }
            },
            child: const Text("Approve", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _confirmReject(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Reject Intern?", style: TextStyle(color: Colors.white)),
        content: Text("Reject ${intern.fullName}? They will NOT gain access to the system.",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _internsProvider.rejectIntern(intern.id);
              if (!context.mounted) return;

              if (success) {
                showProAlert(
                  context,
                  title: "Rejected",
                  message: "Intern rejected successfully",
                );
              } else {
                showProAlert(
                  context,
                  title: "Error",
                  message: _internsProvider.error ?? 'Failed to reject intern',
                  isError: true,
                );
              }
            },
            child: const Text("Reject", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ── THE DETAILED "MANY INFO" DIALOG ──
  void _showAddInternDialog(BuildContext context) {
    // Controllers for form fields
    final TextEditingController _fullNameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final CreateInternNotifier _internNotifier = CreateInternNotifier();
    final CreateInternFormNotifier _formNotifier = CreateInternFormNotifier();
    String? _selectedMentorId;
    String? _selectedDepartmentId;

    // Initialize form data when dialog opens
    _formNotifier.initializeFormData();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Create new Intern",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Full Name
                TextField(
                    controller: _fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(label: "Full Name", hint: "John Doe", icon: Icons.person)
                ),
                const SizedBox(height: 15),

                // Email
                TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.greenLight),
                    decoration: proLinkInputDecoration(
                        label: "Email",
                        hint: "username@univ-constantine2.dz",
                        icon: Icons.alternate_email
                    )
                ),
                const SizedBox(height: 15),

                // Password
                TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                        label: "Password",
                        hint: "Enter initial password",
                        icon: Icons.lock
                    )
                ),
                const SizedBox(height: 15),

                // Department Dropdown (with loading state)
                AnimatedBuilder(
                  animation: _formNotifier,
                  builder: (context, child) {
                    if (_formNotifier.departmentsLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Loading departments...", style: TextStyle(color: AppColors.grey)),
                          ],
                        ),
                      );
                    }

                    if (_formNotifier.departmentsError != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          "❌ ${_formNotifier.departmentsError}",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      );
                    }

                    return Container(
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
                          value: _selectedDepartmentId,
                          hint: const Text("Select Department", style: TextStyle(color: AppColors.grey)),
                          items: _formNotifier.departments
                              .map((dept) => DropdownMenuItem(
                                  value: dept.id,
                                  child: Text(dept.name, style: const TextStyle(color: Colors.white))))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDepartmentId = val;
                              _selectedMentorId = null; // Reset mentor when department changes
                            });
                            if (val != null) {
                              _formNotifier.fetchMentorsByDepartment(val);
                            } else {
                              _formNotifier.clearMentors();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // Mentor Assignment Dropdown (with loading state, only enabled if department selected)
                AnimatedBuilder(
                  animation: _formNotifier,
                  builder: (context, child) {
                    final isMentorDisabled = _selectedDepartmentId == null;

                    if (_selectedDepartmentId != null && _formNotifier.mentorsLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Loading mentors...", style: TextStyle(color: AppColors.grey)),
                          ],
                        ),
                      );
                    }

                    if (_selectedDepartmentId != null && _formNotifier.mentorsError != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          "❌ ${_formNotifier.mentorsError}",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isMentorDisabled ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMentorDisabled ? AppColors.border.withOpacity(0.5) : AppColors.border,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          value: _selectedMentorId,
                          disabledHint: const Text(
                            "Select Department First",
                            style: TextStyle(color: AppColors.greyDark),
                          ),
                          hint: const Text("Select Mentor", style: TextStyle(color: AppColors.grey)),
                          items: isMentorDisabled ? <DropdownMenuItem<String>>[]
                              : _formNotifier.mentors
                                  .map((mentor) {
                                    final name = mentor['full_name'] ?? mentor['fullName'] ?? 'Unknown';
                                    final id = (mentor['_id'] ?? mentor['id'] ?? '').toString();
                                    return DropdownMenuItem<String>(
                                        value: id,
                                        child: Text(name, style: const TextStyle(color: Colors.white)));
                                  })
                                  .toList(),
                          onChanged: isMentorDisabled
                              ? null
                              : (val) {
                                  setState(() => _selectedMentorId = val);
                                },
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                AnimatedBuilder(
                  animation: _internNotifier,
                  builder: (context, child) {
                    return ElevatedButton(
                      onPressed: () async {
                        print('═══════════════════════════════════════════════════════════');
                        print('🎯 CREATE BUTTON PRESSED!');
                        print('═══════════════════════════════════════════════════════════');

                        // Validate ONLY required fields
                        String? validationError;

                        if (_fullNameController.text.isEmpty) {
                          validationError = "⚠️ Please enter full name";
                        } else if (_emailController.text.isEmpty) {
                          validationError = "⚠️ Please enter email";
                        } else if (_passwordController.text.isEmpty) {
                          validationError = "⚠️ Please enter password";
                        }

                        if (validationError != null) {
                          print('⛔ Validation Error: $validationError');
                          showProAlert(
                            context,
                            title: "Invalid Input",
                            message: validationError,
                            isError: true,
                          );
                          return;
                        }

                        print('✅ Validation passed - Department & Mentor are OPTIONAL');
                        
                        if (_selectedDepartmentId != null) print('Department ID: $_selectedDepartmentId');
                        if (_selectedMentorId != null) print('Mentor ID: $_selectedMentorId');

                        // Show request body for debugging
                        final requestBody = {
                          'full_name': _fullNameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'password': _passwordController.text,
                          if (_selectedDepartmentId != null) 'department_id': _selectedDepartmentId,
                          if (_selectedMentorId != null) 'mentor_id': _selectedMentorId,
                        };

                        print('═══════════════════════════════════════════════════════════');
                        print('📋 REQUEST BODY FROM UI:');
                        print(requestBody.toString());
                        print('═══════════════════════════════════════════════════════════');

                        print('🚀 Calling _internNotifier.createIntern()...');

                        // Call provider to create intern
                        final success = await _internNotifier.createIntern(
                          fullName: _fullNameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          department: _selectedDepartmentId,
                          mentor: _selectedMentorId,
                        );

                        print('🔄 Returned from _internNotifier.createIntern() - success: $success');

                        if (!context.mounted) return;

                        if (success) {
                          print('✅ SUCCESS: Intern created');
                          showProAlert(
                            context,
                            title: "Success",
                            message: _internNotifier.message ?? 'Intern created successfully',
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (mounted) {
                                setState(() {
                                  // Refresh the list
                                  _internsProvider.fetchInterns();
                                });
                              }
                            }
                          });
                        } else {
                          print('❌ FAILED: ${_internNotifier.error}');
                          showProAlert(
                            context,
                            title: "Creation Failed",
                            message: _internNotifier.error ?? 'Failed to create intern',
                            isError: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _internNotifier.isLoading ? AppColors.grey : AppColors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: _internNotifier.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("CREATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Admin Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader("General"),
          _settingsTile(Icons.language, "Language", "English (US)", () {
            // Show Language Picker
          }),
          _settingsTile(Icons.dark_mode, "Appearance", "Dark Mode", null),

          const SizedBox(height: 25),
          _sectionHeader("System Control"),
          _settingsTile(Icons.notifications_active, "Push Notifications", "On", () {}),
          _settingsTile(Icons.security, "Two-Factor Auth", "Highly Recommended", () {}),
          _settingsTile(Icons.storage, "Database Backup", "Last sync: 2h ago", () {}),

          const SizedBox(height: 25),
          _sectionHeader("Organization"),
          _settingsTile(Icons.domain, "University Details", "Constantine 2", () {}),
          _settingsTile(Icons.admin_panel_settings, "Role Permissions", "Edit access levels", () {}),

          const SizedBox(height: 40),
          Center(
            child: Text("Pro-Link v1.0.4", style: TextStyle(color: AppColors.grey.withOpacity(0.5), fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(color: AppColors.greenLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
      ),
    );
  }
}
class ReviewRequestPage extends StatefulWidget {
  final String name;
  final String department;

  const ReviewRequestPage({super.key, required this.name, required this.department});

  @override
  State<ReviewRequestPage> createState() => _ReviewRequestPageState();
}

class _ReviewRequestPageState extends State<ReviewRequestPage> {
  // 1. Controller to capture the rejection reason
  final TextEditingController _reasonController = TextEditingController();

  // 2. The Logic Function
  void _handleAction(bool isApproved) {
    if (!isApproved && _reasonController.text.trim().isEmpty) {
      // If rejecting, make sure they wrote a reason
      showProAlert(
        context,
        title: "Reason Required",
        message: "Please provide a reason for rejection",
        isError: true,
      );
      return;
    }

    // Success Message
    showProAlert(
      context,
      title: isApproved ? "Request Approved" : "Request Rejected",
      message: isApproved ? "${widget.name} has been approved." : "The request has been rejected.",
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Review Request", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150')),
            const SizedBox(height: 15),
            Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.department, style: const TextStyle(color: AppColors.grey, fontSize: 16)),
            const SizedBox(height: 15),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_filled, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text("Pending Validation", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Details Card
            _buildDetailCard(),
            const SizedBox(height: 25),

            // 3. ADDED: Reason for Rejection Field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(" Admin Notes / Rejection Reason", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Reason",
                hint: "Type reason if rejecting...",
                icon: Icons.edit_note,
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction(false), // Reject
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(16)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction(true), // Approve
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.all(16)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Application Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          Divider(color: AppColors.border, height: 30),
          _detailRow("Full Name", widget.name),
          _detailRow("Email", "${widget.name.toLowerCase().replaceAll(' ', '.')}@university.edu"),
          _detailRow("Registration", "Oct 24, 2023"),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
class AllRequestsPage extends StatefulWidget {
  const AllRequestsPage({super.key});

  @override
  State<AllRequestsPage> createState() => _AllRequestsPageState();
}

class _AllRequestsPageState extends State<AllRequestsPage> {
  late AdminInternsListNotifier _pendingProvider;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pendingProvider = context.read<AdminInternsListNotifier>();
    _pendingProvider.fetchPendingInterns();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Pending Requests"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar to find specific requests
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Search Requests",
                hint: "Filter by name...",
                icon: Icons.search,
              ),
            ),
          ),

          Expanded(
            child: AnimatedBuilder(
              animation: _pendingProvider,
              builder: (context, child) {
                // Loading state
                if (_pendingProvider.pendingLoading)
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                    ),
                  );

                // Error state
                if (_pendingProvider.error != null)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            _pendingProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _pendingProvider.fetchPendingInterns(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );

                // Empty state
                if (_pendingProvider.pendingInternsList.isEmpty)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.grey, size: 60),
                        const SizedBox(height: 16),
                        const Text(
                          "✅ No pending requests",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  );

                // Pending interns list
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _pendingProvider.pendingInternsList.length,
                  itemBuilder: (context, index) {
                    final intern = _pendingProvider.pendingInternsList[index];
                    return _requestCard(context, intern);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Card with approve/decline circular buttons (same as ManageInterns)
  Widget _requestCard(BuildContext context, InternModel intern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // ── AVATAR & INFO ──
            CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Text(
                intern.fullName[0].toUpperCase(),
                style: const TextStyle(color: AppColors.greenLight),
              ),
            ),
            const SizedBox(width: 12),

            // ── NAME & DEPARTMENT ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intern.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${intern.department ?? 'N/A'}${intern.departmentCode != null ? ' (${intern.departmentCode})' : ''}",
                    style: const TextStyle(color: AppColors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),

            // ── APPROVE & REJECT BUTTONS ──
            IconButton(
              onPressed: () => _confirmApproveRequest(intern),
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _confirmRejectRequest(intern),
              icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmApproveRequest(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Approve ${intern.fullName}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'They will gain access to the system.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = context.read<AdminInternsListNotifier>();
              final success = await notifier.approveIntern(intern.id);
              if (!context.mounted) return;

              if (success) {
                showProAlert(
                  context,
                  title: 'Success',
                  message: 'Intern approved successfully',
                );
              } else {
                showProAlert(
                  context,
                  title: 'Error',
                  message: notifier.error ?? 'Failed to approve intern',
                  isError: true,
                );
              }
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _confirmRejectRequest(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reject ${intern.fullName}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'They will NOT gain access to the system.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = context.read<AdminInternsListNotifier>();
              final success = await notifier.rejectIntern(intern.id);
              if (!context.mounted) return;

              if (success) {
                showProAlert(
                  context,
                  title: 'Success',
                  message: 'Intern rejected successfully',
                );
              } else {
                showProAlert(
                  context,
                  title: 'Error',
                  message: notifier.error ?? 'Failed to reject intern',
                  isError: true,
                );
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
class ProLinkApp extends StatelessWidget {
  const ProLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro-Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoginPage(),
      routes: {
        '/login':  (context) => const LoginPage(),
        '/admin':  (context) => const AdminDashboard(),
        '/mentor': (context) => const MentorDashboard(),
        '/intern': (context) => const InternDashboard(),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Particle System (animated background)
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  double x, y, radius, speed, angle, opacity, drift;
  _Particle({
    required this.x, required this.y, required this.radius,
    required this.speed, required this.angle,
    required this.opacity, required this.drift,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlesPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // ── Radial background gradient ───────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.35),
        radius: 0.85,
        colors: [Color(0xFF0D3520), Color(0xFF070D09)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── Subtle horizontal scanlines (depth effect) ───────────────────────────
    final linePaint = Paint()
      ..color = AppColors.greenDeep.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // ── Compute current particle positions ───────────────────────────────────
    final List<Offset> positions = particles.map((p) {
      return Offset(
        p.x * size.width  + math.cos(p.angle + t * p.speed) * p.drift,
        p.y * size.height + math.sin(p.angle + t * p.speed) * p.drift,
      );
    }).toList();

    // ── Connecting lines ──────────────────────────────────────────────────────
    final connPaint = Paint()..strokeWidth = 0.5;
    final threshold = size.width * 0.22;
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final d = (positions[j] - positions[i]).distance;
        if (d < threshold) {
          connPaint.color = AppColors.border.withOpacity(0.35 * (1 - d / threshold));
          canvas.drawLine(positions[i], positions[j], connPaint);
        }
      }
    }

    // ── Particles ─────────────────────────────────────────────────────────────
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final pos = positions[i];

      // glow
      canvas.drawCircle(pos, p.radius * 3.5,
          Paint()
            ..color = AppColors.greenLight.withOpacity(p.opacity * 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

      // core
      canvas.drawCircle(pos, p.radius,
          Paint()..color = AppColors.green.withOpacity(p.opacity * 0.7));
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Login Page
// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _bgCtrl;   // particle loop
  late final AnimationController _entryCtrl; // card entry
  late final AnimationController _logoCtrl;  // logo pulse

  late final Animation<double> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _logoPulse;

  // ── Form state ─────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;
  int  _selectedRole = 0; // 0=Admin  1=Mentor  2=Intern

  static const _roles     = ['Admin',                    'Mentor',              'Intern'];
  static const _roleIcons = [Icons.admin_panel_settings, Icons.school_rounded,  Icons.badge_rounded];
  static const _roleColors = [AppColors.gold, AppColors.greenLight, AppColors.teal];

  // ── Particle data ──────────────────────────────────────────────────────────
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Particle background — infinite loop
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

    // Card slides up on enter
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _cardSlide = Tween<double>(begin: 90, end: 0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0, 0.7, curve: Curves.easeOut)));

    // Logo gentle pulse
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _logoPulse = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    // Seeded particles for a consistent layout
    final rng = math.Random(7);
    _particles = List.generate(20, (i) => _Particle(
      x:       rng.nextDouble(),
      y:       rng.nextDouble(),
      radius:  rng.nextDouble() * 2.5 + 1,
      speed:   rng.nextDouble() * 0.28 + 0.04,
      angle:   rng.nextDouble() * math.pi * 2,
      opacity: rng.nextDouble() * 0.5 + 0.2,
      drift:   rng.nextDouble() * 28 + 10,
    ));

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    _logoCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _isLoading = false);
    const routes = ['/admin', '/mentor', '/intern'];
    Navigator.pushReplacementNamed(context, routes[_selectedRole]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Particle layer
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlesPainter(_particles, _bgCtrl.value * math.pi * 2),
              size: Size.infinite,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _entryCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _cardFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _cardSlide.value),
                        child: child,
                      ),
                    ),
                    child: _buildCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (logo + title) ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Column(children: [
        // Animated logo bubble
        ScaleTransition(
          scale: _logoPulse,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.greenDeep, AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.green.withOpacity(0.5), blurRadius: 28, spreadRadius: 2),
              ],
              border: Border.all(color: AppColors.greenLight.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 38),
          ),
        ),
        const SizedBox(height: 14),
        // Pro-Link gradient text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.white, AppColors.greenGlow],
          ).createShader(bounds),
          child: const Text('Pro-Link',
              style: TextStyle(color: Colors.white, fontSize: 34,
                  fontWeight: FontWeight.w800, letterSpacing: 2.5, fontFamily: 'Poppins')),
        ),
        const SizedBox(height: 3),
        Text('Enterprise Internship & Skill Tracking',
            style: TextStyle(color: AppColors.grey.withOpacity(0.85),
                fontSize: 12, letterSpacing: 1.1, fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text('Constantine 2 University  ·  IFA',
            style: TextStyle(color: AppColors.gold.withOpacity(0.7),
                fontSize: 11, letterSpacing: 0.8, fontFamily: 'Poppins')),
      ]),
    );
  }

  // ── Login card ────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // Title
                const Text('Welcome Back',
                    style: TextStyle(color: AppColors.white, fontSize: 22,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                const SizedBox(height: 3),
                Text('Sign in to continue to your workspace',
                    style: TextStyle(color: AppColors.grey, fontSize: 13, fontFamily: 'Poppins')),
                const SizedBox(height: 22),

                // Role selector
                _buildRoleSelector(),
                const SizedBox(height: 22),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.white, fontFamily: 'Poppins'),
                  decoration: proLinkInputDecoration(
                      label: 'Email Address', hint: 'you@prolink.app',
                      icon: Icons.email_outlined),
                  validator: (v) => (v == null || v.isEmpty) ? 'Email required' : null,
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: const TextStyle(color: AppColors.white, fontFamily: 'Poppins'),
                  decoration: proLinkInputDecoration(
                      label: 'Password', hint: '••••••••',
                      icon: Icons.lock_outline_rounded).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.grey, size: 20),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 4) ? 'Password too short' : null,
                ),
                const SizedBox(height: 6),

                // Forgot
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: AppColors.greenLight,
                        padding: EdgeInsets.zero),
                    child: const Text('Forgot Password?',
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
                  ),
                ),
                const SizedBox(height: 14),

                // Login button
                GradientButton(label: 'Sign In', icon: Icons.login_rounded,
                    onTap: _login, isLoading: _isLoading),
                const SizedBox(height: 20),

                // Footer
                Row(children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Pro-Link © 2025',
                        style: TextStyle(color: AppColors.greyDark, fontSize: 11, fontFamily: 'Poppins')),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Role selector ─────────────────────────────────────────────────────────
  Widget _buildRoleSelector() {
    return LayoutBuilder(builder: (context, constraints) {
      final itemW = (constraints.maxWidth - 8) / 3;
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(children: [
          // Sliding highlight
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            left: _selectedRole * itemW + 4,
            top: 4, bottom: 4,
            width: itemW - 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_roleColors[_selectedRole].withOpacity(0.25),
                    _roleColors[_selectedRole].withOpacity(0.15)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _roleColors[_selectedRole].withOpacity(0.5)),
              ),
            ),
          ),
          // Tabs
          Row(children: List.generate(3, (i) {
            final active = i == _selectedRole;
            return GestureDetector(
              onTap: () => setState(() => _selectedRole = i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: itemW,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  AnimatedScale(
                    scale: active ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(_roleIcons[i],
                        size: 18,
                        color: active ? _roleColors[i] : AppColors.greyDark),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                        color: active ? _roleColors[i] : AppColors.greyDark,
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        fontFamily: 'Poppins'),
                    child: Text(_roles[i]),
                  ),
                ]),
              ),
            );
          })),
        ]),
      );
    });
  }
}
