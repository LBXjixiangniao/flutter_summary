import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetLoadingBuilder extends StatefulWidget {
  final Widget child;
  final WidgetBuilder loadingbuilder;
  final bool loading;
  final Duration timeoutDuration;
  final VoidCallback loadingTimeoutCallback;
  final double width;
  final double height;

  ///用于在loading状态切换成另一个loading
  final String loadingUid;

  const WidgetLoadingBuilder({
    Key key,
    this.loadingbuilder,
    this.loading,
    this.loadingUid,
    @required this.child,
    this.timeoutDuration,
    this.loadingTimeoutCallback,
    this.width,
    this.height,
  })  : assert(child != null),
        super(key: key);
  @override
  _WidgetLoadingBuilderState createState() => _WidgetLoadingBuilderState();
}

class _WidgetLoadingBuilderState extends State<WidgetLoadingBuilder> {
  OverlayEntry _childOverlayEntry;
  OverlayEntry _loadingOverlayEntry;
  GlobalKey<OverlayState> _overLayKey = GlobalKey();
  Timer _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _childOverlayEntry = OverlayEntry(builder: (_) => widget.child);
    Timer.run(() {
      changeLoading();
    });
  }

  void changeLoading() {
    ///显示或者隐藏
    _timeoutTimer?.cancel();

    OverlayEntry tmpLoading;
    if (widget.loading == true) {
      ///添加loading
      tmpLoading = loadingOverlayEntry();
      _overLayKey.currentState.insert(tmpLoading);

      ///设定超时
      if (widget.timeoutDuration != null) {
        _timeoutTimer = Timer(widget.timeoutDuration, () {
          if (_loadingOverlayEntry != null) {
            _loadingOverlayEntry.remove();
            _loadingOverlayEntry = null;
          }
          if (widget.loadingTimeoutCallback != null) {
            widget.loadingTimeoutCallback();
          }
        });
      }
    }

    ///删除旧的loading
    if (_loadingOverlayEntry != null) {
      _loadingOverlayEntry.remove();
    }

    _loadingOverlayEntry = tmpLoading;
  }

  OverlayEntry loadingOverlayEntry() {
    return OverlayEntry(
      builder: (_) => widget.loadingbuilder != null
          ? widget.loadingbuilder(context)
          : Container(
              color: Color(0x11333333),
              child: Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void didUpdateWidget(WidgetLoadingBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.loading == true && (_loadingOverlayEntry == null || widget.loadingUid != oldWidget.loadingUid)) ||
        (widget.loading != true && _loadingOverlayEntry != null) ||
        widget.loadingbuilder != null) {
      changeLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Overlay(
          key: _overLayKey,
          initialEntries: [_childOverlayEntry],
        ),
      );
    } else {
      return IntrinsicHeight(
        child: Overlay(
          key: _overLayKey,
          initialEntries: [_childOverlayEntry],
        ),
      );
    }
  }
}
