import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Pro-Link Color System  (derived from Constantine 2 University logo palette)
//  Deep forest green + black + white — corporate, authoritative, modern
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  // Backgrounds
  static const Color bg          = Color(0xFF070D09);  // near-black with green tint
  static const Color surface     = Color(0xFF0C1A10);  // dark surface
  static const Color card        = Color(0xFF102015);  // card background
  static const Color overlay     = Color(0xFF0F2318);  // hover / selected bg

  // Borders & dividers
  static const Color border      = Color(0xFF1C3D27);
  static const Color divider     = Color(0xFF153020);

  // Green scale
  static const Color greenDeep   = Color(0xFF084D25);  // darkest
  static const Color green       = Color(0xFF0D8C45);  // primary
  static const Color greenLight  = Color(0xFF13C260);  // accent
  static const Color greenGlow   = Color(0xFF1AE06A);  // glow highlight
  static const Color greenPastel = Color(0xFF2EB86A);  // pastel variant

  // Text
  static const Color white       = Color(0xFFEBF5EE);  // primary text
  static const Color grey        = Color(0xFF7DAF90);  // secondary text
  static const Color greyDark    = Color(0xFF3B6B4F);  // disabled / placeholder

  // Semantic
  static const Color gold        = Color(0xFFD4A820);  // university gold
  static const Color red         = Color(0xFFE53935);  // reject / error
  static const Color orange      = Color(0xFFF59E0B);  // warning / pending
  static const Color teal        = Color(0xFF00BFA5);  // info / teal accent

  // Role colours
  static const Color admin       = Color(0xFFD4A820);  // gold for admin
  static const Color mentor      = Color(0xFF0D8C45);  // green for mentor
  static const Color intern      = Color(0xFF00BFA5);  // teal for intern
}

// ─────────────────────────────────────────────────────────────────────────────
//  Theme
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Poppins', // Sets the default for the entire app

    colorScheme: ColorScheme.dark(
      // 'background' is deprecated, use 'surface'
      surface: AppColors.bg,
      onSurface: AppColors.white,

      // Use surfaceContainer for cards/dialogs if using M3 logic
      surfaceContainer: AppColors.surface,

      primary: AppColors.green,
      onPrimary: AppColors.bg,
      secondary: AppColors.greenLight,
      tertiary: AppColors.gold,
      error: AppColors.red,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false, // Optional: adjust based on your design
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    ),

    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.surface),

    cardTheme: CardThemeData( // This is the correct configuration object
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    // Cleaned up textTheme (fontFamily is inherited from above)
    textTheme: const TextTheme(
      displayLarge:  TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w700),
      headlineMedium:TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge:    TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium:   TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge:     TextStyle(color: AppColors.white, fontSize: 14),
      bodyMedium:    TextStyle(color: AppColors.grey,  fontSize: 13),
      labelSmall:    TextStyle(color: AppColors.grey,  fontSize: 11, letterSpacing: 0.8),
    ),

    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    iconTheme: const IconThemeData(color: AppColors.grey),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.grey),
      hintStyle: TextStyle(color: AppColors.greyDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
    ),
  );
}
// ─────────────────────────────────────────────────────────────────────────────
//  Shared Input Decoration Helper
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration proLinkInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.green, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.grey, fontFamily: 'Poppins'),
      hintStyle: TextStyle(color: AppColors.greyDark, fontFamily: 'Poppins'),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
    );

// ─────────────────────────────────────────────────────────────────────────────
//  Shared UI Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Professional Alert Dialog
void showProAlert(BuildContext context, {required String title, required String message, bool isError = false}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: glassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.red : AppColors.greenLight,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Dismiss',
                onTap: () => Navigator.pop(context),
                colors: isError 
                  ? [AppColors.red, AppColors.red.withOpacity(0.8)] 
                  : [AppColors.green, AppColors.greenLight],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Glassmorphism card
Widget glassCard({required Widget child, double radius = 20, EdgeInsets? padding}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.88),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    ),
  );
}

/// Section header
Widget sectionHeader(String title, {String? action, VoidCallback? onAction}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
          style: const TextStyle(
              color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action,
              style: const TextStyle(color: AppColors.greenLight, fontSize: 12, fontFamily: 'Poppins')),
        ),
    ],
  );
}

/// Animated counter widget
class AnimatedCounter extends StatelessWidget {
  final int target;
  final TextStyle? style;
  const AnimatedCounter({super.key, required this.target, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (_, value, __) => Text(value.toInt().toString(), style: style),
    );
  }
}

/// Role badge
Widget roleBadge(String role) {
  final Map<String, Color> roleColors = {
    'Admin': AppColors.gold,
    'Mentor': AppColors.green,
    'Intern': AppColors.teal,
  };
  final color = roleColors[role] ?? AppColors.grey;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(role,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
  );
}

/// Gradient button
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final List<Color> colors;
  final bool isLoading;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.colors = const [AppColors.green, AppColors.greenLight],
    this.isLoading = false,
    this.height = 52,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _press, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) { _press.reverse(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.isLoading
                ? [AppColors.greenDeep, AppColors.greenDeep]
                : widget.colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.isLoading ? [] : [
              BoxShadow(color: widget.colors.first.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(mainAxisSize: MainAxisSize.min, children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Pulsing dot indicator
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulsingDot({super.key, required this.color, this.size = 8});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_anim.value),
          boxShadow: [BoxShadow(color: widget.color.withOpacity(_anim.value * 0.6), blurRadius: 6)],
        ),
      ),
    );
  }
}
