import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetLoadingBuilder extends StatefulWidget {
  final Widget child;
  final WidgetBuilder loadingbuilder;
  final bool loading;
  final Duration timeoutDuration;
  final VoidCallback loadingTimeoutCallback;

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
  })  : assert(child != null),
        super(key: key);
  @override
  _WidgetLoadingBuilderState createState() => _WidgetLoadingBuilderState();
}

class _WidgetLoadingBuilderState extends State<WidgetLoadingBuilder> {
  Timer _timeoutTimer;

  @override
  void initState() {
    super.initState();
    setupTimer();
  }

  void setupTimer() {
    ///设定超时
    if (widget.timeoutDuration != null && widget.loading == true && widget.loadingTimeoutCallback != null) {
      _timeoutTimer = Timer(widget.timeoutDuration, () {
        widget.loadingTimeoutCallback?.call();
      });
    }
  }

  @override
  void didUpdateWidget(WidgetLoadingBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    setupTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timeoutTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        IgnorePointer(
          ignoring: widget.loading == true,
          child: widget.child,
        ),
        if (widget.loading)
          widget.loadingbuilder == null
              ? CircleDotsLoadingWidget(
                  // color: ColorHelper.ThemeColor,
                  color: Colors.yellow,
                  size: 24,
                )
              : widget.loadingbuilder(context),
      ],
    );
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
  _CircleDotsPainter _dotPainter;
  @override
  void initState() {
    super.initState();
    _dotPainter = _CircleDotsPainter(widget.color);
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
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Transform(
        transform: transform,
        alignment: Alignment.center,
        child: CustomPaint(
          key: ValueKey(widget.size),
          size: widget.size != null ? Size(widget.size, widget.size) : null,
          painter: _dotPainter,
        ),
      ),
    );
  }
}

class _CircleDotsPainter extends CustomPainter {
  final Color color;

  ///缓存渲染的视图，以免不停重复渲染
  Picture _picture;

  _CircleDotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _picture ??= renderAsPicture(size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawPicture(_picture);

    canvas.restore();
  }

  Picture renderAsPicture(Size size) {
    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);
    double radius = min(size.width, size.height) / 2;
    for (int i = 0; i < (2 * pi) ~/ AngleUnit; i++) {
      double angle = i * AngleUnit;
      double x = radius * cos(angle);
      double y = radius * sin(angle);
      int powNumber = (angle - pi).abs() ~/ AngleUnit;
      canvas.drawCircle(Offset(x, y), 1 * pow(DotScaleUnit, powNumber) * radius / BaseDotRadius,
          Paint()..color = color ?? Colors.yellow);
    }
    return recorder.endRecording();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
