import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_summary/main/counter/count_page/count_page.dart';
import 'package:flutter_summary/router/router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProviderCounter extends StatelessWidget {
  final RefreshController _refreshController = RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bloc demo'),
        actions: <Widget>[
          InkWell(
            child: Center(child: Text('count')),
            onTap: () {
              // Navigator.push(
              //   context,
              //   Router.routeForPage(
              //     page: CountPage(),
              //     pageWrapBuilder: (child, context) => BlocProvider.value(
              //       value: bloc,
              //       child: child,
              //     ),
              //   ),
              // );
            },
          )
        ],
      ),
      body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {},
          
          child: InheritedProvider(
            // create: (context) => ,
            child: SingleChildScrollView(
              child: Container(
                height: 100,
                alignment: Alignment.center,
                child: Text('hello'),
                // currentState is CounterValueState ? currentState.count.toString() : 
              ),
            ),
          )),
    );
  }
}


