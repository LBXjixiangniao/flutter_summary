import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_summary/main/counter/bloc/counter_bloc.dart';
import 'package:flutter_summary/util/bind_state_callback.dart';
import 'package:flutter_summary/util/global_method.dart';
import 'package:flutter_summary/widgets/toast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CountPage extends StatefulWidget {
  final int count;
  const CountPage({Key key, this.count}) : super(key: key);

  @override
  _CountPageState createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  int _count;

  @override
  void initState() {
    super.initState();
    // bloc.listen((currentState) {
    //   if (currentState is CounterChangeState) {
    //     _refreshController.requestRefresh();
    //   }
    // });
  }

  void onRefresh() {
    BlocProvider.of<CounterBloc>(context).add(GetCounterValueEvent(
      BoolBindStateCallback(
        state: this,
        callback: (result) {
          if (result) {
            _refreshController.refreshCompleted();
          } else {
            _refreshController.refreshFailed();
          }
        },
      ),
    ));
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
                  value: _count,
                  bindCallback: BoolBindStateCallback(
                      state: this,
                      callback: (result) {
                        if (result) {
                          CustomToast.showShort('保存成功');
                          BlocProvider.of<CounterBloc>(context).addState(CounterChangeState());
                          Navigator.pop(context);
                        }
                      }),
                ),
              );
            },
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: onRefresh,
        child: BlocBuilder<CounterBloc, CounterState>(
          buildWhen: (pre, currentState) {
            if (currentState is CounterValueState) {
              _count = currentState.count;
              return true;
            }
            return false;
          },
          builder: (_, currentState) {
            return ListView(
              children: <Widget>[
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(_count != null ? _count.toString() : 'hello'),
                ),
                if (_count != null) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _count++;
                      });
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text('加'),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _count++;
                      });
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text('减'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
