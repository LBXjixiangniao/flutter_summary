import 'package:flutter/material.dart' hide Router;
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_summary/lifecycle/lifecycle.dart';
import 'package:flutter_summary/router/router.dart';
import 'package:flutter_summary/styles/pingfang_textstyle.dart';
import 'package:oktoast/oktoast.dart';

import 'main/demo_list.dart';
import 'main/flutter_boost/flutter_boost_first_page.dart';
import 'styles/color_helper.dart';

void main() {
  runApp(MyApp());
}

void registerPageForFlutterBoost() {
  FlutterBoost.singleton.registerPageBuilders(<String, PageBuilder>{
    'FlutterBoostFirstPage': (String pageName, Map<String, dynamic> params, String _) => FlutterBoostFirstPage(),
    '/': (String pageName, Map<String, dynamic> params, String _) => DemoList(),
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    registerPageForFlutterBoost();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorObservers: [CustomNavigatorObserver()],
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: PingFangType.medium,
            textTheme: TextTheme(
              headline5: CustomTextStyle.h1,
              headline6: CustomTextStyle.h2,
              subtitle1: CustomTextStyle.h2,
              subtitle2: CustomTextStyle.body,
              bodyText1: CustomTextStyle.bodyBold,
              bodyText2: CustomTextStyle.body,
              caption: CustomTextStyle.captionLight,
            ),
            appBarTheme: AppBarTheme(
              elevation: 1,
              color: Colors.white,
              brightness: Brightness.light,
              iconTheme: IconThemeData(color: ColorHelper.Black51),
              actionsIconTheme: IconThemeData(color: ColorHelper.Black33),
              textTheme: TextTheme(
                button: CustomTextStyle.h2,
                headline6: CustomTextStyle.h1,
              ),
            ),
            dividerColor: ColorHelper.DividerColor,
            scaffoldBackgroundColor: ColorHelper.BGColor),
        builder: FlutterBoost.init(),
        home: DemoList(),
        // routes: {
        //   RouterManager.root: (ctx) {
        //     LifeCycle.initApp(ctx);
        //     return RouterManager.rootPageBuilder(ctx);
        //   }
        // },
      ),
    );
  }
}
