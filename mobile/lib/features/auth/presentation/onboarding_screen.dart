import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import 'widgets/onboarding_page_indicator.dart';

/// Conteúdo de um slide do Onboarding.
class OnboardingSlide {
  const OnboardingSlide({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  /// Ícone lucide (v0.487.0, mesma versão do protótipo) em `assets/icons`.
  final String iconAsset;
  final String title;
  final String description;
}

/// Os 3 slides de `OnboardingScreen.tsx`, com os textos originais.
const onboardingSlides = [
  OnboardingSlide(
    iconAsset: 'assets/icons/calendar.svg',
    title: 'Organize a rotina com facilidade',
    description:
        'Gerencie consultas, medicamentos e horários de forma simples e intuitiva.',
  ),
  OnboardingSlide(
    iconAsset: 'assets/icons/heart_outline.svg',
    title: 'Monitore consultas, medicamentos e saúde',
    description:
        'Acompanhe indicadores vitais e mantenha o histórico médico sempre atualizado.',
  ),
  OnboardingSlide(
    iconAsset: 'assets/icons/users.svg',
    title: 'Conecte-se à família e garanta bem-estar',
    description:
        'Compartilhe informações importantes e cuide com segurança e carinho.',
  ),
];

/// Onboarding do CareSync (PROJECT_SPEC.md, seção 2 — "Onboarding").
///
/// Reproduz `OnboardingScreen.tsx` do protótipo Figma Make:
/// - o conteúdo do slide troca instantaneamente ao tocar em "Próximo" (o
///   protótipo não tem swipe nem animação de página; só os dots animam);
/// - no último slide o botão vira "Começar" e "Pular" deixa de ser exibido;
/// - "Pular" e "Começar" concluem o Onboarding e levam ao Login (`App.tsx`).
///
/// Correção de inconsistência do protótipo (CLAUDE.md): o azul `#2F80ED`
/// estava hardcoded; aqui usa o token `primary`, idêntico no tema claro e
/// que passa a respeitar o dark mode.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentSlide = 0;

  bool get _isLastSlide => _currentSlide == onboardingSlides.length - 1;

  void _handleNext() {
    if (_isLastSlide) {
      _complete();
    } else {
      setState(() => _currentSlide++);
    }
  }

  void _complete() => context.go(RoutePaths.login);

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slide = onboardingSlides[_currentSlide];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colors.background,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                // `min-h-screen` + `flex-1`: conteúdo centralizado na
                // altura disponível, rolando só se não couber.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  // `px-6 py-12`
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Align(
                    child: ConstrainedBox(
                      // `w-full max-w-md`
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: _OnboardingContent(
                        slide: slide,
                        currentIndex: _currentSlide,
                        isLastSlide: _isLastSlide,
                        onNext: _handleNext,
                        onSkip: _complete,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.slide,
    required this.currentIndex,
    required this.isLastSlide,
    required this.onNext,
    required this.onSkip,
  });

  final OnboardingSlide slide;
  final int currentIndex;
  final bool isLastSlide;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final textTheme = Theme.of(context).textTheme;

    // `text-2xl font-semibold text-foreground` (line-height 2rem / 1.5rem).
    final titleStyle = textTheme.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
      color: colors.foreground,
    );
    // `text-lg text-muted-foreground` (line-height 1.75rem / 1.125rem).
    final descriptionStyle = textTheme.bodyLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
      color: colors.mutedForeground,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // `w-32 h-32 rounded-full bg-[#2F80ED]/10` + ícone `w-16 h-16`.
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            slide.iconAsset,
            key: ValueKey(slide.iconAsset),
            width: 64,
            height: 64,
            colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 32),
        Text(slide.title, style: titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          slide.description,
          style: descriptionStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OnboardingPageIndicator(
          count: onboardingSlides.length,
          currentIndex: currentIndex,
        ),
        const SizedBox(height: 48),
        AppButton(
          label: isLastSlide ? 'Começar' : 'Próximo',
          onPressed: onNext,
        ),
        if (!isLastSlide) ...[
          const SizedBox(height: 12),
          AppButton(
            label: 'Pular',
            onPressed: onSkip,
            variant: AppButtonVariant.ghost,
          ),
        ],
      ],
    );
  }
}
