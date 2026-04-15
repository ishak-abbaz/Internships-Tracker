import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Mentor Dashboard - Refactored (No Chart Version)
// ─────────────────────────────────────────────────────────────────────────────

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});
  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedDept = 'All';
  int get _assignedCount => _myInterns.length;
  int get _pendingAttendance => _myInterns.where((e) => e['present'] == false).length;
  int get _recentUploadsCount => _modules.length;


  final List<Map<String, dynamic>> _myInterns = [
    {'name': 'Lina Bouzid',    'dept': 'Data Science',   'attendance': 0.92, 'grade': 17.5, 'present': true},
    {'name': 'Omar Khelil',    'dept': 'Design',         'attendance': 0.78, 'grade': 14.0, 'present': true},
    {'name': 'Yasmine Taleb',  'dept': 'Data Science',   'attendance': 0.85, 'grade': 16.0, 'present': false},
    {'name': 'Bilal Messaoud', 'dept': 'Development',    'attendance': 0.60, 'grade': 12.5, 'present': false},
  ];

  final List<Map<String, String>> _modules = [
    {'title': 'Python Basics',         'type': 'PDF',  'date': 'Jan 3'},
    {'title': 'Data Cleaning Notebook','type': 'IPYNB','date': 'Jan 5'},
    {'title': 'Week 2 Assignment',     'type': 'DOCX', 'date': 'Jan 7'},
  ];
  List<Map<String, dynamic>> get _filteredInterns {
    return _myInterns.where((intern) {
      final matchesSearch = intern['name'].toLowerCase().contains(_searchCtrl.text.toLowerCase());
      final matchesDept = _selectedDept == 'All' || intern['dept'] == _selectedDept;
      return matchesSearch && matchesDept;
    }).toList();
  }

  int _bottomTab = 0;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))..forward();

    // Ensure this list length matches the number of _staggered calls in build
    _fades  = List.generate(4, (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryCtrl,
            curve: Interval(i * 0.15, i * 0.15 + 0.55, curve: Curves.easeOut))));

    _slides = List.generate(4, (i) => Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl,
            curve: Interval(i * 0.15, i * 0.15 + 0.55, curve: Curves.easeOutCubic))));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int idx, Widget child) => FadeTransition(
      opacity: _fades[idx],
      child: SlideTransition(position: _slides[idx], child: child));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _staggered(0, _buildSummaryCards()),
                  const SizedBox(height: 24),
                  _staggered(1, _buildMyInterns()),

                  const SizedBox(height: 24),

                  // --- PASTE THE NEW SCHEDULE CARD HERE ---
                  _staggered(2, Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.greenLight.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.event_note, color: AppColors.greenLight),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Next: Python Workshop",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("Today at 14:00 • Room 4B",
                                style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),
                  _staggered(3, _buildTrainingModules()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.bg.withOpacity(0.92),
      leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer())),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Mentor Portal', style: TextStyle(color: AppColors.white,
            fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        Text('Good morning, Dr. Rami 👋',
            style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
      ]),
      actions: [
        Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
              onPressed: () {}),
          Positioned(right: 10, top: 10,
            child: Container(width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.orange,
                    border: Border.all(color: AppColors.bg, width: 1.5))),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(radius: 18, backgroundColor: AppColors.greenDeep,
              child: const Text('DR', style: TextStyle(color: AppColors.white,
                  fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Poppins'))),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(children: [
      Expanded(
          child: _MiniStat(
              value: '$_assignedCount',
              label: 'Assigned',
              icon: Icons.people_outline_rounded,
              color: AppColors.greenLight
          )
      ),

      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceMarkingScreen()),
            );
          },
          child: _MiniStat(
              value: '2',
              label: 'Absent Today',
              icon: Icons.person_off_rounded,
              color: AppColors.orange
          ),
        ),
      ),
      Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EvaluationScreen(internName: "Pending Intern"),
              ),
            );
          },
          child: _MiniStat(
            value: '3',
            label: 'To Grade',
            icon: Icons.assignment_late_rounded,
            color: AppColors.teal,
          ),
        ),
      ),

    ]);

  }
  // ── My Interns List ────────────────────────────────────────────────────────
  Widget _buildMyInterns() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sectionHeader('My Intern Group', action: 'Reset'),
      const SizedBox(height: 16),

      // SEARCH BAR
      TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() {}), // Refresh list on type
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name...',
          hintStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.greenLight),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 12),

      // DEPARTMENT FILTER CHIPS
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Data Science', 'Design', 'Development'].map((dept) {
            bool isSelected = _selectedDept == dept;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(dept),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedDept = dept),
                selectedColor: AppColors.greenLight,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),

      // THE FILTERED LIST
      _filteredInterns.isEmpty
          ? const Center(child: Text("No interns found", style: TextStyle(color: AppColors.grey)))
          : Column(
        children: _filteredInterns.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell( // <--- ADD THIS
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _InternDetailScreen(intern: e),
                ),
              );
            },
            child: _InternRow(
              name: e['name'],
              dept: e['dept'],
              attendance: e['attendance'],
              grade: e['grade'],
              present: e['present'],
            ),
          ),
        )).toList(),
      ),
    ]);
  }




  Widget _buildTrainingModules() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sectionHeader('Training Modules', action: '+ Upload'),
      const SizedBox(height: 12),
      ..._modules.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ModuleCard(title: m['title']!, type: m['type']!, date: m['date']!),
      )),
    ]);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.bg,
      child: Column(children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.greenDeep, AppColors.green]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 28)),
            const SizedBox(height: 10),
            const Text('Dr. Rami Bencheikh',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                    fontSize: 15, fontFamily: 'Poppins')),
            Text('Data Science Supervisor',
                style: TextStyle(color: Colors.white.withOpacity(0.7),
                    fontSize: 12, fontFamily: 'Poppins')),
          ]),
        ),

        _drawerItem(
            Icons.calendar_month_rounded,
            'Schedule',
            false,
            onTap: () {
              Navigator.pop(context); // Close side menu
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScheduleScreen())
              );
            }
        ),



        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          _drawerItem(
            Icons.people_rounded,
            'My Interns',
            false,
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyInternsScreen())
              );
            },
          ),

          _drawerItem(
            Icons.upload_file_rounded,
            'Upload Module',
            false,
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModuleManagementScreen())
              );
            },
          ),


        ])),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GradientButton(
            label: 'Log Out', icon: Icons.logout_rounded,
            colors: [AppColors.greenDeep, AppColors.green],
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
          ),
        ),
      ]),
    );
  }

  // Add "VoidCallback? onTap" to the parameters
  Widget _drawerItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: active ? AppColors.greenLight : AppColors.grey, size: 22),
      title: Text(label, style: TextStyle(color: active ? AppColors.greenLight : AppColors.white,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          fontFamily: 'Poppins', fontSize: 14)),
      tileColor: active ? AppColors.greenDeep.withOpacity(0.3) : Colors.transparent,
      onTap: onTap, // <--- Use the passed onTap here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class ModuleManagementScreen extends StatefulWidget {
  const ModuleManagementScreen({super.key});

  @override
  State<ModuleManagementScreen> createState() => _ModuleManagementScreenState();
}

class _ModuleManagementScreenState extends State<ModuleManagementScreen> {
  // Mock data for modules
  final List<Map<String, String>> _modules = [
    {'title': 'Introduction to Data Science', 'weeks': 'Week 1-2', 'file': 'intro.pdf'},
    {'title': 'Advanced Python & NumPy', 'weeks': 'Week 3-4', 'file': 'python_adv.docx'},
  ];

  void _deleteModule(int index) {
    setState(() => _modules.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Module deleted"), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Training Modules"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _modules.length,
        itemBuilder: (context, i) => _buildModuleCard(i),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.greenLight,
        onPressed: () => _showModuleForm(context), // Create new
        label: const Text("New Module", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildModuleCard(int index) {
    final module = _modules[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.folder_copy_rounded, color: AppColors.teal),
        title: Text(module['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("${module['weeks']} • ${module['file']}", style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EDIT BUTTON
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.grey),
              onPressed: () => _showModuleForm(context, index: index),
            ),
            // DELETE BUTTON
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => _deleteModule(index),
            ),
          ],
        ),
      ),
    );
  }

  // --- Combined Create & Edit Form ---
  void _showModuleForm(BuildContext context, {int? index}) {
    bool isEditing = index != null;
    final titleController = TextEditingController(text: isEditing ? _modules[index]['title'] : "");
    final weekController = TextEditingController(text: isEditing ? _modules[index]['weeks'] : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEditing ? "Edit Module" : "Create New Module",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInput(titleController, "Module Title", Icons.title_rounded),
            const SizedBox(height: 16),
            _buildInput(weekController, "Duration (e.g., Week 5)", Icons.date_range_rounded),
            const SizedBox(height: 24),

            // UPLOAD PLACEHOLDER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal, style: BorderStyle.solid),
                color: AppColors.teal.withOpacity(0.05),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: AppColors.teal, size: 32),
                  SizedBox(height: 8),
                  Text("Tap to upload PDF or DOCX", style: TextStyle(color: AppColors.teal, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    if (isEditing) {
                      _modules[index] = {'title': titleController.text, 'weeks': weekController.text, 'file': 'updated_file.pdf'};
                    } else {
                      _modules.add({'title': titleController.text, 'weeks': weekController.text, 'file': 'new_upload.pdf'});
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text(isEditing ? "Update Module" : "Save Module",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        filled: true,
        fillColor: AppColors.bg.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
class MyInternsScreen extends StatefulWidget {
  const MyInternsScreen({super.key});

  @override
  State<MyInternsScreen> createState() => _MyInternsScreenState();
}

class _MyInternsScreenState extends State<MyInternsScreen> {
  // Mock data: In a real app, this has a 'mentor' field
  final List<Map<String, dynamic>> _allInterns = [
    {'name': 'Lina Bouzid', 'dept': 'Data Science', 'attendance': 0.9, 'grade': 16.5, 'present': true, 'mentor': 'Dr. Rami Bencheikh'},
    {'name': 'Omar Khelil', 'dept': 'AI Engineering', 'attendance': 0.85, 'grade': 14.0, 'present': false, 'mentor': 'Dr. Rami Bencheikh'},
    {'name': 'Yasmine Taleb', 'dept': 'Data Science', 'attendance': 0.95, 'grade': 18.0, 'present': true, 'mentor': 'Other Mentor'},
    {'name': 'Bilal Messaoud', 'dept': 'Cybersecurity', 'attendance': 0.7, 'grade': 12.5, 'present': true, 'mentor': 'Dr. Rami Bencheikh'},
  ];

  @override
  Widget build(BuildContext context) {
    // Filter the list to only show interns for this specific teacher
    final myInterns = _allInterns.where((i) => i['mentor'] == 'Dr. Rami Bencheikh').toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("My Students"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTeacherHeader(myInterns.length),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myInterns.length,
              itemBuilder: (context, index) {
                final intern = myInterns[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _InternDetailScreen(intern: intern)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.greenLight.withOpacity(0.1),
                          child: Text(intern['name'][0], style: const TextStyle(color: AppColors.greenLight)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(intern['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(intern['dept'], style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      color: AppColors.greenDeep.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Supervised by:", style: TextStyle(color: AppColors.grey, fontSize: 12)),
          const Text("Dr. Rami Bencheikh", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("$count Active Interns", style: const TextStyle(color: AppColors.greenLight, fontSize: 13)),
        ],
      ),
    );
  }
}

class EvaluationScreen extends StatefulWidget {
  final String internName;
  const EvaluationScreen({super.key, required this.internName});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  // Rubric categories and their scores (0.0 to 10.0)
  final Map<String, double> _rubric = {
    "Code Quality": 5.0,
    "Problem Solving": 5.0,
    "Documentation": 5.0,
    "Communication": 5.0,
  };

  double get _totalScore {
    double sum = _rubric.values.reduce((a, b) => a + b);
    return (sum / 40) * 20; // Convert to a /20 scale
  }

  void _saveStatus(bool isFinal) {
    String message = isFinal ? "Evaluation Submitted!" : "Draft Saved Successfully";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isFinal ? AppColors.green : AppColors.teal,
      ),
    );
    if (isFinal) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text("Evaluate ${widget.internName}"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreHeader(),
            const SizedBox(height: 30),
            const Text("Rubric Scoring",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._rubric.keys.map((criterion) => _buildRubricSlider(criterion)),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greenLight.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calculated Grade", style: TextStyle(color: AppColors.grey)),
              Text("Based on Rubric", style: TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          Text("${_totalScore.toStringAsFixed(1)} / 20",
              style: const TextStyle(color: AppColors.greenLight, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRubricSlider(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              Text("${_rubric[title]!.toInt()}/10",
                  style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Slider(
          value: _rubric[title]!,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.greenLight,
          inactiveColor: AppColors.border,
          onChanged: (val) => setState(() => _rubric[title] = val),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _saveStatus(false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.teal),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text("Save as Draft", style: TextStyle(color: AppColors.teal)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveStatus(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenLight,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text("Submit Final Grade",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _HomeView extends StatelessWidget {
  final String moduleName;
  final List<Map<String, dynamic>> interns;
  const _HomeView({required this.moduleName, required this.interns});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildModuleProgress(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          sectionHeader("Recent Submissions"),
          const SizedBox(height: 12),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(moduleName, style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontSize: 14)),
          const Text("Mentor Dashboard", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        const CircleAvatar(backgroundColor: AppColors.surface, child: Icon(Icons.person, color: Colors.white)),
      ],
    );
  }

  Widget _buildModuleProgress() {
    return glassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Syllabus Completion", style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white10, color: AppColors.greenLight, minHeight: 8),
        const SizedBox(height: 8),
        const Text("Week 7 of 12 (Advanced Numpy)", style: TextStyle(color: AppColors.grey, fontSize: 11)),
      ]),
    );
  }

  Widget _buildStatsGrid() {
    return Row(children: [
      Expanded(child: _statCard("Interns", "${interns.length}", Icons.people, AppColors.teal)),
      const SizedBox(width: 12),
      Expanded(child: _statCard("Pending", "3", Icons.pending_actions, AppColors.orange)),
      const SizedBox(width: 12),
      Expanded(child: _statCard("Avg Grade", "14.5", Icons.grade, AppColors.greenLight)),
    ]);
  }

  Widget _statCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
      ]),
    );
  }

  Widget _buildRecentActivity() {
    return glassCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        ListTile(title: const Text("Lab 4 Uploaded", style: TextStyle(color: Colors.white, fontSize: 13)), subtitle: const Text("22 students submitted", style: TextStyle(color: AppColors.grey, fontSize: 11)), leading: const Icon(Icons.file_upload, color: AppColors.teal)),
      ]),
    );
  }
}

class _InternListView extends StatelessWidget {
  final List<Map<String, dynamic>> interns;
  const _InternListView({required this.interns});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search intern...",
              hintStyle: const TextStyle(color: AppColors.grey),
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true, fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: interns.length,
            itemBuilder: (context, index) {
              final intern = interns[index];
              return ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => _InternDetailScreen(intern: intern))),
                leading: CircleAvatar(backgroundColor: AppColors.greenDeep, child: Text(intern['name'][0], style: const TextStyle(color: Colors.white))),
                title: Text(intern['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(intern['dept'], style: const TextStyle(color: AppColors.grey)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14),
              );
            },
          ),
        ),
      ]),
    );
  }
}


class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("My Schedule"), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTimeSlot("09:00", "Morning Stand-up", "Check-in with Interns", AppColors.greenLight),
          _buildTimeSlot("11:30", "Code Review", "Lina & Omar's Project", AppColors.teal),
          _buildTimeSlot("14:00", "Workshop", "Data Cleaning in Python", AppColors.orange),
          _buildTimeSlot("16:00", "Office Hours", "Available for Q&A", AppColors.grey),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border(left: BorderSide(color: color, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InternDetailScreen extends StatelessWidget {
  final Map<String, dynamic> intern;
  const _InternDetailScreen({required this.intern});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.7),
                radius: 1.2,
                colors: [Color(0xFF0D3D25), AppColors.bg],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSnapshotRow(),
                      const SizedBox(height: 30),
                      sectionHeader("Academic Performance"),
                      const SizedBox(height: 12),
                      _buildMarksList(context),
                      const SizedBox(height: 30),
                      _buildActionButtons(context),                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.bg,
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.greenLight.withOpacity(0.2),
                child: Text(intern['name'][0],
                    style: const TextStyle(fontSize: 32, color: AppColors.greenLight, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(intern['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(intern['dept'],
                  style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotRow() {
    return Row(
      children: [
        Expanded(
          child: _SnapshotCard(
            label: "Attendance",
            value: "${(intern['attendance'] * 100).toInt()}%",
            icon: Icons.event_available_rounded,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _SnapshotCard(
            label: "Current Grade",
            value: "${intern['grade']}/20",
            icon: Icons.auto_graph_rounded,
            color: AppColors.greenLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMarksList(BuildContext context) {
    // Mock data for marks history
    final List<Map<String, String>> history = [
      {'title': 'Python Basics Quiz', 'score': '18', 'date': 'Jan 10'},
      {'title': 'Data Cleaning Lab', 'score': '16', 'date': 'Jan 15'},
      {'title': 'Mid-term Project', 'score': '17.5', 'date': 'Jan 22'},
    ];

    return Column(
      children: history.map((item) => GestureDetector(
        onTap: () => _showEditMarkDialog(context, item['title']!, item['score']!),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(item['date']!, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Text("${item['score']!}/20", style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_note_rounded, color: AppColors.grey, size: 18), // Visual hint it's editable
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // CONTACT BUTTON
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showContactInfo(context),
            icon: const Icon(Icons.mail_outline),
            label: const Text("Contact"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 15),
        // EDIT MARKS BUTTON
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showEditMarkDialog(context, "Python Basics Quiz", "18"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenLight,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text("Edit Marks", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- 1. CONTACT INFO BOTTOM SHEET ---
  void _showContactInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Contact Intern", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.teal),
              title: Text("${intern['name'].toString().toLowerCase().replaceAll(' ', '.')}@univ.dz",
                  style: const TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.greenLight),
              title: const Text("+213 555 12 34 56", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. EDIT MARK DIALOG ---
  void _showEditMarkDialog(BuildContext context, String taskTitle, String currentScore) {
    final TextEditingController gradeController = TextEditingController(text: currentScore);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Edit $taskTitle", style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Updating grade for ${intern['name']}", style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            const SizedBox(height: 15),
            TextField(
              controller: gradeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "New Grade",
                suffixText: "/20",
                labelStyle: TextStyle(color: AppColors.greenLight),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.greenLight)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenLight),
            onPressed: () {
              // Success feedback
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$taskTitle updated to ${gradeController.text}/20")),
              );
            },
            child: const Text("Update", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SnapshotCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
// ── Components & Helper Classes ──────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _MiniStat({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22,
            fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
        Text(label, style: const TextStyle(color: AppColors.grey,
            fontSize: 10, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class AttendanceMarkingScreen extends StatefulWidget {
  const AttendanceMarkingScreen({super.key});
  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  // Mock data: In a real app, this comes from your provider/state
  final List<Map<String, dynamic>> _attendanceList = [
    {'name': 'Lina Bouzid', 'status': 'P', 'note': ''},
    {'name': 'Omar Khelil', 'status': 'P', 'note': ''},
    {'name': 'Yasmine Taleb', 'status': 'A', 'note': 'Medical'},
    {'name': 'Bilal Messaoud', 'status': 'L', 'note': 'Transport'},
  ];

  void _bulkMarkPresent() {
    setState(() {
      for (var person in _attendanceList) {
        person['status'] = 'P';
      }
    });
  }

  void _showNoteDialog(int index) {
    TextEditingController _noteCtrl = TextEditingController(text: _attendanceList[index]['note']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Note for ${_attendanceList[index]['name']}", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: _noteCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Reason for absence/late...", hintStyle: TextStyle(color: AppColors.grey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => _attendanceList[index]['note'] = _noteCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Weekly Attendance"),
        actions: [
          IconButton(icon: const Icon(Icons.done_all, color: AppColors.greenLight),
              onPressed: _bulkMarkPresent, tooltip: "Mark All Present"),
        ],
      ),
      body: Column(
        children: [
          _buildWeekHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _attendanceList.length,
              itemBuilder: (context, i) {
                final item = _attendanceList[i];
                return ListTile(
                  title: Text(item['name'], style: const TextStyle(color: Colors.white)),
                  subtitle: item['note'].isNotEmpty
                      ? Text(item['note'], style: const TextStyle(color: AppColors.orange, fontSize: 11))
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusBtn(i, "P", AppColors.greenLight),
                      _statusBtn(i, "L", AppColors.orange),
                      _statusBtn(i, "A", AppColors.red),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.sticky_note_2_outlined,
                            color: item['note'].isNotEmpty ? AppColors.greenLight : AppColors.grey, size: 20),
                        onPressed: () => _showNoteDialog(i),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Week 7: Advanced Python", style: TextStyle(color: AppColors.grey)),
          Text("${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statusBtn(int index, String label, Color color) {
    bool isSelected = _attendanceList[index]['status'] == label;
    return GestureDetector(
      onTap: () => setState(() => _attendanceList[index]['status'] = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: isSelected ? Colors.black : color,
            fontWeight: FontWeight.bold,
          )),
        ),
      ),
    );
  }
}

class _InternRow extends StatelessWidget {
  final String name, dept;
  final double attendance, grade;
  final bool present;
  const _InternRow({required this.name, required this.dept,
    required this.attendance, required this.grade, required this.present});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Stack(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.greenDeep,
            child: Text(name[0], style: const TextStyle(color: AppColors.white,
                fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ),
          Positioned(right: 0, bottom: 0,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: present ? AppColors.greenGlow : AppColors.red,
                border: Border.all(color: AppColors.card, width: 1.5),
              ),
            ),
          ),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: AppColors.white, fontSize: 13,
              fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          Text(dept, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${(attendance * 100).toInt()}% att.',
              style: TextStyle(
                  color: attendance >= 0.8 ? AppColors.greenLight : AppColors.orange,
                  fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.greenDeep.withOpacity(0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$grade/20', style: const TextStyle(color: AppColors.greenLight,
                fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ),
        ]),
      ]),
    );
  }
}


class _ModuleCard extends StatelessWidget {
  final String title, type, date;
  const _ModuleCard({required this.title, required this.type, required this.date});

  Color get _typeColor => type == 'PDF' ? AppColors.red
      : type == 'DOCX' ? AppColors.teal
      : AppColors.gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(type, style: TextStyle(color: _typeColor,
              fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Poppins'))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.white, fontSize: 13,
              fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          Text('Uploaded $date', style: const TextStyle(color: AppColors.grey,
              fontSize: 11, fontFamily: 'Poppins')),
        ])),
        const Icon(Icons.download_rounded, color: AppColors.grey, size: 20),
      ]),
    );
  }
}