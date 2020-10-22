import 'package:flutter/material.dart';
import 'package:flutter_summary/util/image_helper.dart';

class DefaultAppBar extends AppBar {
  DefaultAppBar(
      {Key key,
      Widget leading,
      bool automaticallyImplyLeading = true,
      Widget title,
      String titleText,
      List<Widget> actions,
      String actionText,
      VoidCallback actionTextOnTap,
      Widget flexibleSpace,
      PreferredSizeWidget bottom,
      double elevation,
      ShapeBorder shape,
      Color backgroundColor,
      Brightness brightness,
      IconThemeData iconTheme,
      IconThemeData actionsIconTheme,
      TextTheme textTheme,
      bool primary = true,
      bool centerTitle = true,
      double titleSpacing = NavigationToolbar.kMiddleSpacing,
      double toolbarOpacity = 1.0,
      double bottomOpacity = 1.0})
      : super(
          key: key,
          leading: leading ?? (automaticallyImplyLeading == true ? DefaultAppBarLeading() : null),
          automaticallyImplyLeading: automaticallyImplyLeading,
          title: title ?? (titleText != null ? Text(titleText) : null),
          actions: actions ??
              (actionText != null
                  ? [
                      MaterialButton(
                          highlightColor: Colors.white,
                          splashColor: Colors.white,
                          child: Text(
                            actionText,
                            style: TextStyle(fontSize: 16, color: Color(0xff333333)),
                          ),
                          onPressed: actionTextOnTap),
                    ]
                  : null),
          flexibleSpace: flexibleSpace,
          bottom: bottom,
          elevation: elevation,
          shape: shape,
          backgroundColor: backgroundColor,
          brightness: brightness,
          iconTheme: iconTheme,
          actionsIconTheme: actionsIconTheme,
          textTheme: textTheme,
          primary: primary,
          centerTitle: centerTitle,
          titleSpacing: titleSpacing,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
        );
}

class DefaultAppBarLeading extends StatelessWidget {
  final VoidCallback onTap;
  DefaultAppBarLeading({this.onTap});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: ImageIcon(
        AssetImage(
          ImageHelper.image('icon_topBar_back_arrow.png'),
        ),
        size: 20,
      ),
      onPressed: onTap ??
          () {
            Navigator.pop(context);
          },
    );
  }
}
