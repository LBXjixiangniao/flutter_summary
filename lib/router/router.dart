import 'package:flutter/material.dart';
import 'package:flutter_summary/main/demo_list.dart';

typedef PageWrapBuilder = Widget Function(Widget child, BuildContext context);
typedef RouteBuilder = Route<dynamic> Function(WidgetBuilder pageBuilder, RouteSettings setting);

class Router {
  Router._();
  static Router _routes = Router._();
  List<String> _routesName = [];

  static String root = "/";
  static get rootPageBuilder => (_) => DemoList();

  static String _routeNameForPage(Type page) => page.toString();

  ///创建Route，routeName是page.runtimeType.toString()
  static Route<dynamic> routeForPage({
    @required Widget page,
    PageWrapBuilder pageWrapBuilder,
    RouteBuilder customRouteBuilder,
  }) {
    assert(page != null);
    String routeName = _routeNameForPage(page.runtimeType);
    WidgetBuilder builder;
    if (pageWrapBuilder != null) {
      builder = (context) => pageWrapBuilder(page, context);
    } else {
      builder = (_) => page;
    }
    if (customRouteBuilder != null) {
      return customRouteBuilder(builder, RouteSettings(name: routeName));
    } else {
      return MaterialPageRoute(builder: builder, settings: RouteSettings(name: routeName));
    }
  }

  ///当前页面是否在路由顶层
  static bool isPageAtTop(BuildContext context, dynamic page) {
    assert(page is State || page is Widget);
    String currentRouteName = ModalRoute.of(context).settings.name;
    Widget widget = page is Widget ? page : (page as State).widget;
    return _routeNameForPage(widget.runtimeType) == currentRouteName;
  }

  ///页面对应的路由名称
  static String routeNameForPage(dynamic page) {
    assert(page is State || page is Widget);
    Widget widget = page is Widget ? page : (page as State).widget;
    return _routeNameForPage(widget.runtimeType);
  }

  ///记录push的routeName
  static _pushRouteName(String routeName) {
    _routes._routesName.add(routeName ?? routeName.toString());
  }

  ///pop的时候删除最后一个routeName
  static _popRouteName() {
    if (_routes._routesName.isNotEmpty) {
      _routes._routesName.removeLast();
    }
  }

  ///前一个route的name
  static String get previousRouteName {
    if (_routes._routesName.length > 1) {
      return _routes._routesName[_routes._routesName.length - 2];
    }
    return null;
  }

  ///最后一个route的name
  static String get lastRouteName {
    if (_routes._routesName is List) {
      return _routes._routesName.last;
    }
    return null;
  }

  ///最后一个route的name
  ///因为弹框之类的所有route name（为null）都记录在_routesName中，所以建此方法返回_routesName中在该类中定义的route name的最后一个
  static String get lastNotNullRouteName {
    return _routes._routesName?.reversed?.firstWhere((test) => test != null, orElse: () => null);
  }

  static RoutePredicate routeFilter(String routeName) => (route) => route.settings.name == routeName;
}

///用来监听路由push和pop
class CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);

    ///如果没有给route设置name的话，默认name是null
    Router._pushRouteName(route.settings.name);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    Router._popRouteName();
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    super.didRemove(route, previousRoute);
    Router._popRouteName();
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    Router._popRouteName();
    Router._pushRouteName(newRoute.settings.name);
  }
}
