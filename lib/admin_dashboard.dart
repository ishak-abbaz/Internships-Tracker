import 'package:flutter/material.dart';
import 'theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Shared Data Store  (single source of truth)
// ─────────────────────────────────────────────────────────────────────────────
class AppData {
  static final List<Map<String, dynamic>> departments = [
    {'id':'d1','name':'Computer Science','icon':Icons.computer_rounded,'specialties':[
      {'id':'s1','name':'Artificial Intelligence','years':[
        {'label':'Licence 1','groups':['G01','G02']},
        {'label':'Licence 2','groups':['G01','G02']},
        {'label':'Licence 3','groups':['G01','G02','G03']},
        {'label':'Master 1','groups':['G01','G02']},
        {'label':'Master 2','groups':['G01']},
      ]},
      {'id':'s2','name':'Software Engineering','years':[
        {'label':'Licence 1','groups':['G01','G02']},
        {'label':'Licence 3','groups':['G01','G02']},
        {'label':'Master 1','groups':['G01']},
        {'label':'Master 2','groups':['G01']},
      ]},
    ]},
    {'id':'d2','name':'Cybersecurity','icon':Icons.security_rounded,'specialties':[
      {'id':'s3','name':'Network Security','years':[
        {'label':'Licence 3','groups':['G01','G02']},
        {'label':'Master 1','groups':['G01']},
        {'label':'Master 2','groups':['G01']},
      ]},
    ]},
    {'id':'d3','name':'Data Science','icon':Icons.analytics_rounded,'specialties':[
      {'id':'s4','name':'Machine Learning','years':[
        {'label':'Master 1','groups':['G01','G02']},
        {'label':'Master 2','groups':['G01']},
      ]},
    ]},
  ];

  // Key = "specId|yearLabel|group"  →  list of sessions
  static final Map<String, List<Map<String, String>>> schedules = {
    's1|Master 1|G01':[
      {'day':'Sunday',   'time':'08:00–10:00','subject':'Deep Learning',     'room':'Lab 05','teacher':'Dr. Rahmani'},
      {'day':'Sunday',   'time':'10:00–12:00','subject':'Computer Vision',   'room':'Room 12','teacher':'Prof. Zenati'},
      {'day':'Monday',   'time':'08:00–10:00','subject':'NLP Fundamentals',  'room':'Lab 03','teacher':'Dr. Rahmani'},
      {'day':'Tuesday',  'time':'14:00–16:00','subject':'Research Methods',  'room':'Room 08','teacher':'Prof. Zenati'},
      {'day':'Wednesday','time':'08:00–10:00','subject':'Reinforcement L.',  'room':'Lab 05','teacher':'Dr. Rahmani'},
    ],
    's1|Master 1|G02':[
      {'day':'Sunday', 'time':'10:00–12:00','subject':'Deep Learning',   'room':'Lab 06','teacher':'Dr. Rahmani'},
      {'day':'Monday', 'time':'10:00–12:00','subject':'NLP Fundamentals','room':'Lab 04','teacher':'M. Loukil'},
      {'day':'Tuesday','time':'08:00–10:00','subject':'Computer Vision', 'room':'Room 14','teacher':'Prof. Zenati'},
    ],
    's2|Licence 3|G01':[
      {'day':'Sunday',  'time':'08:00–10:00','subject':'Advanced CSS',   'room':'Lab 01','teacher':'Prof. Zenati'},
      {'day':'Monday',  'time':'10:00–12:00','subject':'React Framework','room':'Lab 02','teacher':'M. Loukil'},
      {'day':'Thursday','time':'14:00–16:00','subject':'Databases II',   'room':'Room 05','teacher':'Prof. Zenati'},
    ],
    's3|Master 1|G01':[
      {'day':'Sunday',   'time':'08:00–10:00','subject':'Cryptography',  'room':'Lab 09','teacher':'M. Loukil'},
      {'day':'Tuesday',  'time':'10:00–12:00','subject':'Ethical Hacking','room':'Lab 09','teacher':'M. Loukil'},
      {'day':'Wednesday','time':'14:00–16:00','subject':'Forensics',      'room':'Room 11','teacher':'Dr. Rahmani'},
    ],
  };

  static final List<Map<String, String>> interns = [
    {'name':'Lina Bouzid', 'dept':'AI', 'nr':'20203501','status':'Active', 'email':'lina.bouzid@university.edu','mentor':'Dr. Rahmani'},
    {'name':'Omar Khelil', 'dept':'Web','nr':'20203502','status':'Active', 'email':'omar.khelil@university.edu','mentor':'Prof. Zenati'},
    {'name':'Yassine Ben', 'dept':'Mob','nr':'20203503','status':'Pending','email':'yassine.ben@university.edu','mentor':''},
    {'name':'Ahmed Rayan', 'dept':'Cyb','nr':'20203504','status':'Active', 'email':'ahmed.rayan@university.edu','mentor':'M. Loukil'},
    {'name':'Sophia Lee',  'dept':'SE', 'nr':'20203505','status':'Active', 'email':'sophia.lee@university.edu','mentor':'Dr. Rahmani'},
  ];

  static final List<Map<String, dynamic>> mentors = [
    {'name':'Dr. Amine Rahmani','specialty':'Machine Learning','interns':5,'email':'rahmani.a@univ-constantine2.dz','dept':'CS','phone':'0661 00 11 22'},
    {'name':'Prof. Sarah Zenati','specialty':'Software Eng',  'interns':3,'email':'s.zenati@univ-constantine2.dz','dept':'SE','phone':'0661 00 33 44'},
    {'name':'M. Karim Loukil',  'specialty':'Cybersecurity', 'interns':8,'email':'k.loukil@univ-constantine2.dz','dept':'Sec','phone':'0661 00 55 66'},
  ];

  static final List<Map<String, String>> pendingRequests = [
    {'name':'Lina Bouzid','dept':'AI Department',       'email':'lina.bouzid@university.edu'},
    {'name':'Omar Khelil','dept':'Web Dev',             'email':'omar.khelil@university.edu'},
    {'name':'James Smith','dept':'Business Admin',      'email':'james.smith@university.edu'},
    {'name':'Sophia Lee', 'dept':'Software Engineering','email':'sophia.lee@university.edu'},
    {'name':'Ahmed Rayan','dept':'Cybersecurity',       'email':'ahmed.rayan@university.edu'},
  ];
}

// ═════════════════════════════════════════════════════════════════════════════
//  ADMIN DASHBOARD — Home
// ═════════════════════════════════════════════════════════════════════════════
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _searchCtrl = TextEditingController();
  String _q = '';

  List<Map<String, String>> get _fi => _q.isEmpty ? [] :
  AppData.interns.where((i) => i['name']!.toLowerCase().contains(_q) || i['dept']!.toLowerCase().contains(_q) || i['nr']!.contains(_q)).toList();

  List<Map<String, dynamic>> get _fm => _q.isEmpty ? [] :
  AppData.mentors.where((m) => m['name'].toString().toLowerCase().contains(_q) || m['specialty'].toString().toLowerCase().contains(_q)).toList();

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _go(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: _drawer(context),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
          title: const Text('Admin Central', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Search
        TextField(controller: _searchCtrl, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            decoration: proLinkInputDecoration(label: 'Search', hint: 'Interns, mentors, departments…', icon: Icons.search).copyWith(
                suffixIcon: _q.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18),
                    onPressed: () { _searchCtrl.clear(); setState(() => _q = ''); }) : null)),

        if (_q.isNotEmpty) ...[
          const SizedBox(height: 14),
          if (_fi.isEmpty && _fm.isEmpty) _noResults(),
          if (_fi.isNotEmpty) ...[_rHead('Interns', Icons.badge_rounded, AppColors.teal), ..._fi.map(_iTile)],
          if (_fm.isNotEmpty) ...[const SizedBox(height: 8), _rHead('Mentors', Icons.school_rounded, AppColors.greenLight), ..._fm.map(_mTile)],
          const SizedBox(height: 14), const Divider(color: AppColors.divider),
        ],
        const SizedBox(height: 20),

        // Stats
        Row(children: [
          Expanded(child: _chip('Active', '${AppData.interns.where((i)=>i['status']=='Active').length}', AppColors.greenLight, Icons.groups_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _chip('Pending', '${AppData.pendingRequests.length}', AppColors.orange, Icons.pending_actions_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _chip('Mentors', '${AppData.mentors.length}', AppColors.gold, Icons.school_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _chip('Depts', '${AppData.departments.length}', AppColors.teal, Icons.business_rounded)),
        ]),
        const SizedBox(height: 24),

        // Pending validations
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Pending Validations', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          _badge('${AppData.pendingRequests.length}', AppColors.orange),
        ]),
        const SizedBox(height: 6),
        Text('Review and approve new registrations.', style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 13, fontFamily: 'Poppins')),
        const SizedBox(height: 14),
        ...AppData.pendingRequests.take(2).map((r) => _invCard(r['name']!, r['dept']!)),
        Center(child: TextButton(onPressed: () => _go(const AllRequestsPage()),
            child: const Text('View All Requests', style: TextStyle(color: AppColors.greenLight, fontFamily: 'Poppins')))),
        const SizedBox(height: 20),

        // Quick actions
        const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _actBtn('Assign Intern', Icons.person_add_alt_1_rounded, AppColors.green,    () => _go(const ManageInternsPage()))),
          const SizedBox(width: 10),
          Expanded(child: _actBtn('Add Mentor',   Icons.school_rounded,           AppColors.teal,     () => _go(const ManageMentorsPage()))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _actBtn('Schedules',    Icons.calendar_today_rounded,   AppColors.gold,     () => _go(const ScheduleManagementPage()))),
          const SizedBox(width: 10),
          Expanded(child: _actBtn('Departments',  Icons.business_rounded,         AppColors.teal,     () => _go(const ManageDepartmentsPage()))),
        ]),
        const SizedBox(height: 28),

        // Resource center
        const Text('Resource Center', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 14),
        _resTile('Office Schedule',   'Uploaded (v2.1)', Icons.check_circle,  AppColors.greenLight),
        _resTile('Policy Handbook',   'Missing',          Icons.error_outline, AppColors.red),
        _resTile('Intern Guidelines', 'Uploaded (v1.0)', Icons.check_circle,  AppColors.greenLight),
        const SizedBox(height: 20),
      ])),
    );
  }

  Widget _noResults() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Row(children: [const Icon(Icons.search_off, color: AppColors.grey, size: 20), const SizedBox(width: 12),
      Text('No results for "$_q"', style: const TextStyle(color: AppColors.grey, fontFamily: 'Poppins'))]),
  );

  Widget _rHead(String t, IconData ic, Color c) => Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Icon(ic, color: c, size: 16), const SizedBox(width: 6),
        Text(t, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins'))]));

  Widget _iTile(Map<String, String> i) => Container(margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: AppColors.teal.withOpacity(0.2),
            child: Text(i['name']![0], style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(i['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13)),
          Text('NR: ${i['nr']} · ${i['dept']}', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        ])),
        _badge(i['status']!, i['status'] == 'Active' ? AppColors.greenLight : AppColors.orange),
      ]));

  Widget _mTile(Map<String, dynamic> m) => Container(margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: AppColors.greenLight.withOpacity(0.15),
            child: Text(m['name'][0], style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13)),
          Text(m['specialty'], style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
        ])),
        Text('${m['interns']} interns', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontFamily: 'Poppins')),
      ]));

  Widget _badge(String t, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.4))),
      child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins')));

  Widget _chip(String label, String value, Color color, IconData icon) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.25))),
      child: Column(children: [Icon(icon, color: color, size: 16), const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9, fontFamily: 'Poppins'), textAlign: TextAlign.center)]));

  Widget _actBtn(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
          child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13))])));

  Widget _invCard(String name, String dept) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CircleAvatar(backgroundColor: AppColors.surface, child: Text(name[0], style: const TextStyle(color: AppColors.greenLight))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          Text(dept, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
        ])),
        ElevatedButton(onPressed: () => _go(ReviewRequestPage(name: name, department: dept)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            child: const Text('Review', style: TextStyle(fontFamily: 'Poppins', fontSize: 12))),
      ]));

  Widget _resTile(String title, String status, IconData ic, Color statusColor) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
      child: ListTile(contentPadding: EdgeInsets.zero,
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.description, color: Colors.white, size: 24)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          subtitle: Row(children: [Icon(ic, size: 14, color: statusColor), const SizedBox(width: 5), Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontFamily: 'Poppins'))]),
          trailing: const Icon(Icons.file_download_outlined, color: AppColors.grey)));

  Widget _drawer(BuildContext ctx) => Drawer(backgroundColor: AppColors.surface, child: Column(children: [
    const DrawerHeader(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.hub_rounded, color: AppColors.greenLight, size: 50), SizedBox(height: 10),
      Text('ADMIN PORTAL', style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.2, fontFamily: 'Poppins')),
    ]))),
    _dt(ctx, Icons.dashboard,          'Dashboard',       () => Navigator.pop(ctx)),
    _dt(ctx, Icons.business,           'Departments',     () { Navigator.pop(ctx); _go(const ManageDepartmentsPage()); }),
    _dt(ctx, Icons.calendar_today,     'Schedules',       () { Navigator.pop(ctx); _go(const ScheduleManagementPage()); }),
    _dt(ctx, Icons.menu_book_rounded,  'Policy Handbooks',() { Navigator.pop(ctx); _go(const PolicyManagementPage()); }),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColors.border)),
    _dt(ctx, Icons.people,             'Manage Interns',  () { Navigator.pop(ctx); _go(const ManageInternsPage()); }),
    _dt(ctx, Icons.school,             'Manage Mentors',  () { Navigator.pop(ctx); _go(const ManageMentorsPage()); }),
    _dt(ctx, Icons.analytics_outlined, 'Reports',         () { Navigator.pop(ctx); _go(const ReportsScreen()); }),
    _dt(ctx, Icons.settings,           'Settings',        () { Navigator.pop(ctx); _go(const AdminSettingsPage()); }),
    const Spacer(),
    _dt(ctx, Icons.logout, 'Logout', () => Navigator.pushReplacementNamed(ctx, '/login'), color: Colors.redAccent),
    const SizedBox(height: 20),
  ]));

  Widget _dt(BuildContext ctx, IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) =>
      ListTile(leading: Icon(icon, color: color == Colors.white ? AppColors.greenLight : color, size: 22),
          title: Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
          onTap: onTap, dense: true, visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
}

// ═════════════════════════════════════════════════════════════════════════════
//  MANAGE DEPARTMENTS  (Dept → Specialty → Year → Group chip)
// ═════════════════════════════════════════════════════════════════════════════
class ManageDepartmentsPage extends StatefulWidget {
  const ManageDepartmentsPage({super.key});
  @override State<ManageDepartmentsPage> createState() => _ManageDepartmentsPageState();
}

class _ManageDepartmentsPageState extends State<ManageDepartmentsPage> {
  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('University Structure', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent,
        actions: [IconButton(icon: const Icon(Icons.add_business, color: AppColors.greenLight), onPressed: () => _addDept(ctx))]),
    body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: AppData.departments.length,
        itemBuilder: (_, i) => _deptCard(ctx, i)),
  );

  Widget _deptCard(BuildContext ctx, int di) {
    final d = AppData.departments[di];
    return Container(margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
        child: Theme(data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
          leading: Icon(d['icon'] as IconData, color: AppColors.greenLight),
          title: Text(d['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          subtitle: Text('${(d['specialties'] as List).length} Specialties', style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
          iconColor: AppColors.greenLight, collapsedIconColor: AppColors.grey,
          children: [
            const Divider(color: AppColors.border, height: 1),
            ...(d['specialties'] as List).asMap().entries.map((e) => _specTile(ctx, di, e.key, e.value as Map<String, dynamic>)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: OutlinedButton.icon(onPressed: () => _addSpec(ctx, di),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.greenLight),
                    label: const Text('Add Specialty', style: TextStyle(color: AppColors.greenLight, fontFamily: 'Poppins')),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.greenLight)))),
          ],
        )));
  }

  Widget _specTile(BuildContext ctx, int di, int si, Map<String, dynamic> spec) =>
      Theme(data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
        tilePadding: const EdgeInsets.only(left: 32, right: 16),
        leading: const Icon(Icons.folder_special_rounded, color: AppColors.gold, size: 20),
        title: Text(spec['name'], style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        iconColor: AppColors.gold, collapsedIconColor: AppColors.gold,
        children: [
          ...(spec['years'] as List).asMap().entries.map((e) => _yearTile(ctx, di, si, e.key, e.value as Map<String, dynamic>)),
          Padding(padding: const EdgeInsets.only(left: 48, bottom: 10),
              child: TextButton.icon(onPressed: () => _addYear(ctx, di, si),
                  icon: const Icon(Icons.add, size: 14, color: AppColors.teal),
                  label: const Text('Add Year', style: TextStyle(color: AppColors.teal, fontSize: 12, fontFamily: 'Poppins')))),
        ],
      ));

  Widget _yearTile(BuildContext ctx, int di, int si, int yi, Map<String, dynamic> year) {
    final groups = (year['groups'] as List).cast<String>();
    return Padding(padding: const EdgeInsets.only(left: 48, right: 16, bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.calendar_view_week_rounded, color: AppColors.teal, size: 16), const SizedBox(width: 8),
        Text(year['label'], style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13))]),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ...groups.asMap().entries.map((ge) => _groupChip(ctx, di, si, yi, ge.value)),
        GestureDetector(onTap: () => _addGroup(ctx, di, si, yi), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: AppColors.grey, size: 14), SizedBox(width: 4),
              Text('Group', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))]))),
      ]),
      const SizedBox(height: 10), const Divider(color: AppColors.divider, height: 1),
    ]));
  }

  Widget _groupChip(BuildContext ctx, int di, int si, int yi, String group) {
    final specId = (AppData.departments[di]['specialties'] as List)[si]['id'];
    final yearLabel = ((AppData.departments[di]['specialties'] as List)[si]['years'] as List)[yi]['label'];
    final key = '$specId|$yearLabel|$group';
    final has = AppData.schedules.containsKey(key);
    final count = AppData.schedules[key]?.length ?? 0;
    return GestureDetector(
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => GroupScheduleViewPage(
            deptName: AppData.departments[di]['name'],
            specName: (AppData.departments[di]['specialties'] as List)[si]['name'],
            yearLabel: yearLabel, group: group, scheduleKey: key))),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: has ? AppColors.greenLight.withOpacity(0.12) : AppColors.surface,
                borderRadius: BorderRadius.circular(20), border: Border.all(color: has ? AppColors.greenLight.withOpacity(0.5) : AppColors.border)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(has ? Icons.event_available_rounded : Icons.event_busy_rounded, color: has ? AppColors.greenLight : AppColors.grey, size: 14),
                const SizedBox(width: 5), Text(group, style: TextStyle(color: has ? AppColors.greenLight : AppColors.grey, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              ]),
              if (has) Text('$count sessions', style: const TextStyle(color: AppColors.grey, fontSize: 9, fontFamily: 'Poppins')),
            ])));
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────
  void _sheet(BuildContext ctx, String title, List<Widget> body) => showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 20), ...body, const SizedBox(height: 20)])));

  Widget _tf(TextEditingController ctrl, String hint, IconData icon) =>
      TextField(controller: ctrl, style: const TextStyle(color: Colors.white),
          decoration: proLinkInputDecoration(label: hint, hint: hint, icon: icon));

  Widget _btn(String label, VoidCallback fn) => SizedBox(width: double.infinity,
      child: ElevatedButton(onPressed: fn,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))));

  void _addDept(BuildContext ctx) {
    final ctrl = TextEditingController();
    _sheet(ctx, 'New Department', [
      _tf(ctrl, 'Department name', Icons.business), const SizedBox(height: 20),
      _btn('Create', () { if (ctrl.text.isNotEmpty) { setState(() => AppData.departments.add({'id':'d${DateTime.now().millisecondsSinceEpoch}','name':ctrl.text,'icon':Icons.folder_rounded,'specialties':[]})); Navigator.pop(ctx); }}),
    ]);
  }

  void _addSpec(BuildContext ctx, int di) {
    final ctrl = TextEditingController();
    _sheet(ctx, 'New Specialty', [
      _tf(ctrl, 'Specialty name', Icons.workspace_premium), const SizedBox(height: 20),
      _btn('Add Specialty', () { if (ctrl.text.isNotEmpty) { setState(() => (AppData.departments[di]['specialties'] as List).add({'id':'s${DateTime.now().millisecondsSinceEpoch}','name':ctrl.text,'years':[]})); Navigator.pop(ctx); }}),
    ]);
  }

  void _addYear(BuildContext ctx, int di, int si) {
    String? sel;
    const years = ['Licence 1','Licence 2','Licence 3','Master 1','Master 2'];
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => StatefulBuilder(builder: (c, ss) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Add Year Level', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, dropdownColor: AppColors.surface, value: sel,
                      hint: const Text('Select year', style: TextStyle(color: AppColors.greyDark, fontFamily: 'Poppins')),
                      items: years.map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')))).toList(),
                      onChanged: (v) => ss(() => sel = v)))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { if (sel != null) { setState(() => ((AppData.departments[di]['specialties'] as List)[si]['years'] as List).add({'label':sel,'groups':[]})); Navigator.pop(ctx); }},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Add Year', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
              const SizedBox(height: 20),
            ]))));
  }

  void _addGroup(BuildContext ctx, int di, int si, int yi) {
    final ctrl = TextEditingController();
    _sheet(ctx, 'Add Group', [
      _tf(ctrl, 'Group name (e.g. G03)', Icons.groups_rounded), const SizedBox(height: 20),
      _btn('Add Group', () { if (ctrl.text.isNotEmpty) { setState(() => (((AppData.departments[di]['specialties'] as List)[si]['years'] as List)[yi]['groups'] as List).add(ctrl.text)); Navigator.pop(ctx); }}),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  GROUP SCHEDULE VIEW
// ═════════════════════════════════════════════════════════════════════════════
class GroupScheduleViewPage extends StatefulWidget {
  final String deptName, specName, yearLabel, group, scheduleKey;
  const GroupScheduleViewPage({super.key, required this.deptName, required this.specName, required this.yearLabel, required this.group, required this.scheduleKey});
  @override State<GroupScheduleViewPage> createState() => _GroupScheduleViewPageState();
}

class _GroupScheduleViewPageState extends State<GroupScheduleViewPage> {
  static const _days = ['Sunday','Monday','Tuesday','Wednesday','Thursday'];
  static const _dayColors = [AppColors.greenLight, AppColors.teal, AppColors.gold, AppColors.orange, AppColors.greenPastel];

  List<Map<String, String>> get _slots => AppData.schedules[widget.scheduleKey] ?? [];

  @override
  Widget build(BuildContext ctx) {
    final byDay = <String, List<Map<String, String>>>{for (final d in _days) d: _slots.where((s) => s['day'] == d).toList()};
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: Colors.transparent,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.specName} · ${widget.group}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15)),
            Text('${widget.yearLabel} · ${widget.deptName}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.grey)),
          ]),
          actions: [IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.greenLight), onPressed: () => _addSlot(ctx))]),
      body: _slots.isEmpty ? _empty(ctx) : ListView(padding: const EdgeInsets.all(16), children: [
        ..._days.asMap().entries.map((e) {
          final day = e.value; final color = _dayColors[e.key]; final sess = byDay[day]!;
          if (sess.isEmpty) return const SizedBox.shrink();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(bottom: 10, top: 4), child: Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
              Text(day, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins')),
            ])),
            ...sess.map((s) => _sessionCard(s, color)),
            const SizedBox(height: 12),
          ]);
        }),
      ]),
    );
  }

  Widget _sessionCard(Map<String, String> s, Color ac) => Container(margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: ac, width: 4))),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s['subject']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
          const SizedBox(height: 5),
          Row(children: [const Icon(Icons.schedule, color: AppColors.grey, size: 13), const SizedBox(width: 4), Text(s['time']!, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')),
            const SizedBox(width: 12), const Icon(Icons.person_outline, color: AppColors.grey, size: 13), const SizedBox(width: 4),
            Flexible(child: Text(s['teacher']!, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 3),
          Row(children: [const Icon(Icons.room_outlined, color: AppColors.grey, size: 13), const SizedBox(width: 4), Text(s['room']!, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))]),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: ac.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('2h', style: TextStyle(color: ac, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
      ])));

  Widget _empty(BuildContext ctx) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.calendar_today_rounded, color: AppColors.greyDark, size: 60), const SizedBox(height: 16),
    const Text('No schedule yet', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
    const SizedBox(height: 8), Text('Tap + to add sessions', style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontFamily: 'Poppins')),
    const SizedBox(height: 24),
    ElevatedButton.icon(onPressed: () => _addSlot(ctx), icon: const Icon(Icons.add), label: const Text('Add First Session', style: TextStyle(fontFamily: 'Poppins')),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ]));

  Widget _drop(String label, List<String> items, String? val, Function(String?) fn) =>
      Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, dropdownColor: AppColors.surface, value: val,
              hint: Text(label, style: const TextStyle(color: AppColors.greyDark, fontFamily: 'Poppins', fontSize: 12)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 12)))).toList(),
              onChanged: fn)));

  void _addSlot(BuildContext ctx) {
    final subCtrl = TextEditingController(); final teachCtrl = TextEditingController(); final roomCtrl = TextEditingController();
    String? selDay; String? selTime;
    const times = ['08:00–10:00','10:00–12:00','12:00–14:00','14:00–16:00','16:00–18:00'];
    const days = ['Sunday','Monday','Tuesday','Wednesday','Thursday'];
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => StatefulBuilder(builder: (c, ss) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Add Session', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              TextField(controller: subCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Subject', hint: 'e.g. Deep Learning', icon: Icons.book_rounded)),
              const SizedBox(height: 12),
              TextField(controller: teachCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Teacher', hint: 'Dr. Full Name', icon: Icons.person_outline)),
              const SizedBox(height: 12),
              TextField(controller: roomCtrl, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Room', hint: 'e.g. Lab 05', icon: Icons.room_outlined)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _drop('Day', days, selDay, (v) => ss(() => selDay = v))),
                const SizedBox(width: 10),
                Expanded(child: _drop('Time slot', times, selTime, (v) => ss(() => selTime = v))),
              ]),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () { if (subCtrl.text.isNotEmpty && selDay != null && selTime != null) { setState(() { AppData.schedules.putIfAbsent(widget.scheduleKey, () => []); AppData.schedules[widget.scheduleKey]!.add({'subject':subCtrl.text,'teacher':teachCtrl.text,'room':roomCtrl.text,'day':selDay!,'time':selTime!}); }); Navigator.pop(ctx); }},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Save Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
            ])))));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SCHEDULE MANAGEMENT  (overview — pick dept → specialty → year → group)
// ═════════════════════════════════════════════════════════════════════════════
class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});
  @override State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  final _searchCtrl = TextEditingController();
  String _q = '';
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Schedules', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _searchCtrl, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          onChanged: (v) => setState(() => _q = v.toLowerCase()),
          decoration: proLinkInputDecoration(label: 'Search', hint: 'Department, specialty, group…', icon: Icons.search).copyWith(
              suffixIcon: _q.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18),
                  onPressed: () { _searchCtrl.clear(); setState(() => _q = ''); }) : null))),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: AppData.departments.length,
          itemBuilder: (_, di) => _deptSection(ctx, AppData.departments[di]))),
    ]),
  );

  Widget _deptSection(BuildContext ctx, Map<String, dynamic> dept) {
    final specs = (dept['specialties'] as List).cast<Map<String, dynamic>>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10, top: 8), child: Row(children: [
        Icon(dept['icon'] as IconData, color: AppColors.greenLight, size: 18), const SizedBox(width: 8),
        Text(dept['name'], style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins')),
      ])),
      ...specs.map((spec) => _specSection(ctx, dept['name'], spec)),
      const SizedBox(height: 8),
    ]);
  }

  Widget _specSection(BuildContext ctx, String deptName, Map<String, dynamic> spec) {
    final years = (spec['years'] as List).cast<Map<String, dynamic>>();
    return Container(margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Theme(data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
          leading: const Icon(Icons.folder_special_rounded, color: AppColors.gold, size: 20),
          title: Text(spec['name'], style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins')),
          subtitle: Text('${years.length} year levels', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
          iconColor: AppColors.gold, collapsedIconColor: AppColors.grey,
          children: years.map((year) => _yearGroups(ctx, deptName, spec, year)).toList(),
        )));
  }

  Widget _yearGroups(BuildContext ctx, String deptName, Map<String, dynamic> spec, Map<String, dynamic> year) {
    final groups = (year['groups'] as List).cast<String>();
    return Padding(padding: const EdgeInsets.only(left: 20, right: 16, bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.school_outlined, color: AppColors.teal, size: 14), const SizedBox(width: 6),
        Text(year['label'], style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins'))]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: groups.map((g) {
        final key = '${spec['id']}|${year['label']}|$g';
        final has = AppData.schedules.containsKey(key);
        final count = AppData.schedules[key]?.length ?? 0;
        return GestureDetector(
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => GroupScheduleViewPage(
                deptName: deptName, specName: spec['name'], yearLabel: year['label'], group: g, scheduleKey: key))),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: has ? AppColors.greenLight.withOpacity(0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12), border: Border.all(color: has ? AppColors.greenLight.withOpacity(0.4) : AppColors.border)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(has ? Icons.event_available_rounded : Icons.event_busy_rounded, color: has ? AppColors.greenLight : AppColors.grey, size: 14),
                    const SizedBox(width: 5), Text(g, style: TextStyle(color: has ? AppColors.greenLight : AppColors.grey, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  ]),
                  if (has) Text('$count sessions', style: const TextStyle(color: AppColors.grey, fontSize: 9, fontFamily: 'Poppins')),
                ])));
      }).toList()),
    ]));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  MANAGE MENTORS
// ═════════════════════════════════════════════════════════════════════════════
class ManageMentorsPage extends StatefulWidget {
  const ManageMentorsPage({super.key});
  @override State<ManageMentorsPage> createState() => _ManageMentorsPageState();
}

class _ManageMentorsPageState extends State<ManageMentorsPage> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _filtered = [];
  @override void initState() { super.initState(); _filtered = List.from(AppData.mentors); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _filter(String q) { final query = q.trim().toLowerCase(); setState(() => _filtered = query.isEmpty ? List.from(AppData.mentors) : AppData.mentors.where((m) => m['name'].toString().toLowerCase().contains(query) || m['specialty'].toString().toLowerCase().contains(query)).toList()); }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Mentor Management', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent, elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.group_add_rounded, color: AppColors.greenLight), onPressed: () => _addMentorSheet(ctx))]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _s('Total', '${AppData.mentors.length}', AppColors.gold),
            _s('Interns', '${AppData.interns.where((i)=>i['status']=='Active').length}', AppColors.greenLight),
            _s('Depts', '3', AppColors.teal),
          ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(controller: _searchCtrl, onChanged: _filter, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: proLinkInputDecoration(label: 'Search Mentors', hint: 'Name, specialty or email…', icon: Icons.search).copyWith(
                  suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18), onPressed: () { _searchCtrl.clear(); _filter(''); }) : null))),
      _filtered.isEmpty ? Expanded(child: Center(child: const Text('No mentors found.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')))) :
      Expanded(child: ListView.builder(itemCount: _filtered.length, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (_, i) => _mentorCard(ctx, _filtered[i], i))),
    ]),
  );

  Widget _s(String l, String v, Color c) => Column(children: [Text(v, style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))]);

  Widget _mentorCard(BuildContext ctx, Map<String, dynamic> m, int i) => Container(margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: ListTile(contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(radius: 25, backgroundColor: AppColors.surface, child: Text(m['name'][0], style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold))),
          title: Text(m['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['specialty'], style: const TextStyle(color: AppColors.greenLight, fontSize: 12, fontFamily: 'Poppins')),
            Row(children: [const Icon(Icons.people_outline, color: AppColors.grey, size: 14), const SizedBox(width: 4), Text('${m['interns']} interns', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins'))]),
          ]),
          trailing: PopupMenuButton<String>(icon: const Icon(Icons.more_vert, color: AppColors.grey), color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              onSelected: (v) { if (v=='view') _infoDialog(ctx, m); if (v=='delete') _delDialog(ctx, i); },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.badge_outlined, color: AppColors.greenLight, size: 20), SizedBox(width: 10), Text('View Info', style: TextStyle(color: Colors.white, fontFamily: 'Poppins'))])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.redAccent, fontFamily: 'Poppins'))])),
              ])));

  void _infoDialog(BuildContext ctx, Map<String, dynamic> m) => showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircleAvatar(radius: 35, backgroundColor: AppColors.surface, child: Icon(Icons.school, color: AppColors.greenLight, size: 30)),
        const SizedBox(height: 12), Text(m['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const Divider(color: AppColors.border, height: 24),
        _ir(Icons.alternate_email, 'Email', m['email']), _ir(Icons.workspace_premium, 'Specialty', m['specialty']),
        _ir(Icons.business, 'Dept', m['dept']), _ir(Icons.phone, 'Phone', m['phone']),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface), child: const Text('Close', style: TextStyle(color: Colors.white)))),
      ])));

  Widget _ir(IconData ic, String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Icon(ic, color: AppColors.grey, size: 18), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')), Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Poppins'))]))  ]));

  void _delDialog(BuildContext ctx, int i) => showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.surface,
      title: const Text('Remove Mentor?', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      content: const Text('This will unassign all supervised interns.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.grey))),
        TextButton(onPressed: () { final ri = AppData.mentors.indexOf(_filtered[i]); setState(() { AppData.mentors.removeAt(ri); _filtered.removeAt(i); }); Navigator.pop(ctx); },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)))]));

  void _addMentorSheet(BuildContext ctx) => showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Register New Mentor', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), const SizedBox(height: 20),
            TextField(style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Full Name', hint: 'Dr. Name', icon: Icons.person)), const SizedBox(height: 15),
            TextField(keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppColors.greenLight),
                decoration: proLinkInputDecoration(label: 'University Email', hint: 'username@univ-constantine2.dz', icon: Icons.alternate_email)), const SizedBox(height: 15),
            TextField(style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Specialty', hint: 'e.g. AI', icon: Icons.workspace_premium)), const SizedBox(height: 25),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('CREATE MENTOR ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))), const SizedBox(height: 30),
          ]))));
}

// ═════════════════════════════════════════════════════════════════════════════
//  MANAGE INTERNS  (with assignment flow)
// ═════════════════════════════════════════════════════════════════════════════
class ManageInternsPage extends StatefulWidget {
  const ManageInternsPage({super.key});
  @override State<ManageInternsPage> createState() => _ManageInternsPageState();
}

class _ManageInternsPageState extends State<ManageInternsPage> {
  List<Map<String, String>> _filtered = [];
  final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _filtered = List.from(AppData.interns); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _filter(String q) { final query = q.trim().toLowerCase(); setState(() => _filtered = query.isEmpty ? List.from(AppData.interns) : AppData.interns.where((i) => i['name']!.toLowerCase().contains(query) || i['dept']!.toLowerCase().contains(query) || i['nr']!.contains(query)).toList()); }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Intern Management', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent, elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.person_add_alt_1, color: AppColors.greenLight), onPressed: () => _addInternSheet(ctx))]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _ms('Total', '${AppData.interns.length}', Colors.blue),
        _ms('Active', '${AppData.interns.where((i)=>i['status']=='Active').length}', AppColors.green),
        _ms('Pending', '${AppData.interns.where((i)=>i['status']=='Pending').length}', AppColors.orange),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(controller: _searchCtrl, onChanged: _filter, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: proLinkInputDecoration(label: 'Search Interns', hint: 'Name, NR or department…', icon: Icons.search).copyWith(
                  suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18), onPressed: () { _searchCtrl.clear(); _filter(''); }) : null))),
      const SizedBox(height: 4),
      _filtered.isEmpty ? Expanded(child: Center(child: const Text('No interns match.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')))) :
      Expanded(child: ListView.builder(itemCount: _filtered.length, padding: const EdgeInsets.all(16), itemBuilder: (_, i) => _internCard(ctx, _filtered[i], i))),
    ]),
  );

  Widget _ms(String l, String v, Color c) => Column(children: [Text(v, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins'))]);

  Widget _internCard(BuildContext ctx, Map<String, String> data, int index) {
    final active = data['status'] == 'Active';
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.surface, child: Text(data['name']![0], style: const TextStyle(color: AppColors.greenLight))),
            title: Text(data['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            subtitle: Row(children: [Text('NR: ${data['nr']} · ${data['dept']}', style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')), const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: active ? AppColors.greenLight.withOpacity(0.15) : AppColors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(data['status']!, style: TextStyle(color: active ? AppColors.greenLight : AppColors.orange, fontSize: 9, fontWeight: FontWeight.w700, fontFamily: 'Poppins')))]),
            trailing: PopupMenuButton<String>(icon: const Icon(Icons.more_vert, color: AppColors.grey), color: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (v) { if (v=='view') _infoDialog(ctx, data); if (v=='assign') _assignDialog(ctx, data); if (v=='delete') _delDialog(ctx, index); },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'view',   child: Row(children: [Icon(Icons.info_outline,    color: AppColors.greenLight, size: 20), SizedBox(width: 10), Text('View Info',     style: TextStyle(color: Colors.white, fontFamily: 'Poppins'))])),
                  const PopupMenuItem(value: 'assign', child: Row(children: [Icon(Icons.assignment_ind,  color: AppColors.teal,       size: 20), SizedBox(width: 10), Text('Assign Mentor', style: TextStyle(color: Colors.white, fontFamily: 'Poppins'))])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline,  color: Colors.redAccent,     size: 20), SizedBox(width: 10), Text('Delete',        style: TextStyle(color: Colors.redAccent, fontFamily: 'Poppins'))])),
                ])));
  }

  void _infoDialog(BuildContext ctx, Map<String, String> data) => showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 40, backgroundColor: AppColors.greenDeep, child: Text(data['name']![0], style: const TextStyle(fontSize: 30, color: Colors.white))),
        const SizedBox(height: 12),
        Text(data['name']!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        Text('Intern', style: TextStyle(color: AppColors.greenLight.withOpacity(0.8), fontSize: 13, fontFamily: 'Poppins')),
        const Divider(color: AppColors.border, height: 24),
        _ir(Icons.numbers, 'Registration NR', data['nr']!), _ir(Icons.school, 'Department', data['dept']!),
        _ir(Icons.person_outline, 'Mentor', data['mentor']!.isNotEmpty ? data['mentor']! : 'Unassigned'),
        _ir(Icons.alternate_email, 'Email', data['email']!), const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface), child: const Text('Close', style: TextStyle(color: Colors.white)))),
      ])));

  Widget _ir(IconData ic, String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Icon(ic, color: AppColors.grey, size: 18), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')), Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Poppins'))]))  ]));

  void _assignDialog(BuildContext ctx, Map<String, String> data) {
    String? selDept = data['dept']; String? selMentor = data['mentor']?.isNotEmpty == true ? data['mentor'] : null;
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => StatefulBuilder(builder: (c, ss) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [CircleAvatar(backgroundColor: AppColors.greenDeep, child: Text(data['name']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), const Text('Assign Internship', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))])]),
              const SizedBox(height: 20),
              _drop('Department', AppData.departments.map((d) => d['name'] as String).toList(), selDept, (v) => ss(() => selDept = v)),
              const SizedBox(height: 14),
              _drop('Mentor', AppData.mentors.map((m) => m['name'] as String).toList(), selMentor, (v) => ss(() => selMentor = v)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () { setState(() { data['mentor'] = selMentor ?? ''; data['status'] = 'Active'; }); Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${data['name']} assigned to $selMentor'), backgroundColor: AppColors.green)); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('CONFIRM ASSIGNMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
              const SizedBox(height: 10),
            ]))));
  }

  Widget _drop(String label, List<String> items, String? val, Function(String?) fn) => Container(padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, dropdownColor: AppColors.surface, value: val,
          hint: Text('Select $label', style: const TextStyle(color: AppColors.greyDark, fontFamily: 'Poppins')),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')))).toList(),
          onChanged: fn)));

  void _delDialog(BuildContext ctx, int i) => showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: AppColors.surface,
      title: const Text('Remove Intern?', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      content: const Text('All records will be deleted.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.grey))),
        TextButton(onPressed: () { final ri = AppData.interns.indexOf(_filtered[i]); setState(() { AppData.interns.removeAt(ri); _filtered.removeAt(i); }); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.redAccent)))]));

  void _addInternSheet(BuildContext ctx) {
    String? selMentor;
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (_) => StatefulBuilder(builder: (c, ss) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Official Registration', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), const SizedBox(height: 20),
              TextField(style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Full Name', hint: 'Ahmed Benali', icon: Icons.person)), const SizedBox(height: 15),
              TextField(keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppColors.greenLight), decoration: proLinkInputDecoration(label: 'University Email', hint: 'username@univ.dz', icon: Icons.alternate_email)), const SizedBox(height: 15),
              TextField(style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Registration NR', hint: '2020…', icon: Icons.numbers)), const SizedBox(height: 15),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, dropdownColor: AppColors.surface, value: selMentor,
                      hint: const Text('Select Mentor', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')),
                      items: AppData.mentors.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name'], style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')))).toList(),
                      onChanged: (v) => ss(() => selMentor = v)))),
              const SizedBox(height: 25),
              ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('VALIDATE & ASSIGN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
              const SizedBox(height: 30),
            ])))));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  POLICY MANAGEMENT
// ═════════════════════════════════════════════════════════════════════════════
class PolicyManagementPage extends StatefulWidget {
  const PolicyManagementPage({super.key});
  @override State<PolicyManagementPage> createState() => _PolicyManagementPageState();
}

class _PolicyManagementPageState extends State<PolicyManagementPage> {
  List<Map<String, dynamic>> handbooks = [
    {"title":"Internship Rules 2026","isActive":true,"versions":[{"version":"v2.1","date":"10/01/2026"},{"version":"v2.0","date":"01/09/2025"}]},
    {"title":"Mentor Guidelines",   "isActive":false,"versions":[{"version":"v1.0","date":"12/12/2025"}]},
  ];

  @override Widget build(BuildContext ctx) => Scaffold(backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Policy Handbooks', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: handbooks.length, itemBuilder: (_, i) => _card(handbooks[i])),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.green, onPressed: _upload, child: const Icon(Icons.add_to_photos)));

  Widget _card(Map<String, dynamic> doc) => Container(margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: (doc['isActive'] as bool) ? AppColors.greenLight.withOpacity(0.3) : AppColors.border)),
      child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
          leading: Icon(Icons.menu_book, color: (doc['isActive'] as bool) ? AppColors.greenLight : AppColors.grey),
          title: Text(doc['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          trailing: Switch(value: doc['isActive'] as bool, activeColor: AppColors.greenLight, onChanged: (v) => setState(() => doc['isActive'] = v)),
          children: [const Divider(color: AppColors.border, height: 1),
            const Padding(padding: EdgeInsets.all(12), child: Align(alignment: Alignment.centerLeft, child: Text('Version History', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
            ...(doc['versions'] as List).map((v) => ListTile(dense: true, leading: const Icon(Icons.file_present, color: AppColors.grey, size: 18),
                title: Text('Version ${v['version']}', style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
                subtitle: Text('Uploaded: ${v['date']}', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins')),
                trailing: TextButton(onPressed: () {}, child: const Text('View', style: TextStyle(color: AppColors.teal, fontFamily: 'Poppins'))))),
            const SizedBox(height: 10)])));

  void _upload() => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Upload New Handbook', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), const SizedBox(height: 20),
            TextField(style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Document Title', hint: 'e.g. Code of Conduct', icon: Icons.description)), const SizedBox(height: 15),
            TextField(style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Version', hint: 'v1.1', icon: Icons.history)), const SizedBox(height: 20),
            Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
                child: const Column(children: [Icon(Icons.upload_file, color: AppColors.greenLight, size: 30), SizedBox(height: 10), Text('Select PDF', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins'))])),
            const SizedBox(height: 25),
            ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('PUBLISH', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
            const SizedBox(height: 30)])));
}

// ═════════════════════════════════════════════════════════════════════════════
//  REVIEW REQUEST  +  ALL REQUESTS
// ═════════════════════════════════════════════════════════════════════════════
class ReviewRequestPage extends StatefulWidget {
  final String name, department;
  const ReviewRequestPage({super.key, required this.name, required this.department});
  @override State<ReviewRequestPage> createState() => _ReviewRequestPageState();
}

class _ReviewRequestPageState extends State<ReviewRequestPage> {
  final _rc = TextEditingController();
  @override void dispose() { _rc.dispose(); super.dispose(); }

  void _handle(bool approve) {
    if (!approve && _rc.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provide rejection reason'), backgroundColor: Colors.redAccent)); return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? '${widget.name} Approved!' : 'Request Rejected'), backgroundColor: approve ? AppColors.green : Colors.red));
    Navigator.pop(context);
  }

  @override Widget build(BuildContext ctx) => Scaffold(backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Review Request', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150')), const SizedBox(height: 14),
        Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        Text(widget.department, style: const TextStyle(color: AppColors.grey, fontSize: 16, fontFamily: 'Poppins')), const SizedBox(height: 14),
        Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.access_time_filled, color: Colors.orange, size: 18), SizedBox(width: 8), Text('Pending Validation', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))])),
        const SizedBox(height: 28),
        Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Application Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins')), const Divider(color: AppColors.border, height: 28),
              _dr('Full Name', widget.name), _dr('Email', '${widget.name.toLowerCase().replaceAll(' ', '.')}@university.edu'),
              _dr('Department', widget.department), _dr('Registration', 'Oct 24, 2023'),
            ])),
        const SizedBox(height: 24),
        const Align(alignment: Alignment.centerLeft, child: Text(' Admin Notes / Rejection Reason', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
        const SizedBox(height: 10),
        TextField(controller: _rc, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: proLinkInputDecoration(label: 'Reason', hint: 'Type reason if rejecting…', icon: Icons.edit_note)),
        const SizedBox(height: 28),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _handle(false), icon: const Icon(Icons.close), label: const Text('Reject', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(16)))),
          const SizedBox(width: 14),
          Expanded(child: ElevatedButton.icon(onPressed: () => _handle(true), icon: const Icon(Icons.check), label: const Text('Approve', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.all(16)))),
        ]), const SizedBox(height: 20),
      ])));

  Widget _dr(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')), Text(v, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Poppins'))]));
}

class AllRequestsPage extends StatefulWidget {
  const AllRequestsPage({super.key});
  @override State<AllRequestsPage> createState() => _AllRequestsPageState();
}

class _AllRequestsPageState extends State<AllRequestsPage> {
  List<Map<String, String>> _filtered = [];
  final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _filtered = List.from(AppData.pendingRequests); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }
  void _filter(String q) { final query = q.trim().toLowerCase(); setState(() => _filtered = query.isEmpty ? List.from(AppData.pendingRequests) : AppData.pendingRequests.where((r) => r['name']!.toLowerCase().contains(query) || r['dept']!.toLowerCase().contains(query)).toList()); }

  @override Widget build(BuildContext ctx) => Scaffold(backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('All Pending Requests', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), centerTitle: true),
      body: Column(children: [
      Padding(padding: const EdgeInsets.all(20), child: TextField(controller: _searchCtrl, onChanged: _filter, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          decoration: proLinkInputDecoration(label: 'Search', hint: 'Filter by name or department…', icon: Icons.search).copyWith(
              suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey, size: 18), onPressed: () { _searchCtrl.clear(); _filter(''); }) : null))),
  _filtered.isEmpty ? Expanded(child: Center(child: const Text('No requests match.', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')))) :
  Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: _filtered.length, itemBuilder: (_, i) => Container(
  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
  child: Row(children: [CircleAvatar(backgroundColor: AppColors.surface, child: Text(_filtered[i]['name']![0], style: const TextStyle(color: AppColors.greenLight))),
  const SizedBox(width: 14),
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(_filtered[i]['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
  Text(_filtered[i]['dept']!, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))])),
  IconButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ReviewRequestPage(name: _filtered[i]['name']!, department: _filtered[i]['dept']!))),
  icon: const Icon(Icons.arrow_forward_ios, color: AppColors.greenLight, size: 18))]))),
  )]
  )
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  REPORTS
// ═════════════════════════════════════════════════════════════════════════════
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  static const attendance = [
    {"name": "Ahmed Benali", "dept": "AI",    "present": "95%", "status": "Excellent"},
    {"name": "Sara Zeghidi", "dept": "Web",   "present": "82%", "status": "Good"},
    {"name": "Mourad Kasmi", "dept": "Cyber", "present": "60%", "status": "Warning"},
  ];
  static const evaluations = [
    {"intern": "Ahmed Benali", "mentor": "Dr. Rahmani",  "score": "18.5", "comment": "Highly Proactive"},
    {"intern": "Sara Zeghidi", "mentor": "Prof. Zenati", "score": "14.0", "comment": "Good progress"},
  ];

  @override Widget build(BuildContext ctx) => Scaffold(backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('University Reports', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent,
          actions: [TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: AppColors.greenLight), label: const Text('Export', style: TextStyle(color: AppColors.greenLight, fontFamily: 'Poppins'))), const SizedBox(width: 10)]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _h('Attendance Summary'),
        Container(width: double.infinity, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
            child: DataTable(columnSpacing: 15, headingRowColor: WidgetStateProperty.all(AppColors.surface),
                columns: const [DataColumn(label: Text('Intern',  style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins'))), DataColumn(label: Text('Dept',    style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins'))), DataColumn(label: Text('Present', style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins'))), DataColumn(label: Text('Status',  style: TextStyle(color: AppColors.grey, fontFamily: 'Poppins')))],
                rows: attendance.map((d) => DataRow(cells: [DataCell(Text(d['name']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins'))), DataCell(Text(d['dept']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins'))), DataCell(Text(d['present']!, style: const TextStyle(color: AppColors.greenLight, fontSize: 12, fontFamily: 'Poppins'))), DataCell(Text(d['status']!, style: TextStyle(color: d['status'] == 'Warning' ? Colors.redAccent : AppColors.greenLight, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))])).toList())),
        const SizedBox(height: 28), _h('Evaluation Summaries'),
        ...evaluations.map((e) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [CircleAvatar(backgroundColor: AppColors.surface, child: Text(e['score']!, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e['intern']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')), Text('Mentor: ${e['mentor']!}', style: const TextStyle(color: AppColors.grey, fontSize: 11, fontFamily: 'Poppins'))])),
              Text(e['comment']!, style: const TextStyle(color: AppColors.greenLight, fontSize: 11, fontStyle: FontStyle.italic, fontFamily: 'Poppins'))]))),
      ])));

  static Widget _h(String t) => Padding(padding: const EdgeInsets.only(bottom: 12, left: 4, top: 4), child: Text(t, style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')));
}

// ═════════════════════════════════════════════════════════════════════════════
//  SETTINGS
// ═════════════════════════════════════════════════════════════════════════════
class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});
  @override State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  String _language = 'English (US)'; bool _notifs = true; bool _twoFactor = false;
  String _difficulty = 'Standard'; bool _compact = false;
  static const _langs = ['English (US)', 'Français', 'العربية', 'Tamazight'];
  static const _diffs = ['Beginner', 'Standard', 'Advanced'];

  @override Widget build(BuildContext ctx) => Scaffold(backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Admin Settings', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _sec('Appearance'),
        _row(icon: Icons.dark_mode_rounded, iconColor: AppColors.teal, title: 'Dark Mode', subtitle: 'Always enabled', trailing: Switch(value: true, onChanged: null, activeColor: AppColors.teal)),
        _row(icon: Icons.view_compact_rounded, iconColor: AppColors.greenLight, title: 'Compact Mode', subtitle: _compact ? 'Reduced spacing' : 'Standard spacing', trailing: Switch(value: _compact, activeColor: AppColors.greenLight, onChanged: (v) => setState(() => _compact = v))),
        const SizedBox(height: 20), _sec('Language'),
        _row(icon: Icons.language_rounded, iconColor: AppColors.gold, title: 'Display Language', subtitle: _language, trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
            onTap: () => _picker(ctx, 'Choose Language', _langs, _language, (v) => setState(() => _language = v))),
        const SizedBox(height: 20), _sec('Interface Difficulty'),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Complexity Level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14)), const SizedBox(height: 4),
          const Text('Controls how much detail is shown', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins')), const SizedBox(height: 16),
          Row(children: _diffs.map((d) { final sel = d == _difficulty; final c = d=='Beginner'?AppColors.teal:d=='Standard'?AppColors.greenLight:AppColors.gold;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _difficulty = d), child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: sel?c.withOpacity(0.15):AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel?c:AppColors.border, width: sel?1.5:1)),
              child: Column(children: [Icon(d=='Beginner'?Icons.filter_1_rounded:d=='Standard'?Icons.filter_2_rounded:Icons.filter_3_rounded, color: sel?c:AppColors.greyDark, size: 20), const SizedBox(height: 4),
                Text(d, style: TextStyle(color: sel?c:AppColors.greyDark, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Poppins'))]))));
          }).toList()),
        ])),
        const SizedBox(height: 20), _sec('System Control'),
        _row(icon: Icons.notifications_active_rounded, iconColor: AppColors.orange, title: 'Push Notifications', subtitle: _notifs?'Enabled':'Disabled', trailing: Switch(value: _notifs, activeColor: AppColors.orange, onChanged: (v) => setState(() => _notifs = v))),
        _row(icon: Icons.security_rounded, iconColor: AppColors.red, title: 'Two-Factor Auth', subtitle: _twoFactor?'Active — secured':'Not enabled', trailing: Switch(value: _twoFactor, activeColor: AppColors.greenLight, onChanged: (v) => setState(() => _twoFactor = v))),
        _row(icon: Icons.storage_rounded, iconColor: AppColors.grey, title: 'Database Backup', subtitle: 'Last sync: 2h ago', trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
            onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Triggering backup…'), backgroundColor: AppColors.green))),
        const SizedBox(height: 20), _sec('Organization'),
        _row(icon: Icons.domain_rounded, iconColor: AppColors.greenLight, title: 'University Details', subtitle: 'Constantine 2 · IFA', trailing: const Icon(Icons.chevron_right, color: AppColors.grey), onTap: () {}),
        _row(icon: Icons.admin_panel_settings_rounded, iconColor: AppColors.gold, title: 'Role Permissions', subtitle: 'Edit access levels', trailing: const Icon(Icons.chevron_right, color: AppColors.grey), onTap: () {}),
        const SizedBox(height: 28),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.red.withOpacity(0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.red.withOpacity(0.3))),
            child: Row(children: [const Icon(Icons.logout_rounded, color: AppColors.red), const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Sign Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700, fontFamily: 'Poppins')), const Text('Return to login', style: TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))])),
              TextButton(onPressed: () => Navigator.pushReplacementNamed(ctx, '/login'), child: const Text('Logout', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))])),
        const SizedBox(height: 28), Center(child: Text('Pro-Link v1.0.4', style: TextStyle(color: AppColors.grey.withOpacity(0.4), fontSize: 12, fontFamily: 'Poppins'))), const SizedBox(height: 20),
      ]));

  Widget _sec(String t) => Padding(padding: const EdgeInsets.only(bottom: 12, left: 2), child: Text(t.toUpperCase(), style: const TextStyle(color: AppColors.greenLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.4, fontFamily: 'Poppins')));

  Widget _row({required IconData icon, required Color iconColor, required String title, required String subtitle, required Widget trailing, VoidCallback? onTap}) =>
      GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
          child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)), const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins')), Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontFamily: 'Poppins'))])), trailing])));

  void _picker(BuildContext ctx, String title, List<String> items, String selected, ValueChanged<String> onSelect) =>
      showModalBottomSheet(context: ctx, backgroundColor: AppColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
            const Divider(color: AppColors.border, height: 1),
            ...items.map((item) { final sel = item == selected; return ListTile(
                title: Text(item, style: TextStyle(color: sel?AppColors.greenLight:Colors.white, fontFamily: 'Poppins', fontWeight: sel?FontWeight.w700:FontWeight.normal)),
                trailing: sel ? const Icon(Icons.check_rounded, color: AppColors.greenLight) : null,
                onTap: () { onSelect(item); Navigator.pop(ctx); });})
          ])));
}