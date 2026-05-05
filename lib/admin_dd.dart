import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'theme.dart';
import 'mentor_dashboard.dart';
import 'intern_dashboard_live.dart';
import 'models/department_model.dart';
import 'models/office_schedule_model.dart';
import 'models/policy_document_model.dart';
import 'providers/admin_office_provider.dart';
import 'services/admin_department_service.dart';
import 'services/api_exception.dart';

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

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // ── THE THREE LINES MENU (DRAWER) - Unchanged ──
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            const DrawerHeader(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hub_rounded, color: AppColors.greenLight, size: 50),
                    SizedBox(height: 10),
                    Text("ADMIN PORTAL", style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.2)),
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

            // NEW: Policy & Documents Screen
            _drawerTile(context, Icons.menu_book_rounded, "Policy Handbooks", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PolicyManagementPage()));
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

            // 4. System & Exit
            _drawerTile(context, Icons.settings, "Settings", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSettingsPage()));
            }),

            const Spacer(),
            _drawerTile(context, Icons.analytics_outlined, "Reports & Analytics", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
            }),

            _drawerTile(
                context,
                Icons.logout,
                "Logout",
                    () => Navigator.pushReplacementNamed(context, '/login'),
                color: Colors.redAccent
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP SEARCH BAR (From Photo 1)
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Search",
                hint: "Search Intern Records...",
                icon: Icons.search,
              ),
            ),
            const SizedBox(height: 25),

            // 2. PENDING VALIDATIONS SECTION
            const Text("Pending Intern Validations",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Review and approve new student registrations.",
                style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 15),
            _invitationCard(context, "Lina Bouzid", "AI Department"),
            _invitationCard(context, "Omar Khelil", "Web Dev"),

            Center(
              child: TextButton(
                  onPressed: () {
                    // Navigates to the new list page
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllRequestsPage())
                    );
                  },
                  child: const Text("View All Requests", style: TextStyle(color: AppColors.greenLight))
              ),
            ),

            const SizedBox(height: 20),

            // 3. ASSIGNMENTS SECTION (The Stats Grid from Photo 1)
            // 3. ASSIGNMENTS SECTION
            const Text("Assignments",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                    child: _buildSmallStatCard(
                        "Active Interns",
                        "128",
                        AppColors.greenLight,
                        Icons.groups_rounded // Icon for interns
                    )
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildSmallStatCard(
                        "Unassigned",
                        "12",
                        AppColors.red,
                        Icons.person_off_rounded // Icon for unassigned
                    )
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text("Quick Assign Intern"),
              style: ElevatedButton.styleFrom(
                backgroundColor : AppColors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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

  Widget _buildResourceTile(String title, String status, IconData icon, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.description, color: Colors.white, size: 24),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(icon, size: 14, color: statusColor),
            const SizedBox(width: 5),
            Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.file_download_outlined, color: AppColors.grey),
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

  Widget _invitationCard(BuildContext context, String name, String dept) {
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
          CircleAvatar(backgroundColor: AppColors.surface, child: Text(name[0], style: const TextStyle(color: AppColors.greenLight))),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(dept, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ]
              )
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewRequestPage(name: name, department: dept)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Review"),
          )
        ],
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // --- MOCK DATA FOR ATTENDANCE ---
  final List<Map<String, dynamic>> attendanceData = [
    {"name": "Ahmed Benali", "dept": "AI", "present": "95%", "status": "Excellent"},
    {"name": "Sara Zeghidi", "dept": "Web", "present": "82%", "status": "Good"},
    {"name": "Mourad Kasmi", "dept": "Cyber", "present": "60%", "status": "Warning"},
  ];

  // --- MOCK DATA FOR EVALUATIONS ---
  final List<Map<String, dynamic>> evaluationData = [
    {"intern": "Ahmed Benali", "mentor": "Dr. Rahmani", "score": 18.5, "comment": "Highly Proactive"},
    {"intern": "Sara Zeghidi", "mentor": "Prof. Zenati", "score": 14.0, "comment": "Good progress"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("University Reports"),
        backgroundColor: Colors.transparent,
        actions: [
          // THE EXPORT BUTTON
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generating PDF/Excel Report..."), backgroundColor: AppColors.green),
              );
            },
            icon: const Icon(Icons.download_rounded, color: AppColors.greenLight),
            label: const Text("Export", style: TextStyle(color: AppColors.greenLight)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Attendance Summary"),
            _buildAttendanceTable(),
            const SizedBox(height: 30),
            _sectionHeader("Evaluation Summaries"),
            _buildEvaluationList(),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // --- ATTENDANCE TABLE ---
  Widget _buildAttendanceTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: DataTable(
        columnSpacing: 15,
        headingRowColor: MaterialStateProperty.all(AppColors.surface),
        columns: const [
          DataColumn(label: Text("Intern", style: TextStyle(color: AppColors.grey))),
          DataColumn(label: Text("Dept", style: TextStyle(color: AppColors.grey))),
          DataColumn(label: Text("Present", style: TextStyle(color: AppColors.grey))),
          DataColumn(label: Text("Status", style: TextStyle(color: AppColors.grey))),
        ],
        rows: attendanceData.map((data) => DataRow(
          cells: [
            DataCell(Text(data['name'], style: const TextStyle(color: Colors.white, fontSize: 12))),
            DataCell(Text(data['dept'], style: const TextStyle(color: Colors.white, fontSize: 12))),
            DataCell(Text(data['present'], style: const TextStyle(color: AppColors.greenLight, fontSize: 12))),
            DataCell(Text(data['status'], style: TextStyle(
                color: data['status'] == 'Warning' ? Colors.redAccent : Colors.white,
                fontSize: 11, fontWeight: FontWeight.bold
            ))),
          ],
        )).toList(),
      ),
    );
  }

  // --- EVALUATION LIST ---
  Widget _buildEvaluationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: evaluationData.length,
      itemBuilder: (context, index) {
        final eval = evaluationData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Text("${eval['score']}", style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eval['intern'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Mentor: ${eval['mentor']}", style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Text(eval['comment'], style: const TextStyle(color: AppColors.greenLight, fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }
}

class ManageMentorsPage extends StatefulWidget {
  const ManageMentorsPage({super.key});

  @override
  State<ManageMentorsPage> createState() => _ManageMentorsPageState();
}

class _ManageMentorsPageState extends State<ManageMentorsPage> {
  // Demo Data - You can expand this list
  final List<Map<String, dynamic>> mentors = [
    {"name": "Dr. Amine Rahmani", "specialty": "Machine Learning", "interns": 5, "email": "rahmani.a@univ-constantine2.dz"},
    {"name": "Prof. Sarah Zenati", "specialty": "Software Eng", "interns": 3, "email": "s.zenati@univ-constantine2.dz"},
    {"name": "M. Karim Loukil", "specialty": "Cybersecurity", "interns": 8, "email": "k.loukil@univ-constantine2.dz"},
  ];

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
      body: Column(
        children: [
          // Statistics Summary
          _buildMentorStats(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Search Mentors",
                hint: "Name or Specialty...",
                icon: Icons.search,
              ),
            ),
          ),

          // List of Mentors
          Expanded(
            child: ListView.builder(
              itemCount: mentors.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final mentor = mentors[index];
                return _mentorCard(mentor, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Statistics Header
  Widget _buildMentorStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _miniStat("Total Mentors", "${mentors.length}", AppColors.gold),
          _miniStat("Total Capacity", "45", AppColors.greenLight),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ],
    );
  }

  // Individual Mentor Card with Popup Menu
  Widget _mentorCard(Map<String, dynamic> mentor, int index) {
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
          child: Text(mentor['name'][0],
              style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
        ),
        title: Text(mentor['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mentor['specialty'], style: const TextStyle(color: AppColors.greenLight, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_outline, color: AppColors.grey, size: 14),
                const SizedBox(width: 4),
                Text("Supervising: ${mentor['interns']} Interns",
                    style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
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
              _showMentorInfo(context, mentor);
            } else if (value == 'delete') {
              _confirmDeleteMentor(index);
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

            // 1. Official Email
            _infoRow(Icons.alternate_email, "University Gmail", mentor['email']),

            // 2. Specialty
            _infoRow(Icons.workspace_premium, "Specialty", mentor['specialty']),

            // 3. Department (Added)
            _infoRow(Icons.business, "Department", mentor['dept'] ?? "Computer Science"),

            // 4. Phone (Added)
            _infoRow(Icons.phone, "Contact", mentor['phone'] ?? "No Phone Added"),

            // 5. DIPLOMA VIEW ROW
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.greenLight, size: 18),
                  const SizedBox(width: 12),
                  const Text("Diploma:", style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        // Logic to open the PDF/Image
                      },
                      child: const Text("View File",
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
                  )
                ],
              ),
            ),

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  // Create Mentor Form
  // 1. Updated Registration Form
  void _showAddMentorDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
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
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Full Name", hint: "Dr. Name", icon: Icons.person)),
              const SizedBox(height: 15),

              // SPECIALIZED FIELD: University Gmail
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.greenLight),
                  decoration: proLinkInputDecoration(
                      label: "University Gmail",
                      hint: "username@univ-constantine2.dz",
                      icon: Icons.alternate_email
                  )),
              const SizedBox(height: 15),

              TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Specialty", hint: "e.g. AI", icon: Icons.workspace_premium)),
              const SizedBox(height: 20),

              // NEW: DIPLOMA UPLOAD SPACE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(" Verification Document", style: TextStyle(color: AppColors.grey, fontSize: 13)),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Logic to pick file/image will go here
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening File Picker...")));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, color: AppColors.greenLight),
                      SizedBox(width: 10),
                      Text("Upload Mentor Diploma (PDF/JPG)", style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("CREATE MENTOR ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }



  // Delete Confirmation
  void _confirmDeleteMentor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Remove Mentor?", style: TextStyle(color: Colors.white)),
        content: const Text("Warning: This will unassign all interns currently supervised by this mentor."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                setState(() => mentors.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text("Remove", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
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
  late final AdminOfficeProvider _officeProvider;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _officeProvider = AdminOfficeProvider();
    _officeProvider.loadSchedules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _officeProvider.dispose();
    super.dispose();
  }

  void _filterSchedules(String query) {
    setState(() => _searchTerm = query.trim().toLowerCase());
  }

  List<OfficeScheduleModel> _filteredSchedules(List<OfficeScheduleModel> items) {
    if (_searchTerm.isEmpty) {
      return items;
    }

    return items.where((schedule) {
      final haystack = [
        schedule.title,
        schedule.description ?? '',
        schedule.departmentCode ?? '',
        schedule.departmentId ?? '',
      ].join(' ').toLowerCase();

      return haystack.contains(_searchTerm);
    }).toList();
  }

  String _scheduleDescription(OfficeScheduleModel schedule) {
    final direct = (schedule.description ?? '').trim();
    if (direct.isNotEmpty) {
      return direct;
    }

    final notes = (schedule.notes ?? '').trim();
    if (notes.isNotEmpty) {
      return notes;
    }

    final timeParts = <String>[];
    if ((schedule.startTime ?? '').trim().isNotEmpty) {
      timeParts.add(schedule.startTime!.trim());
    }
    if ((schedule.endTime ?? '').trim().isNotEmpty) {
      timeParts.add(schedule.endTime!.trim());
    }
    if (timeParts.isNotEmpty) {
      return 'Time: ${timeParts.join(' - ')}';
    }

    return 'No description';
  }

  Future<void> _openScheduleDetails(OfficeScheduleModel schedule) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: AppColors.greenLight, strokeWidth: 2),
      ),
    );

    final details = await _officeProvider.getScheduleById(schedule.id);

    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_officeProvider.error ?? 'Unable to fetch schedule details.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final summary = [
      if ((details.departmentCode ?? '').trim().isNotEmpty) 'Dept: ${details.departmentCode}',
      if (details.version != null) 'v${details.version}',
      if ((details.weekday ?? '').trim().isNotEmpty) details.weekday!,
      if ((details.scheduleDate ?? '').trim().isNotEmpty) details.scheduleDate!,
    ].join(' • ');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (details.title).trim().isEmpty ? 'Schedule' : details.title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _scheduleDescription(details),
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                summary,
                style: const TextStyle(color: AppColors.greenLight, fontSize: 12),
              ),
            ],
            if ((details.fileUrl ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                details.fileUrl!,
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final departmentCodeController = TextEditingController();
    final versionController = TextEditingController();

    PlatformFile? selectedFile;
    bool isSubmitting = false;
    String? modalError;

    showModalBottomSheet<void>(
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
                const Text("Create Schedule",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Title (Optional)",
                    hint: "e.g. Office Schedule v1",
                    icon: Icons.title,
                  ),
                ),

                const SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Description",
                    hint: "Optional schedule description",
                    icon: Icons.notes,
                  ),
                ),

                const SizedBox(height: 15),
                TextField(
                  controller: departmentCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Department Code",
                    hint: "e.g. DEV",
                    icon: Icons.business,
                  ),
                ),

                const SizedBox(height: 15),
                TextField(
                  controller: versionController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Version",
                    hint: "1",
                    icon: Icons.history,
                  ),
                ),

                const SizedBox(height: 20),
                _uploadBox(
                  label: 'Upload Time-Table PDF',
                  selectedFileName: selectedFile?.name,
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['pdf'],
                      withData: true,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      setModalState(() {
                        selectedFile = result.files.first;
                        modalError = null;
                      });
                    }
                  },
                ),

                if (modalError != null) ...[
                  const SizedBox(height: 12),
                  Text(modalError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (versionController.text.trim().isNotEmpty &&
                                  int.tryParse(versionController.text.trim()) == null) {
                            setModalState(() => modalError = 'Version must be numeric.');
                            return;
                          }

                          if (selectedFile == null || selectedFile?.bytes == null) {
                            setModalState(() => modalError = 'Please select a PDF file first.');
                            return;
                          }

                          setModalState(() {
                            isSubmitting = true;
                            modalError = null;
                          });

                          final success = await _officeProvider.uploadSchedule(
                            title: titleController.text.trim(),
                            fileBytes: selectedFile!.bytes!,
                            fileName: selectedFile!.name,
                            description: descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            departmentCode: departmentCodeController.text.trim().isEmpty
                                ? null
                                : departmentCodeController.text.trim(),
                            version: int.tryParse(versionController.text.trim()),
                          );

                          if (!mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.of(this.context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule uploaded successfully.'),
                                backgroundColor: AppColors.green,
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            modalError = _officeProvider.error ?? 'Unable to upload schedule.';
                            isSubmitting = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50)),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("SAVE SCHEDULE"),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
      departmentCodeController.dispose();
      versionController.dispose();
    });
  }

  void _showEditScheduleDialog(OfficeScheduleModel schedule) {
    final titleController = TextEditingController(text: schedule.title);
    final descriptionController = TextEditingController(text: schedule.description ?? '');
    final departmentCodeController = TextEditingController(text: schedule.departmentCode ?? '');
    final versionController = TextEditingController(
      text: schedule.version == null ? '' : schedule.version.toString(),
    );

    PlatformFile? selectedFile;
    bool isSubmitting = false;
    String? modalError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                const Text(
                  'Update Schedule',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Title (Optional)',
                    hint: 'e.g. Office Schedule v2',
                    icon: Icons.title,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Description',
                    hint: 'Optional schedule description',
                    icon: Icons.notes,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: departmentCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Department Code',
                    hint: 'e.g. DEV',
                    icon: Icons.business,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: versionController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Version',
                    hint: '1',
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(height: 20),
                _uploadBox(
                  label: 'Replace PDF (Optional)',
                  selectedFileName: selectedFile?.name,
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['pdf'],
                      withData: true,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      setModalState(() {
                        selectedFile = result.files.first;
                        modalError = null;
                      });
                    }
                  },
                ),
                if (modalError != null) ...[
                  const SizedBox(height: 12),
                  Text(modalError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (versionController.text.trim().isNotEmpty &&
                              int.tryParse(versionController.text.trim()) == null) {
                            setModalState(() => modalError = 'Version must be numeric.');
                            return;
                          }

                          setModalState(() {
                            isSubmitting = true;
                            modalError = null;
                          });

                          final success = await _officeProvider.updateSchedule(
                            id: schedule.id,
                            title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
                            description: descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            departmentCode: departmentCodeController.text.trim().isEmpty
                                ? null
                                : departmentCodeController.text.trim(),
                            version: int.tryParse(versionController.text.trim()),
                            fileBytes: selectedFile?.bytes,
                            fileName: selectedFile?.name,
                          );

                          if (!mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.of(this.context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule updated successfully.'),
                                backgroundColor: AppColors.green,
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            modalError = _officeProvider.error ?? 'Unable to update schedule.';
                            isSubmitting = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('UPDATE SCHEDULE'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
      departmentCodeController.dispose();
      versionController.dispose();
    });
  }

  Future<void> _confirmDeleteSchedule(OfficeScheduleModel schedule) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Delete Schedule?', style: TextStyle(color: Colors.white)),
            content: Text(
              'This will permanently delete "${schedule.title.isEmpty ? 'Schedule' : schedule.title}".',
              style: const TextStyle(color: AppColors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final success = await _officeProvider.deleteSchedule(schedule.id);
    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule deleted successfully.'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_officeProvider.error ?? 'Unable to delete schedule.'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminOfficeProvider>.value(
      value: _officeProvider,
      child: Consumer<AdminOfficeProvider>(
        builder: (context, officeProvider, _) {
          final filtered = _filteredSchedules(officeProvider.schedules);

          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(title: const Text("Schedules"), backgroundColor: Colors.transparent),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterSchedules,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                      label: "Search Schedule",
                      hint: "Title, description, or department code...",
                      icon: Icons.search,
                    ),
                  ),
                ),
                if (officeProvider.error != null && !officeProvider.isSchedulesLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      officeProvider.error!,
                      style: const TextStyle(color: AppColors.red, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: officeProvider.isSchedulesLoading && officeProvider.schedules.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.greenLight,
                            strokeWidth: 2,
                          ),
                        )
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No schedules available yet.',
                                style: TextStyle(color: AppColors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: officeProvider.loadSchedules,
                              child: ListView.builder(
                                itemCount: filtered.length,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) => _scheduleCard(filtered[index]),
                              ),
                            ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.green,
              onPressed: _showAddScheduleDialog,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _scheduleCard(OfficeScheduleModel s) {
    final subtitle = [
      if (s.departmentCode != null && s.departmentCode!.isNotEmpty) 'Dept: ${s.departmentCode!}',
      if (s.version != null) 'v${s.version}',
    ].join(' • ');

    return InkWell(
      onTap: () => _openScheduleDetails(s),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.title,
                    style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    s.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _scheduleDescription(s),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.grey, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    subtitle.isEmpty ? 'Tap to view details' : subtitle,
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
            if (s.fileUrl != null && s.fileUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                s.fileUrl!,
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditScheduleDialog(s),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.greenLight),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: AppColors.greenLight),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDeleteSchedule(s),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadBox({
    required String label,
    required VoidCallback onTap,
    String? selectedFileName,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.upload_file, color: AppColors.greenLight),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                selectedFileName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
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
      setState(() => _error = e.message);
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDepartmentDetails(dept),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                      color: dept.isActive
                          ? AppColors.greenLight.withOpacity(0.18)
                          : AppColors.orange.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: dept.isActive
                            ? AppColors.greenLight.withOpacity(0.4)
                            : AppColors.orange.withOpacity(0.4),
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
        ),
      ),
    );
  }

  Future<void> _openDepartmentDetails(DepartmentModel dept) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: AppColors.greenLight, strokeWidth: 2),
      ),
    );

    DepartmentModel? details;
    String? errorMessage;

    try {
      details = await _departmentService.getDepartmentById(dept.id);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Unable to fetch department details.';
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Unable to fetch department details.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final deptDetails = details;
    final description = (deptDetails.description ?? '').trim();
    final statusLabel = deptDetails.isActive ? 'Active' : 'Inactive';
    final statusColor = deptDetails.isActive ? AppColors.greenLight : AppColors.orange;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deptDetails.name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  deptDetails.code,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12, letterSpacing: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.tag, 'Code', deptDetails.code),
            _detailRow(Icons.info_outline, 'Status', statusLabel),
            if (description.isNotEmpty) _detailRow(Icons.notes, 'Description', description),
            if ((deptDetails.createdAt ?? '').isNotEmpty)
              _detailRow(Icons.calendar_today, 'Created', deptDetails.createdAt!),
            if ((deptDetails.updatedAt ?? '').isNotEmpty)
              _detailRow(Icons.update, 'Updated', deptDetails.updatedAt!),
            if ((deptDetails.createdByAdminId ?? '').isNotEmpty)
              _detailRow(Icons.verified_user, 'Created By', deptDetails.createdByAdminId!),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
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
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Department deleted successfully.')),
                );
              } on ApiException catch (e) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              } catch (_) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Unable to delete department.')),
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
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(content: Text('Department updated successfully.')),
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
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(content: Text('Department created successfully.')),
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
                  : Text(_isEdit ? 'Save Changes' : 'Create Department'),
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
  final TextEditingController _searchController = TextEditingController();
  late final AdminOfficeProvider _officeProvider;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _officeProvider = AdminOfficeProvider();
    _officeProvider.loadPolicies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _officeProvider.dispose();
    super.dispose();
  }

  void _filterPolicies(String query) {
    setState(() => _searchTerm = query.trim().toLowerCase());
  }

  List<PolicyDocumentModel> _filteredPolicies(List<PolicyDocumentModel> items) {
    if (_searchTerm.isEmpty) {
      return items;
    }

    return items.where((policy) => policy.title.toLowerCase().contains(_searchTerm)).toList();
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final versionController = TextEditingController();
    final departmentCodeController = TextEditingController();
    final targetRoleController = TextEditingController();

    PlatformFile? selectedFile;
    bool isSubmitting = false;
    String? modalError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                const Text(
                  "Upload New Handbook",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Document Title",
                    hint: "e.g. Code of Conduct",
                    icon: Icons.description,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Description (Optional)",
                    hint: "Brief description",
                    icon: Icons.notes,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: versionController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: proLinkInputDecoration(
                          label: "Version (Optional)",
                          hint: "1",
                          icon: Icons.history,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: targetRoleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: proLinkInputDecoration(
                          label: "Target Role (Optional)",
                          hint: "All",
                          icon: Icons.group,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: departmentCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: "Department Code (Optional)",
                    hint: "DEV",
                    icon: Icons.business,
                  ),
                ),
                const SizedBox(height: 20),
                _uploadBox(
                  label: 'Select PDF Document',
                  selectedFileName: selectedFile?.name,
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['pdf'],
                      withData: true,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      setModalState(() {
                        selectedFile = result.files.first;
                        modalError = null;
                      });
                    }
                  },
                ),
                if (modalError != null) ...[
                  const SizedBox(height: 12),
                  Text(modalError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ],
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            setModalState(() => modalError = 'Document title is required.');
                            return;
                          }

                          if (selectedFile == null || selectedFile?.bytes == null) {
                            setModalState(() => modalError = 'Please select a PDF file first.');
                            return;
                          }

                          setModalState(() {
                            isSubmitting = true;
                            modalError = null;
                          });

                          final success = await _officeProvider.uploadPolicy(
                            title: titleController.text.trim(),
                            fileBytes: selectedFile!.bytes!,
                            fileName: selectedFile!.name,
                            description: descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            departmentCode: departmentCodeController.text.trim().isEmpty
                                ? null
                                : departmentCodeController.text.trim(),
                            targetRole: targetRoleController.text.trim().isEmpty
                                ? null
                                : targetRoleController.text.trim(),
                            version: int.tryParse(versionController.text.trim()),
                          );

                          if (!mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.of(this.context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Policy handbook uploaded successfully.'),
                                backgroundColor: AppColors.green,
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            modalError = _officeProvider.error ?? 'Unable to upload policy handbook.';
                            isSubmitting = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "PUBLISH DOCUMENT",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
      versionController.dispose();
      departmentCodeController.dispose();
      targetRoleController.dispose();
    });
  }

  void _showEditPolicyDialog(PolicyDocumentModel policy) {
    final titleController = TextEditingController(text: policy.title);
    final descriptionController = TextEditingController(text: policy.description ?? '');
    final versionController = TextEditingController(text: policy.version == null ? '' : policy.version.toString());
    final departmentCodeController = TextEditingController(text: policy.departmentCode ?? '');
    final targetRoleController = TextEditingController(text: policy.targetRole ?? '');

    PlatformFile? selectedFile;
    bool isSubmitting = false;
    String? modalError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                const Text(
                  'Update Handbook',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Document Title',
                    hint: 'e.g. Code of Conduct',
                    icon: Icons.description,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Description (Optional)',
                    hint: 'Brief description',
                    icon: Icons.notes,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: versionController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: proLinkInputDecoration(
                          label: 'Version (Optional)',
                          hint: '1',
                          icon: Icons.history,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: targetRoleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: proLinkInputDecoration(
                          label: 'Target Role (Optional)',
                          hint: 'All',
                          icon: Icons.group,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: departmentCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(
                    label: 'Department Code (Optional)',
                    hint: 'DEV',
                    icon: Icons.business,
                  ),
                ),
                const SizedBox(height: 20),
                _uploadBox(
                  label: 'Replace PDF (Optional)',
                  selectedFileName: selectedFile?.name,
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['pdf'],
                      withData: true,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      setModalState(() {
                        selectedFile = result.files.first;
                        modalError = null;
                      });
                    }
                  },
                ),
                if (modalError != null) ...[
                  const SizedBox(height: 12),
                  Text(modalError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (versionController.text.trim().isNotEmpty &&
                              int.tryParse(versionController.text.trim()) == null) {
                            setModalState(() => modalError = 'Version must be numeric.');
                            return;
                          }

                          setModalState(() {
                            isSubmitting = true;
                            modalError = null;
                          });

                          final success = await _officeProvider.updatePolicy(
                            id: policy.id,
                            title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
                            description: descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            departmentCode: departmentCodeController.text.trim().isEmpty
                                ? null
                                : departmentCodeController.text.trim(),
                            targetRole: targetRoleController.text.trim().isEmpty
                                ? null
                                : targetRoleController.text.trim(),
                            version: int.tryParse(versionController.text.trim()),
                            fileBytes: selectedFile?.bytes,
                            fileName: selectedFile?.name,
                          );

                          if (!mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.of(this.context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Policy handbook updated successfully.'),
                                backgroundColor: AppColors.green,
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            modalError = _officeProvider.error ?? 'Unable to update policy handbook.';
                            isSubmitting = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'UPDATE DOCUMENT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
      versionController.dispose();
      departmentCodeController.dispose();
      targetRoleController.dispose();
    });
  }

  Future<void> _confirmDeletePolicy(PolicyDocumentModel policy) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Delete Policy?', style: TextStyle(color: Colors.white)),
            content: Text(
              'This will permanently delete "${policy.title}".',
              style: const TextStyle(color: AppColors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final success = await _officeProvider.deletePolicy(policy.id);
    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Policy handbook deleted successfully.'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_officeProvider.error ?? 'Unable to delete policy handbook.'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminOfficeProvider>.value(
      value: _officeProvider,
      child: Consumer<AdminOfficeProvider>(
        builder: (context, officeProvider, _) {
          final filtered = _filteredPolicies(officeProvider.policies);
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(title: const Text("Policy Handbooks"), backgroundColor: Colors.transparent),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPolicies,
                    style: const TextStyle(color: Colors.white),
                    decoration: proLinkInputDecoration(
                      label: 'Search Policies',
                      hint: 'Search by title...',
                      icon: Icons.search,
                    ),
                  ),
                ),
                if (officeProvider.error != null && !officeProvider.isPoliciesLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      officeProvider.error!,
                      style: const TextStyle(color: AppColors.red, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: officeProvider.isPoliciesLoading && officeProvider.policies.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.greenLight,
                            strokeWidth: 2,
                          ),
                        )
                      : officeProvider.policies.isEmpty
                          ? const Center(
                              child: Text(
                                'No policy handbooks uploaded yet.',
                                style: TextStyle(color: AppColors.grey),
                              ),
                            )
                          : filtered.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No policy handbooks found.',
                                    style: TextStyle(color: AppColors.grey),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: officeProvider.loadPolicies,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) => _buildPolicyCard(filtered[index]),
                                  ),
                                ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.green,
              onPressed: _showUploadDialog,
              child: const Icon(Icons.add_to_photos),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPolicyCard(PolicyDocumentModel doc) {
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
        subtitle: Text(
          doc.description ?? 'No description',
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          doc.isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: doc.isActive ? AppColors.greenLight : AppColors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          const Divider(color: AppColors.border, height: 1),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Version History", style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.file_present, color: AppColors.grey, size: 18),
            title: Text(
              'Version v${doc.version ?? 1}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            subtitle: Text(
              'Uploaded: ${doc.updatedAt ?? doc.createdAt ?? '-'}',
              style: const TextStyle(color: AppColors.grey, fontSize: 11),
            ),
            trailing: doc.fileUrl == null
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(doc.fileUrl!),
                          backgroundColor: AppColors.surface,
                        ),
                      );
                    },
                    child: const Text('View', style: TextStyle(color: Colors.blue)),
                  ),
          ),
          if (doc.departmentCode != null || doc.targetRole != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (doc.departmentCode != null)
                    Text(
                      'Dept: ${doc.departmentCode}',
                      style: const TextStyle(color: AppColors.grey, fontSize: 11),
                    ),
                  if (doc.departmentCode != null && doc.targetRole != null)
                    const Text('  •  ', style: TextStyle(color: AppColors.grey)),
                  if (doc.targetRole != null)
                    Text(
                      'Role: ${doc.targetRole}',
                      style: const TextStyle(color: AppColors.grey, fontSize: 11),
                    ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditPolicyDialog(doc),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.greenLight),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: AppColors.greenLight),
                ),
              ),
              TextButton.icon(
                onPressed: () => _confirmDeletePolicy(doc),
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _uploadBox({
    required String label,
    required VoidCallback onTap,
    String? selectedFileName,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.upload_file, color: AppColors.greenLight, size: 30),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: AppColors.grey)),
            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                selectedFileName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
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
  // Demo Data
  final List<Map<String, String>> interns = [
    {"name": "Lina Bouzid", "dept": "AI", "nr": "20203501", "status": "Active"},
    {"name": "Omar Khelil", "dept": "Web", "nr": "20203502", "status": "Active"},
    {"name": "Yassine Ben", "dept": "Mobile", "nr": "20203503", "status": "Pending"},
  ];

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
      body: Column(
        children: [
          // ── QUICK STATS ──
          _buildTopStats(),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Search Interns",
                hint: "Search by Name or Registration NR...",
                icon: Icons.search,
              ),
            ),
          ),

          // ── INTERN LIST ──
          Expanded(
            child: ListView.builder(
              itemCount: interns.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = interns[index];
                return _internCard(item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _miniStat("Total", "${interns.length}", Colors.blue),
          _miniStat("Active", "110", AppColors.green),
          _miniStat("M1/M2", "45", AppColors.gold),
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

  Widget _internCard(Map<String, String> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surface,
          child: Text(data['name']![0], style: const TextStyle(color: AppColors.greenLight)),
        ),
        title: Text(data['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("NR: ${data['nr']} • ${data['dept']}", style: const TextStyle(color: AppColors.grey, fontSize: 12)),

        // ── THE THREE DOTS MENU ──
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.grey),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'view') {
              _showInternInfo(context, data);
            } else if (value == 'delete') {
              _confirmDelete(index);
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
  void _showInternInfo(BuildContext context, Map<String, String> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.border)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.greenDeep,
              child: Text(data['name']![0], style: const TextStyle(fontSize: 30, color: Colors.white)),
            ),
            const SizedBox(height: 15),
            Text(data['name']!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Intern Student", style: TextStyle(color: AppColors.greenLight.withOpacity(0.8), fontSize: 14)),

            const Divider(color: AppColors.border, height: 30),

            // Academic Info Rows
            _infoRow(Icons.numbers, "Registration NR", data['nr']!),
            _infoRow(Icons.school, "Specialty", data['dept']!),
            _infoRow(Icons.calendar_month, "Academic Year", "Master 1 (M1)"), // Example detail
            _infoRow(Icons.phone, "Phone Number", "0661 00 00 00"),

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
        ),
      ),
    );
  }

// Helper for the Info Rows
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Remove Intern?", style: TextStyle(color: Colors.white)),
        content: const Text("All academic records for this student will be deleted."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                setState(() => interns.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  // ── THE DETAILED "MANY INFO" DIALOG ──
  void _showAddInternDialog(BuildContext context) {
    // Controller for the new specialized field
    final TextEditingController _uniEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Official University Registration",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Standard Info
              TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: proLinkInputDecoration(label: "Full Name", hint: "Ahmed Benali", icon: Icons.person)
              ),
              const SizedBox(height: 15),

              // SPECIALIZED FIELD: University Gmail
              TextField(
                  controller: _uniEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.greenLight), // Highlighted color
                  decoration: proLinkInputDecoration(
                      label: "University Gmail",
                      hint: "username@univ-constantine2.dz",
                      icon: Icons.alternate_email
                  )
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: proLinkInputDecoration(label: "Registration NR", hint: "2020...", icon: Icons.numbers)
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Internship Duration Picker Space
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Logic to pick start/end date
                        await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030));
                      },
                      icon: const Icon(Icons.date_range, size: 16, color: AppColors.greenLight),
                      label: const Text("Set Dates", style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 18)
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Mentor Assignment Dropdown Space
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
                    hint: const Text("Select Mentor", style: TextStyle(color: AppColors.grey)),
                    items: ["Dr. Rahmani", "Prof. Zenati"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (val) {},
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("VALIDATE & ASSIGN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
            ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide a reason for rejection"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Success Message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isApproved ? "${widget.name} Approved!" : "Request Rejected"),
        backgroundColor: isApproved ? AppColors.green : Colors.red,
      ),
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
class AllRequestsPage extends StatelessWidget {
  const AllRequestsPage({super.key});

  // Example data list
  final List<Map<String, String>> allRequests = const [
    {"name": "Lina Bouzid", "dept": "AI Department"},
    {"name": "Omar Khelil", "dept": "Web Dev"},
    {"name": "James Smith", "dept": "Business Admin"},
    {"name": "Sophia Lee", "dept": "Software Engineering"},
    {"name": "Ahmed Rayan", "dept": "Cybersecurity"},
  ];

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
              style: const TextStyle(color: Colors.white),
              decoration: proLinkInputDecoration(
                label: "Search Requests",
                hint: "Filter by name...",
                icon: Icons.search,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: allRequests.length,
              itemBuilder: (context, index) {
                final request = allRequests[index];
                // Reusing your existing invitation card design
                return _requestCard(context, request['name']!, request['dept']!);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom version of your card for the full list
  Widget _requestCard(BuildContext context, String name, String dept) {
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
              child: Text(name[0], style: const TextStyle(color: AppColors.greenLight))
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(dept, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewRequestPage(name: name, department: dept))
              );
            },
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.greenLight, size: 18),
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
