import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_summary/main/counter/bloc/counter_bloc.dart';
import 'package:flutter_summary/router/router.dart';
import 'package:flutter_summary/util/bind_state_callback.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../count_page.dart';

class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  CounterBloc bloc = CounterBloc();
  int _count;

  @override
  void initState() {
    super.initState();
    bloc.listen((currentState) {
      if (currentState is CounterChangeState) {
        _refreshController.requestRefresh();
      }
    });
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void onRefresh() {
    bloc.add(GetCounterValueEvent(
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
        title: Text('bloc demo'),
        actions: <Widget>[
          InkWell(
            child: Center(child: Text('count')),
            onTap: () {
              Navigator.push(context, Router.routeForPage(page: CountPage()));
            },
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          child: BlocBuilder<CounterBloc, CounterState>(
            buildWhen: (preState, currentState) {
              if (currentState is CounterValueState) {
                _count = currentState.count;
                return true;
              }
              return false;
            },
            bloc: bloc,
            builder: (_, currentState) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: Text(currentState is CounterValueState ? currentState.count.toString() : 'hello'),
              );
            },
          ),
        ),
      ),
    );
  }
}
