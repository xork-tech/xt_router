import 'package:flutter/material.dart';

import '../xt_router.dart';

class XtRouterDelegate<T> extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final Map<T, GlobalKey<NavigatorState>> _keys;
  late final Map<T, List<XtPage>> _pageStacks;
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

  bool pop() {
    if (currentPageStack.length > 1) {
      currentPageStack.removeLast();
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final navBar = currentPageStack.last.canBottomNavigationBar
        ? _bottomNavBarBuilder(context, _selectedRoute)
        : null;
    return Scaffold(
      body: Stack(
        children: [
          for (final entry in _pageStacks.entries)
            Offstage(
              offstage: entry.key != _selectedRoute,
              child: Navigator(
                key: _keys[entry.key]!,
                pages: [...entry.value],
                onPopPage: (route, result) {
                  if (!route.didPop(result)) {
                    return false;
                  }
                  if (_pageStacks[_selectedRoute]!.length > 1) {
                    _pageStacks[_selectedRoute]?.removeLast();
                  } else {
                    return false;
                  }
                  notifyListeners();
                  return true;
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: navBar,
    );
  }
}