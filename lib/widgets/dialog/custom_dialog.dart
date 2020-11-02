import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/styles/color_helper.dart';

import '../widget_loading_builder.dart';
import 'dialog_route.dart';

void showDefaultLoading({
  @required BuildContext context,
  String title,
  bool barrierDismissible = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    child: Align(
      alignment: Alignment.center,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleDotsLoadingWidget(
              size: 35,
              color: ColorHelper.ThemeColor,
            ),
            SizedBox(height: 15),
            Text(
              title ?? '正在加载...',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: ColorHelper.Black153,
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showSingleAlert({
  @required BuildContext context,
  dynamic title,
  String buttonTitle,
  @required Widget child,
  VoidCallback callback,
  Color buttonTitleColor,
}) {
  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (BuildContext context) {
  //     return DefaultAlertDialog(
  //       title: (title is Widget || title == null)
  //           ? title
  //           : Text(
  //               title.toString(),
  //             ),
  //       content: child,
  //       actions: <Widget>[
  //         CupertinoDialogAction(
  //           child: Text(
  //             buttonTitle ?? '确定',
  //             style: TextStyle(
  //                 decoration: TextDecoration.none,
  //                 fontFamily: PingFangType.regular,
  //                 color: buttonTitleColor ?? ColorHelper.Black153,
  //                 fontSize: 16),
  //           ),
  //           onPressed: () {
  //             if (callback != null) {
  //               callback();
  //             } else {
  //               Navigator.pop(context);
  //             }
  //           },
  //         ),
  //       ],
  //     );
  //   },
  // );
}

//title可以是widget，如果不是widget，且不是null，则toString()转成字符串用Text显示，
void showConfirmOrCancelAlert(
    {@required BuildContext context,
    dynamic title,
    @required Widget child,
    String confirmButtonTitle,
    String cancelButtonTitle,
    bool autoDimissWhenCancel = true,
    VoidCallback confirmCallback,
    VoidCallback cancelCallback}) {
  Zone.current.scheduleMicrotask(() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return DefaultAlertDialog(
        //   title: (title is Widget || title == null) ? title : Text(title.toString()),
        //   content: Material(
        //     child: child,
        //     color: Colors.transparent,
        //   ),
        //   actions: <Widget>[
        //     CupertinoDialogAction(
        //       child: Text(
        //         cancelButtonTitle ?? '取消',
        //         style: TextStyle(
        //             decoration: TextDecoration.none,
        //             fontFamily: PingFangType.regular,
        //             color: ColorHelper.Black153,
        //             fontSize: 16),
        //       ),
        //       onPressed: () {
        //         autoDimissWhenCancel ? Navigator.pop(context) : null;
        //         if (cancelCallback != null) {
        //           cancelCallback();
        //         }
        //       },
        //     ),
        //     CupertinoDialogAction(
        //       child: Text(
        //         confirmButtonTitle ?? '确定',
        //         style: TextStyle(
        //             decoration: TextDecoration.none,
        //             fontFamily: PingFangType.regular,
        //             color: ColorHelper.ThemeColor,
        //             fontSize: 16),
        //       ),
        //       onPressed: () {
        //         if (confirmCallback != null) {
        //           confirmCallback();
        //         } else {
        //           Navigator.pop(context);
        //         }
        //       },
        //     ),
        //   ],
        // );
      },
    );
  });
}

void showActionSheet(
    {@required BuildContext context,
    bool barrierDismissible = false,
    dynamic title,
    dynamic message,
    dynamic cancelButton = '取消',
    @required List<dynamic> actions,
    void tapAtIndex(int index),
    ScrollController messageScrollController,
    ScrollController actionScrollController}) {
  List<Widget> actionsList;
  // if (Util.notNullAndZero(actions?.length)) {
  //   if (actions.first is Widget) {
  //     actionsList = actions;
  //   } else {
  //     actionsList = [];
  //     for (int i = 0; i < actions.length; i++) {
  //       actionsList.add(CupertinoActionSheetAction(
  //         child: Text(
  //           actions[i].toString(),
  //           softWrap: false,
  //           overflow: TextOverflow.ellipsis,
  //           style: TextStyle(
  //               decoration: TextDecoration.none,
  //               fontFamily: PingFangType.medium,
  //               fontSize: 16,
  //               color: ColorHelper.Black94),
  //         ),
  //         onPressed: () {
  //           if (tapAtIndex != null) {
  //             tapAtIndex(i);
  //           }
  //         },
  //       ));
  //     }
  //   }
  // }
  // showCupertinoModalPopup(
  //   // barrierDismissible: barrierDismissible,
  //   builder: (dialogContext) {
  //     return CupertinoActionSheet(
  //       title: title == null
  //           ? title
  //           : (title is Widget
  //               ? title
  //               : Text(
  //                   title.toString(),
  //                   style: TextStyle(fontFamily: PingFangType.bold, fontSize: 24, color: ColorHelper.Black51),
  //                 )),
  //       message: message == null
  //           ? message
  //           : (message is Widget
  //               ? message
  //               : Text(
  //                   message.toString(),
  //                   style: TextStyle(fontFamily: PingFangType.medium, fontSize: 13, color: ColorHelper.Black51),
  //                 )),
  //       cancelButton: cancelButton == null
  //           ? cancelButton
  //           : (cancelButton is Widget
  //               ? cancelButton
  //               : CupertinoActionSheetAction(
  //                   onPressed: () {
  //                     Navigator.pop(dialogContext);
  //                   },
  //                   child: Text(
  //                     cancelButton.toString(),
  //                     style: TextStyle(
  //                         decoration: TextDecoration.none,
  //                         fontFamily: PingFangType.medium,
  //                         fontSize: 20,
  //                         color: ColorHelper.Black51),
  //                   ),
  //                 )),
  //       actions: actionsList,
  //       messageScrollController: messageScrollController,
  //       actionScrollController: actionScrollController,
  //     );
  //   },
  //   context: context,
  // );
}

void showDialogForContext({
  @required BuildContext context,
  @required Widget Function(RelativeRect position, Size size, BuildContext context) builder,
  Color barrierColor = const Color(0x00FFFFFF),
  bool barrierDismissible = true,
}) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  Navigator.of(context, rootNavigator: true).push(
    DialogRoute(
      settings: RouteSettings(name: 'showDialogForContext'),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      transitionDuration: const Duration(milliseconds: 150),
      barrierDismissible: barrierDismissible,
      pageBuilder: (builderContext, _, __) => builder(position, button.size, builderContext),
    ),
  );
}

void showDateSelect({
  BuildContext ctx,
  void Function(DateTime) dateSelect,
  DateTime initialDate,
  @required DateTime firstDate,
  @required DateTime lastDate,
}) {
  // showDialogForContext(
  //   context: ctx,
  //   builder: (position, size, cont) {
  //     return Column(
  //       children: <Widget>[
  //         SizedBox(
  //           height: position.top + size.height,
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 18.0),
  //           child: Material(
  //             elevation: 2,
  //             borderRadius: BorderRadius.vertical(
  //               bottom: Radius.circular(4),
  //             ),
  //             color: Colors.white,
  //             child: MediaQuery.removePadding(
  //               context: ctx,
  //               child: CustomCalendarDatePickerStyle(
  //                 context: ctx,
  //                 child: CalendarDatePicker(
  //                   initialDate: initialDate ?? DateTime.now(),
  //                   firstDate: firstDate,
  //                   lastDate: lastDate,
  //                   onDateChanged: dateSelect,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         Spacer()
  //       ],
  //     );
  //   },
  // );
}
