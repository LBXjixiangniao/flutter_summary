import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'not_delay_build_widget.dart';

class GridInfo {
  final String url;
  final String title;
  final String icon;
  final String aboveIcon;
  final String subTitle;
  final int index;

  GridInfo({@required this.index, @required this.icon, @required this.url, @required this.title, @required this.subTitle, @required this.aboveIcon});
}

class DelayBuildWidgetTestPage extends NotDelayBuildWidget {
  @override
  _DelayBuildWidgetTestPageState createState() => _DelayBuildWidgetTestPageState();
}

class _DelayBuildWidgetTestPageState extends NotDelayBuildWidgetState {
  @override
  String get pageTitle => '延时构建小部件测试';
  Widget item(GridInfo info) {
    return DelayBuildChild(
      info: info,
      child: super.item(info),
    );
  }
}

class DelayBuildChild extends StatefulWidget {
  final GridInfo info;
  final Widget child;
  final Widget placeholder;
  const DelayBuildChild({Key key, this.child, this.placeholder, this.info}) : super(key: key);
  @override
  _DelayBuildChildState createState() => _DelayBuildChildState();

  @override
  DelayBuildElement createElement() {
    return DelayBuildElement(this);
  }
}

class DelayBuildElement extends StatefulElement {
  DelayBuildElement(DelayBuildChild widget) : super(widget);

  @override
  void update(covariant DelayBuildChild newWidget) {
    (state as _DelayBuildChildState).info.valid = false;
    super.update(newWidget);
  }
}

class _DelayBuildChildState extends State<DelayBuildChild> {
  bool canBuild = false;
  BuildInfo info;

  @override
  void dispose() {
    super.dispose();
    info.valid = false;
    print('dispose:${widget.info.index}');
  }

  @override
  void deactivate() {
    info.valid = false;
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    print('initState:${widget.info.index}');
    print('list length:${DelayBuildManager._list.length}');
    info = BuildInfo(
      rebuild: () {
        setState(() {
          canBuild = true;
        });
      },
    );
    delayBuildManager.add(info);
  }

  @override
  void didUpdateWidget(covariant DelayBuildChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    info.valid = false;
    canBuild = false;
    info = BuildInfo(
      rebuild: () {
        if (mounted) {
          setState(() {
            canBuild = true;
          });
        }
      },
    );
    delayBuildManager.add(info);
  }

  @override
  Widget build(BuildContext context) {
    print('build:${widget.info.index},canBuild:$canBuild');
    return RepaintBoundary(
      child: !canBuild ? SizedBox(width: 0,height:0,) : widget.child,
      // child: Visibility(
      //   visible: canBuild,
      //   child: widget.child,
      // ),
    );
  }
}

DelayBuildManager delayBuildManager = DelayBuildManager();

class DelayBuildManager {
  static ListQueue<BuildInfo> _list = ListQueue<BuildInfo>();
  bool get haveRebuildAction => true;
  bool isRunning = false;
  void add(BuildInfo info) {
    _list.add(info);
    if (!isRunning) {
      isRunning = true;
      Future.delayed(Duration(milliseconds: 96), () {
        actionNext();
      });
    }
  }

  void actionNext() {
    if (_list.isNotEmpty) {
      isRunning = true;
      BuildInfo info = _list.last;
      if (info != null && info.valid) {
        info.rebuild?.call();
      }
      _list.removeLast();
      Future.delayed(Duration(milliseconds: 96), () {
        actionNext();
      });
    } else {
      isRunning = false;
    }
  }
}

class BuildInfo {
  bool valid;
  final VoidCallback rebuild;

  BuildInfo({this.rebuild, this.valid = true});
}
