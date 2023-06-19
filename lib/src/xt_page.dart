import 'package:flutter/material.dart';

class XtPage<T> extends Page<T> {
  final Widget child;

  //show bottom navigation bar if it available
  final bool canBottomNavigationBar;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.allowSnapshotting}
  final bool allowSnapshotting;

  const XtPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    this.canBottomNavigationBar = true,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedXtPageRoute<T>(page: this);
  }
}

class _PageBasedXtPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _PageBasedXtPageRoute({
    required XtPage page,
    super.allowSnapshotting,
  }) : super(settings: page) {
    assert(opaque);
  }

  XtPage<T> get _page => settings as XtPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
