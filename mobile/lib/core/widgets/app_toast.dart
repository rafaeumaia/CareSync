import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Mostra um toast de sucesso, equivalente ao `toast.success(...)` do
/// protótipo (`<Toaster position="top-center" richColors />`, sonner
/// 2.0.3):
/// - no topo, centralizado: 356px de largura a 24px do topo; em telas de
///   até 600px, ocupa a largura menos 16px de cada lado, a 16px do topo
///   (abaixo da área segura);
/// - fundo, borda de 1px e texto nas cores "success" do sonner, cantos de
///   8px, padding de 16px e sombra `0 4px 12px rgba(0,0,0,.1)`;
/// - ícone de check preenchido (20px) e texto de 13px/500 na fonte do
///   sistema;
/// - entra deslizando de cima (400ms), some após 4s e pode ser arrastado
///   para cima para fechar; vários toasts se empilham (até 3 visíveis), os
///   de trás 14px abaixo e 5% menores a cada nível.
///
/// O protótipo usa sempre o tema claro do sonner; aqui o toast segue o
/// tema do app (no escuro, as cores "success" escuras do próprio sonner).
void showAppSuccessToast(BuildContext context, String message) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final toaster = _toasters[overlay] ??= _ToasterController(overlay);
  toaster.show(message);
}

final _toasters = Expando<_ToasterController>();

/// Constantes do sonner 2.0.3.
abstract final class _Sonner {
  static const lifetime = Duration(milliseconds: 4000);
  static const transition = Duration(milliseconds: 400);
  static const timeBeforeUnmount = Duration(milliseconds: 200);
  static const visibleToasts = 3;
  static const width = 356.0;
  static const gap = 14.0;
  static const offset = 24.0;
  static const mobileOffset = 16.0;
  static const mobileBreakpoint = 600.0;
  static const swipeThreshold = 45.0;

  /// `transition` sem função de tempo explícita usa `ease`.
  static const ease = Cubic(0.25, 0.1, 0.25, 1);

  static const successIcon =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" '
      'fill="currentColor" height="20" width="20"><path fill-rule="evenodd" '
      'd="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214'
      '-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 '
      '001.137-.089l4-5.5z" clip-rule="evenodd"/></svg>';
}

/// Cores `--success-*` do sonner: claro e escuro.
({Color background, Color border, Color text}) _successColors(
  Brightness brightness,
) => brightness == Brightness.dark
    ? (
        background: const Color(0xFF001F0F), // hsl(150, 100%, 6%)
        border: const Color(0xFF003D1C), // hsl(147, 100%, 12%)
        text: const Color(0xFF59F3A6), // hsl(150, 86%, 65%)
      )
    : (
        background: const Color(0xFFECFDF3), // hsl(143, 85%, 96%)
        border: const Color(0xFFBFFCD9), // hsl(145, 92%, 87%)
        text: const Color(0xFF008A2E), // hsl(140, 100%, 27%)
      );

class _ToastData {
  _ToastData(this.id, this.message);

  final int id;
  final String message;
  bool removed = false;
  bool swipedOut = false;
}

class _ToasterController extends ChangeNotifier {
  _ToasterController(this._overlay);

  final OverlayState _overlay;
  OverlayEntry? _entry;
  int _nextId = 0;

  /// Mais recente primeiro.
  final toasts = <_ToastData>[];

  void show(String message) {
    toasts.insert(0, _ToastData(_nextId++, message));
    if (_entry == null) {
      _entry = OverlayEntry(builder: (_) => _ToasterView(controller: this));
      _overlay.insert(_entry!);
    }
    notifyListeners();
  }

  void dismiss(_ToastData toast, {bool swiped = false}) {
    if (toast.removed) return;
    toast
      ..removed = true
      ..swipedOut = swiped;
    notifyListeners();
    Timer(_Sonner.timeBeforeUnmount, () {
      toasts.remove(toast);
      if (toasts.isEmpty) {
        _entry?.remove();
        _entry = null;
      }
      if (_entry != null) notifyListeners();
    });
  }
}

class _ToasterView extends StatefulWidget {
  const _ToasterView({required this.controller});

  final _ToasterController controller;

  @override
  State<_ToasterView> createState() => _ToasterViewState();
}

class _ToasterViewState extends State<_ToasterView> {
  final _heights = <int, double>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width <= _Sonner.mobileBreakpoint;
    final offset = isMobile ? _Sonner.mobileOffset : _Sonner.offset;
    final width = isMobile
        ? media.size.width - 2 * _Sonner.mobileOffset
        : _Sonner.width;

    final active = [
      for (final t in widget.controller.toasts)
        if (!t.removed) t,
    ];
    final frontHeight = active.isEmpty ? null : _heights[active.first.id];

    // Os mais antigos são pintados primeiro (por baixo).
    final ordered = widget.controller.toasts.reversed.toList();
    return Positioned(
      top: media.padding.top + offset,
      left: (media.size.width - width) / 2,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final toast in ordered)
            _Toast(
              key: ValueKey(toast.id),
              toast: toast,
              // `--toasts-before`: posição entre os toasts ainda ativos.
              index: toast.removed ? null : active.indexOf(toast),
              frontHeight: frontHeight,
              onHeight: (h) {
                if (_heights[toast.id] != h) {
                  setState(() => _heights[toast.id] = h);
                }
              },
              onDismiss: (swiped) =>
                  widget.controller.dismiss(toast, swiped: swiped),
            ),
        ],
      ),
    );
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    super.key,
    required this.toast,
    required this.index,
    required this.frontHeight,
    required this.onHeight,
    required this.onDismiss,
  });

  final _ToastData toast;

  /// Nulo quando o toast está saindo.
  final int? index;
  final double? frontHeight;
  final ValueChanged<double> onHeight;
  final ValueChanged<bool> onDismiss;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> {
  bool _mounted = false;
  Timer? _timer;
  double _swipe = 0;
  bool _swiping = false;

  /// Último índice ativo, mantido durante a animação de saída.
  int _lastIndex = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_Sonner.lifetime, () => widget.onDismiss(false));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _mounted = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    // `SWIPE_THRESHOLD` (45px) ou um gesto rápido para cima.
    if (-_swipe >= _Sonner.swipeThreshold || velocity < -110) {
      _timer?.cancel();
      setState(() => _swiping = false);
      widget.onDismiss(true);
    } else {
      setState(() {
        _swiping = false;
        _swipe = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _successColors(Theme.of(context).brightness);
    final index = widget.index;
    if (index != null) _lastIndex = index;
    final removed = widget.toast.removed;
    final front = index == 0 || (removed && _lastIndex == 0);
    final visible = _lastIndex < _Sonner.visibleToasts;

    double y;
    double scale = 1;
    double opacity;
    if (!_mounted) {
      y = -_height; // `translateY(-100%)`.
      opacity = 0;
    } else if (removed) {
      // Toast da frente sobe e some; os de trás descem 40% e somem.
      y = widget.toast.swipedOut || front ? _swipe - _height : _height * 0.4;
      opacity = 0;
    } else {
      y = _Sonner.gap * _lastIndex + _swipe;
      scale = 1 - _lastIndex * 0.05;
      opacity = visible ? 1 : 0;
    }

    final content = Row(
      children: [
        // `[data-icon]`: 16px com margens -3px/4px; o SVG de 20px vaza
        // (margem -1px).
        Transform.translate(
          offset: const Offset(-3, 0),
          child: SizedBox(
            width: 16,
            height: 16,
            child: OverflowBox(
              maxWidth: 20,
              maxHeight: 20,
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(-1, 0),
                child: SvgPicture.string(
                  _Sonner.successIcon,
                  width: 20,
                  height: 20,
                  theme: SvgTheme(currentColor: colors.text),
                ),
              ),
            ),
          ),
        ),
        // margem de 4px (-3px já descontados) + `gap: 6px`.
        const SizedBox(width: 4 - 3 + 6),
        Expanded(
          child: Text(
            widget.toast.message,
            style: TextStyle(
              inherit: false,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: colors.text,
              letterSpacing: 0,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ),
      ],
    );

    final box = Container(
      // Os de trás assumem a altura do da frente.
      height: front ? null : widget.frontHeight,
      padding: const EdgeInsets.all(15), // 16px menos a borda de 1px.
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: _MeasureSize(
        onChange: (size) {
          // Padding de 15px + borda de 1px, dos dois lados.
          _height = size.height + 32;
          widget.onHeight(_height);
        },
        child: AnimatedOpacity(
          // Conteúdo dos toasts de trás fica oculto.
          opacity: front ? 1 : 0,
          duration: _Sonner.transition,
          child: content,
        ),
      ),
    );

    final duration = _swiping
        ? Duration.zero
        : removed && !front
        ? const Duration(milliseconds: 500)
        : _Sonner.transition;

    return Semantics(
      liveRegion: true,
      child: GestureDetector(
        onVerticalDragStart: front && !removed
            ? (_) => setState(() => _swiping = true)
            : null,
        onVerticalDragUpdate: front && !removed
            ? (d) => setState(
                // Só para cima; para baixo, resistência forte.
                () => _swipe = (_swipe + d.delta.dy).clamp(-double.infinity, 4),
              )
            : null,
        onVerticalDragEnd: front && !removed ? _onDragEnd : null,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: opacity),
          duration: removed && !front
              ? const Duration(milliseconds: 200)
              : _Sonner.transition,
          curve: _Sonner.ease,
          builder: (context, o, child) => IgnorePointer(
            ignoring: !visible || removed,
            child: Opacity(opacity: o.clamp(0, 1), child: child),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: y),
            duration: duration,
            curve: _Sonner.ease,
            builder: (context, dy, child) =>
                Transform.translate(offset: Offset(0, dy), child: child),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: scale),
              duration: _Sonner.transition,
              curve: _Sonner.ease,
              builder: (context, s, child) =>
                  Transform.scale(scale: s, child: child),
              child: box,
            ),
          ),
        ),
      ),
    );
  }
}

/// Informa o tamanho do filho após o layout.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _last) return;
    _last = size;
    final current = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(current));
  }
}
