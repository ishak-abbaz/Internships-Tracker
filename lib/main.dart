import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'theme.dart';
import 'admin_dashboard.dart';
import 'mentor_dashboard.dart';
import 'intern_dashboard.dart';

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
        '/admin':  (context) =>  AdminDashboard(),
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