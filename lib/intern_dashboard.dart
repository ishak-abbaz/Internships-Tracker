import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'theme.dart';
import 'providers/auth_provider.dart';
import 'providers/trainingModule_provider.dart';
import 'models/training_module_model.dart';
import 'providers/evaluation_provider.dart';
import 'models/evaluation_model.dart';
import 'models/user_model.dart';
import 'providers/internship_assignment_provider.dart';
import 'providers/admin_office_provider.dart';
import 'config/api_config.dart';
import 'services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Intern Dashboard (Main Controller)
// ─────────────────────────────────────────────────────────────────────────────

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    InternHomeContent(onProfileTap: () => setState(() => _selectedIndex = 3)),
    const SchedulePage(), // Now Linked!
    const ProfessionalIDPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _pages[_selectedIndex],
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
            _navItem(Icons.home_rounded, "Home", 0),
            _navItem(Icons.calendar_month_rounded, "Schedule", 1),
            _navItem(Icons.badge_rounded, "ID Card", 2),
            _navItem(Icons.person_rounded, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
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

// ─────────────────────────────────────────────────────────────────────────────
//  1. Intern Home Content
// ─────────────────────────────────────────────────────────────────────────────

class InternHomeContent extends StatelessWidget {
  final VoidCallback onProfileTap;

  const InternHomeContent({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 70),

          // --- HEADER: Cleaned up (Mark removed from here) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    Text(
                      "${user?.fullName ?? 'Intern'} 👋",
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
                  backgroundColor: AppColors.greenDeep,
                  child: Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'I',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          const Text(
            "Internship Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // --- SUMMARY GRID: Mark is now clickable here ---
          _buildSummaryGrid(context),

          const SizedBox(height: 20),
          _buildTrainingShortcut(context),

          const SizedBox(height: 30),

          // Quick Action / Tip Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.greenLight.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.greenLight),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Reminder: Submit your weekly logbook by Friday 4:00 PM.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTrainingShortcut(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TrainingModulesPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.greenLight.withOpacity(0.2), AppColors.bg],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greenLight.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.school, color: AppColors.greenLight),
            SizedBox(width: 15),
            Text(
              "Continue Training Modules",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    final evalProvider = context.watch<EvaluationNotifier>();
    final assignmentProvider = context.watch<InternshipAssignmentNotifier>();
    
    final lastMark = evalProvider.evaluations.isNotEmpty 
        ? evalProvider.evaluations.first.overallMark.toStringAsFixed(1)
        : "N/A";

    final deptCode = assignmentProvider.myAssignment?.departmentName ?? "N/A";
    final mentorName = assignmentProvider.myAssignment?.mentorName ?? "Assigning...";

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _summaryCard("Department", deptCode, Icons.business, AppColors.greenLight),
        _summaryCard("My Mentor", mentorName, Icons.school, AppColors.gold),
        Consumer<AdminOfficeNotifier>(
          builder: (context, office, _) {
            final nextShift = office.schedules.isNotEmpty 
                ? office.schedules.first.title 
                : "None";
            return _summaryCard("Office Schedule", nextShift, Icons.timer, Colors.blueAccent);
          },
        ),

        // CLICKABLE MARK CARD
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EvaluationScreen()),
          ),
          child: _summaryCard(
            "Last Mark",
            "$lastMark / 100",
            Icons.grade,
            Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(color: AppColors.grey, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  2. Professional ID Page
// ─────────────────────────────────────────────────────────────────────────────

class ProfessionalIDPage extends StatelessWidget {
  const ProfessionalIDPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final assignment = context.watch<InternshipAssignmentNotifier>().myAssignment;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          "OFFICIAL IDENTIFICATION",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
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
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: AppColors.greenLight,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        assignment?.id_photo_url != null
                            ? CircleAvatar(
                                radius: 70,
                                backgroundImage: NetworkImage(assignment!.id_photo_url!),
                                backgroundColor: AppColors.greenDeep,
                              )
                            : CircleAvatar(
                                radius: 70,
                                backgroundColor: AppColors.greenDeep,
                                child: Text(
                                  user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'I',
                                  style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user?.fullName.toUpperCase() ?? 'INTERN NAME',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      assignment?.subject ?? "Research Intern",
                      style: const TextStyle(
                        color: AppColors.greenLight,
                        fontSize: 14,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 40,
                      ),
                      child: Divider(color: AppColors.border),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 120,
                        color: AppColors.bg,
                      ),
                    ),
                    const SizedBox(height: 35),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const _IDInfo(label: "BLOOD", value: "O+"),
                          _IDInfo(
                            label: "EXPIRES",
                            value: assignment != null
                                ? "${assignment.endDate.month.toString().padLeft(2, '0')}/${assignment.endDate.year}"
                                : "06/2026",
                          ),
                          const _IDInfo(label: "GROUP", value: "G-01"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (result != null && result.files.single.bytes != null) {
                      final bytes = result.files.single.bytes!;
                      final fileName = result.files.single.name;

                      // Show loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Uploading photo...")),
                      );

                      final token = await AuthService().getToken();
                      final uri = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.internWorkId}/photo");
                      
                      final request = http.MultipartRequest('POST', uri)
                        ..headers['Authorization'] = 'Bearer $token'
                        ..files.add(http.MultipartFile.fromBytes(
                          'file',
                          bytes,
                          filename: fileName,
                          contentType: MediaType('image', fileName.split('.').last),
                        ));

                      final response = await request.send();

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Photo uploaded successfully!")),
                        );
                        // Refresh assignment to get new photo URL
                        context.read<InternshipAssignmentNotifier>().fetchMyAssignment();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload failed: ${response.statusCode}")),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text("UPDATE ID PHOTO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenDeep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _IDInfo extends StatelessWidget {
  final String label, value;

  const _IDInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3. Profile Page
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final TextEditingController _phoneController = TextEditingController(
    text: "+213 555 12 34 56",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "lina.bouzid@university.edu",
  );

  // --- LOGOUT DIALOG ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Logout", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to exit the portal?",
            style: TextStyle(color: AppColors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: AppColors.grey)),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                // Navigate to Login and clear navigation history
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text(
                "LOGOUT",
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
    final user = context.watch<AuthProvider>().currentUser;
    final assignment = context.watch<InternshipAssignmentNotifier>().myAssignment;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("MY PROFILE"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(
              _isEditing ? Icons.check_circle : Icons.edit,
              color: _isEditing ? AppColors.greenLight : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: AppColors.greenDeep,
              child: Text(
                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'I',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.fullName ?? 'Intern Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildField("Registration ID", "PR-2024-001", Icons.badge, false),
            _buildField(
              "Department",
              assignment?.departmentName ?? "Not Assigned",
              Icons.business,
              false,
            ),
            _buildField(
              "Phone",
              _phoneController.text,
              Icons.phone,
              _isEditing,
            ),
            _buildField(
              "Email",
              user?.email ?? _emailController.text,
              Icons.email,
              _isEditing,
            ),

            const SizedBox(height: 30),

            // --- LOGOUT BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text("LOGOUT FROM PORTAL"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120), // Space for floating bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, IconData icon, bool editing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: editing ? AppColors.card : AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: editing ? AppColors.greenLight : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.grey, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  4. Schedule Page (Calendar & Shifts)
// ─────────────────────────────────────────────────────────────────────────────

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOfficeNotifier>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final office = context.watch<AdminOfficeNotifier>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          "MY SCHEDULE",
          style: TextStyle(letterSpacing: 1.5, fontSize: 14),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: office.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.greenLight))
          : Column(
              children: [
                // --- HORIZONTAL DATE PICKER ---
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      _dateItem("14", "Mon", false),
                      _dateItem("15", "Tue", true), // Active Day
                      _dateItem("16", "Wed", false),
                      _dateItem("17", "Thu", false),
                      _dateItem("18", "Fri", false),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- SHIFT/CLASS LIST ---
                Expanded(
                  child: office.schedules.isEmpty
                      ? const Center(child: Text("No schedules uploaded", style: TextStyle(color: AppColors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: office.schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = office.schedules[index];
                            return _scheduleCard(
                              time: schedule.academicYear ?? "2024-2025",
                              title: schedule.title,
                              location: schedule.group ?? "All Groups",
                              instructor: schedule.teacherName ?? "Faculty",
                              color: index % 2 == 0 ? AppColors.greenLight : Colors.blueAccent,
                              isNow: index == 0,
                              url: schedule.fileUrl,
                            );
                          },
                        ),
                ),
                // Inside the ListView of SchedulePage
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SemesterTimetablePage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(20),
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
                        "Full Semester View",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "View your weekly 2024-2025 schedule",
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.grey,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 120), // Extra space for the floating menu
        ],
      ),
    );
  }

  // --- Date Picker Widget ---
  Widget _dateItem(String day, String weekday, bool isActive) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.greenLight : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.greenLight : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: TextStyle(
              color: isActive ? Colors.black : AppColors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            day,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Timeline Card Widget ---
  Widget _scheduleCard({
    required String time,
    required String title,
    required String location,
    required String instructor,
    required Color color,
    required bool isNow,
    String? url,
  }) {
    return GestureDetector(
      onTap: url != null ? () => launchUrl(Uri.parse(url)) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNow ? color : AppColors.border,
            width: isNow ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isNow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "NOW",
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.person_outline,
                        color: AppColors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        instructor,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

class TrainingModulesPage extends StatefulWidget {
  const TrainingModulesPage({super.key});

  @override
  State<TrainingModulesPage> createState() => _TrainingModulesPageState();
}

class _TrainingModulesPageState extends State<TrainingModulesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingModuleNotifier>().fetchForIntern();
      context.read<EvaluationNotifier>().fetchInternEvaluations();
      context.read<InternshipAssignmentNotifier>().fetchMyAssignment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TrainingModuleNotifier>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("TRAINING MODULES"),
        backgroundColor: Colors.transparent,
      ),
      body: notifier.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.greenLight))
          : notifier.error != null
              ? Center(child: Text(notifier.error!, style: const TextStyle(color: AppColors.red)))
              : notifier.modules.isEmpty
                  ? const Center(child: Text("No modules assigned yet", style: TextStyle(color: AppColors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: notifier.modules.length,
                      itemBuilder: (context, index) {
                        final module = notifier.modules[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModuleDetailPage(module: module),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppColors.surface,
                                  child: Icon(Icons.school_outlined, color: AppColors.greenLight),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        module.title,
                                        style: TextStyle(
                                          color: module.isCompleted ? AppColors.grey : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: module.isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        module.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.grey),
                                if (module.isCompleted)
                                  const Icon(Icons.check_circle, color: AppColors.greenLight, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class ModuleDetailPage extends StatelessWidget {
  final TrainingModuleModel module;
  const ModuleDetailPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.surface,
                child: const Icon(Icons.library_books, size: 60, color: AppColors.greenLight),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.title,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.business, color: AppColors.grey, size: 16),
                      const SizedBox(width: 5),
                      Text("Department: ${module.departmentCode}", style: const TextStyle(color: AppColors.grey)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    module.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  
                  const Text(
                    "RESOURCES",
                    style: TextStyle(
                        color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 15),

                  _buildFileTile(
                    context,
                    fileName: "Training Resource",
                    url: module.url,
                    icon: Icons.link_rounded,
                    color: AppColors.greenLight,
                  ),
                  
                  const SizedBox(height: 50),
                  
                  if (!module.isCompleted)
                    Consumer<TrainingModuleNotifier>(
                      builder: (context, notifier, child) {
                        return Center(
                          child: GradientButton(
                            label: notifier.isLoading ? "MARKING..." : "MARK AS COMPLETE",
                            isLoading: notifier.isLoading,
                            onTap: () async {
                              final success = await notifier.markAsComplete(module.id);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      },
                    )
                  else
                    const Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.greenLight, size: 48),
                          SizedBox(height: 10),
                          Text("Completed", style: TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTile(
    BuildContext context, {
    required String fileName,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "External Resource",
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.greenLight,
              size: 20,
            ),
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not launch URL")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SemesterTimetablePage extends StatelessWidget {
  const SemesterTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("SEMESTER TIMETABLE", style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Allows swiping if screen is small
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surface),
              dataRowColor: WidgetStateProperty.all(
                AppColors.card.withOpacity(0.5),
              ),
              border: TableBorder.all(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              columns: const [
                DataColumn(
                  label: Text("TIME", style: TextStyle(color: AppColors.gold)),
                ),
                DataColumn(
                  label: Text("SUN", style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text("MON", style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text("TUE", style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text("WED", style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text("THU", style: TextStyle(color: Colors.white)),
                ),
              ],
              rows: [
                _buildRow("08:30", "ML Lab", "AI Eth", "Math", "DevOps", "NLP"),
                _buildRow("10:30", "ML Lab", "AI Eth", "Math", "DevOps", "NLP"),
                _buildRow(
                  "13:00",
                  "Project",
                  "---",
                  "Seminar",
                  "---",
                  "Research",
                ),
                _buildRow(
                  "15:00",
                  "Project",
                  "---",
                  "Soft Skills",
                  "---",
                  "Research",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
    String time,
    String sun,
    String mon,
    String tue,
    String wed,
    String thu,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            time,
            style: const TextStyle(
              color: AppColors.greenLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(sun, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        DataCell(
          Text(mon, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        DataCell(
          Text(tue, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        DataCell(
          Text(wed, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        DataCell(
          Text(thu, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }
}

class TrainingFilesPage extends StatelessWidget {
  const TrainingFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("COURSE MATERIALS", style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _fileCard(
            context,
            "AI_Ethics_Manual.pdf",
            "PDF Document",
            Icons.picture_as_pdf,
            Colors.redAccent,
          ),
          _fileCard(
            context,
            "Flutter_Best_Practices.epub",
            "E-Book",
            Icons.menu_book_rounded,
            Colors.orangeAccent,
          ),
          _fileCard(
            context,
            "Source_Code_Samples.zip",
            "Archive",
            Icons.folder_zip_rounded,
            Colors.blueAccent,
          ),
          _fileCard(
            context,
            "Research_Portal_Link",
            "External URL",
            Icons.link_rounded,
            AppColors.greenLight,
          ),
        ],
      ),
    );
  }

  Widget _fileCard(
    BuildContext context,
    String name,
    String type,
    IconData icon,
    Color color,
  ) {
    return Container(
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Action buttons
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: AppColors.greenLight,
            ),
            onPressed: () => _handleFileAction(context, "Downloading $name..."),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: AppColors.grey),
            onPressed: () => _handleFileAction(context, "Opening $name..."),
          ),
        ],
      ),
    );
  }

  void _handleFileAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.surface),
    );
  }
}

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvaluationNotifier>().fetchInternEvaluations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EvaluationNotifier>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("PERFORMANCE REVIEW",
            style: TextStyle(fontSize: 14, letterSpacing: 1.2, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.greenLight))
          : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Total Score Card
                      _buildScoreHeader(provider.averageMark),

                      const SizedBox(height: 30),
                      const Text("RECENT EVALUATIONS",
                          style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      if (provider.evaluations.isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text("No evaluations yet", style: TextStyle(color: AppColors.grey)),
                        ))
                      else
                        ...provider.evaluations.map((eval) => _rubricTile(
                              eval.weekLabel ?? "General Evaluation",
                              "${eval.overallMark}/100",
                              eval.overallMark / 100,
                              eval.feedback ?? "No feedback provided",
                              eval.mentorName ?? "Mentor",
                            )),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
    );
  }

  // --- HELPER 1: SCORE HEADER ---
  Widget _buildScoreHeader(double? averageMark) {
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
          const Text("Average Grade", style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                averageMark?.toStringAsFixed(1) ?? "N/A",
                style: const TextStyle(color: AppColors.greenLight, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const Text("/100", style: TextStyle(color: AppColors.grey, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER 2: RUBRIC TILE ---
  Widget _rubricTile(String title, String score, double progress, String comment, String mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(score, style: TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text("By $mentor", style: const TextStyle(color: AppColors.gold, fontSize: 11)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.bg,
              color: AppColors.greenLight,
            ),
          ),
          const SizedBox(height: 10),
          Text(comment, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}