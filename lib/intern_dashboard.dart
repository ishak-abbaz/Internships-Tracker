import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Intern Data Store
// ─────────────────────────────────────────────────────────────────────────────
class InternData {
  static const String name       = 'Lina Bouzid';
  static const String nameUpper  = 'LINA BOUZID';
  static const String role       = 'AI Research Intern';
  static const String dept       = 'Computer Science / AI';
  static const String mentor     = 'Dr. Amine Rahmani';
  static const String regId      = 'PR-2024-001';
  static const String nr         = '20203501';
  static const String group      = 'G-01';
  static const String year       = 'Master 1';
  static const String bloodType  = 'O+';
  static const String expiry     = '06/2026';
  static const String phone      = '+213 555 12 34 56';
  static const String email      = 'lina.bouzid@university.edu';
  static const double lastGrade  = 17.5;
  static const String avatarUrl  = 'https://i.pravatar.cc/300?img=47';
  static const String nextShift  = '08:30 AM';
  static const String nextRoom   = 'Lab 04 · Block B';

  // Weekly schedule
  static const List<Map<String, String>> weekSessions = [
    {'time':'08:30–10:30','title':'Machine Learning Lab',  'room':'Lab 04 · Block B','teacher':'Dr. Rahmani','type':'Lab',      'color':'green'},
    {'time':'11:00–12:30','title':'Ethics in AI',          'room':'Amphi A',          'teacher':'Prof. Belhadj','type':'Lecture','color':'blue'},
    {'time':'14:00–16:00','title':'Project Research',      'room':'Library Hub',      'teacher':'Self Study',  'type':'Study',  'color':'gold'},
  ];

  // Full week timetable [Sun, Mon, Tue, Wed, Thu]
  static const List<Map<String, dynamic>> timetable = [
    {'time':'08:00–10:00','sun':'ML Lab',   'mon':'AI Ethics','tue':'Math',     'wed':'DevOps', 'thu':'NLP'},
    {'time':'10:00–12:00','sun':'ML Lab',   'mon':'AI Ethics','tue':'Math',     'wed':'DevOps', 'thu':'NLP'},
    {'time':'13:00–15:00','sun':'Project',  'mon':'---',      'tue':'Seminar',  'wed':'---',    'thu':'Research'},
    {'time':'15:00–17:00','sun':'Project',  'mon':'---',      'tue':'Soft Skills','wed':'---',  'thu':'Research'},
  ];

  // Training modules
  static final List<Map<String, dynamic>> modules = [
    {'title':'Introduction to AI Ethics',   'duration':'45 min',  'progress':1.0, 'icon':Icons.psychology_rounded,   'type':'PDF',  'file':'AI_Ethics_Manual.pdf',     'size':'2.4 MB','desc':'Core principles of AI ethics, bias, and responsible deployment.','lessons':5,'completed':5},
    {'title':'Git & GitHub Workflow',       'duration':'1h 20min','progress':0.6, 'icon':Icons.code_rounded,          'type':'PDF',  'file':'Git_Guide.pdf',            'size':'1.1 MB','desc':'Version control, branching strategies, and collaborative workflows.','lessons':8,'completed':5},
    {'title':'Flutter State Management',   'duration':'2h 15min','progress':0.1, 'icon':Icons.flutter_dash,          'type':'DOCX', 'file':'Flutter_StateGuide.docx',  'size':'3.2 MB','desc':'Provider, Riverpod, and BLoC patterns for production Flutter apps.','lessons':12,'completed':1},
    {'title':'Data Security Basics',       'duration':'30 min',  'progress':0.0, 'icon':Icons.security_rounded,      'type':'PDF',  'file':'DataSecurity.pdf',         'size':'890 KB','desc':'Encryption, secure storage, and OWASP top 10 for interns.','lessons':4,'completed':0},
    {'title':'Professional Communication', 'duration':'1h',      'progress':0.8, 'icon':Icons.record_voice_over_rounded,'type':'PPTX','file':'CommSkills.pptx',         'size':'5.1 MB','desc':'Writing reports, presenting findings, and email etiquette.','lessons':6,'completed':5},
  ];

  // Evaluations / rubric scores (read-only for intern)
  static const List<Map<String, dynamic>> evaluations = [
    {'criterion':'Technical Skills',  'score':4.5,'max':5, 'comment':'Excellent code quality and architecture.', 'color':'teal'},
    {'criterion':'Punctuality',       'score':5.0,'max':5, 'comment':'Always on time, zero absences.',           'color':'green'},
    {'criterion':'Teamwork',          'score':3.5,'max':5, 'comment':'Needs more proactive communication.',       'color':'orange'},
    {'criterion':'Documentation',     'score':4.0,'max':5, 'comment':'Clear and concise logs maintained.',        'color':'gold'},
    {'criterion':'Initiative',        'score':4.0,'max':5, 'comment':'Takes on additional tasks voluntarily.',    'color':'teal'},
  ];

  // Attendance history
  static const List<Map<String, String>> attendance = [
    {'week':'Week 7','date':'Jan 14–18','status':'P','note':''},
    {'week':'Week 6','date':'Jan 7–11', 'status':'P','note':''},
    {'week':'Week 5','date':'Dec 31–Jan 4','status':'L','note':'Transport delay'},
    {'week':'Week 4','date':'Dec 24–28','status':'P','note':''},
    {'week':'Week 3','date':'Dec 17–21','status':'A','note':'Medical certificate'},
    {'week':'Week 2','date':'Dec 10–14','status':'P','note':''},
    {'week':'Week 1','date':'Dec 3–7',  'status':'P','note':''},
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main Controller — Bottom Nav
// ─────────────────────────────────────────────────────────────────────────────
class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});
  @override State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> {
  int _idx = 0;

  List<Widget> get _pages => [
    InternHomeContent(onGoTo: (i) => setState(() => _idx = i)),
    const SchedulePage(),
    const ProfessionalIDPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _pages[_idx],
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _navItem(Icons.home_rounded,           'Home',     0),
      _navItem(Icons.calendar_month_rounded, 'Schedule', 1),
      _navItem(Icons.badge_rounded,          'ID Card',  2),
      _navItem(Icons.person_rounded,         'Profile',  3),
    ]),
  );

  Widget _navItem(IconData icon, String label, int index) {
    final sel = _idx == index;
    return GestureDetector(
      onTap: () => setState(() => _idx = index),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: sel ? 18 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.greenLight.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: sel ? AppColors.greenLight : AppColors.grey, size: 24),
          if (sel) ...[const SizedBox(width: 6), Text(label, style: const TextStyle(color: AppColors.greenLight, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))],
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  HOME CONTENT
// ═════════════════════════════════════════════════════════════════════════════
class InternHomeContent extends StatelessWidget {
  final void Function(int) onGoTo;
  const InternHomeContent({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: () => onGoTo(3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back,', style: TextStyle(color: AppColors.grey, fontSize: 13, fontFamily: 'Poppins')),
            Text('${InternData.name} 👋', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ])),
          GestureDetector(onTap: () => onGoTo(3),
              child: Stack(children: [
                CircleAvatar(radius: 26, backgroundImage: const NetworkImage(InternData.avatarUrl)),
                Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: AppColors.greenGlow, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 2)))),
              ])),
        ]),
        const SizedBox(height: 28),

        // ── Summary cards grid ─────────────────────────────────────────────
        const Text('Internship Overview', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 14),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.55,
            children: [
              _infoCard('Department', InternData.dept, Icons.business_rounded, AppColors.greenLight),
              _infoCard('My Mentor',  InternData.mentor.split(' ').take(2).join(' '), Icons.school_rounded, AppColors.gold),
              _infoCard('Next Shift', InternData.nextShift, Icons.timer_rounded, AppColors.teal),
              GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluationViewScreen())),
                  child: _infoCard('Last Mark', '${InternData.lastGrade} / 20', Icons.grade_rounded, AppColors.orange, tap: true)),
            ]),
        const SizedBox(height: 24),

        // ── Attendance quick view ──────────────────────────────────────────
        _sectionHeader('Attendance', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()))),
        const SizedBox(height: 12),
        _buildAttendanceStrip(),
        const SizedBox(height: 24),

        // ── Next session banner ────────────────────────────────────────────
        _sectionHeader('Today\'s Session', onTap: () => onGoTo(1)),
        const SizedBox(height: 12),
        _buildNextSessionBanner(context),
        const SizedBox(height: 24),

        // ── Training shortcut ──────────────────────────────────────────────
        _sectionHeader('Training', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingModulesPage()))),
        const SizedBox(height: 12),
        _buildTrainingProgress(context),
        const SizedBox(height: 24),

        // ── Reminder banner ────────────────────────────────────────────────
        Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.greenLight.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.greenLight.withOpacity(0.25))),
            child: Row(children: [
              const Icon(Icons.notifications_active_rounded, color: AppColors.greenLight, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Reminder: Submit your weekly logbook by Friday 4:00 PM.', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins'))),
            ])),
      ]),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color, {bool tap = false}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: tap ? color.withOpacity(0.35) : AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Icon(icon, color: color, size: 18), if (tap) ...[const Spacer(), const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.greyDark, size: 11)]]),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins')),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _sectionHeader(String title, {VoidCallback? onTap}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
    if (onTap != null) GestureDetector(onTap: onTap, child: const Text('View all', style: TextStyle(color: AppColors.greenLight, fontSize: 12, fontFamily: 'Poppins'))),
  ]);

  Widget _buildAttendanceStrip() {
    final records = InternData.attendance.take(7).toList();
    final present = records.where((r) => r['status'] == 'P').length;
    final pct = (present / records.length * 100).toInt();
    return Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$pct% Attendance Rate', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              Text('Last ${records.length} weeks tracked', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
            ])),
            Text('$present/${records.length}', style: TextStyle(color: pct >= 80 ? AppColors.greenLight : AppColors.orange, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
              value: present / records.length, backgroundColor: AppColors.surface,
              color: pct >= 80 ? AppColors.greenLight : AppColors.orange, minHeight: 8)),
          const SizedBox(height: 12),
          Row(children: records.map((r) {
            final c = r['status'] == 'P' ? AppColors.greenLight : r['status'] == 'L' ? AppColors.orange : AppColors.red;
            return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(height: 28, decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.4))),
                    child: Center(child: Text(r['status']!, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))))));
          }).toList()),
        ]));
  }

  Widget _buildNextSessionBanner(BuildContext context) => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterTimetablePage())),
      child: Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.greenDeep.withOpacity(0.6), AppColors.bg], end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.greenLight.withOpacity(0.25))),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.greenLight.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.science_rounded, color: AppColors.greenLight)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Machine Learning Lab', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const Text('08:30 – 10:30 · Lab 04 · Dr. Rahmani', style: TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.greenLight.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('NOW', style: TextStyle(color: AppColors.greenLight, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
          ])));

  Widget _buildTrainingProgress(BuildContext context) {
    final done = InternData.modules.where((m) => (m['progress'] as double) == 1.0).length;
    final total = InternData.modules.length;
    final overall = InternData.modules.map((m) => m['progress'] as double).reduce((a, b) => a + b) / total;
    return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingModulesPage())),
        child: Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.school_rounded, color: AppColors.gold, size: 20), const SizedBox(width: 10),
                Expanded(child: Text('$done of $total modules completed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.greyDark, size: 13),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                  value: overall, backgroundColor: AppColors.surface, color: AppColors.gold, minHeight: 8)),
              const SizedBox(height: 8),
              Row(children: InternData.modules.map((m) {
                final prog = m['progress'] as double;
                final c = prog == 1.0 ? AppColors.greenLight : prog > 0 ? AppColors.gold : AppColors.greyDark;
                return Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))));
              }).toList()),
            ])));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PROFESSIONAL ID PAGE  — Upgraded card design
// ═════════════════════════════════════════════════════════════════════════════
class ProfessionalIDPage extends StatefulWidget {
  const ProfessionalIDPage({super.key});
  @override State<ProfessionalIDPage> createState() => _ProfessionalIDPageState();
}

class _ProfessionalIDPageState extends State<ProfessionalIDPage> with SingleTickerProviderStateMixin {
  bool _flipped = false;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _flip() {
    if (_flipped) { _ctrl.reverse(); } else { _ctrl.forward(); }
    setState(() => _flipped = !_flipped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('OFFICIAL ID', style: TextStyle(letterSpacing: 2, fontSize: 12, color: AppColors.grey, fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent, centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined, color: AppColors.greenLight), onPressed: () => _showPhotoUploadSheet(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(children: [
          // Flip hint
          Text('Tap card to flip', style: TextStyle(color: AppColors.grey.withOpacity(0.6), fontSize: 12, fontFamily: 'Poppins')),
          const SizedBox(height: 16),

          // Flippable card
          GestureDetector(
            onTap: _flip,
            child: AnimatedBuilder(animation: _anim, builder: (_, child) {
              final angle = _anim.value * math.pi;
              final isBack = angle > math.pi / 2;
              return Transform(alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                child: isBack
                    ? Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(math.pi), child: _buildCardBack())
                    : _buildCardFront(),
              );
            }),
          ),
          const SizedBox(height: 28),

          // Action buttons
          Row(children: [
            Expanded(child: _actionBtn('Download', Icons.file_download_outlined, AppColors.greenLight, () => _snack(context, 'ID Card downloaded to storage'))),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn('Share', Icons.share_outlined, AppColors.teal, () => _snack(context, 'Sharing ID Card…'))),
          ]),
          const SizedBox(height: 120),
        ]),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFF0C2B1A), Color(0xFF0A1F12)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: AppColors.greenLight.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.greenLight.withOpacity(0.12), blurRadius: 30, spreadRadius: 2)],
      ),
      child: Column(children: [
        // Header stripe
        Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: AppColors.greenDeep.withOpacity(0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
            child: Row(children: [
              const Icon(Icons.hub_rounded, color: AppColors.greenLight, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Pro-Link · Constantine 2 University', style: TextStyle(color: AppColors.greenLight, fontSize: 11, letterSpacing: 0.8, fontFamily: 'Poppins'))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.greenLight.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('INTERN', style: TextStyle(color: AppColors.greenLight, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))),
            ])),

        const SizedBox(height: 24),

        // Avatar with upload ring
        Stack(alignment: Alignment.bottomRight, children: [
          Container(padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenLight], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: const CircleAvatar(radius: 52, backgroundImage: NetworkImage(InternData.avatarUrl))),
          Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 2.5)),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16)),
        ]),
        const SizedBox(height: 16),

        const Text(InternData.nameUpper, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        const Text(InternData.role, style: TextStyle(color: AppColors.greenLight, fontSize: 13, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        Text(InternData.dept, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        const SizedBox(height: 24),

        // ID number
        Container(margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: AppColors.bg.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.tag_rounded, color: AppColors.grey, size: 14),
              const SizedBox(width: 6),
              Text(InternData.regId, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13, letterSpacing: 1.2)),
            ])),
        const SizedBox(height: 20),

        // QR code
        Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.qr_code_2_rounded, size: 110, color: Color(0xFF0A1F12))),
        const SizedBox(height: 8),
        const Text('Scan to verify identity', style: TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins')),
        const SizedBox(height: 20),

        // Footer bar
        Container(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(color: AppColors.greenDeep.withOpacity(0.4), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _idField('BLOOD', InternData.bloodType),
              _vDiv(),
              _idField('GROUP', InternData.group),
              _vDiv(),
              _idField('YEAR', InternData.year),
              _vDiv(),
              _idField('EXPIRES', InternData.expiry),
            ])),
      ]),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFF0A1F12), Color(0xFF0C2B1A)], begin: Alignment.topRight, end: Alignment.bottomLeft),
        border: Border.all(color: AppColors.greenLight.withOpacity(0.3), width: 1.5),
      ),
      child: Column(children: [
        const SizedBox(height: 28),
        const Text('INTERN DETAILS', style: TextStyle(color: AppColors.grey, fontSize: 11, letterSpacing: 2, fontFamily: 'Poppins')),
        const SizedBox(height: 20),
        _backRow(Icons.numbers_rounded,         'Registration NR',  InternData.nr),
        _backRow(Icons.alternate_email_rounded,  'University Email', InternData.email),
        _backRow(Icons.phone_outlined,           'Phone',           InternData.phone),
        _backRow(Icons.school_rounded,           'Mentor',          InternData.mentor),
        _backRow(Icons.business_rounded,         'Department',      InternData.dept),
        _backRow(Icons.calendar_today_rounded,   'Expiry',          InternData.expiry),
        const SizedBox(height: 20),
        // Magnetic stripe decoration
        Container(height: 46, margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A))),
        const SizedBox(height: 16),
        Container(margin: const EdgeInsets.symmetric(horizontal: 20), height: 30,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            child: Center(child: Text(InternData.regId, style: const TextStyle(color: Colors.black87, fontSize: 13, letterSpacing: 4, fontFamily: 'Courier')))),
        const SizedBox(height: 20),
        const Text('This card is property of Constantine 2 University.', style: TextStyle(color: AppColors.greyDark, fontSize: 9, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _idField(String label, String value) => Column(children: [
    Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 8, letterSpacing: 0.8, fontFamily: 'Poppins')),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Poppins')),
  ]);

  Widget _vDiv() => Container(width: 1, height: 28, color: AppColors.border);

  Widget _backRow(IconData ic, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(children: [
        Icon(ic, color: AppColors.greenLight, size: 16), const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Poppins'), overflow: TextOverflow.ellipsis)),
      ]));

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.35))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 18), const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ])));

  void _showPhotoUploadSheet(BuildContext context) => showModalBottomSheet(
      context: context, backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Update ID Photo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        const Text('Choose a clear, well-lit photo of your face', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _photoOption(context, Icons.camera_alt_rounded, 'Camera',  AppColors.greenLight)),
          const SizedBox(width: 12),
          Expanded(child: _photoOption(context, Icons.photo_library_rounded, 'Gallery', AppColors.teal)),
        ]),
        const SizedBox(height: 16),
      ])));

  Widget _photoOption(BuildContext context, IconData icon, String label, Color color) => GestureDetector(
      onTap: () { Navigator.pop(context); _snack(context, '$label opened…'); },
      child: Container(padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.35))),
          child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins'))])));

  void _snack(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.green));
}

// ═════════════════════════════════════════════════════════════════════════════
//  PROFILE PAGE
// ═════════════════════════════════════════════════════════════════════════════
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editing = false;
  final _phoneCtrl = TextEditingController(text: InternData.phone);
  final _emailCtrl = TextEditingController(text: InternData.email);

  @override void dispose() { _phoneCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('MY PROFILE', style: TextStyle(fontFamily: 'Poppins', letterSpacing: 1)), backgroundColor: Colors.transparent,
          actions: [IconButton(
              icon: Icon(_editing ? Icons.check_circle_rounded : Icons.edit_rounded, color: _editing ? AppColors.greenLight : Colors.white),
              onPressed: () { if (_editing) _saveProfile(context); setState(() => _editing = !_editing); })]),
      body: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 120), child: Column(children: [

        // Avatar
        Stack(alignment: Alignment.bottomRight, children: [
          Container(padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenLight])),
              child: const CircleAvatar(radius: 55, backgroundImage: NetworkImage(InternData.avatarUrl))),
          GestureDetector(
              onTap: () => _showPhotoSheet(context),
              child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 3)),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 16))),
        ]),
        const SizedBox(height: 14),
        const Text(InternData.name, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        Text(InternData.role, style: const TextStyle(color: AppColors.greenLight, fontSize: 13, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        roleBadge('Intern'),
        const SizedBox(height: 28),

        // Read-only fields
        _sec('Academic Info'),
        _field('Registration ID', InternData.regId, Icons.badge_rounded, false, null),
        _field('Department', InternData.dept, Icons.business_rounded, false, null),
        _field('Mentor', InternData.mentor, Icons.school_rounded, false, null),
        _field('Year', InternData.year, Icons.school_outlined, false, null),
        _field('Group', InternData.group, Icons.groups_rounded, false, null),
        const SizedBox(height: 8),

        // Editable fields
        _sec('Contact Info'),
        _field('Phone', _phoneCtrl.text, Icons.phone_rounded, _editing, _phoneCtrl),
        _field('Email', _emailCtrl.text, Icons.alternate_email_rounded, _editing, _emailCtrl),
        const SizedBox(height: 28),

        // Quick links
        _sec('Quick Links'),
        _quickLink(context, Icons.history_edu_rounded,  'Attendance History', AppColors.teal,       const AttendanceHistoryScreen()),
        _quickLink(context, Icons.star_half_rounded,    'My Evaluations',     AppColors.gold,       const EvaluationViewScreen()),
        _quickLink(context, Icons.school_rounded,       'Training Modules',   AppColors.greenLight, const TrainingModulesPage()),
        const SizedBox(height: 24),

        // Logout
        ElevatedButton.icon(
            onPressed: () => _logoutDialog(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('LOGOUT FROM PORTAL', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red.withOpacity(0.1), foregroundColor: AppColors.red,
                minimumSize: const Size(double.infinity, 55), side: const BorderSide(color: AppColors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
      ])),
    );
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Align(alignment: Alignment.centerLeft, child: Text(t.toUpperCase(), style: const TextStyle(color: AppColors.greenLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.4, fontFamily: 'Poppins'))));

  Widget _field(String label, String value, IconData icon, bool editing, TextEditingController? ctrl) {
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: editing ? AppColors.card : AppColors.surface, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: editing ? AppColors.greenLight : AppColors.border)),
        child: Row(children: [
          Icon(icon, color: editing ? AppColors.greenLight : AppColors.grey, size: 18), const SizedBox(width: 14),
          Expanded(child: editing && ctrl != null
              ? TextField(controller: ctrl, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins'), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins')),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
          ])),
          if (!editing) const Icon(Icons.lock_outline_rounded, color: AppColors.greyDark, size: 14),
        ]));
  }

  Widget _quickLink(BuildContext context, IconData icon, String label, Color color, Widget page) => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18)), const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'Poppins'))),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.greyDark, size: 14),
          ])));

  void _saveProfile(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!'), backgroundColor: AppColors.green));

  void _showPhotoSheet(BuildContext context) => showModalBottomSheet(context: context, backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Update Profile Photo', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _photoBtn(context, Icons.camera_alt_rounded, 'Camera',  AppColors.greenLight)),
          const SizedBox(width: 12),
          Expanded(child: _photoBtn(context, Icons.photo_library_rounded, 'Gallery', AppColors.teal)),
        ]),
        const SizedBox(height: 12),
      ])));

  Widget _photoBtn(BuildContext ctx, IconData ic, String l, Color c) => GestureDetector(onTap: () => Navigator.pop(ctx),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.3))),
          child: Column(children: [Icon(ic, color: c, size: 26), const SizedBox(height: 6), Text(l, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontFamily: 'Poppins'))])));

  void _logoutDialog(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Logout', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      content: const Text('Are you sure you want to exit the portal?', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.grey))),
        TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
            child: const Text('LOGOUT', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold))),
      ]));
}

// ═════════════════════════════════════════════════════════════════════════════
//  SCHEDULE PAGE
// ═════════════════════════════════════════════════════════════════════════════
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _activeDay = DateTime.now().weekday % 7; // 0=Sun
  static const _days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  static const _typeColors = {'Lab': AppColors.greenLight, 'Lecture': AppColors.teal, 'Study': AppColors.gold, 'default': AppColors.grey};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('MY SCHEDULE', style: TextStyle(letterSpacing: 1.5, fontSize: 14, fontFamily: 'Poppins')), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: Column(children: [
        // Date strip
        Container(height: 92, padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7, itemBuilder: (_, i) => _dateItem(i))),

        // Content
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
          Text('Today · ${_days[_activeDay]}', style: const TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 14),
          ...InternData.weekSessions.asMap().entries.map((e) => _scheduleCard(e.value, e.key == 0)),
          const SizedBox(height: 20),

          // Full timetable link
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterTimetablePage())),
              child: Container(padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.gold.withOpacity(0.4))),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.calendar_view_week_rounded, color: AppColors.gold, size: 22)),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Full Semester Timetable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      Text('View your weekly 2024–2025 schedule', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
                    ])),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey, size: 14),
                  ]))),
          const SizedBox(height: 120),
        ])),
      ]),
    );
  }

  Widget _dateItem(int i) {
    final sel = i == _activeDay;
    final date = DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7)).add(Duration(days: i));
    return GestureDetector(onTap: () => setState(() => _activeDay = i),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 60, margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: sel ? AppColors.greenLight : AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.greenLight : AppColors.border)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_days[i], style: TextStyle(color: sel ? Colors.black : AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Text('${date.day}', style: TextStyle(color: sel ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              if (i < 3) Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: sel ? Colors.black45 : AppColors.greenLight, shape: BoxShape.circle)),
            ])));
  }

  Widget _scheduleCard(Map<String, String> s, bool isNow) {
    final color = _typeColors[s['type']] ?? _typeColors['default']!;
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isNow ? color : AppColors.border, width: isNow ? 1.5 : 1)),
        child: Row(children: [
          Container(width: 4, height: 60, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(s['time']!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              if (isNow) ...[const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [PulsingDot(color: color, size: 6), const SizedBox(width: 4), Text('NOW', style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))]))],
            ]),
            const SizedBox(height: 5),
            Text(s['title']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: AppColors.grey, size: 13), const SizedBox(width: 3),
              Text(s['room']!, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
              const SizedBox(width: 12),
              const Icon(Icons.person_outline_rounded, color: AppColors.grey, size: 13), const SizedBox(width: 3),
              Text(s['teacher']!, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
            ]),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(s['type']!, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
        ]));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SEMESTER TIMETABLE PAGE
// ═════════════════════════════════════════════════════════════════════════════
class SemesterTimetablePage extends StatelessWidget {
  const SemesterTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('SEMESTER TIMETABLE', style: TextStyle(fontSize: 13, letterSpacing: 1, fontFamily: 'Poppins')), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(scrollDirection: Axis.vertical, child: SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Padding(padding: const EdgeInsets.all(16),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.surface),
                dataRowColor: WidgetStateProperty.all(AppColors.card),
                border: TableBorder.all(color: AppColors.border, borderRadius: BorderRadius.circular(8)),
                columns: const [
                  DataColumn(label: Text('TIME', style: TextStyle(color: AppColors.gold, fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('SUN',  style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('MON',  style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('TUE',  style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('WED',  style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('THU',  style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
                ],
                rows: InternData.timetable.map((row) => DataRow(cells: [
                  DataCell(Text(row['time'], style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 11))),
                  ...[row['sun'],row['mon'],row['tue'],row['wed'],row['thu']].map((v) => DataCell(Text(v, style: TextStyle(color: v=='---'?AppColors.greyDark:Colors.white, fontFamily: 'Poppins', fontSize: 12)))),
                ])).toList(),
              )))),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TRAINING MODULES PAGE
// ═════════════════════════════════════════════════════════════════════════════
class TrainingModulesPage extends StatelessWidget {
  const TrainingModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final done  = InternData.modules.where((m) => (m['progress'] as double) == 1.0).length;
    final total = InternData.modules.length;
    final overall = InternData.modules.map((m) => m['progress'] as double).reduce((a, b) => a + b) / total;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('TRAINING MODULES', style: TextStyle(fontFamily: 'Poppins', letterSpacing: 1)), backgroundColor: Colors.transparent),
      body: Column(children: [
        // Progress header
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.school_rounded, color: AppColors.gold, size: 20), const SizedBox(width: 10),
                Expanded(child: Text('$done of $total Completed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                Text('${(overall * 100).toInt()}%', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: overall, backgroundColor: AppColors.surface, color: AppColors.gold, minHeight: 8)),
            ])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: InternData.modules.length,
            itemBuilder: (_, i) {
              final m = InternData.modules[i];
              final prog = m['progress'] as double;
              final c = prog == 1.0 ? AppColors.greenLight : prog > 0 ? AppColors.gold : AppColors.greyDark;
              return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ModuleDetailPage(module: m))),
                  child: Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Container(width: 50, height: 50, decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                            child: prog == 1.0
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.greenLight, size: 26)
                                : Icon(m['icon'] as IconData, color: c, size: 24)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                          const SizedBox(height: 3),
                          Row(children: [
                            Text(m['duration'], style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
                            const SizedBox(width: 10),
                            Text('${m['completed']}/${m['lessons']} lessons', style: TextStyle(color: c, fontSize: 11, fontFamily: 'Poppins')),
                          ]),
                          const SizedBox(height: 10),
                          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: prog, backgroundColor: AppColors.surface, color: c, minHeight: 5)),
                        ])),
                        const SizedBox(width: 8),
                        Column(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                              child: Text(m['type'], style: const TextStyle(color: AppColors.grey, fontSize: 9, fontFamily: 'Poppins'))),
                          const SizedBox(height: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.greyDark, size: 13),
                        ]),
                      ])));
            })),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  MODULE DETAIL PAGE
// ═════════════════════════════════════════════════════════════════════════════
class ModuleDetailPage extends StatelessWidget {
  final Map<String, dynamic> module;
  const ModuleDetailPage({super.key, required this.module});

  Color get _color {
    final prog = module['progress'] as double;
    if (prog == 1.0) return AppColors.greenLight;
    if (prog > 0)    return AppColors.gold;
    return AppColors.greyDark;
  }

  // ── Extracted helper so the ternary never sits inside children:[] ───────────
  Widget _completeButton(BuildContext context) {
    final bool done = (module['progress'] as double) >= 1.0;
    if (done) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.greenLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.greenLight.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, color: AppColors.greenLight),
            SizedBox(width: 8),
            Text('Module Completed!',
                style: TextStyle(color: AppColors.greenLight,
                    fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ],
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${module['title']} marked complete!'),
            backgroundColor: AppColors.green));
        Navigator.pop(context);
      },
      icon: const Icon(Icons.check_rounded, size: 18),
      label: const Text('MARK AS COMPLETE',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _fileTile(BuildContext context, String fileName, String size, String type) {
    final Color c = type == 'PDF'
        ? Colors.redAccent
        : type == 'DOCX'
        ? Colors.blueAccent
        : type == 'PPTX'
        ? AppColors.orange
        : AppColors.teal;
    final IconData ic = type == 'PDF'
        ? Icons.picture_as_pdf_rounded
        : type == 'DOCX'
        ? Icons.description_rounded
        : type == 'PPTX'
        ? Icons.slideshow_rounded
        : Icons.code_rounded;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(ic, color: c, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fileName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: 13)),
            Text(size,
                style: const TextStyle(
                    color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.visibility_outlined, color: AppColors.grey, size: 20),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening $fileName…'),
                  backgroundColor: AppColors.surface)),
        ),
        IconButton(
          icon: const Icon(Icons.file_download_outlined,
              color: AppColors.greenLight, size: 20),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading $fileName…'),
                  backgroundColor: AppColors.green)),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.greenDeep.withOpacity(0.8), AppColors.bg],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(module['icon'] as IconData, color: _color, size: 52),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(module['type'],
                            style: TextStyle(
                                color: _color,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(module['title'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 8),

                  // Meta row
                  Row(children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(module['duration'],
                        style: const TextStyle(
                            color: AppColors.grey, fontFamily: 'Poppins')),
                    const SizedBox(width: 16),
                    Icon(Icons.menu_book_rounded, color: _color, size: 14),
                    const SizedBox(width: 4),
                    Text('${module['completed']}/${module['lessons']} lessons',
                        style: TextStyle(color: _color, fontFamily: 'Poppins')),
                  ]),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: module['progress'] as double,
                      backgroundColor: AppColors.surface,
                      color: _color,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Overview
                  const Text('Overview',
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Text(module['desc'],
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 24),

                  // Complete button — extracted to avoid ternary-in-children error
                  _completeButton(context),
                  const SizedBox(height: 24),

                  // Downloads
                  const Text('RESOURCES & DOWNLOADS',
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 14),
                  _fileTile(
                    context,
                    module['file'] as String,
                    module['size'] as String,
                    module['type'] as String,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  EVALUATION VIEW SCREEN  (read-only for intern)
// ═════════════════════════════════════════════════════════════════════════════
class EvaluationViewScreen extends StatelessWidget {
  const EvaluationViewScreen({super.key});

  static const _colorMap = {'teal': AppColors.teal, 'green': AppColors.greenLight, 'orange': AppColors.orange, 'gold': AppColors.gold};

  double get _total => InternData.evaluations.fold(0, (s, e) => s + (e['score'] as double));
  double get _max   => InternData.evaluations.fold(0, (s, e) => s + (e['max'] as double));
  double get _grade => _max == 0 ? 0 : (_total / _max) * 20;

  Color get _gradeColor => _grade >= 16 ? AppColors.greenLight : _grade >= 12 ? AppColors.teal : _grade >= 8 ? AppColors.orange : AppColors.red;
  String get _gradeLabel => _grade >= 16 ? 'Excellent' : _grade >= 12 ? 'Good' : _grade >= 8 ? 'Satisfactory' : 'Needs Improvement';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('PERFORMANCE REVIEW', style: TextStyle(fontSize: 13, letterSpacing: 1.2, fontFamily: 'Poppins')), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Score header
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: _gradeColor.withOpacity(0.35))),
            child: Column(children: [
              Text(_gradeLabel, style: TextStyle(color: _gradeColor, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(_grade.toStringAsFixed(1), style: TextStyle(color: _gradeColor, fontSize: 52, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                Text('/20', style: TextStyle(color: _gradeColor.withOpacity(0.6), fontSize: 20, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _max == 0 ? 0 : _total / _max, backgroundColor: AppColors.surface, color: _gradeColor, minHeight: 10)),
              const SizedBox(height: 8),
              Text('Top 5% of Internship Group', style: TextStyle(color: AppColors.grey.withOpacity(0.8), fontSize: 12, fontFamily: 'Poppins')),
            ])),
        const SizedBox(height: 28),

        const Text('GRADING RUBRIC', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Poppins')),
        const SizedBox(height: 14),

        ...InternData.evaluations.map((e) {
          final color = _colorMap[e['color']] ?? AppColors.teal;
          final score = e['score'] as double;
          final max   = e['max'] as int;
          return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.25))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(e['criterion'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  Text('$score/$max', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                ]),
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: score / max, minHeight: 7, backgroundColor: AppColors.surface, color: color)),
                const SizedBox(height: 10),
                Text(e['comment'], style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic, fontFamily: 'Poppins')),
              ]));
        }),

        const SizedBox(height: 20),
        const Text("MENTOR'S FEEDBACK", style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Poppins')),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border),
                gradient: LinearGradient(colors: [AppColors.greenDeep.withOpacity(0.2), AppColors.card], begin: Alignment.topLeft)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68')),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(InternData.mentor, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 13)),
                  const Text('Supervisor', style: TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
                ]),
              ]),
              const SizedBox(height: 14),
              const Text('"Lina has shown exceptional growth in her understanding of Flutter architecture. Her ability to solve complex UI bugs independently is impressive. Keep pushing the boundaries!"',
                  style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 13, fontStyle: FontStyle.italic, fontFamily: 'Poppins')),
            ])),
        const SizedBox(height: 100),
      ])),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  ATTENDANCE HISTORY SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  int get _present => InternData.attendance.where((r) => r['status'] == 'P').length;
  int get _absent  => InternData.attendance.where((r) => r['status'] == 'A').length;
  int get _late    => InternData.attendance.where((r) => r['status'] == 'L').length;

  Color _statusColor(String s) => s == 'P' ? AppColors.greenLight : s == 'L' ? AppColors.orange : AppColors.red;
  String _statusLabel(String s) => s == 'P' ? 'Present' : s == 'L' ? 'Late' : 'Absent';
  IconData _statusIcon(String s) => s == 'P' ? Icons.check_circle_rounded : s == 'L' ? Icons.schedule_rounded : Icons.cancel_rounded;

  @override
  Widget build(BuildContext context) {
    final pct = (_present / InternData.attendance.length * 100).toInt();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('ATTENDANCE HISTORY', style: TextStyle(fontSize: 13, letterSpacing: 1, fontFamily: 'Poppins')), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [

        // Summary card
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(children: [
                Expanded(child: _summaryChip('$_present', 'Present', AppColors.greenLight)),
                Expanded(child: _summaryChip('$_late',    'Late',    AppColors.orange)),
                Expanded(child: _summaryChip('$_absent',  'Absent',  AppColors.red)),
                Expanded(child: _summaryChip('$pct%',     'Rate',    AppColors.teal)),
              ]),
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                  value: _present / InternData.attendance.length, backgroundColor: AppColors.surface,
                  color: pct >= 80 ? AppColors.greenLight : AppColors.orange, minHeight: 10)),
            ])),
        const SizedBox(height: 24),

        // History list
        ...InternData.attendance.map((r) {
          final c = _statusColor(r['status']!);
          return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: r['status'] != 'P' ? c.withOpacity(0.3) : AppColors.border)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_statusIcon(r['status']!), color: c, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['week']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  Text(r['date']!, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
                  if (r['note']!.isNotEmpty) ...[const SizedBox(height: 3), Text(r['note']!, style: TextStyle(color: c, fontSize: 11, fontStyle: FontStyle.italic, fontFamily: 'Poppins'))],
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.3))),
                    child: Text(_statusLabel(r['status']!), style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
              ]));
        }),
        const SizedBox(height: 40),
      ])),
    );
  }

  Widget _summaryChip(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
    Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 10, fontFamily: 'Poppins')),
  ]);
}