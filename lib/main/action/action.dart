import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionPage extends StatefulWidget {
  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Action相关类学习'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(onPressed: () {}, child: Text('Press Me')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FadButton(onPressed: () {}, child: Text('And Me')),
          ),
          ActionListener(
            action: CallbackAction(onInvoke: (Intent intent) {
              print(intent);
            }),
            listener: (Action<Intent> action) {
              print(action);
            },
            child: Text('actionListener'),
          ),
        ],
      ),
    );
  }
}

class FadButton extends StatefulWidget {
  const FadButton({Key key, this.onPressed, this.child}) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;

  @override
  _FadButtonState createState() => _FadButtonState();
}

class _FadButtonState extends State<FadButton> {
  bool _focused = false;
  bool _hovering = false;
  bool _on = false;
  Map<Type, Action<Intent>> _actionMap;
  Map<LogicalKeySet, Intent> _shortcutMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction(
        onInvoke: (Intent intent) => _toggleState(),
      ),
    };
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.keyX): const ActivateIntent(),
    };
  }

  Color get color {
    Color baseColor = Colors.lightBlue;
    if (_focused) {
      baseColor = Color.alphaBlend(Colors.black.withOpacity(0.25), baseColor);
    }
    if (_hovering) {
      baseColor = Color.alphaBlend(Colors.black.withOpacity(0.1), baseColor);
    }
    return baseColor;
  }

  void _toggleState() {
    setState(() {
      _on = !_on;
    });
  }

  void _handleFocusHighlight(bool value) {
    setState(() {
      _focused = value;
    });
  }

  void _handleHoveHighlight(bool value) {
    setState(() {
      _hovering = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleState,
      child: FocusableActionDetector(
        actions: _actionMap,
        shortcuts: _shortcutMap,
        onShowFocusHighlight: _handleFocusHighlight,
        onShowHoverHighlight: _handleHoveHighlight,
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              color: color,
              child: widget.child,
            ),
            Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.all(10.0),
              color: _on ? Colors.red : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
