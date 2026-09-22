import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';

/// Tela de abertura do CareSync (PROJECT_SPEC.md, seção 2 — "Splash").
///
/// Reproduz fielmente `SplashScreen.tsx` do protótipo Figma Make: fundo em
/// gradiente diagonal azul, coração pulsante com um ponto central, nome do
/// app e slogan, com animação de entrada (fade + scale). Confirmado também
/// em `App.tsx` do protótipo: a tela permanece visível por exatos 2
/// segundos e então navega automaticamente para o Onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// `setTimeout(..., 2000)` em `App.tsx` do protótipo original.
  static const _autoNavigateDelay = Duration(seconds: 2);

  // Entrada do conteúdo: `initial={{ scale: 0.5, opacity: 0 }}` ->
  // `animate={{ scale: 1, opacity: 1 }}`, `transition={{ duration: 0.5 }}`.
  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceOpacity;

  // Pulso do coração: `animate={{ scale: [1, 1.1, 1] }}`,
  // `transition={{ duration: 1.5, repeat: Infinity }}` — cada metade do
  // keyframe (1 -> 1.1 e 1.1 -> 1) dura 750ms, totalizando os 1.5s do ciclo.
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _entranceScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Só inicia a contagem dos 2s após o primeiro frame ter sido de fato
    // renderizado, para que a Splash fique visível pelo tempo completo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigationTimer = Timer(_autoNavigateDelay, () {
        if (mounted) context.go(RoutePaths.onboarding);
      });
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColorTokens.lightAccent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorTokens.lightPrimary,
                  AppColorTokens.lightAccent,
                ],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) => Opacity(
                  opacity: _entranceOpacity.value,
                  child: Transform.scale(
                    scale: _entranceScale.value,
                    child: child,
                  ),
                ),
                child: _SplashContent(
                  pulseController: _pulseController,
                  pulseScale: _pulseScale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.pulseController,
    required this.pulseScale,
  });

  final AnimationController pulseController;
  final Animation<double> pulseScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) => Transform.scale(
            scale: pulseScale.value,
            child: child,
          ),
          child: const _SplashHeart(),
        ),
        const SizedBox(height: 16),
        Text(
          'CareSync',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cuidar com organização',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Coração (80x80, `w-20 h-20` no original) com um ponto azul de 8x8
/// exatamente centralizado sobre ele (`absolute inset-0 ... w-2 h-2`).
class _SplashHeart extends StatelessWidget {
  const _SplashHeart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/heart.svg',
            width: 80,
            height: 80,
          ),
          const _SplashHeartDot(),
        ],
      ),
    );
  }
}

class _SplashHeartDot extends StatelessWidget {
  const _SplashHeartDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColorTokens.lightPrimary,
        shape: BoxShape.circle,
      ),
    );
  }
}
