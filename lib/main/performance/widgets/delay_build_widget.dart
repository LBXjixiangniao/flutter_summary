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

  GridInfo(
      {@required this.index,
      @required this.icon,
      @required this.url,
      @required this.title,
      @required this.subTitle,
      @required this.aboveIcon});
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
      placeholder: Container(
        color: Colors.red,
        width: 60,
        height: 80,
      ),
      child: super.item(info),
    );
  }
}

/**
 * DelayBuildChild的child会延时build
 * placeholder：child还没build的时候显示
 * buildManager：用于管理延时build，不传递该参数就使用默认的_delayBuildManager管理
 */
class DelayBuildChild extends StatefulWidget {
  final Widget child;
  final Widget placeholder;
  final DelayBuildManager buildManager;
  DelayBuildChild({Key key, this.child, this.placeholder, this.buildManager}) : super(key: key);
  @override
  _DelayBuildChildState createState() => _DelayBuildChildState();
}

class _DelayBuildChildState extends State<DelayBuildChild> {
  bool canBuild = false;
  BuildInfo info;
  DelayBuildManager buildManager;

  @override
  void dispose() {
    super.dispose();
    info.valid = false;
  }

  @override
  void initState() {
    super.initState();
    createInfoAndAddToBuildStack();
  }

  @override
  void didUpdateWidget(covariant DelayBuildChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    info.valid = false;
    canBuild = false;
    createInfoAndAddToBuildStack();
  }

  void createInfoAndAddToBuildStack() {
    info = BuildInfo(
      rebuild: () {
        if (mounted) {
          setState(() {
            canBuild = true;
          });
        }
      },
    );
    buildManager = widget.buildManager ?? _delayBuildManager;
    buildManager._add(info);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: !canBuild ? widget.placeholder : widget.child,
    );
  }
}

DelayBuildManager _delayBuildManager = DelayBuildManager();

class DelayBuildManager {
  final int delayMilliseconds;

  final LinkedList<BuildInfo> _list = LinkedList<BuildInfo>();
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  DelayBuildManager({this.delayMilliseconds = 96});
  void _add(BuildInfo info) {
    _list.add(info);
    if (!_isRunning) {
      _isRunning = true;
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        _actionNext();
      });
    }
  }

  void _actionNext() {
    if (_list.isNotEmpty) {
      _isRunning = true;
      BuildInfo info = _list.last;
      info.unlink();
      if (info != null && info.valid) {
        info.rebuild?.call();
        Future.delayed(Duration(milliseconds: delayMilliseconds), () {
          _actionNext();
        });
      } else {
        _actionNext();
      }
    } else {
      _isRunning = false;
    }
  }
}

class BuildInfo extends LinkedListEntry<BuildInfo> {
  bool valid;
  final VoidCallback rebuild;

  BuildInfo({this.rebuild, this.valid = true});
}
