import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'counter_data_model/counter_model.dart';

class ProviderCounter extends StatelessWidget {
  final RefreshController _refreshController = RefreshController(initialRefresh: true);
  final CounterModel _counterModel = CounterModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bloc demo'),
      ),
      body: ChangeNotifierProvider(
        create: (BuildContext context) => _counterModel,
        child: Consumer<CounterModel>(
          builder: (BuildContext context, CounterModel value, Widget child) {
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () {
                value.requestNetworkData().then((requestResult) {
                  if (requestResult) {
                    _refreshController.refreshCompleted();
                  } else {
                    _refreshController.refreshFailed();
                  }
                });
              },
              child: child,
            );
          },
          child: ListView(
            children: <Widget>[
              Selector<CounterModel, int>(
                shouldRebuild: (previous, next) {
                  return previous != next;
                },
                builder: (BuildContext context, int value, Widget child) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _counterModel.addCountOne();
                          },
                        ),
                        Text('count one'),
                        Text(value == null ? 'hello' : value.toString()),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            _counterModel.deleteCountOne();
                          },
                        ),
                      ],
                    ),
                    // currentState is CounterValueState ? currentState.count.toString() :
                  );
                },
                selector: (_, model) => model?.countOne,
              ),
              Selector<CounterModel, int>(
                shouldRebuild: (previous, next) {
                  return previous != next;
                },
                builder: (BuildContext context, int value, Widget child) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _counterModel.addCountTwo();
                          },
                        ),
                        Text('count two'),
                        Text(value == null ? 'hello' : value.toString()),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            _counterModel.deleteCountTwo();
                          },
                        ),
                      ],
                    ),
                    // currentState is CounterValueState ? currentState.count.toString() :
                  );
                },
                selector: (_, model) => model?.countTwo,
              ),
              Selector<CounterModel, int>(
                shouldRebuild: (previous, next) {
                  return previous != next;
                },
                builder: (BuildContext context, int value, Widget child) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _counterModel.addCountThree();
                          },
                        ),
                        Text('count one'),
                        Text(value == null ? 'hello' : value.toString()),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            _counterModel.deleteCountThree();
                          },
                        ),
                      ],
                    ),
                    // currentState is CounterValueState ? currentState.count.toString() :
                  );
                },
                selector: (_, model) => model?.countThree,
              )
            ],
          ),
        ),
      ),
    );
  }
}
