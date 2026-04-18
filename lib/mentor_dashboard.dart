import 'package:flutter/material.dart';
import 'theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Mentor Data Store
// ─────────────────────────────────────────────────────────────────────────────
class MentorData {
  static const String mentorName = 'Dr. Rami Bencheikh';
  static const String mentorInitials = 'DR';
  static const String mentorTitle = 'Data Science Supervisor';

  static final List<Map<String, dynamic>> myInterns = [
    {'name':'Lina Bouzid',   'dept':'Data Science',  'nr':'20203501','email':'lina.bouzid@uni.dz',   'phone':'0661 11 22 33','attendance':0.92,'grade':17.5,'present':true,  'grades':[ {'title':'Python Basics Quiz','score':18.0,'date':'Jan 10','max':20}, {'title':'Data Cleaning Lab','score':16.5,'date':'Jan 15','max':20}, {'title':'Mid-term Project','score':17.5,'date':'Jan 22','max':20}]},
    {'name':'Omar Khelil',   'dept':'Design',         'nr':'20203502','email':'omar.khelil@uni.dz',   'phone':'0662 22 33 44','attendance':0.78,'grade':14.0,'present':true,  'grades':[ {'title':'Python Basics Quiz','score':14.0,'date':'Jan 10','max':20}, {'title':'Data Cleaning Lab','score':13.5,'date':'Jan 15','max':20}]},
    {'name':'Yasmine Taleb', 'dept':'Data Science',  'nr':'20203503','email':'yasmine.taleb@uni.dz', 'phone':'0663 33 44 55','attendance':0.85,'grade':16.0,'present':false, 'grades':[ {'title':'Python Basics Quiz','score':17.0,'date':'Jan 10','max':20}, {'title':'Mid-term Project','score':15.0,'date':'Jan 22','max':20}]},
    {'name':'Bilal Messaoud','dept':'Development',   'nr':'20203504','email':'bilal.messaoud@uni.dz','phone':'0664 44 55 66','attendance':0.60,'grade':12.5,'present':false, 'grades':[ {'title':'Python Basics Quiz','score':12.0,'date':'Jan 10','max':20}]},
    {'name':'Sara Khaldi',   'dept':'Data Science',  'nr':'20203505','email':'sara.khaldi@uni.dz',   'phone':'0665 55 66 77','attendance':0.95,'grade':18.5,'present':true,  'grades':[ {'title':'Python Basics Quiz','score':19.0,'date':'Jan 10','max':20}, {'title':'Data Cleaning Lab','score':18.5,'date':'Jan 15','max':20}, {'title':'Mid-term Project','score':18.0,'date':'Jan 22','max':20}]},
  ];

  static final List<Map<String, dynamic>> modules = [
    {'title':'Python Basics',          'type':'PDF',  'date':'Jan 3', 'week':'Week 1–2','desc':'Introduction to Python syntax, data types and control flow.','size':'2.4 MB'},
    {'title':'Data Cleaning Notebook', 'type':'IPYNB','date':'Jan 5', 'week':'Week 3–4','desc':'Hands-on notebook for cleaning real-world datasets with pandas.','size':'1.8 MB'},
    {'title':'Week 2 Assignment',      'type':'DOCX', 'date':'Jan 7', 'week':'Week 2',  'desc':'Assignment covering Python fundamentals and list comprehensions.','size':'340 KB'},
    {'title':'NumPy Deep Dive',        'type':'PDF',  'date':'Jan 12','week':'Week 5–6','desc':'Advanced numerical computing with NumPy arrays and broadcasting.','size':'3.1 MB'},
  ];

  // Attendance log — week → intern name → status/note
  static final Map<String, Map<String, Map<String,String>>> attendanceLog = {
    'Week 7':{
      'Lina Bouzid':    {'status':'P','note':''},
      'Omar Khelil':    {'status':'P','note':''},
      'Yasmine Taleb':  {'status':'A','note':'Medical appointment'},
      'Bilal Messaoud': {'status':'L','note':'Transport delay'},
      'Sara Khaldi':    {'status':'P','note':''},
    },
    'Week 6':{
      'Lina Bouzid':    {'status':'P','note':''},
      'Omar Khelil':    {'status':'A','note':'Sick leave'},
      'Yasmine Taleb':  {'status':'P','note':''},
      'Bilal Messaoud': {'status':'P','note':''},
      'Sara Khaldi':    {'status':'P','note':''},
    },
  };

  // My schedule sessions
  static final List<Map<String, String>> scheduleSessions = [
    {'day':'Sunday',   'time':'09:00–10:00','title':'Morning Stand-up','room':'Online',  'type':'Meeting',  'group':'All interns'},
    {'day':'Sunday',   'time':'11:00–13:00','title':'Python Workshop', 'room':'Lab 05', 'type':'Workshop', 'group':'Data Science'},
    {'day':'Monday',   'time':'10:00–12:00','title':'Code Review',     'room':'Room 4B','type':'Review',   'group':'Lina & Omar'},
    {'day':'Tuesday',  'time':'14:00–16:00','title':'Data Cleaning Lab','room':'Lab 03','type':'Lab',      'group':'All interns'},
    {'day':'Wednesday','time':'09:00–10:00','title':'Office Hours',    'room':'Office 7','type':'Office',  'group':'Open'},
    {'day':'Thursday', 'time':'13:00–15:00','title':'Project Eval',   'room':'Room 12','type':'Evaluation','group':'Bilal & Sara'},
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  MENTOR DASHBOARD  (Home)
// ─────────────────────────────────────────────────────────────────────────────
class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});
  @override State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedDept = 'All';
  String _searchQuery = '';

  int get _assignedCount => MentorData.myInterns.length;
  int get _absentToday   => MentorData.myInterns.where((e) => e['present'] == false).length;
  int get _toGrade       => MentorData.myInterns.where((e) => (e['grades'] as List).length < 3).length;

  List<Map<String, dynamic>> get _filtered => MentorData.myInterns.where((i) {
    final matchName = i['name'].toString().toLowerCase().contains(_searchQuery);
    final matchDept = _selectedDept == 'All' || i['dept'] == _selectedDept;
    return matchName && matchDept;
  }).toList();

  List<String> get _depts => ['All', ...{...MentorData.myInterns.map((i) => i['dept'] as String)}];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
    _fades  = List.generate(5, (i) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryCtrl, curve: Interval(i*0.12, i*0.12+0.5, curve: Curves.easeOut))));
    _slides = List.generate(5, (i) => Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _entryCtrl, curve: Interval(i*0.12, i*0.12+0.5, curve: Curves.easeOutCubic))));
  }

  @override void dispose() { _searchCtrl.dispose(); _entryCtrl.dispose(); super.dispose(); }

  Widget _s(int idx, Widget child) => FadeTransition(opacity: _fades[idx], child: SlideTransition(position: _slides[idx], child: child));

  void _push(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: _buildDrawer(),
      body: SafeArea(child: CustomScrollView(slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            _s(0, _buildSummaryCards()),
            const SizedBox(height: 22),
            _s(1, _buildNextSession()),
            const SizedBox(height: 22),
            _s(2, _buildMyInterns()),
            const SizedBox(height: 22),
            _s(3, _buildTrainingModulesPreview()),
            const SizedBox(height: 22),
            _s(4, _buildSyllabusProgress()),
          ])),
        ),
      ])),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar() => SliverAppBar(
    pinned: true,
    backgroundColor: AppColors.bg.withOpacity(0.95),
    leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu_rounded, color: AppColors.white), onPressed: () => Scaffold.of(ctx).openDrawer())),
    title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('Mentor Portal', style: TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      Text('Good morning, Dr. Rami 👋', style: TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
    ]),
    actions: [
      Stack(children: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.white), onPressed: () {}),
        Positioned(right: 10, top: 10, child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.orange, border: Border.all(color: AppColors.bg, width: 1.5)))),
      ]),
      Padding(padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(radius: 18, backgroundColor: AppColors.greenDeep,
              child: const Text('DR', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Poppins')))),
    ],
  );

  // ── Summary Cards ──────────────────────────────────────────────────────────
  Widget _buildSummaryCards() => Row(children: [
    Expanded(child: _statCard('$_assignedCount', 'Assigned', Icons.people_outline_rounded, AppColors.greenLight, null)),
    const SizedBox(width: 10),
    Expanded(child: GestureDetector(onTap: () => _push(const AttendanceMarkingScreen()),
        child: _statCard('$_absentToday', 'Absent Today', Icons.person_off_rounded, AppColors.orange, 'Tap to mark'))),
    const SizedBox(width: 10),
    Expanded(child: GestureDetector(onTap: () => _push(EvaluationScreen(intern: MentorData.myInterns[0])),
        child: _statCard('$_toGrade', 'To Grade', Icons.assignment_late_rounded, AppColors.teal, 'Tap to grade'))),
  ]);

  Widget _statCard(String value, String label, IconData icon, Color color, String? hint) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.25))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20), const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
      if (hint != null) ...[const SizedBox(height: 4), Text(hint, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontFamily: 'Poppins'))],
    ]),
  );

  // ── Next Session ───────────────────────────────────────────────────────────
  Widget _buildNextSession() => GestureDetector(
    onTap: () => _push(const MentorScheduleScreen()),
    child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.greenLight.withOpacity(0.2))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.greenLight.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.event_note_rounded, color: AppColors.greenLight)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Next Session', style: TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
          const Text('Python Workshop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const Text('Today at 11:00 · Lab 05 · Data Science', style: TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey, size: 14),
      ]),
    ),
  );

  // ── My Interns ─────────────────────────────────────────────────────────────
  Widget _buildMyInterns() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('My Intern Group', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      TextButton(onPressed: () => _push(const MyInternsScreen()), child: const Text('View All', style: TextStyle(color: AppColors.greenLight, fontSize: 12, fontFamily: 'Poppins'))),
    ]),
    const SizedBox(height: 12),
    // Search
    TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        decoration: InputDecoration(hintText: 'Search by name…', hintStyle: const TextStyle(color: AppColors.grey, fontFamily: 'Poppins'),
            prefixIcon: const Icon(Icons.search, color: AppColors.greenLight, size: 20),
            suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18),
                onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); }) : null,
            filled: true, fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 12))),
    const SizedBox(height: 10),
    // Dept filter chips
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _depts.map((dept) {
      final sel = _selectedDept == dept;
      return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: () => setState(() => _selectedDept = dept),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: sel ? AppColors.greenLight : AppColors.surface, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppColors.greenLight : AppColors.border)),
              child: Text(dept, style: TextStyle(color: sel ? Colors.black : AppColors.grey, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.normal, fontFamily: 'Poppins')))));
    }).toList())),
    const SizedBox(height: 14),
    _filtered.isEmpty
        ? Container(padding: const EdgeInsets.all(20), alignment: Alignment.center,
        child: const Text('No interns found', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')))
        : Column(children: _filtered.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(onTap: () => _push(InternDetailScreen(intern: e)),
            child: _InternRow(intern: e)))).toList()),
  ]);

  // ── Training Modules Preview ───────────────────────────────────────────────
  Widget _buildTrainingModulesPreview() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Training Modules', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      TextButton(onPressed: () => _push(const ModuleManagementScreen()), child: const Text('Manage', style: TextStyle(color: AppColors.greenLight, fontSize: 12, fontFamily: 'Poppins'))),
    ]),
    const SizedBox(height: 12),
    ...MentorData.modules.take(3).map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _ModuleCard(module: m, onTap: null))),
  ]);

  // ── Syllabus Progress ──────────────────────────────────────────────────────
  Widget _buildSyllabusProgress() => Container(padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Syllabus Completion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Poppins')),
        Text('65%', style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
      ]),
      const SizedBox(height: 6),
      const Text('Week 7 of 12 — Advanced NumPy', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: 0.65, backgroundColor: AppColors.surface, color: AppColors.greenLight, minHeight: 10)),
      const SizedBox(height: 12),
      Row(children: [
        _prog('Completed', '7', AppColors.greenLight), const SizedBox(width: 20),
        _prog('Remaining', '5', AppColors.orange), const SizedBox(width: 20),
        _prog('Avg Grade', '15.3', AppColors.teal),
      ]),
    ]),
  );

  Widget _prog(String l, String v, Color c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
    Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins')),
  ]);

  // ── Drawer ─────────────────────────────────────────────────────────────────
  Widget _buildDrawer() => Drawer(backgroundColor: AppColors.bg, child: Column(children: [
    DrawerHeader(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.greenDeep, AppColors.green])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.white.withOpacity(0.2), child: const Icon(Icons.school_rounded, color: Colors.white, size: 28)),
          const SizedBox(height: 10),
          Text(MentorData.mentorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Poppins')),
          Text(MentorData.mentorTitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'Poppins')),
        ])),
    Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), children: [
      _dItem(Icons.dashboard_rounded,    'Dashboard',       () => Navigator.pop(context)),
      _dItem(Icons.people_rounded,       'My Interns',      () { Navigator.pop(context); _push(const MyInternsScreen()); }),
      _dItem(Icons.how_to_reg_rounded,   'Attendance',      () { Navigator.pop(context); _push(const AttendanceMarkingScreen()); }),
      _dItem(Icons.star_half_rounded,    'Evaluations',     () { Navigator.pop(context); _push(EvaluationScreen(intern: MentorData.myInterns[0])); }),
      _dItem(Icons.calendar_month_rounded,'Schedule',       () { Navigator.pop(context); _push(const MentorScheduleScreen()); }),
      _dItem(Icons.upload_file_rounded,  'Training Modules',() { Navigator.pop(context); _push(const ModuleManagementScreen()); }),
    ])),
    Padding(padding: const EdgeInsets.all(16), child: GradientButton(label: 'Log Out', icon: Icons.logout_rounded,
        colors: const [AppColors.greenDeep, AppColors.green],
        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false))),
  ]));

  Widget _dItem(IconData icon, String label, VoidCallback onTap) => ListTile(
      leading: Icon(icon, color: AppColors.grey, size: 22),
      title: Text(label, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w400, fontFamily: 'Poppins', fontSize: 14)),
      onTap: onTap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
}

// ═════════════════════════════════════════════════════════════════════════════
//  MY INTERNS SCREEN  (full list with search + filter)
// ═════════════════════════════════════════════════════════════════════════════
class MyInternsScreen extends StatefulWidget {
  const MyInternsScreen({super.key});
  @override State<MyInternsScreen> createState() => _MyInternsScreenState();
}

class _MyInternsScreenState extends State<MyInternsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _dept = 'All';
  String _sort = 'Name';

  List<Map<String, dynamic>> get _filtered {
    var list = MentorData.myInterns.where((i) {
      final mName = i['name'].toString().toLowerCase().contains(_query);
      final mDept = _dept == 'All' || i['dept'] == _dept;
      return mName && mDept;
    }).toList();
    if (_sort == 'Grade') list.sort((a, b) => (b['grade'] as double).compareTo(a['grade'] as double));
    if (_sort == 'Attendance') list.sort((a, b) => (b['attendance'] as double).compareTo(a['attendance'] as double));
    if (_sort == 'Name') list.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    return list;
  }

  List<String> get _depts => ['All', ...{...MentorData.myInterns.map((i) => i['dept'] as String)}];

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('My Interns', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent, elevation: 0),
    body: Column(children: [
      // Stats header
      Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.greenDeep.withOpacity(0.25), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.greenLight.withOpacity(0.2))),
          child: Row(children: [
            _hStat('${MentorData.myInterns.length}', 'Total', AppColors.greenLight),
            _vDiv(), _hStat('${MentorData.myInterns.where((i)=>i['present']==true).length}', 'Present', AppColors.teal),
            _vDiv(), _hStat('${MentorData.myInterns.where((i)=>i['present']==false).length}', 'Absent', AppColors.orange),
            _vDiv(), _hStat('${(MentorData.myInterns.map((i)=>i['grade'] as double).reduce((a,b)=>a+b)/MentorData.myInterns.length).toStringAsFixed(1)}', 'Avg Grade', AppColors.gold),
          ])),
      // Search
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: InputDecoration(hintText: 'Search by name…', hintStyle: const TextStyle(color: AppColors.grey, fontFamily: 'Poppins'),
                  prefixIcon: const Icon(Icons.search, color: AppColors.greenLight, size: 20),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
      // Filters
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _depts.map((d) {
              final sel = _dept == d;
              return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: () => setState(() => _dept = d),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: sel ? AppColors.greenLight : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.greenLight : AppColors.border)),
                      child: Text(d, style: TextStyle(color: sel ? Colors.black : AppColors.grey, fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.normal, fontFamily: 'Poppins')))));
            }).toList()))),
            PopupMenuButton<String>(icon: const Icon(Icons.sort_rounded, color: AppColors.grey), color: AppColors.surface,
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (_) => ['Name','Grade','Attendance'].map((s) => PopupMenuItem(value: s, child: Text(s, style: TextStyle(color: _sort==s?AppColors.greenLight:Colors.white, fontFamily: 'Poppins')))).toList()),
          ])),
      Expanded(child: _filtered.isEmpty
          ? const Center(child: Text('No interns found.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')))
          : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filtered.length,
          itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => InternDetailScreen(intern: _filtered[i]))),
                  child: _InternRow(intern: _filtered[i]))))),
    ]),
  );

  Widget _hStat(String v, String l, Color c) => Expanded(child: Column(children: [Text(v, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins'))]));
  Widget _vDiv() => Container(height: 30, width: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4));
}

// ═════════════════════════════════════════════════════════════════════════════
//  INTERN DETAIL SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class InternDetailScreen extends StatelessWidget {
  final Map<String, dynamic> intern;
  const InternDetailScreen({super.key, required this.intern});

  @override
  Widget build(BuildContext ctx) {
    final grades = (intern['grades'] as List).cast<Map<String, dynamic>>();
    final avg = grades.isEmpty ? 0.0 : grades.map((g) => g['score'] as double).reduce((a,b)=>a+b) / grades.length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(-0.5,-0.7), radius: 1.2, colors: [Color(0xFF0D3D25), AppColors.bg]))),
        CustomScrollView(slivers: [
          SliverAppBar(expandedHeight: 200, pinned: true, backgroundColor: AppColors.bg,
              flexibleSpace: FlexibleSpaceBar(background: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Stack(children: [
                  CircleAvatar(radius: 42, backgroundColor: AppColors.greenLight.withOpacity(0.2),
                      child: Text(intern['name'][0], style: const TextStyle(fontSize: 34, color: AppColors.greenLight, fontWeight: FontWeight.bold))),
                  Positioned(bottom: 2, right: 2, child: Container(width: 14, height: 14,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: intern['present']==true ? AppColors.greenGlow : AppColors.red, border: Border.all(color: AppColors.bg, width: 2)))),
                ]),
                const SizedBox(height: 10),
                Text(intern['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                Text(intern['dept'], style: const TextStyle(color: AppColors.grey, fontSize: 13, fontFamily: 'Poppins')),
              ])))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Snapshot row
            Row(children: [
              Expanded(child: _snap('${(intern['attendance']*100).toInt()}%', 'Attendance', Icons.event_available_rounded, AppColors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _snap('${intern['grade']}/20', 'Current Grade', Icons.auto_graph_rounded, AppColors.greenLight)),
              const SizedBox(width: 12),
              Expanded(child: _snap('NR ${intern['nr']}', 'Student ID', Icons.badge_rounded, AppColors.gold)),
            ]),
            const SizedBox(height: 24),
            // Contact
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  _contactRow(Icons.alternate_email, intern['email']),
                  const Divider(color: AppColors.divider, height: 20),
                  _contactRow(Icons.phone_outlined, intern['phone']),
                ])),
            const SizedBox(height: 24),
            // Grades
            const Text('Academic Performance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            ...grades.map((g) => _gradeRow(ctx, g)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.greenDeep.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Average', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')),
                  Text('${avg.toStringAsFixed(1)} / 20', style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                ])),
            const SizedBox(height: 24),
            // Action buttons
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _contactSheet(ctx),
                  icon: const Icon(Icons.mail_outline, size: 16), label: const Text('Contact', style: TextStyle(fontFamily: 'Poppins')),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => EvaluationScreen(intern: intern))),
                  icon: const Icon(Icons.star_half_rounded, size: 16), label: const Text('Evaluate', style: TextStyle(fontFamily: 'Poppins')),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenLight, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)))),
            ]),
            const SizedBox(height: 20),
          ]))),
        ]),
      ]),
    );
  }

  Widget _snap(String v, String l, IconData ic, Color c) => Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.25))),
      child: Column(children: [Icon(ic, color: c, size: 20), const SizedBox(height: 8), Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), textAlign: TextAlign.center), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 9, fontFamily: 'Poppins'), textAlign: TextAlign.center)]));

  Widget _contactRow(IconData ic, String v) => Row(children: [Icon(ic, color: AppColors.greenLight, size: 18), const SizedBox(width: 12), Text(v, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13))]);

  Widget _gradeRow(BuildContext ctx, Map<String, dynamic> g) => GestureDetector(
      onTap: () => _editGradeDialog(ctx, g),
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              Text(g['date'], style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
            ])),
            Row(children: [
              Text('${g['score']}/${g['max']}', style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(width: 8),
              const Icon(Icons.edit_note_rounded, color: AppColors.grey, size: 16),
            ]),
          ])));

  void _editGradeDialog(BuildContext ctx, Map<String, dynamic> g) {
    final ctrl = TextEditingController(text: '${g['score']}');
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.surface,
        title: Text('Edit ${g['title']}', style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Poppins')),
        content: TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(labelText: 'Score (max ${g['max']})', suffixText: '/${g['max']}', labelStyle: const TextStyle(color: AppColors.greenLight), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.greenLight)))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenLight),
              onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${g['title']} updated to ${ctrl.text}/${g['max']}'), backgroundColor: AppColors.green)); },
              child: const Text('Update', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')))]));
  }

  void _contactSheet(BuildContext ctx) => showModalBottomSheet(context: ctx, backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Contact ${intern['name']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Icons.email, color: AppColors.teal), title: Text(intern['email'], style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')), onTap: () {}),
        ListTile(leading: const Icon(Icons.phone, color: AppColors.greenLight), title: Text(intern['phone'], style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')), onTap: () {}),
      ])));
}

// ═════════════════════════════════════════════════════════════════════════════
//  ATTENDANCE MARKING SCREEN  — weekly view with bulk mark
// ═════════════════════════════════════════════════════════════════════════════
class AttendanceMarkingScreen extends StatefulWidget {
  const AttendanceMarkingScreen({super.key});
  @override State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  String _currentWeek = 'Week 7';
  late Map<String, Map<String, String>> _log;

  @override void initState() { super.initState(); _loadWeek(); }

  void _loadWeek() {
    final source = MentorData.attendanceLog[_currentWeek];
    if (source != null) {
      _log = {for (final e in source.entries) e.key: Map.from(e.value)};
    } else {
      _log = {for (final i in MentorData.myInterns) i['name'] as String: {'status':'P','note':''}};
    }
  }

  void _switchWeek(String week) { setState(() { _currentWeek = week; _loadWeek(); }); }

  void _bulkMarkPresent() => setState(() { for (final k in _log.keys) { _log[k]!['status'] = 'P'; _log[k]!['note'] = ''; } });

  int get _presentCount => _log.values.where((v) => v['status'] == 'P').length;
  int get _absentCount  => _log.values.where((v) => v['status'] == 'A').length;
  int get _lateCount    => _log.values.where((v) => v['status'] == 'L').length;

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Attendance', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.done_all_rounded, color: AppColors.greenLight), tooltip: 'Mark All Present', onPressed: _bulkMarkPresent),
          IconButton(icon: const Icon(Icons.save_rounded, color: AppColors.teal), tooltip: 'Save', onPressed: () => ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Attendance saved!'), backgroundColor: AppColors.green))),
        ]),
    body: Column(children: [
      // Week selector
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: AppColors.surface,
          child: Row(children: [
            Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: MentorData.attendanceLog.keys.map((week) {
              final sel = week == _currentWeek;
              return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: () => _switchWeek(week),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: sel ? AppColors.greenLight : AppColors.bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.greenLight : AppColors.border)),
                      child: Text(week, style: TextStyle(color: sel ? Colors.black : AppColors.grey, fontWeight: sel ? FontWeight.w700 : FontWeight.normal, fontSize: 12, fontFamily: 'Poppins')))));
            }).toList()))),
            const SizedBox(width: 8),
            GestureDetector(onTap: () => _addWeek(ctx), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)), child: const Icon(Icons.add, color: AppColors.greenLight, size: 18))),
          ])),
      // Summary chips
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        _sumChip('Present', _presentCount, AppColors.greenLight),
        const SizedBox(width: 8),
        _sumChip('Absent', _absentCount, AppColors.red),
        const SizedBox(width: 8),
        _sumChip('Late', _lateCount, AppColors.orange),
        const Spacer(),
        Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
      ])),
      // List
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _log.length,
          itemBuilder: (_, i) {
            final name = _log.keys.elementAt(i);
            final entry = _log[name]!;
            return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  CircleAvatar(radius: 20, backgroundColor: _statusColor(entry['status']!).withOpacity(0.15),
                      child: Text(name[0], style: TextStyle(color: _statusColor(entry['status']!), fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    if (entry['note']!.isNotEmpty) Text(entry['note']!, style: const TextStyle(color: AppColors.orange, fontSize: 11, fontFamily: 'Poppins')),
                  ])),
                  Row(children: [
                    _statusBtn(name, 'P', AppColors.greenLight),
                    const SizedBox(width: 6),
                    _statusBtn(name, 'L', AppColors.orange),
                    const SizedBox(width: 6),
                    _statusBtn(name, 'A', AppColors.red),
                    const SizedBox(width: 8),
                    IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        icon: Icon(Icons.sticky_note_2_outlined, color: entry['note']!.isNotEmpty ? AppColors.greenLight : AppColors.greyDark, size: 20),
                        onPressed: () => _noteDialog(ctx, name, entry)),
                  ]),
                ]));
          })),
    ]),
  );

  Widget _sumChip(String l, int v, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text('$v', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), const SizedBox(width: 4), Text(l, style: TextStyle(color: c, fontSize: 11, fontFamily: 'Poppins'))]));

  Widget _statusBtn(String name, String status, Color color) {
    final sel = _log[name]!['status'] == status;
    return GestureDetector(onTap: () => setState(() => _log[name]!['status'] = status),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 34, height: 34,
            decoration: BoxDecoration(color: sel ? color : Colors.transparent, border: Border.all(color: color), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(status, style: TextStyle(color: sel ? Colors.black : color, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Poppins')))));
  }

  Color _statusColor(String s) => s == 'P' ? AppColors.greenLight : s == 'L' ? AppColors.orange : AppColors.red;

  void _noteDialog(BuildContext ctx, String name, Map<String, String> entry) {
    final ctrl = TextEditingController(text: entry['note']);
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.surface,
        title: Text('Note for $name', style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Poppins')),
        content: TextField(controller: ctrl, maxLines: 3, style: const TextStyle(color: Colors.white),
            decoration: proLinkInputDecoration(label: 'Reason / Note', hint: 'e.g. Medical appointment…', icon: Icons.edit_note_rounded)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: () { setState(() => entry['note'] = ctrl.text); Navigator.pop(ctx); },
              child: const Text('Save', style: TextStyle(fontFamily: 'Poppins')))]));
  }

  void _addWeek(BuildContext ctx) {
    final ctrl = TextEditingController(text: 'Week ${MentorData.attendanceLog.length + 1}');
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.surface,
        title: const Text('Add Week', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white),
            decoration: proLinkInputDecoration(label: 'Week label', hint: 'e.g. Week 8', icon: Icons.calendar_today_rounded)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: () { MentorData.attendanceLog[ctrl.text] = {for (final i in MentorData.myInterns) i['name'] as String: {'status':'P','note':''}}; _switchWeek(ctrl.text); Navigator.pop(ctx); },
              child: const Text('Create', style: TextStyle(fontFamily: 'Poppins')))]));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  EVALUATION SCREEN  — rubric-based with visual scoring
// ═════════════════════════════════════════════════════════════════════════════
class EvaluationScreen extends StatefulWidget {
  final Map<String, dynamic> intern;
  const EvaluationScreen({super.key, required this.intern});
  @override State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  // Rubric: criterion → {score, max, description}
  final List<Map<String, dynamic>> _rubric = [
    {'criterion':'Technical Skills',    'score':0,'max':5,'icon':Icons.code_rounded,            'desc':'Code quality, correctness and use of best practices','color':AppColors.teal},
    {'criterion':'Problem Solving',     'score':0,'max':5,'icon':Icons.psychology_rounded,       'desc':'Ability to break down and solve complex problems','color':AppColors.greenLight},
    {'criterion':'Communication',       'score':0,'max':4,'icon':Icons.chat_bubble_outline_rounded,'desc':'Clarity in reports, presentations and team interaction','color':AppColors.gold},
    {'criterion':'Initiative',          'score':0,'max':3,'icon':Icons.rocket_launch_rounded,    'desc':'Proactivity, curiosity and going beyond assigned tasks','color':AppColors.orange},
    {'criterion':'Documentation',       'score':0,'max':3,'icon':Icons.description_rounded,      'desc':'Quality of written reports and code documentation','color':AppColors.greenPastel},
  ];

  final _commentCtrl = TextEditingController();
  bool _isDraft = false;

  int get _totalScore => _rubric.fold(0, (sum, r) => sum + (r['score'] as int));
  int get _maxScore   => _rubric.fold(0, (sum, r) => sum + (r['max'] as int));
  double get _grade20 => _maxScore == 0 ? 0 : (_totalScore / _maxScore) * 20;

  Color get _gradeColor {
    if (_grade20 >= 16) return AppColors.greenLight;
    if (_grade20 >= 12) return AppColors.teal;
    if (_grade20 >= 8)  return AppColors.orange;
    return AppColors.red;
  }

  String get _gradeLabel {
    if (_grade20 >= 16) return 'Excellent';
    if (_grade20 >= 12) return 'Good';
    if (_grade20 >= 8)  return 'Satisfactory';
    return 'Needs Improvement';
  }

  @override void dispose() { _commentCtrl.dispose(); super.dispose(); }

  void _save(bool isFinal) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFinal ? '✓ Evaluation submitted for ${widget.intern['name']}' : '✓ Draft saved'),
        backgroundColor: isFinal ? AppColors.green : AppColors.teal));
    if (isFinal) { setState(() => _isDraft = false); Navigator.pop(context); }
    else setState(() => _isDraft = true);
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: Text('Evaluate ${widget.intern['name']}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent,
        actions: [if (_isDraft) Container(margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.orange.withOpacity(0.4))),
            child: const Center(child: Text('DRAFT', style: TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))))]),
    body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Header — intern info + live score
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gradeColor.withOpacity(0.3))),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: _gradeColor.withOpacity(0.15),
                child: Text(widget.intern['name'][0], style: TextStyle(color: _gradeColor, fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.intern['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
              Text(widget.intern['dept'], style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_grade20.toStringAsFixed(1), style: TextStyle(color: _gradeColor, fontSize: 36, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
              Text('/ 20  ·  $_gradeLabel', style: TextStyle(color: _gradeColor.withOpacity(0.7), fontSize: 11, fontFamily: 'Poppins')),
            ]),
          ])),
      const SizedBox(height: 8),
      // Progress bar
      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _maxScore == 0 ? 0 : _totalScore / _maxScore, backgroundColor: AppColors.surface, color: _gradeColor, minHeight: 8)),
      Padding(padding: const EdgeInsets.only(top: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$_totalScore / $_maxScore pts', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        Text('${(_maxScore == 0 ? 0 : _totalScore/_maxScore*100).toStringAsFixed(0)}%', style: TextStyle(color: _gradeColor, fontSize: 11, fontFamily: 'Poppins')),
      ])),

      const SizedBox(height: 24),
      const Text('Rubric Criteria', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      const SizedBox(height: 14),

      // Rubric cards
      ..._rubric.asMap().entries.map((e) => _rubricCard(e.key, e.value)),

      const SizedBox(height: 20),
      // Comment
      const Text('Overall Comment', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      const SizedBox(height: 10),
      TextField(controller: _commentCtrl, maxLines: 4, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          decoration: proLinkInputDecoration(label: 'Comment', hint: 'Write your overall feedback…', icon: Icons.edit_outlined)),
      const SizedBox(height: 28),

      // Buttons
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () => _save(false),
            icon: const Icon(Icons.save_outlined, size: 16), label: const Text('Save Draft', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.teal, side: const BorderSide(color: AppColors.teal), padding: const EdgeInsets.symmetric(vertical: 16)))),
        const SizedBox(width: 14),
        Expanded(child: ElevatedButton.icon(onPressed: () => _save(true),
            icon: const Icon(Icons.send_rounded, size: 16), label: const Text('Submit Final', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenLight, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)))),
      ]),
      const SizedBox(height: 20),
    ])),
  );

  Widget _rubricCard(int idx, Map<String, dynamic> r) {
    final score = r['score'] as int;
    final max   = r['max'] as int;
    final color = r['color'] as Color;
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: score > 0 ? color.withOpacity(0.35) : AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(r['icon'] as IconData, color: color, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['criterion'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14)),
              Text(r['desc'], style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$score', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
              Text('/ $max', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
            ]),
          ]),
          const SizedBox(height: 14),
          // Score buttons (0 to max)
          Row(children: List.generate(max + 1, (i) {
            final sel = i == score;
            return Expanded(child: Padding(padding: EdgeInsets.only(right: i < max ? 5 : 0),
                child: GestureDetector(onTap: () => setState(() => _rubric[idx]['score'] = i),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                        height: 38,
                        decoration: BoxDecoration(color: sel ? color : AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? color : AppColors.border)),
                        child: Center(child: Text('$i', style: TextStyle(color: sel ? Colors.black : AppColors.grey, fontWeight: sel ? FontWeight.w800 : FontWeight.normal, fontSize: 13, fontFamily: 'Poppins')))))));
          })),
          const SizedBox(height: 10),
          // Mini progress
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: max == 0 ? 0 : score / max, backgroundColor: AppColors.surface, color: color, minHeight: 4)),
        ]));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  MENTOR SCHEDULE SCREEN  — weekly timetable view
// ═════════════════════════════════════════════════════════════════════════════
class MentorScheduleScreen extends StatefulWidget {
  const MentorScheduleScreen({super.key});
  @override State<MentorScheduleScreen> createState() => _MentorScheduleScreenState();
}

class _MentorScheduleScreenState extends State<MentorScheduleScreen> {
  static const _days = ['Sunday','Monday','Tuesday','Wednesday','Thursday'];
  static const _dayColors = [AppColors.greenLight, AppColors.teal, AppColors.gold, AppColors.orange, AppColors.greenPastel];
  static const _typeColors = {
    'Meeting':   AppColors.teal,
    'Workshop':  AppColors.greenLight,
    'Review':    AppColors.gold,
    'Lab':       AppColors.orange,
    'Office':    AppColors.grey,
    'Evaluation':AppColors.red,
  };

  late List<Map<String, String>> _sessions;
  @override void initState() { super.initState(); _sessions = List.from(MentorData.scheduleSessions); }

  @override
  Widget build(BuildContext ctx) {
    final byDay = <String, List<Map<String, String>>>{for (final d in _days) d: _sessions.where((s) => s['day'] == d).toList()};
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('My Schedule', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent,
          actions: [IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.greenLight), onPressed: () => _addSessionDialog(ctx))]),
      body: Column(children: [
        // Week summary strip
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              _weekStat('${_sessions.length}', 'Sessions',  AppColors.greenLight),
              _vd(), _weekStat('${_sessions.where((s)=>s['type']=='Workshop'||s['type']=='Lab').length}', 'Practical', AppColors.teal),
              _vd(), _weekStat('${_sessions.where((s)=>s['type']=='Evaluation').length}', 'Evals', AppColors.orange),
              _vd(), _weekStat('2h avg', 'Duration', AppColors.gold),
            ])),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          ..._days.asMap().entries.map((e) {
            final day = e.value; final dayColor = _dayColors[e.key]; final daySessions = byDay[day]!;
            if (daySessions.isEmpty) return const SizedBox.shrink();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(bottom: 10, top: 4), child: Row(children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: dayColor, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
                Text(day, style: TextStyle(color: dayColor, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins')),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: dayColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('${daySessions.length} session${daySessions.length>1?'s':''}', style: TextStyle(color: dayColor, fontSize: 10, fontFamily: 'Poppins'))),
              ])),
              ...daySessions.map((s) => _sessionCard(ctx, s, _typeColors[s['type']] ?? AppColors.grey)),
              const SizedBox(height: 14),
            ]);
          }),
          const SizedBox(height: 20),
        ])),
      ]),
    );
  }

  Widget _weekStat(String v, String l, Color c) => Expanded(child: Column(children: [Text(v, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins'))]));
  Widget _vd() => Container(height: 28, width: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _sessionCard(BuildContext ctx, Map<String, String> s, Color color) => GestureDetector(
      onTap: () => _editSessionDialog(ctx, s),
      child: Container(margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: color, width: 4))),
          child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(s['type']!, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
              ]),
              const SizedBox(height: 6),
              Text(s['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.schedule_rounded, color: AppColors.grey, size: 13), const SizedBox(width: 4), Text(s['time']!, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
                const SizedBox(width: 12),
                const Icon(Icons.room_outlined, color: AppColors.grey, size: 13), const SizedBox(width: 4), Text(s['room']!, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.groups_outlined, color: AppColors.grey, size: 13), const SizedBox(width: 4), Text(s['group']!, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins'))]),
            ])),
            const Icon(Icons.edit_outlined, color: AppColors.greyDark, size: 16),
          ]))));

  void _addSessionDialog(BuildContext ctx) {
    final titleCtrl = TextEditingController(); final roomCtrl = TextEditingController(); final groupCtrl = TextEditingController();
    String? selDay; String? selTime; String? selType;
    const times = ['08:00–10:00','09:00–10:00','10:00–12:00','11:00–13:00','13:00–15:00','14:00–16:00','16:00–18:00'];
    const days  = ['Sunday','Monday','Tuesday','Wednesday','Thursday'];
    const types = ['Meeting','Workshop','Review','Lab','Office','Evaluation'];
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => StatefulBuilder(builder: (c, ss) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Add Session', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Title', hint: 'e.g. Python Workshop', icon: Icons.title_rounded)),
              const SizedBox(height: 12),
              TextField(controller: roomCtrl,  style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Room', hint: 'e.g. Lab 05', icon: Icons.room_outlined)),
              const SizedBox(height: 12),
              TextField(controller: groupCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Group', hint: 'e.g. All interns', icon: Icons.groups_rounded)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _drop('Day', days, selDay, (v) => ss(() => selDay = v))),
                const SizedBox(width: 10),
                Expanded(child: _drop('Time', times, selTime, (v) => ss(() => selTime = v))),
              ]),
              const SizedBox(height: 12),
              _drop('Type', types, selType, (v) => ss(() => selType = v)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () { if (titleCtrl.text.isNotEmpty && selDay != null && selTime != null && selType != null) { setState(() => _sessions.add({'title':titleCtrl.text,'room':roomCtrl.text,'group':groupCtrl.text,'day':selDay!,'time':selTime!,'type':selType!})); Navigator.pop(ctx); }},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Save Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
            ])))));
  }

  void _editSessionDialog(BuildContext ctx, Map<String, String> s) {
    showModalBottomSheet(context: ctx, backgroundColor: AppColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(s['title']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          _infoTile(Icons.schedule_rounded, 'Time', s['time']!), _infoTile(Icons.room_outlined, 'Room', s['room']!),
          _infoTile(Icons.groups_outlined, 'Group', s['group']!), _infoTile(Icons.label_outline_rounded, 'Type', s['type']!),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { setState(() => _sessions.remove(s)); Navigator.pop(ctx); },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins')))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Close', style: TextStyle(fontFamily: 'Poppins')))),
          ]),
        ])));
  }

  Widget _infoTile(IconData ic, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [Icon(ic, color: AppColors.grey, size: 16), const SizedBox(width: 10), Text('$l: ', style: const TextStyle(color: AppColors.grey, fontSize: 13, fontFamily: 'Poppins')), Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Poppins'))]));

  Widget _drop(String label, List<String> items, String? val, Function(String?) fn) =>
      Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, dropdownColor: AppColors.surface, value: val,
              hint: Text(label, style: const TextStyle(color: AppColors.greyDark, fontFamily: 'Poppins', fontSize: 12)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 12)))).toList(),
              onChanged: fn)));
}

// ═════════════════════════════════════════════════════════════════════════════
//  MODULE MANAGEMENT SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class ModuleManagementScreen extends StatefulWidget {
  const ModuleManagementScreen({super.key});
  @override State<ModuleManagementScreen> createState() => _ModuleManagementScreenState();
}

class _ModuleManagementScreenState extends State<ModuleManagementScreen> {
  late List<Map<String, dynamic>> _modules;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override void initState() { super.initState(); _modules = List.from(MentorData.modules); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filtered => _query.isEmpty ? _modules
      : _modules.where((m) => m['title'].toString().toLowerCase().contains(_query) || m['type'].toString().toLowerCase().contains(_query)).toList();

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Training Modules', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent, elevation: 0),
    body: Column(children: [
      // Stats
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        _mStat('${_modules.length}', 'Modules', AppColors.teal),
        const SizedBox(width: 10),
        _mStat('${_modules.where((m)=>m['type']=='PDF').length}',  'PDFs',      AppColors.red),
        const SizedBox(width: 10),
        _mStat('${_modules.where((m)=>m['type']!='PDF').length}', 'Other',     AppColors.gold),
      ])),
      // Search
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: proLinkInputDecoration(label: 'Search Modules', hint: 'Title or type…', icon: Icons.search).copyWith(
                  suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); }) : null))),
      const SizedBox(height: 8),
      Expanded(child: _filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.folder_off_rounded, color: AppColors.greyDark, size: 50), const SizedBox(height: 12), const Text('No modules found.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins'))]))
          : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filtered.length,
          itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ModuleCard(module: _filtered[i],
              onTap: () => _showModuleForm(ctx, existing: _filtered[i]))))),
    ]),
    floatingActionButton: FloatingActionButton.extended(backgroundColor: AppColors.greenLight, onPressed: () => _showModuleForm(ctx),
        label: const Text('New Module', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        icon: const Icon(Icons.add, color: Colors.black)),
  );

  Widget _mStat(String v, String l, Color c) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.25))),
      child: Column(children: [Text(v, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins'))])));

  void _showModuleForm(BuildContext ctx, {Map<String, dynamic>? existing}) {
    final bool editing = existing != null;
    final titleCtrl = TextEditingController(text: editing ? existing['title'] : '');
    final weekCtrl  = TextEditingController(text: editing ? existing['week']  : '');
    final descCtrl  = TextEditingController(text: editing ? existing['desc']  : '');
    String? selType = editing ? existing['type'] : null;
    const types = ['PDF','DOCX','IPYNB','PPTX','ZIP'];

    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => StatefulBuilder(builder: (c, ss) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(editing ? 'Edit Module' : 'Create New Module', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Module Title', hint: 'e.g. Python Basics', icon: Icons.title_rounded)),
              const SizedBox(height: 14),
              TextField(controller: weekCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Duration / Week', hint: 'e.g. Week 1–2', icon: Icons.date_range_rounded)),
              const SizedBox(height: 14),
              TextField(controller: descCtrl, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Description', hint: 'Brief description of this module…', icon: Icons.notes_rounded)),
              const SizedBox(height: 14),
              // Type selector
              const Text('File Type', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: types.map((t) {
                final sel = t == selType;
                final c2 = t=='PDF'?AppColors.red:t=='DOCX'?AppColors.teal:t=='IPYNB'?AppColors.gold:t=='PPTX'?AppColors.orange:AppColors.grey;
                return GestureDetector(onTap: () => ss(() => selType = t), child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: sel ? c2 : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? c2 : AppColors.border)),
                    child: Text(t, style: TextStyle(color: sel ? Colors.black : AppColors.grey, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12, fontFamily: 'Poppins'))));
              }).toList()),
              const SizedBox(height: 20),
              // Upload zone
              Container(width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.teal.withOpacity(0.4))),
                  child: const Column(children: [Icon(Icons.cloud_upload_outlined, color: AppColors.teal, size: 32), SizedBox(height: 8), Text('Tap to upload file', style: TextStyle(color: AppColors.teal, fontSize: 13, fontFamily: 'Poppins'))])),
              const SizedBox(height: 24),
              Row(children: [
                if (editing) ...[
                  Expanded(child: OutlinedButton(onPressed: () { setState(() => _modules.remove(existing)); Navigator.pop(ctx); },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins')))),
                  const SizedBox(width: 12),
                ],
                Expanded(child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        setState(() {
                          final m = {'title':titleCtrl.text,'week':weekCtrl.text,'desc':descCtrl.text,'type':selType??'PDF','date':DateTime.now().day.toString(),'size':'—'};
                          if (editing) { final i = _modules.indexOf(existing); _modules[i] = m; } else { _modules.add(m); }
                        }); Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenLight, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(editing ? 'Update Module' : 'Save Module', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
              ]),
            ])))));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

class _InternRow extends StatelessWidget {
  final Map<String, dynamic> intern;
  const _InternRow({required this.intern});

  @override
  Widget build(BuildContext context) {
    final att = intern['attendance'] as double;
    final grade = intern['grade'] as double;
    final present = intern['present'] as bool;
    return Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Stack(children: [
            CircleAvatar(radius: 22, backgroundColor: AppColors.greenDeep,
                child: Text(intern['name'][0], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
            Positioned(right: 0, bottom: 0, child: Container(width: 11, height: 11,
                decoration: BoxDecoration(shape: BoxShape.circle, color: present ? AppColors.greenGlow : AppColors.red, border: Border.all(color: AppColors.card, width: 1.5)))),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(intern['name'], style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            Text(intern['dept'], style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bar_chart_rounded, color: att >= 0.8 ? AppColors.greenLight : AppColors.orange, size: 13),
              const SizedBox(width: 3),
              Text('${(att*100).toInt()}%', style: TextStyle(color: att >= 0.8 ? AppColors.greenLight : AppColors.orange, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            ]),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.greenDeep.withOpacity(0.4), borderRadius: BorderRadius.circular(6)),
                child: Text('$grade/20', style: const TextStyle(color: AppColors.greenLight, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
          ]),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.greyDark, size: 13),
        ]));
  }
}

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;
  final VoidCallback? onTap;
  const _ModuleCard({required this.module, required this.onTap});

  Color get _typeColor => module['type'] == 'PDF' ? AppColors.red : module['type'] == 'DOCX' ? AppColors.teal : module['type'] == 'IPYNB' ? AppColors.gold : AppColors.orange;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: _typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(module['type'], style: TextStyle(color: _typeColor, fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Poppins')))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(module['title'], style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const SizedBox(height: 3),
              Text(module['week'] ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
              if ((module['desc'] ?? '').isNotEmpty) Text(module['desc'], style: const TextStyle(color: AppColors.greyDark, fontSize: 10, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.download_rounded, color: AppColors.grey, size: 20),
              if ((module['size'] ?? '').isNotEmpty && module['size'] != '—') ...[const SizedBox(height: 2), Text(module['size'], style: const TextStyle(color: AppColors.greyDark, fontSize: 9, fontFamily: 'Poppins'))],
            ]),
          ])));
}