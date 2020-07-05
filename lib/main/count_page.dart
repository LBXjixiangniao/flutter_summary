import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_summary/main/counter/bloc/counter_bloc.dart';
import 'package:flutter_summary/util/bind_state_callback.dart';

class CountPage extends StatefulWidget {
  final int count;
  const CountPage({Key key, this.count}) : super(key: key);

  @override
  _CountPageState createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _count;

  @override
  void initState() {
    _count = widget.count ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改计数'),
        actions: <Widget>[
          InkWell(
            child: Center(child: Text('保存')),
            onTap: () {
              BlocProvider.of<CounterBloc>(context).add(
                CounterSaveEvent(
                  bindCallback: BoolBindStateCallback(state: this, callback: (result) {}),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Text(_count.toString()),
          InkWell(
            child: Text('加'),
            onTap: () {
              setState(() {
                _count++;
              });
            },
          ),
          InkWell(
            child: Text('减'),
            onTap: () {
              setState(() {
                _count--;
              });
            },
          ),
        ],
      ),
    );
  }
}
