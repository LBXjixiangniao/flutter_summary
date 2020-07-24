import 'dart:async';
import 'dart:math';

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
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
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

class CircleDotsLoadingWidget extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const CircleDotsLoadingWidget({Key key, this.color, this.size, this.duration}) : super(key: key);
  @override
  _CircleDotsLoadingWidgetState createState() => _CircleDotsLoadingWidgetState();
}

const double AngleUnit = pi / 4;
const double DotScaleUnit = 8 / 6;
const double BaseDotRadius = 20;

class _CircleDotsLoadingWidgetState extends State<CircleDotsLoadingWidget> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1,
      vsync: this,
      duration: widget.duration ?? Duration(seconds: 1),
    )
      ..repeat()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double turnsValue = _animationController.value;
    final Matrix4 transform = Matrix4.rotationZ(turnsValue * pi * 2.0);
    return Container(
      height: widget.size,
      width: widget.size,
      alignment: Alignment.center,
      child: Transform(
        transform: transform,
        alignment: Alignment.center,
        child: CustomPaint(
          size: widget.size != null ? Size(widget.size, widget.size) : null,
          painter: _CircleDotsPainter(),
        ),
      ),
    );
  }
}

class _CircleDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print(size);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    double radius = min(size.width, size.height) / 2;
    for (int i = 0; i < (2 * pi) ~/ AngleUnit; i++) {
      double angle = i * AngleUnit;
      double x = radius * cos(angle);
      double y = radius * sin(angle);
      int powNumber = (angle - pi).abs() ~/ AngleUnit;
      canvas.drawCircle(
          Offset(x, y), 1 * pow(DotScaleUnit, powNumber) * radius / BaseDotRadius, Paint()..color = Colors.yellow);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
