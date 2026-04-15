import 'package:flutter/material.dart';
import 'theme.dart';

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
                    const Text(
                      "Lina Bouzid 👋",
                      style: TextStyle(
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
                child: const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _summaryCard("Department", "CS / AI", Icons.business, AppColors.greenLight),
        _summaryCard("My Mentor", "Dr. Rahmani", Icons.school, AppColors.gold),
        _summaryCard("Next Shift", "08:30 AM", Icons.timer, Colors.blueAccent),

        // CLICKABLE MARK CARD
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EvaluationScreen()),
          ),
          child: _summaryCard(
            "Last Mark",
            "17.5 / 20",
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
                        const CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/300",
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
                    const Text(
                      "LINA BOUZID",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "AI Research Intern",
                      style: TextStyle(
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _IDInfo(label: "BLOOD", value: "O+"),
                          _IDInfo(label: "EXPIRES", value: "06/2026"),
                          _IDInfo(label: "GROUP", value: "G-01"),
                        ],
                      ),
                    ),
                  ],
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
            const CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lina Bouzid",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildField("Registration ID", "PR-2024-001", Icons.badge, false),
            _buildField(
              "Department",
              "Artificial Intelligence",
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
              _emailController.text,
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

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  "Upcoming Today",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                _scheduleCard(
                  time: "08:30 - 10:30",
                  title: "Machine Learning Lab",
                  location: "Lab 04 - Block B",
                  instructor: "Dr. Rahmani",
                  color: AppColors.greenLight,
                  isNow: true,
                ),
                _scheduleCard(
                  time: "11:00 - 12:30",
                  title: "Ethics in AI",
                  location: "Amphi A",
                  instructor: "Prof. Belhadj",
                  color: Colors.blueAccent,
                  isNow: false,
                ),
                _scheduleCard(
                  time: "14:00 - 16:00",
                  title: "Project Research",
                  location: "Library Hub",
                  instructor: "Self Study",
                  color: AppColors.gold,
                  isNow: false,
                ),

                const SizedBox(height: 100), // Space for bottom menu
              ],
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
  }) {
    return Container(
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
    );
  }
}

class TrainingModulesPage extends StatelessWidget {
  const TrainingModulesPage({super.key});

  final List<Map<String, dynamic>> modules = const [
    {
      "title": "Introduction to AI Ethics",
      "duration": "45 min",
      "progress": 1.0,
      "icon": Icons.psychology,
    },
    {
      "title": "Git & GitHub Workflow",
      "duration": "1h 20min",
      "progress": 0.6,
      "icon": Icons.code,
    },
    {
      "title": "Flutter State Management",
      "duration": "2h 15min",
      "progress": 0.1,
      "icon": Icons.flutter_dash,
    },
    {
      "title": "Data Security Basics",
      "duration": "30 min",
      "progress": 0.0,
      "icon": Icons.security,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("TRAINING MODULES"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModuleDetailPage(title: module['title']),
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
                  CircleAvatar(
                    backgroundColor: AppColors.surface,
                    child: Icon(module['icon'], color: AppColors.greenLight),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          module['duration'],
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: module['progress'],
                          backgroundColor: AppColors.surface,
                          color: module['progress'] == 1.0
                              ? AppColors.green
                              : AppColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.grey),
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
  final String title;
  const ModuleDetailPage({super.key, required this.title});

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
                child: const Icon(Icons.play_circle_fill, size: 60, color: AppColors.greenLight),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.grey, size: 16),
                      SizedBox(width: 5),
                      Text("Lesson 1 of 5", style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Overview of this module:\n\nIn this section, we will cover the core principles of your internship role...",
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("MARK AS COMPLETE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),

                  // --- FIXED: These are now INSIDE the children list ---
                  const SizedBox(height: 30),
                  const Text(
                    "RESOURCES & DOWNLOADS",
                    style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 15),

                  _buildFileTile(
                    context,
                    fileName: "Internship_Handbook_2024.pdf",
                    fileSize: "2.4 MB",
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                  ),
                  _buildFileTile(
                    context,
                    fileName: "Technical_Setup_Guide.docx",
                    fileSize: "1.1 MB",
                    icon: Icons.description_rounded,
                    color: Colors.blueAccent,
                  ),
                ], // This bracket now correctly closes all children
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
    required String fileSize,
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
                  fileSize,
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Action Buttons
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: AppColors.grey,
              size: 20,
            ),
            onPressed: () {
              // Logic to open internal PDF Viewer
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Opening $fileName...")));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: AppColors.greenLight,
              size: 20,
            ),
            onPressed: () {
              // Logic to download to phone storage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Download Started...")),
              );
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

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("PERFORMANCE REVIEW",
            style: TextStyle(fontSize: 14, letterSpacing: 1.2, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column( // Using Column inside SingleChildScrollView for better structure
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Total Score Card
            _buildScoreHeader(),

            const SizedBox(height: 30),
            const Text("GRADING RUBRIC",
                style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 2. Rubric List
            _rubricTile("Technical Skills", "4.5/5", 0.9, "Excellent code quality."),
            _rubricTile("Punctuality", "5.0/5", 1.0, "Always on time."),
            _rubricTile("Teamwork", "3.5/5", 0.7, "Needs more communication."),
            _rubricTile("Documentation", "4.0/5", 0.8, "Clear and concise logs."),

            const SizedBox(height: 30),
            // 3. Mentor Section
            _buildMentorComments(),

            const SizedBox(height: 100), // Bottom padding for navigation menu
          ],
        ),
      ),
    );
  }

  // --- HELPER 1: SCORE HEADER ---
  Widget _buildScoreHeader() {
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
          const Text("Final Grade", style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("17.5", style: TextStyle(color: AppColors.greenLight, fontSize: 48, fontWeight: FontWeight.bold)),
              const Text("/20", style: TextStyle(color: AppColors.grey, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Top 5% of Internship Group", style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  // --- HELPER 2: RUBRIC TILE ---
  Widget _rubricTile(String title, String score, double progress, String comment) {
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
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(score, style: TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
            ],
          ),
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
          Text(comment, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // --- HELPER 3: MENTOR COMMENTS ---
  Widget _buildMentorComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("MENTOR'S FEEDBACK",
            style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            "\"Lina has shown exceptional growth in her understanding of Flutter architecture. Her ability to solve complex UI bugs independently is impressive.\"",
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}