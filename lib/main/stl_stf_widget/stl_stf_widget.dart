import 'package:flutter/material.dart';

class StlVSStfWidget extends StatefulWidget {
  @override
  _StlVSStfWidgetState createState() => _StlVSStfWidgetState();
}

class _StlVSStfWidgetState extends State<StlVSStfWidget> {
  int titleInt = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('stateless vs stateful widget'),
      ),
      body: Column(
        children: [
          StatelessDemoWidget(
            title: titleInt.toString(),
          ),
          StatefulDemoWidget(
            title: titleInt.toString(),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                titleInt++;
              });
            },
            child: Text('update'),
          )
        ],
      ),
    );
  }
}

class StatelessDemoWidget extends StatelessWidget {
  final String title;

  const StatelessDemoWidget({Key key, this.title}) : super(key: key);

  @override
  StatelessElement createElement() {
    print('stateless widget createElement');
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        onPressed: () {},
        child: Text(title ?? 'Stateless Widget'),
      ),
    );
  }
}

class StatefulDemoWidget extends StatefulWidget {
  final String title;

  const StatefulDemoWidget({Key key, this.title}) : super(key: key);
  
  @override
  _StatefulDemoWidgetState createState() => _StatefulDemoWidgetState();

  @override
  StatefulElement createElement() {
    print('stateful widget createElement');
    return super.createElement();
  }
}

class _StatefulDemoWidgetState extends State<StatefulDemoWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        onPressed: () {},
        child: Text(widget.title ?? 'Stateful Widget'),
      ),
    );
  }
}
