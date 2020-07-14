import 'package:flutter/material.dart';
import 'package:flutter_summary/main/list_data/model/list_model.dart';
import 'package:flutter_summary/util/list_data_cache_manager.dart/default_list_cache_manager.dart';
import 'package:flutter_summary/util/list_data_cache_manager.dart/list_data_cache_manager.dart';
import 'package:flutter_summary/widgets/default_app_bar.dart';
import 'package:flutter_summary/widgets/smart_refresher_footer_and_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const PageCount = 50;

class ListDataPage extends StatefulWidget {
  @override
  _ListDataPageState createState() => _ListDataPageState();
}

class _ListDataPageState extends State<ListDataPage> {
  DefaultListCacheManager<ListItemInfoModel> _dataCacheManager;
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();

    ///初始化缓存管理控件，设置模型转换方法
    _dataCacheManager = DefaultListCacheManager<ListItemInfoModel>(
      modelFromJson: (json) => ListItemInfoModel.fromJson(json),
      modelToJson: (model) => model.toJson(),
      requestNetworkData: (int startIndex) {
        ///加载网络数据
        getData(startIndex);
      },
    );
  }

  void getData(int startIndex) {
    Future.delayed(Duration(seconds: 3), () {
      if (_refreshController.isRefresh) {
        _refreshController.refreshCompleted();
      }
      if (_refreshController.isLoading) {
        _refreshController.loadComplete();
      }

      ///判断是否下拉刷新
      if (startIndex == 0) {
        _dataCacheManager.clear();

        ///清除nodata，以便可以继续上拉加载更多
        _refreshController.loadComplete();
      }

      ///判断是否无更多数据
      if (startIndex > 90) {
        _refreshController.loadNoData();

        ///禁止_dataCacheManager发起的网络请求
        _dataCacheManager.unableNetworkLoading();
      } else {
        ///请求数据结束后允许_dataCacheManager发起网络请求
        _dataCacheManager.enableNetworkLoading();
      }

      List<ListItemInfoModel> result = [];
      List.generate(PageCount, (index) => result.add(ListItemInfoModel(value: index + startIndex)));
      if (_dataCacheManager.itemCount == startIndex) {
        _dataCacheManager.addAll(result);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        titleText: '列表数据管理',
      ),
      body: SmartRefresher(
          header: defaultRefreshHeader(),
          footer: defaultRefreshFooter(),
          enablePullUp: _dataCacheManager.itemCount > 0,
          controller: _refreshController,
          onRefresh: () {
            getData(0);
          },
          onLoading: () {
            if (!_dataCacheManager.isLoadingNetworkData) {
              _dataCacheManager.unableNetworkLoading();
              getData(_dataCacheManager.itemCount);
            }
          },
          child: ListView.separated(
            itemCount: _dataCacheManager.itemCount,
            itemBuilder: (_, index) {
              ListCacheItem<ListItemInfoModel> item = _dataCacheManager.dataAtIndex(index);
              return ListCacheBuilder<ListItemInfoModel>(
                builder: (cacheItem, _) {
                  ListItemInfoModel info = cacheItem?.data;

                  return Container(
                    height: 40,
                    child: Text('${info?.value}'),
                  );
                },
                cacheItem: item,
              );
            },
            separatorBuilder: (_, __) => Divider(
              height: 1,
            ),
          )),
    );
  }
}
