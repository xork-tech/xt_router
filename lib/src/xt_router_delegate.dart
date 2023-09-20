import 'package:flutter/material.dart';

import '../xt_router.dart';

class XtRouterDelegate<T> extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final Map<T, GlobalKey<NavigatorState>> _keys;
  late final Map<T, List<XtPage>> _pageStacks;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final Widget? Function(BuildContext, T) _bottomNavBarBuilder;

  T _selectedRoute;

  XtRouterDelegate({
    required T initRoute,
    required XtPage initPage,
    required Widget? Function(BuildContext, T) bottomNavBarBuilder,
  })  : _keys = {
          initRoute: GlobalKey<NavigatorState>(),
        },
        _pageStacks = {
          initRoute: [initPage],
        },
        _selectedRoute = initRoute,
        _bottomNavBarBuilder = bottomNavBarBuilder;

  List<XtPage> get currentPageStack => _pageStacks[_selectedRoute]!;

  List<XtPage> getPageStack(T route) => _pageStacks[route]!;

  T get selectedRoute => _selectedRoute;

  GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  set selectedRoute(T route) {
    if (_selectedRoute == route && currentPageStack.isNotEmpty) {
      _pageStacks[selectedRoute] = [currentPageStack.first];
    }
    _selectedRoute = route;

    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _keys[selectedRoute]!;

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {}

  @override
  RouteInformation? get currentConfiguration {
    return null;
  }

  void setRoutes(
    Map<T, List<XtPage>> routes, {
    T? selectedRoute,
  }) {
    _pageStacks.clear();
    _keys.clear();
    routes.forEach((key, value) {
      _keys[key] = GlobalKey<NavigatorState>();
      _pageStacks[key] = value;
    });
    if (selectedRoute != null) {
      _selectedRoute = selectedRoute;
    }
    notifyListeners();
  }

  void changeRoute(List<XtPage> pages) {
    currentPageStack.clear();
    currentPageStack.addAll(pages);
    notifyListeners();
  }

  void push(XtPage page) {
    currentPageStack.add(page);
    notifyListeners();
  }

  void replace(XtPage page) {
    currentPageStack.removeLast();
    currentPageStack.add(page);
    notifyListeners();
  }

  void replaceAll(XtPage page) {
    currentPageStack.clear();
    currentPageStack.add(page);
    notifyListeners();
  }

  void didPop(Future<bool> Function(List<XtPage> currentPageStack) didPop) async {
    if (await didPop(currentPageStack)) {
      pop();
      return this.didPop(didPop);
    }
  }

  bool pop() {
    if (currentPageStack.length > 1) {
      currentPageStack.removeLast();
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Future<bool> popRoute() async {
    final overlayContext = navigatorKey.currentState?.overlay?.context;
    if (overlayContext != null) {
      final navigatorState = Navigator.of(overlayContext, rootNavigator: true);

      if (navigatorState.canPop()) {
        navigatorState.pop();
        return true;
      }
    }
    return super.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    final navBar = currentPageStack.last.canBottomNavigationBar ? _bottomNavBarBuilder(context, _selectedRoute) : null;

    return Navigator(
      key: _rootNavigatorKey,
      pages: [
        XtPage(
          child: Scaffold(
            body: Stack(
              children: [
                for (final entry in _pageStacks.entries)
                  Offstage(
                    offstage: entry.key != _selectedRoute,
                    child: HeroControllerScope(
                      controller: MaterialApp.createMaterialHeroController(),
                      child: Navigator(
                        key: _keys[entry.key]!,
                        requestFocus: entry.key == _selectedRoute,
                        pages: [...entry.value],
                        onPopPage: (route, result) {
                          if (entry.value.last.onWillPop != null && !entry.value.last.onWillPop!.call()) {
                            return entry.value.last.onWillPop!.call();
                          }
                          if (!route.didPop(result)) {
                            return false;
                          }
                          if (_pageStacks[_selectedRoute]!.length > 1) {
                            _pageStacks[_selectedRoute]?.removeLast();
                          }
                          notifyListeners();
                          return true;
                        },
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: navBar,
          ),
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _rootNavigatorKey.currentState?.pop();
        return true;
      },
    );
  }
}
