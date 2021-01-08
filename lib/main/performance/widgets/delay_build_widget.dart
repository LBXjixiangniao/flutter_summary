import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_summary/styles/color_helper.dart';
import 'package:flutter_summary/util/image_helper.dart';

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

class DelayBuildWidgetTestPage extends StatefulWidget {
  @override
  _DelayBuildWidgetTestPageState createState() => _DelayBuildWidgetTestPageState();
}

class _DelayBuildWidgetTestPageState extends State<DelayBuildWidgetTestPage> with SingleTickerProviderStateMixin {
  List<GridInfo> dataList = [];
  ScrollController _firstScrollController = ScrollController();
  ScrollController _secondScrollController = ScrollController();
  TabController _tabController;
  PageController _pageController = PageController();
  List<String> imageUrls = [
    '2774198',
    '6194942',
    '2209382',
    '3614942',
    '1906802',
    '5193557',
    '6161317',
    '5859431',
    '6341566',
    '5484328',
    '4685127',
    '3206433',
    '4852349',
    '1376889',
    '5560899',
    '4987688',
    '5949511',
    '6126297',
    '3467152',
    '5707732',
    '5591661',
    '5727545',
    '4617820',
    '4333606',
    '5273001',
    '3673521',
    '5232105',
    '5722868',
    '5567002',
    '1669072',
    '6334707',
    '5716323',
    '6212297',
    '3220237',
    '5855535',
    '5272575',
    '6021588',
    '4000213',
    '5993563',
    '3402578',
    '6066993',
    '5390006',
    '3410287',
    '6070378',
    '6167767',
    '5968900',
    '1030934',
    '1683994',
    '6102555',
    '4468058',
    '5914166',
    '6291566',
    '4621378',
    '5965972',
    '5913391',
    '5312333',
    '5101217',
    '5855527',
    '6061293',
    '5770047',
    '4558306',
    '2109762',
    '5913949',
    '6070129',
    '2886574',
    '6032603',
    '5615782',
    '5997712',
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    String content = '拉开就分开了拉萨附近都是六块腹肌饭撒的克己复礼看到撒酒疯黎噶搜ID股份分开那份礼物来自空间的佛i阿哥辣椒素的弗兰克为列宁格勒';
    Random random = Random();
    int i = 0;
    imageUrls.forEach((element) {
      int titleStart = random.nextInt(content.length - 5);
      int subTitleStart = random.nextInt(content.length - 5);
      dataList.add(
        GridInfo(
          index: i,
          aboveIcon: random.nextInt(3).toString(),
          icon: random.nextInt(9).toString(),
          subTitle: content.substring(titleStart, titleStart + random.nextInt(4) + 1),
          title: content.substring(subTitleStart, subTitleStart + random.nextInt(4) + 1),
          url:
              'https://images.pexels.com/photos/$element/pexels-photo-$element.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
        ),
      );
      i++;
    });
  }

  Widget pageBuild({ScrollController controller, Widget childBuilder(GridInfo info)}) {
    return GridView.builder(
      controller: controller,
      itemCount: dataList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, index) {
        GridInfo info = dataList[index];
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(builder: (_, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: childBuilder(info),
                  );
                }),
              ),
              Row(
                children: [
                  Text(
                    info.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Image.asset(
                    ImageHelper.image('icon_${info.icon}.png'),
                    width: 30,
                  ),
                  Spacer(),
                  Text(
                    info.subTitle,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget item(GridInfo info) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: BoxConstraints.expand().maxWidth,
        child: Stack(
          children: [
            // Image.network(
            //   info.url,
            //   fit: BoxFit.contain,
            // ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: ColorHelper.DividerColor, spreadRadius: 1, blurRadius: 4)],
                      ),
                      child: Text(
                        info.title + info.subTitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorHelper.Black153,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.yellow,
                      child: Text(
                        info.index.toString(),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  ImageHelper.image(
                    'icon_a_${info.aboveIcon}.png',
                  ),
                  width: 40,
                ),
                Row(
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    Text(
                      info.subTitle,
                      style: TextStyle(fontSize: 14, color: Colors.black12),
                    ),
                  ],
                ),
                Text(
                  info.subTitle + info.title,
                  style: TextStyle(fontSize: 18, color: Colors.yellow[100]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('延时构建小部件测试'),
        actions: [
          FlatButton(
            onPressed: () {
              ScrollController scrollController =
                  _tabController.index == 0 ? _firstScrollController : _secondScrollController;
              if (scrollController.offset > 100) {
                scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.linear);
              } else {
                scrollController.animateTo(7000, duration: Duration(milliseconds: 500), curve: Curves.linear);
              }
            },
            child: Text('刷新'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
              height: 44,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.red,
                onTap: (index) {
                  _pageController.animateToPage(index, duration: Duration(milliseconds: 100), curve: Curves.linear);
                },
                tabs: [Text('延时构建'), Text('不延时')],
              )),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                pageBuild(
                  controller: _firstScrollController,
                  childBuilder: (info) {
                    return DelayBuildChild(
                      info: info,
                      child: item(info),
                    );
                  },
                ),
                pageBuild(
                  controller: _secondScrollController,
                  childBuilder: (info) {
                    return item(info);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
        setState(() {
          canBuild = true;
        });
      },
    );
    delayBuildManager.add(info);
  }

  @override
  Widget build(BuildContext context) {
    print('build:${widget.info.index},canBuild:$canBuild');
    return RepaintBoundary(
      child: !canBuild ? SizedBox() : widget.child,
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
      actionNext();
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
      Future.delayed(Duration(milliseconds: 64), () {
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
