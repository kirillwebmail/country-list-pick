// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Shows a modal material design bottom sheet.
Future<T?> showCustomMaterialModalBottomSheet<T>({
  required BuildContext context,
  double? closeProgressThreshold,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool bounce = false,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Duration? duration,
}) async {
  assert(context != null);
  assert(builder != null);
  assert(expand != null);
  assert(useRootNavigator != null);
  assert(isDismissible != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    closeProgressThreshold: closeProgressThreshold,
    containerBuilder: _materialContainerBuilder(
      context,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      theme: Theme.of(context),
    ),
    secondAnimationController: secondAnimation,
    bounce: bounce,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
  ));
  return result;
}

//Default container builder is the Material Appearance
WidgetWithChildBuilder _materialContainerBuilder(BuildContext context,
    {Color? backgroundColor,
      double? elevation,
      ThemeData? theme,
      Clip? clipBehavior,
      ShapeBorder? shape}) {
  final bottomSheetTheme = Theme.of(context).bottomSheetTheme;
  final color = backgroundColor ??
      bottomSheetTheme.modalBackgroundColor ??
      bottomSheetTheme.backgroundColor;
  final _elevation = elevation ?? bottomSheetTheme.elevation ?? 0.0;
  final _shape = shape ?? bottomSheetTheme.shape;
  final _clipBehavior =
      clipBehavior ?? bottomSheetTheme.clipBehavior ?? Clip.none;

  final result = (context, animation, child) => Material(
      color: color,
      elevation: _elevation,
      shape: _shape,
      clipBehavior: _clipBehavior,
      child: child);
  if (theme != null) {
    return (context, animation, child) =>
        Theme(data: theme, child: result(context, animation, child));
  } else {
    return result;
  }
}

const Duration _bottomSheetDuration = Duration(milliseconds: 400);

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    Key? key,
    this.closeProgressThreshold,
    required this.route,
    this.secondAnimationController,
    this.bounce = false,
    this.expanded = false,
    this.enableDrag = true,
    this.animationCurve,
  })  : assert(expanded != null),
        assert(enableDrag != null),
        super(key: key);

  final double? closeProgressThreshold;
  final ModalBottomSheetRoute<T> route;
  final bool expanded;
  final bool bounce;
  final bool enableDrag;
  final AnimationController? secondAnimationController;
  final Curve? animationCurve;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  String _getRouteLabel() {
    final platform = Theme.of(context).platform; //?? defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        if (Localizations.of(context, MaterialLocalizations) != null) {
          return MaterialLocalizations.of(context).dialogLabel;
        } else {
          return DefaultMaterialLocalizations().dialogLabel;
        }
    }
  }

  ScrollController? _scrollController;

  @override
  void initState() {
    widget.route.animation?.addListener(updateController);
    super.initState();
  }

  @override
  void dispose() {
    widget.route.animation?.removeListener(updateController);
    _scrollController?.dispose();
    super.dispose();
  }

  void updateController() {
    final animation = widget.route.animation;
    if (animation != null) {
      widget.secondAnimationController?.value = animation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(widget.route._animationController != null);
    final scrollController = PrimaryScrollController.of(context) ??
        (_scrollController ??= ScrollController());
    return ModalScrollController(
      controller: scrollController,
      child: Builder(
        builder: (context) => AnimatedBuilder(
          animation: widget.route._animationController!,
          builder: (BuildContext context, final Widget? child) {
            assert(child != null);
            // Disable the initial animation when accessible navigation is on so
            // that the semantics are added to the tree at the correct time.
            return Semantics(
              scopesRoute: true,
              namesRoute: true,
              label: _getRouteLabel(),
              explicitChildNodes: true,
              child: ModalBottomSheet(
                closeProgressThreshold: widget.closeProgressThreshold,
                expanded: widget.route.expanded,
                containerBuilder: widget.route.containerBuilder,
                animationController: widget.route._animationController!,
                shouldClose: widget.route._hasScopedWillPopCallback
                    ? () async {
                  final willPop = await widget.route.willPop();
                  return willPop != RoutePopDisposition.doNotPop;
                }
                    : null,
                onClosing: () {
                  if (widget.route.isCurrent) {
                    Navigator.of(context).pop();
                  }
                },
                child: child!,
                enableDrag: widget.enableDrag,
                bounce: widget.bounce,
                scrollController: scrollController,
                animationCurve: widget.animationCurve,
              ),
            );
          },
          child: widget.route.builder(context),
        ),
      ),
    );
  }
}

class ModalBottomSheetRoute<T> extends PopupRoute<T> {
  ModalBottomSheetRoute({
    this.closeProgressThreshold,
    this.containerBuilder,
    required this.builder,
    this.scrollController,
    this.barrierLabel,
    this.secondAnimationController,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.expanded,
    this.bounce = false,
    this.animationCurve,
    this.duration,
    RouteSettings? settings,
  })  : assert(expanded != null),
        assert(isDismissible != null),
        assert(enableDrag != null),
        super(settings: settings);

  final double? closeProgressThreshold;
  final WidgetWithChildBuilder? containerBuilder;
  final WidgetBuilder builder;
  final bool expanded;
  final bool bounce;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final ScrollController? scrollController;

  final Duration? duration;

  final AnimationController? secondAnimationController;
  final Curve? animationCurve;

  @override
  Duration get transitionDuration => duration ?? _bottomSheetDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black.withOpacity(0.35);

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = ModalBottomSheet.createAnimationController(
      navigator!.overlay!,
      duration: transitionDuration,
    );
    return _animationController!;
  }

  bool get _hasScopedWillPopCallback => hasScopedWillPopCallback;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = SafeArea(
      child: _ModalBottomSheet<T>(
        route: this,
        enableDrag: enableDrag,
        closeProgressThreshold: closeProgressThreshold,
        secondAnimationController: secondAnimationController,
        expanded: expanded,
        bounce: bounce,
        animationCurve: animationCurve,
      ),
    );
    return bottomSheet;

    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    // Widget bottomSheet = MediaQuery.removePadding(
    //   context: context,
    //   // removeTop: true,
    //   child: _ModalBottomSheet<T>(
    //     closeProgressThreshold: closeProgressThreshold,
    //     route: this,
    //     secondAnimationController: secondAnimationController,
    //     expanded: expanded,
    //     bounce: bounce,
    //     enableDrag: enableDrag,
    //     animationCurve: animationCurve,
    //   ),
    // );
    // return bottomSheet;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is ModalBottomSheetRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is ModalBottomSheetRoute || previousRoute is PageRoute;

  Widget getPreviousRouteTransition(
      BuildContext context,
      Animation<double> secondAnimation,
      Widget child,
      ) {
    return child;
  }
}

/// Shows a modal material design bottom sheet.
Future<T?> showCustomModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required WidgetWithChildBuilder containerWidget,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool bounce = false,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Duration? duration,
}) async {
  assert(context != null);
  assert(builder != null);
  assert(containerWidget != null);
  assert(expand != null);
  assert(useRootNavigator != null);
  assert(isDismissible != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
          null;
  final barrierLabel = hasMaterialLocalizations
      ? MaterialLocalizations.of(context).modalBarrierDismissLabel
      : '';

  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    bounce: bounce,
    containerBuilder: containerWidget,
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: barrierLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
  ));
  return result;
}